% read_ct_fiducials.m
%author:pranhav
% this function reads the -ct-fiducials.txt file
function b_CT = read_ct_fiducials(path)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));   
    
    fid = fopen(path, 'r');
    assert(fid > 0, 'Cannot open %s', path);
    
    % Read header line, get Nb
    header = fgetl(fid);
    nums = sscanf(header, '%d');
    if isempty(nums)
        nums = sscanf(regexprep(header, '[^\d,]', ''), '%d');
    end
    
    N_B = nums(1);
    
    fprintf('N_B (CT fiducials) = %d\n', N_B);
    
    % Read all CT fiducial coordinates
    b_CT = read_block(fid, N_B);
    
    fclose(fid);
end