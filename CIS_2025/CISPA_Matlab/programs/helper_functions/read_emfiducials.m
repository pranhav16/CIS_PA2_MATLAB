function [Gcells_fiducials] = read_emfiducials(path)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
    fid = fopen(path, 'r');
    assert(fid > 0, 'Cannot open %s', path);
    
    % Read header line
    header = fgetl(fid);
    nums = sscanf(header, '%d , %d');  % Ng, N_B
    if numel(nums) < 2
        nums = sscanf(regexprep(header, '[^\d,]', ''), '%d,%d');
    end
    
    Ng = nums(1);
    N_B = nums(2);
    
    fprintf('N_G = %d, N_B = %d\n', Ng, N_B);
    
    % Read all fiducial frames
    Gcells_fiducials = cell(1, N_B);
    for k = 1:N_B
        Gcells_fiducials{k} = read_block(fid, Ng);
    end
    
    fclose(fid);
end