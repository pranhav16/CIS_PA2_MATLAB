%read_pivot_data.m
%author:luiza
% this function reads the EM pivot data file (*-empivot.txt)
function [G_frames] = read_pivot_data(filename)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));   

% Opens and reads the EM pivot data file.
    % filename: The path to the NAME-EMPIVOT.TXT file.
    % G_frames: A cell array where each cell contains an NG x 3 matrix of
    %           marker coordinates for a single frame.

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Read the header line to get NG and Nframes
    header_line = fgetl(fid);
    header_data = sscanf(header_line, '%d, %d,');
    NG = header_data(1);
    Nframes = header_data(2);

    % Initialize a cell array to store the data for each frame
    G_frames = cell(1, Nframes);

    % Loop through each frame to read the marker data
    for k = 1:Nframes
        G_k = zeros(NG, 3);
        for i = 1:NG
            line = fgetl(fid);
            G_k(i, :) = sscanf(line, '%f, %f, %f');
        end
        G_frames{k} = G_k;
    end

    fclose(fid);
end