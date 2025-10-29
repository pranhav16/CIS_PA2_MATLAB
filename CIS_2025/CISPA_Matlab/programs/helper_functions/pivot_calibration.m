function [P_dimple] = pivot_calibration(G_frames)
    % Performs pivot calibration to find the dimple post location
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
    
    Nframes = length(G_frames);

    % 5a: Define the local probe coordinate system using the first frame
    G_first_frame = G_frames{1}; 
    G0 = mean(G_first_frame, 1); 
    g = G_first_frame - G0; 

    % Initialize storage for rotations and translations from each frame
    rotations = cell(1, Nframes);
    translations = cell(1, Nframes);

    % 5b: compute the transformation F_G[k] for each frame
    for k = 1:Nframes
        G_k = G_frames{k}; % Get the data for the k-th frame
        [R, p] = find_transformation(g, G_k);
        rotations{k} = R;
        translations{k} = p;
    end

    % 5c: Solve system
    % P_dimple = R_k * t_G + p_k.
    
    A = zeros(3 * Nframes, 6);
    b = zeros(3 * Nframes, 1);
    identity_neg = -eye(3);

    for k = 1:Nframes
        R_k = rotations{k};
        p_k = translations{k};
        
        start_row = 3 * (k - 1) + 1;
        A(start_row:start_row+2, 1:3) = R_k;
        A(start_row:start_row+2, 4:6) = identity_neg;
        b(start_row:start_row+2) = -p_k;
    end

    x = A \ b;

    % The final answer is the last 3 elements of x
    P_dimple = x(4:6);
end