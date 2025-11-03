%compute_probe_tip.m
%author: luiza
% this function calculates the probe tip vector t_G in the probe's local
% coordinate system
function p_tip = compute_probe_tip(Gcells_corrected, g_markers, p_post)
    % Gcells_corrected: cell array of corrected marker positions
    % g_markers: N_G x 3, markers in probe coordinates
    % p_post: 1x3, post position in EM tracker coordinates
    
    Nframes = length(Gcells_corrected);
    
    % Build least-squares system: R[k] * p_tip + t[k] = p_post
    % Rearrange: R[k] * p_tip = p_post - t[k]
    A = zeros(3 * Nframes, 3);
    b = zeros(3 * Nframes, 1);
    % loop thorugh corrected pivot frames
    for k = 1:Nframes
        G_current = Gcells_corrected{k};  % N_G x 3
        
        % Register g_markers to G_current
        [R_k, t_k] = find_transformation(g_markers, G_current);
        
        % Fill system: R[k] * p_tip = p_post' - t[k]
        row_start = 3*(k-1) + 1;
        A(row_start:row_start+2, :) = R_k;
        b(row_start:row_start+2) = p_post' - t_k;
    end
    
    % Solve for p_tip in probe coordinates
    p_tip = (A \ b)';
end