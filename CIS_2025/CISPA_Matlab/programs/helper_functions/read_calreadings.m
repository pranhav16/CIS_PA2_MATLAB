function [Dcells, Acells, Ccells] = read_calreadings(path)
    thisDir = fileparts(mfilename('fullpath'));
    % Two levels up
    parent2 = fileparts(fileparts((thisDir)));
    addpath(genpath(parent2));
  fid = fopen(path,'r');  assert(fid>0, 'Cannot open %s', path);
  header = fgetl(fid);
  nums = sscanf(header, '%d , %d , %d , %d');  % Nd, Na, Nc, Nframes
  if numel(nums) < 4
    nums = sscanf(regexprep(header,'[^\d,]',''),'%d,%d,%d,%d');
  end
  Nd = nums(1); Na = nums(2); Nc = nums(3); Nf = nums(4);
  disp(Nd);
  disp(Na);
  disp(Nf);
  disp(Nc);
  Dcells = cell(1,Nf);  Acells = cell(1,Nf);  Ccells = cell(1,Nf);
  for k = 1:Nf
    Dcells{k} = read_block(fid, Nd);
    Acells{k} = read_block(fid, Na);
    Ccells{k} = read_block(fid, Nc);
  end
  fclose(fid);
end