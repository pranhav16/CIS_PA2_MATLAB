function [Gcells_nav] = read_emnav(path)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2)); 
    fid = fopen(path, 'r');
    assert(fid > 0, 'Cannot open %s', path);
    
    % Read header line
    header = fgetl(fid);
    nums = sscanf(header, '%d , %d');  % Ng, Nframes
    if numel(nums) < 2
        nums = sscanf(regexprep(header, '[^\d,]', ''), '%d,%d');
    end
    
    Ng = nums(1);
    Nframes = nums(2);
    
    fprintf('N_G = %d, N_frames (nav) = %d\n', Ng, Nframes);
    
    % Read all navigation frames
    Gcells_nav = cell(1, Nframes);
    for k = 1:Nframes
        Gcells_nav{k} = read_block(fid, Ng);
    end
    
    fclose(fid);
end