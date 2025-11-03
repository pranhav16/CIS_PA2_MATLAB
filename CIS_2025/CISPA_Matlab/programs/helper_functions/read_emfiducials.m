%read_emfiducials.m
%author: luiza
%this function reads the em-fiducialss.txt files
function [Gcells_fiducials] = read_emfiducials(path)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
    fid = fopen(path, 'r');
    assert(fid > 0, 'Cannot open %s', path);
    
    % Read header line, get Ng and Nb
    header = fgetl(fid);
    nums = sscanf(header, '%d , %d');  % Ng, N_B
    if numel(nums) < 2
        nums = sscanf(regexprep(header, '[^\d,]', ''), '%d,%d');
    end
    
    Ng = nums(1); %markers on probe
    N_B = nums(2); %number of fiducials
    
    fprintf('N_G = %d, N_B = %d\n', Ng, N_B); %print counts
    
    % Read all fiducial frames
    Gcells_fiducials = cell(1, N_B);
    %loop for each fiducial
    for k = 1:N_B
        Gcells_fiducials{k} = read_block(fid, Ng);
    end
    
    fclose(fid);
end