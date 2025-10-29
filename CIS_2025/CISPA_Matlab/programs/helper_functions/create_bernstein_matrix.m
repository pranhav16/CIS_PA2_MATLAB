function A = create_bernstein_matrix(normalized_pos, degree)
    % normalized_pos: N x 3 matrix of positions in [0,1]^3
    % degree: polynomial degree (e.g., 5)
    
    N = size(normalized_pos, 1);
    u = normalized_pos(:, 1);
    v = normalized_pos(:, 2);
    w = normalized_pos(:, 3);
    
    % Number of coefficients for 3D Bernstein polynomial of degree n
    % is (n+1)^3
    n_coeffs = (degree + 1)^3;
    A = zeros(N, n_coeffs);
    
    col = 1;
    for i = 0:degree
        for j = 0:degree
            for k = 0:degree
                % Bernstein basis function B_{i,n}(u) * B_{j,n}(v) * B_{k,n}(w)
                A(:, col) = bernstein_basis(i, degree, u) .* ...
                            bernstein_basis(j, degree, v) .* ...
                            bernstein_basis(k, degree, w);
                col = col + 1;
            end
        end
    end
end

