% test_find_transformation.m
%author:luiza
% This is a unit test for the 'find_transformation' function.
% It checks the function's accuracy with:
% 1. Perfect Data: Uses synthetic data with a known transformation and no noise.
%    The error should be near-zero.
% 2. Noisy Data: Adds Gaussian noise to the target points to simulate
%    real-world conditions and calculates the Fiducial Registration Error (FRE).
function [results_table, fre] = test_find_transformation()
    fprintf('--- Test 1: Unit Test for find_transformation ---\n');
    
    % 1. Define a set of points (P)
    P = [ 0  0  0;
         10  0  0;
          0 10  0;
          0  0 10;
          5  5  5;
         -5  5 10 ];
    N = size(P, 1);

    % 2. Define a ground-truth transformation
    theta = pi / 4; % 45-degree rotation around Z
    R_true = [ cos(theta) -sin(theta) 0;
               sin(theta)  cos(theta) 0;
               0           0          1 ];
    t_true = [50; -30; 100]; % 3x1 translation

    % 3. Create the transformed points (Q)
    Q_perfect = (R_true * P' + t_true)';

    % 4. Call our function to find the transformation
    [R_calc, t_calc] = find_transformation(P, Q_perfect);

    % 5. Calculate and display error for the perfect case
    R_error = norm(R_true - R_calc, 'fro'); % Frobenius norm for matrices
    t_error = norm(t_true - t_calc);         % Euclidean norm for vectors
    
    fprintf('  Test Case 1: Perfect Data (Fake)\n');
    fprintf('    Rotation Error (Frobenius Norm): %e\n', R_error);
    fprintf('    Translation Error (Euclidean Norm): %e\n', t_error);
    
    % 6. Test with noisy data
    noise_level = 0.1; % 0.1mm standard deviation
    Q_noisy = Q_perfect + noise_level * randn(size(Q_perfect));
    
    [R_calc_n, t_calc_n] = find_transformation(P, Q_noisy);
    
    % 7. Calculate Fiducial Registration Error (FRE)
    P_transformed_noisy = (R_calc_n * P' + t_calc_n)';
    errors = P_transformed_noisy - Q_noisy;
    squared_errors = sum(errors.^2, 2);
    fre = sqrt(mean(squared_errors));
    
    fprintf('  Test Case 2: Noisy Data (Fake, Noise=%.2fmm)\n', noise_level);
    fprintf('    Fiducial Registration Error (RMSE): %f mm\n', fre);

    % Store results
    results_table = table(R_error, t_error, fre, ...
        'VariableNames', {'Perfect_R_Error', 'Perfect_t_Error', 'Noisy_FRE_mm'});
end

