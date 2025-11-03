%read_block.m
%author: pranhav
%this function reads a block of N lines of 3D data from a file, skipping
%blanks
function M = read_block(fid, N)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
  M = zeros(N,3); %pre allocate
  i = 1;
  while i <= N %loop until N non blank lines
    ln = fgetl(fid);
    if ~ischar(ln), error('Unexpected EOF'); end
    % skip blank lines
    if all(isspace(ln)), continue; end
    % grab first three numeric tokens on the line
    toks = regexp(ln, '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match');
    if numel(toks) >= 3
      M(i,:) = str2double(toks(1:3));
      i = i + 1;
    end
  end
end