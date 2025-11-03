% assignment_2.m
% authors: Luiza and Pranhav
    % this is the main function for PA2
    % inputs:
    %   mode (string): 'debug' or 'unknown'
    %   letter_index (char): 'a' through 'k'
    %   degree (integer): The degree 'n' of the Bernstein polynomial for distortion correction
    %
    % output:
    %   file named 'pa2-[mode]-[letter]-output2.txt' in the '../output/' directory containing the calculated probe tip positions in CT coordinates
 function assignment_2(mode, letter_index, degree)
    % Step 0: setup
    fprintf('Running PA2 for dataset: %s-%c with polynomial degree %d\n', mode, letter_index, degree);
    % get path to director containing this script
    thisDir = fileparts(mfilename('fullpath'));
        % Two levels up
    parent1 = fileparts((thisDir));
    addpath(genpath(parent1));  %add everything to MATLAB path  
    
    % get all files based on mode and letter_index
    calbody_name = sprintf('pa2-%s-%c-calbody.txt', mode, letter_index);
    calreadings_name = sprintf('pa2-%s-%c-calreadings.txt', mode, letter_index);
    empivot_name = sprintf('pa2-%s-%c-empivot.txt', mode, letter_index);
    emfiducials_name = sprintf('pa2-%s-%c-em-fiducialss.txt', mode, letter_index); 
    ctfiducials_name = sprintf('pa2-%s-%c-ct-fiducials.txt', mode, letter_index);
    emnav_name = sprintf('pa2-%s-%c-em-nav.txt', mode, letter_index);
    output_name = sprintf('pa2-%s-%c-output2.txt', mode, letter_index);
    
    % Step 1: distortion vectors
    %use helper function compute_C that reads calbody/calreadings and
    %calculates C_expected and Ccells (raw EM reading)
    [C_expected,Ccells] = compute_C(calbody_name, calreadings_name);
    
    %calculate distortion vector expected-raw for eahc marker in each frame
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
    
    % Step 2: compute distortion correction coefficients
    % bbox = bounding box of the raw EM measurements
    % define volume over which the correction function is valid
    min_coords = min(all_positions, [], 1);  % [min_x, min_y, min_z]
    max_coords = max(all_positions, [], 1);  % [max_x, max_y, max_z]
    bbox.min = min_coords;
    bbox.max = max_coords;
    % normalize raw positions
    normalized_pos = (all_positions - min_coords) ./ (max_coords - min_coords);
    %create bernstein matrix A using helper function
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
    
    %test the correction on the first point
    test_raw = Ccells{1}(1, 1:3);
    test_corrected = correctDistortion(test_raw, distortion_coeffs);
    test_expected = C_expected{1}(1, 1:3); 
    
    error = norm(test_corrected - test_expected);
    fprintf('Correction error: %.6f mm\n', error);
    
    % Step 3: correct EM pivot data
    [G] = read_pivot_data(empivot_name); %array of raw pivot frames
    
    G_corrected = cell(1,numel(G)); %cell array for corrected frames
    N_frames_pivot = numel(G); 
    N_G = size(G{1},1);%number of probe markers
    for frame = 1:N_frames_pivot
        G_corrected{frame} = [];
        for marker = 1:N_G
            raw_point = G{frame}(marker,:);  % Make it 1x3
            % apply correction from step 2
            G_corrected{frame}(marker,:) = correctDistortion(raw_point, distortion_coeffs);
        end
    end
    

    % do pivot calibration using the corrected pivot data
    p_post_corrected = pivot_calibration(G_corrected); %returns 3x1 vector, which is the position of the pivot point (dimple) in EM tracker's coordinate system
    
    
    
    % Step 4: compute probe tip geometry
    g_markers = G_corrected{1} - mean(G_corrected{1}, 1); % marker ositions relative to their centroid, uses first corrected pivot frame as reference
    %use helper function to calculate p_tip_probe
    p_tip_probe = compute_probe_tip(G_corrected, g_markers, p_post_corrected');% N_G x 3
    
    fprintf('Probe tip in probe coords: [%.4f, %.4f, %.4f]\n', p_tip_probe);
    
    % Step 5: calculate fiducial locations in EM base frame
    % read raw EM readings taken when probe tip touched each CT fiducial
    Gcells_fiducials_raw = read_emfiducials(emfiducials_name);
    
    N_B = length(Gcells_fiducials_raw); % number of fiducials measured
    b_EM = zeros(N_B, 3); % tip positions in F_D
    
    for fid_idx = 1:N_B
        % Correct distortion
        G_fid_raw = Gcells_fiducials_raw{fid_idx}; % raw data for fiducial measurement frame
        Ng = size(G_fid_raw, 1);
        G_fid_corrected = zeros(Ng, 3);
        
        for marker = 1:Ng
            G_fid_corrected(marker, :) = correctDistortion(G_fid_raw(marker, :), distortion_coeffs); %corrct distortion for each marker in this frame
        end
        
        % Register to get probe pose when touching this fiducial using
        % helper function
        [R_G, t_G] = find_transformation(g_markers, G_fid_corrected);
        
        % Transform probe tip to EM coordinates
        b_EM(fid_idx, :) = (R_G * p_tip_probe' + t_G)';
    end
    
    fprintf('\nFiducial positions in EM coordinates:\n');
    disp(b_EM);
    
    % Step 6: compute CT registration F_GC
    %read known CT fiducial coordinates using helper function
    b_CT = read_ct_fiducials(ctfiducials_name);
    
    % Compute registration transformation: b_EM -> b_CT
    [R_reg, t_reg] = find_transformation(b_EM, b_CT);
    
    fprintf('\nRegistration computed (EM -> CT)\n');
    fprintf('R_reg:\n');
    disp(R_reg);
    fprintf('t_reg: [%.4f, %.4f, %.4f]\n', t_reg);
    
    % Step 7: process navigation data
    
    % Read navigation data
    Gcells_nav_raw = read_emnav(emnav_name);
    Nframes_nav = length(Gcells_nav_raw);
    v_CT = zeros(Nframes_nav, 3);  % Output: probe tip positions in CT coords
    
    for frame = 1:Nframes_nav
        % Get raw marker data for this frame
        G_nav_raw = Gcells_nav_raw{frame};
        Ng = size(G_nav_raw, 1);
        
        % Step a: Correct distortion for raw marker readings
        G_nav_corrected = zeros(Ng, 3);
        for marker = 1:Ng
            G_nav_corrected(marker, :) = correctDistortion(G_nav_raw(marker, :), distortion_coeffs);
        end
        
        % Step b: Register to get probe pose in EM coordinates
        [R_G, t_G] = find_transformation(g_markers, G_nav_corrected);
        
        % Step c: Transform probe tip to EM coordinates
        tip_EM = (R_G * p_tip_probe' + t_G)';
        
        % Step d: Transform from EM to CT coordinates
        v_CT(frame, :) = (R_reg * tip_EM' + t_reg)';
    end
    
    fprintf('\nProbe tip positions in CT coordinates:\n');
    disp(v_CT);
    
    % Step 8: write output file
    %get path to output directory
    current_file_path = fileparts(mfilename('fullpath'));
    
    output_dir = fullfile(current_file_path, '..', 'output');
    % ensure directory exists
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
        fprintf('Created directory: %s\n', output_dir);
    else
        fprintf('Directory already exists: %s\n', output_dir);
    end
    write_output2(output_name, v_CT);