%% Step 0
thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
parent1 = fileparts((thisDir));
addpath(genpath(parent1));  
mode = 'debug'; %debug or unknown


letter_index = 'a'; %a-g for debug and h-k for unknown   

calbody_name = sprintf('pa2-%s-%c-calbody.txt', mode, letter_index);
calreadings_name = sprintf('pa2-%s-%c-calreadings.txt', mode, letter_index);
empivot_name = sprintf('pa2-%s-%c-empivot.txt', mode, letter_index);
ctfiducials_name = sprintf('pa2-%s-%c-ct-fiducials.txt', mode, letter_index);
emnav_name = sprintf('pa2-%s-%c-em-nav.txt', mode, letter_index);
output_name = sprintf('pa2-%s-%c-output2.txt', mode, letter_index);

%% Step 1
[C_expected,Ccells] = compute_C(calbody_name, calreadings_name);

distortion_vectors = cell(1,numel(Ccells));

for i = 1:numel(Ccells)
    % Calculate all distortion vectors for cell 'i' in one operation
    % Assuming Ccells{i} is M x N and C_expected{i} is M x 3
    % The result is an M x N matrix, where N is the width of the final vector
    distortion_vectors{i} = Ccells{i}(:, 1:3) - C_expected{i}(:, 1:3); 
end

N_frames = numel(Ccells);
N_C = size(Ccells{1},1);

% Pre-allocate
all_positions = zeros(N_frames * N_C, 3);  % 216 x 3
all_distortions = zeros(N_frames * N_C, 3); % 216 x 3

% Fill the matrices
idx = 1;
for frame = 1:N_frames
    for marker = 1:N_C
        % Position where distortion was measured
        all_positions(idx, :) = Ccells{frame}(marker, :);
        
        % Corresponding distortion vector
        all_distortions(idx, :) = distortion_vectors{frame}(marker, :);
        
        idx = idx + 1;
    end
end

%% Step 2
min_coords = min(all_positions, [], 1);  % [min_x, min_y, min_z]
max_coords = max(all_positions, [], 1);  % [max_x, max_y, max_z]


bbox.min = min_coords;
bbox.max = max_coords;

normalized_pos = (all_positions - min_coords) ./ (max_coords - min_coords);

degree = 5;
A = create_bernstein_matrix(normalized_pos, degree);

% Solve least-squares for each component
coeffs_x = A \ all_distortions(:, 1);
coeffs_y = A \ all_distortions(:, 2);
coeffs_z = A \ all_distortions(:, 3);

% Store all coefficients
distortion_coeffs.x = coeffs_x;
distortion_coeffs.y = coeffs_y;
distortion_coeffs.z = coeffs_z;
distortion_coeffs.degree = degree;
distortion_coeffs.bbox = bbox;

test_raw = Ccells{1}(1, 1:3);
test_corrected = correctDistortion(test_raw, distortion_coeffs);
test_expected = C_expected{1}(1, 1:3);

error = norm(test_corrected - test_expected);
fprintf('Correction error: %.6f mm\n', error);

%% Step 3
[G] = read_pivot_data(empivot_name);

G_corrected = cell(1,numel(G));
N_frames_pivot = numel(G);
N_G = size(G{1},1);
for frame = 1:N_frames_pivot
    G_corrected{frame} = [];
    for marker = 1:N_G
        raw_point = G{frame}(marker,:);  % Make it 1x3
        G_corrected{frame}(marker,:) = correctDistortion(raw_point, distortion_coeffs);
    end
end

g_markers = G_corrected{1} - mean(G_corrected{1}, 1);


p_post_corrected = pivot_calibration(G_corrected);



%% Step 4
p_tip_probe = compute_probe_tip(G_corrected, g_markers, p_post_corrected');

fprintf('Probe tip in probe coords: [%.4f, %.4f, %.4f]\n', p_tip_probe);

%% Step 5
Gcells_fiducials_raw = read_emfiducials('pa2-debug-a-em-fiducialss.txt');

N_B = length(Gcells_fiducials_raw);
b_EM = zeros(N_B, 3);

for fid_idx = 1:N_B
    % Correct distortion
    G_fid_raw = Gcells_fiducials_raw{fid_idx};
    Ng = size(G_fid_raw, 1);
    G_fid_corrected = zeros(Ng, 3);
    
    for marker = 1:Ng
        G_fid_corrected(marker, :) = correctDistortion(G_fid_raw(marker, :), distortion_coeffs);
    end
    
    % Register to get probe pose when touching this fiducial
    [R_G, t_G] = find_transformation(g_markers, G_fid_corrected);
    
    % Transform probe tip to EM coordinates
    b_EM(fid_idx, :) = (R_G * p_tip_probe' + t_G)';
end

fprintf('\nFiducial positions in EM coordinates:\n');
disp(b_EM);

%% Step 6

b_CT = read_ct_fiducials(ctfiducials_name);

% Compute registration: b_EM -> b_CT
[R_reg, t_reg] = find_transformation(b_EM, b_CT);

fprintf('\nRegistration computed (EM -> CT)\n');
fprintf('R_reg:\n');
disp(R_reg);
fprintf('t_reg: [%.4f, %.4f, %.4f]\n', t_reg);

%% Step 7

% Read navigation data
Gcells_nav_raw = read_emnav('pa2-debug-a-em-nav.txt');

Nframes_nav = length(Gcells_nav_raw);
v_CT = zeros(Nframes_nav, 3);  % Output: probe tip positions in CT coords

for frame = 1:Nframes_nav
    % Get raw marker data for this frame
    G_nav_raw = Gcells_nav_raw{frame};
    Ng = size(G_nav_raw, 1);
    
    % Step 1: Correct distortion
    G_nav_corrected = zeros(Ng, 3);
    for marker = 1:Ng
        G_nav_corrected(marker, :) = correctDistortion(G_nav_raw(marker, :), distortion_coeffs);
    end
    
    % Step 2: Register to get probe pose in EM coordinates
    [R_G, t_G] = find_transformation(g_markers, G_nav_corrected);
    
    % Step 3: Transform probe tip to EM coordinates
    tip_EM = (R_G * p_tip_probe' + t_G)';
    
    % Step 4: Transform from EM to CT coordinates
    v_CT(frame, :) = (R_reg * tip_EM' + t_reg)';
end

fprintf('\nProbe tip positions in CT coordinates:\n');
disp(v_CT);

%% Step 8
current_file_path = fileparts(mfilename('fullpath'));

output_dir = fullfile(current_file_path, '..', 'output');

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('Created directory: %s\n', output_dir);
else
    fprintf('Directory already exists: %s\n', output_dir);
end
write_output2(output_name, v_CT);