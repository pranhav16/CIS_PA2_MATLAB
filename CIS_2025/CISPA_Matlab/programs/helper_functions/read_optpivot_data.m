function [D_frames, H_frames] = read_optpivot_data(filename)
    % Opens and reads the Optical pivot data file
    % D_frames: array for EM base marker data (D_i) for each frame
    % H_frames: array for optical probe marker data (H_i) for each frame
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Read the header line 
    header_line = fgetl(fid);
    header_data = sscanf(header_line, '%d, %d, %d,');
    ND = header_data(1);
    NH = header_data(2);
    Nframes = header_data(3);

    D_frames = cell(1, Nframes);
    H_frames = cell(1, Nframes);

    % Loop through each frame to read the two sets of marker data 
    for k = 1:Nframes
        D_k = zeros(ND, 3);
        for i = 1:ND
            line = fgetl(fid);
            D_k(i, :) = sscanf(line, '%f, %f, %f');
        end
        D_frames{k} = D_k;

        H_k = zeros(NH, 3);
        for i = 1:NH
            line = fgetl(fid);
            H_k(i, :) = sscanf(line, '%f, %f, %f');
        end
        H_frames{k} = H_k;
    end

    fclose(fid);
end