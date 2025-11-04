% test_end_to_end.m
%author: luiza
% This script validates the final output of 'assignment_2.m' against the
% truth files
% It is called by 'run_all_validation.m' after 'assignment_2.m' has
% already run and created an output file.
function [rmse] = test_end_to_end(letter, base_path, data_path_base)
    
    mode = 'debug';
    
    % Path to the ground truth output file
    truth_filename = sprintf('pa2-%s-%s-output2.txt', mode, letter);
    truth_path = fullfile(data_path_base, truth_filename);
    
    % Path to our calculated output file
    calc_filename = sprintf('pa2-%s-%s-output2.txt', mode, letter);
    calc_path = fullfile(base_path, 'OUTPUT', calc_filename); % Check uppercase 'OUTPUT'

    % Check if files exist
    if ~exist(truth_path, 'file')
        fprintf('  ERROR: Ground truth file not found: %s\n', truth_path);
        rmse = NaN;
        return;
    end
    if ~exist(calc_path, 'file')
        fprintf('  ERROR: Calculated file not found: %s\n', calc_path);
        fprintf('         (Check if main script wrote to /output or /OUTPUT)\n');
        rmse = NaN;
        return;
    end

    % Read data from files (skip header row)
    try
        % Use dlmread with comma delimiter, skipping 1 header row
        v_truth = dlmread(truth_path, ',', 1, 0);
    catch e
        fprintf('  ERROR: Could not read truth file: %s\n', truth_path);
        fprintf('  %s\n', e.message);
        rmse = NaN;
        return;
    end
    
    try
        % Use dlmread with comma delimiter, skipping 1 header row
        v_calc = dlmread(calc_path, ',', 1, 0);
    catch e
        fprintf('  ERROR: Could not read calculated file: %s\n', calc_path);
        fprintf('  %s\n', e.message);
        rmse = NaN;
        return;
    end
    
    if ~isequal(size(v_truth), size(v_calc))
        fprintf('  ERROR: Output files have different dimensions.\n');
        fprintf('         Truth: %d x %d, Calc: %d x %d\n', ...
                 size(v_truth,1), size(v_truth,2), ...
                 size(v_calc,1), size(v_calc,2));
        rmse = NaN;
        return;
    end
    
    % Calculate error
    errors = v_calc - v_truth;
    squared_errors = sum(errors.^2, 2); % Euclidean distance squared for each point
    rmse = sqrt(mean(squared_errors));
end

