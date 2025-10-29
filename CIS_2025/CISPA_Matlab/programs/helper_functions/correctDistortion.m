function corrected = correctDistortion(raw_point, distortion_coeffs)
    % raw_point: 1x3 or 3x1 vector [qx, qy, qz]
    % distortion_coeffs: structure with .x, .y, .z, .degree, .bbox
    
    % Normalize to [0,1]
    normalized = (raw_point - distortion_coeffs.bbox.min) ./ ...
                 (distortion_coeffs.bbox.max - distortion_coeffs.bbox.min);
    
    % Evaluate Bernstein polynomial at this point
    A = create_bernstein_matrix(normalized(:)', distortion_coeffs.degree);
    
    % Compute distortion at this point
    dist_x = A * distortion_coeffs.x;
    dist_y = A * distortion_coeffs.y;
    dist_z = A * distortion_coeffs.z;
    
    % Subtract distortion from raw reading to get corrected position
    corrected = raw_point - [dist_x, dist_y, dist_z];
end