function B = bernstein_basis(i, n, t)
    % Bernstein basis polynomial B_{i,n}(t)
    % i: index (0 to n)
    % n: degree
    % t: parameter values (column vector)
    
    B = nchoosek(n, i) * (t.^i) .* ((1-t).^(n-i));
end