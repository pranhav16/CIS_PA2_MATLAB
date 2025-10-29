function [R_inv, t_inv] = invert_transform(R, t)
    % Inverts a rigid body transformation given by rotation R and translation t.
    % The inverse transformation is defined by R_inv = R' and t_inv = -R'*t.
    R_inv = R';
    t_inv = -R' * t;
end