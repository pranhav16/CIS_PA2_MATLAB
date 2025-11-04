% run_all_validation.m
%author:luiza
% This is the master script to run the full validation suite.
% 1. Sets up paths.
% 2. Runs unit test for 'find_transformation'
% 3. Runs unit test for 'pivot_calibration'
% 4. Runs unit test for 'test_distortion_correction'
% 5. Runs validation for all debug datasets
%

function run_all_validation
    clc;

    fprintf('RUNNING PA2 VALIDATION\n');


    % --- 1. Setup Paths ---
    % Get the full path to this script
    tests_path = fileparts(mfilename('fullpath'));
    % Navigate up to the 'CISPA_Matlab' directory
    base_path = fullfile(tests_path, '..'); 
    
    % Define other key paths based on this 'base_path'
    data_path = fullfile(base_path, 'PA2_Student_Data');
    output_path = fullfile(base_path, 'output'); 
    addpath(genpath(base_path));

    validation_degree = 5;
    
    % --- 2. Test 1: find_transformation ---
    [~, ~] = test_find_transformation();
    fprintf('\n');
    
    % --- 3. Test 2: pivot_calibration ---
    [~] = test_pivot_calibration();
    fprintf('\n');

    % --- 4. Test 3: Distortion Correction ---
    [dist_rmse] = test_distortion_correction('c', validation_degree, base_path, data_path);
    fprintf('\n');

    % --- 5. Test 4: End-to-End Validation ---
    fprintf('--- Test 4: End-to-End Output Validation ---\n\n');
    debug_datasets = {'a', 'b', 'c', 'd', 'e', 'f'};
    num_datasets = length(debug_datasets);
    results = cell(num_datasets, 1);
    
    % Create a table for results
    results_table = table('Size', [num_datasets, 1], ...
                          'VariableTypes', {'double'}, ...
                          'VariableNames', {'RMSE_mm'}, ...
                          'RowNames', debug_datasets);
    
    for i = 1:num_datasets
        letter = debug_datasets{i};
        fprintf('Running full pipeline for debug-%s (degree %d)...\n', letter, validation_degree);
        
        try
            % Run the main assignment
            assignment_2('debug', letter, validation_degree);
            
            % Validate the output

            [rmse_val] = test_end_to_end(letter, base_path, data_path);
            
            fprintf('  Validation RMSE vs Ground Truth: %f mm\n\n', rmse_val);
            results_table.RMSE_mm(letter) = rmse_val;
            
        catch e
            fprintf('  ERROR running or validating dataset %s: %s\n', letter, e.message);
            fprintf('  Stack trace:\n');
            for k=1:length(e.stack)
                fprintf('    File: %s, Line: %d\n', e.stack(k).file, e.stack(k).line);
            end
            fprintf('\n');
            results_table.RMSE_mm(letter) = NaN;
        end
    end
    
    % --- 6. Final Summary ---
    fprintf('Final End-to-End Results:\n');
    disp(results_table);

end

