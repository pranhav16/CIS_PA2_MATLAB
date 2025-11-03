% bernstein_basis.m
% author: luiza
% this function calculates the value of a single 1D Bernstein basis polynomial used for
% distortion correction
                                    
function B = bernstein_basis(i, n, t)
    % Bernstein basis polynomial B_{i,n}(t)
    % i: index (0 to n)
    % n: degree
    % t: parameter values (column vector)
    
    B = nchoosek(n, i) * (t.^i) .* ((1-t).^(n-i));
end