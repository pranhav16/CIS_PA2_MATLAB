% test_distortion_correction.m (v6 - Plotless, Corrected Args)
%author:luiza
% This function analyzes the "training error" of the distortion correction
% it runs the distortion pipeline on a specified dataset, and then calculates the RMSE of applying that
% correction to the same data it was trained on
%
% This validates how well the Bernstein polynomial model fits the data.
function [rmse] = test_distortion_correction(dataset_letter, degree, base_path, data_path_base)
    fprintf('--- Test 3: Distortion Correction Model Analysis ---\n');
    fprintf('Running on dataset: debug-%s (degree %d)\n', dataset_letter, degree);

    % Add necessary paths (helper functions)
    addpath(fullfile(base_path, 'programs', 'helper_functions'));

    % Define file paths
    calbody_name = sprintf('pa2-debug-%s-calbody.txt', dataset_letter);
    calreadings_name = sprintf('pa2-debug-%s-calreadings.txt', dataset_letter);
    
    % Use the correct, validated data path
    calbody_path = fullfile(data_path_base, calbody_name);
    calreadings_path = fullfile(data_path_base, calreadings_name);
    
    % Check for file existence
    if ~exist(calbody_path, 'file')
        fprintf('    ERROR: Cannot find file: %s\n', calbody_path);
        rmse = NaN;
        return;
    end
    if ~exist(calreadings_path, 'file')
        fprintf('    ERROR: Cannot find file: %s\n', calreadings_path);
        rmse = NaN;
        return;
    end

    % Step 1: distortion vectors
    [C_expected, Ccells] = compute_C(calbody_path, calreadings_path);
    
    distortion_vectors = cell(1,numel(Ccells));
    for i = 1:numel(Ccells)
        distortion_vectors{i} = Ccells{i}(:, 1:3) - C_expected{i}(:, 1:3); 
    end
    
    N_frames = numel(Ccells);
    N_C = size(Ccells{1},1);
    
    all_positions = zeros(N_frames * N_C, 3);  % Raw EM positions
    all_distortions = zeros(N_frames * N_C, 3); % Distortion vectors
    
    idx = 1;
    for frame = 1:N_frames
        for marker = 1:N_C
            all_positions(idx, :) = Ccells{frame}(marker, :);
            all_distortions(idx, :) = distortion_vectors{frame}(marker, :);
            idx = idx + 1;
        end
    end
    
    % Step 2: compute distortion correction coefficients
    min_coords = min(all_positions, [], 1);
    max_coords = max(all_positions, [], 1);
    bbox.min = min_coords;
    bbox.max = max_coords;
    
    normalized_pos = (all_positions - min_coords) ./ (max_coords - min_coords);
    A = create_bernstein_matrix(normalized_pos, degree);
    
    coeffs_x = A \ all_distortions(:, 1);
    coeffs_y = A \ all_distortions(:, 2);
    coeffs_z = A \ all_distortions(:, 3);
    
    distortion_coeffs.x = coeffs_x;
    distortion_coeffs.y = coeffs_y;
    distortion_coeffs.z = coeffs_z;
    distortion_coeffs.degree = degree;
    distortion_coeffs.bbox = bbox;

    % Step 3: Apply correction and calculate RMSE
    fprintf('Analyzing distortion model fit...\n');
    N_points = size(all_positions, 1);
    all_corrected = zeros(N_points, 3);
    
    % C_expected = Ccells - distortion = all_positions - all_distortions
    all_expected = all_positions - all_distortions; 
    
    % Apply correction to all raw points
    for i = 1:N_points
        all_corrected(i, :) = correctDistortion(all_positions(i, :), distortion_coeffs);
    end
    
    % Calculate error
    errors = all_corrected - all_expected; % Residual errors
    squared_errors = sum(errors.^2, 2);
    rmse = sqrt(mean(squared_errors));
    
    fprintf('Distortion Correction Training RMSE: %f mm\n', rmse);
end

