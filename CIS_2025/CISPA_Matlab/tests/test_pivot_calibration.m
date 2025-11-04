% test_pivot_calibration.m
%author:luiza
% This is a unit test for the 'pivot_calibration' function.
% It checks the function's accuracy with:
% 1. Perfect Data: Simulates pivot motion with a known pivot point.
%    The error should be near-zero
% 2. Noisy Data: Adds Gaussian noise to the simulated marker positions
%    to test robustness
function [results_table] = test_pivot_calibration()
    fprintf('--- Test 2: Unit Test for pivot_calibration ---\n');
    
    % 1. Define local probe geometry (g)
    g = [ -50  0  0;
           50  0  0;
            0 50  0;
            0  0 50 ];
    g = g - mean(g, 1); % Center the markers

    % 2. Define ground-truth pivots
    p_tip_probe_true = [10; 15; 120];  % Pivot location in local 'g' frame
    p_tip_tracker_true = [200; 300; 100]; % Pivot location in tracker frame
    
    N_frames = 20;
    G_frames_sim = cell(1, N_frames);
    
    % 3. Simulate pivot data
    for k = 1:N_frames
        % Create a random rotation matrix
        [R_k, ~] = qr(randn(3));
        R_k = R_k * diag([1, 1, det(R_k)]); % Ensure it's a proper rotation
        
        % Calculate the corresponding translation
        p_k = p_tip_tracker_true - R_k * p_tip_probe_true;
        
        % Calculate marker positions in tracker frame
        G_k = (R_k * g' + p_k)';
        G_frames_sim{k} = G_k;
    end
    
    % 4. Call our function (perfect data)
    P_dimple_calc = pivot_calibration(G_frames_sim);
    
    % 5. Calculate and display error
    error_perfect = norm(P_dimple_calc - p_tip_tracker_true);
    fprintf('  Test Case 1: Perfect Data (Fake)\n');
    fprintf('    Pivot Position Error (Euclidean Norm): %e mm\n', error_perfect);
    
    % 6. Add noise and re-test
    noise_level = 0.1; % 0.1mm standard deviation
    G_frames_sim_noisy = cell(1, N_frames);
    for k = 1:N_frames
        G_frames_sim_noisy{k} = G_frames_sim{k} + noise_level * randn(size(g));
    end
    
    P_dimple_calc_noisy = pivot_calibration(G_frames_sim_noisy);
    error_noisy = norm(P_dimple_calc_noisy - p_tip_tracker_true);
    
    fprintf('  Test Case 2: Noisy Data (Fake, Noise=%.2fmm)\n', noise_level);
    fprintf('    Pivot Position Error (Euclidean Norm): %f mm\n', error_noisy);
    
    % Store results
    results_table = table(error_perfect, error_noisy, ...
        'VariableNames', {'Perfect_Error_mm', 'Noisy_Error_mm'});
end

