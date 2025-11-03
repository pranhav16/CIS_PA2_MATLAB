%write_output2.m
%author: pranhav
%this function writes the final PA2 output file
function write_output2(filename, v_CT)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
    output_dir = fullfile(thisDir, '..', '..', 'OUTPUT');
    output_filename = fullfile(output_dir, filename);

    fid = fopen(output_filename, 'w');
    assert(fid > 0, 'Cannot open %s for writing', output_filename);
    %get the number of frames from the data
    Nframes = size(v_CT, 1);
    
    % Write header
    fprintf(fid, '%d, %s\n', Nframes, output_filename);
    
    % Write each position
    for i = 1:Nframes %loop through frames
        fprintf(fid, '%8.2f, %8.2f, %8.2f\n', v_CT(i, 1), v_CT(i, 2), v_CT(i, 3));
    end
    
    fclose(fid);
    fprintf('Output written to %s\n', output_filename);
end