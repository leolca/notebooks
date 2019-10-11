#!/usr/bin/octave -qf
pkg load communications
pkg load image

% check input arguments
arg_list = argv ();
if( length(arg_list) == 0), error('no input file was given!'); endif;
for i=1:length(arg_list),
  if( exist(arg_list{i},'file') != 2 ), error('file does not exist!'); endif;
end;
% get filename
if length(arg_list) == 1,
  filename = arg_list{1};
else error('too many inputs!');
endif;

text = fileread (filename);
symbols = unique ( sort (text) );
counts = arrayfun (@(x) sum(ismember(text,x)),symbols);
[counts, id] = sort (counts,'descend');  
symbols = symbols(id);

p = counts./sum(counts); % mle of the distribution
dict = huffmandict(symbols, p);
% the function huffmanenco requeries integer index as input
% therefore we will create a map to convert chars into integers
% the mapped text will be used in the encoding method
symbolmap = zeros(1,256);
s2a = double (symbols); % convert to ascii values
symbolmap(s2a([1:length(symbols)])) = [1:length(symbols)];
out = huffmanenco(symbolmap( double (text) ), dict);

% create a binarry representation of the output and 
% split it in blocks of 8 bits to be written to file
binvector2dec = @(block_struct) bin2dec(sprintf('%d',block_struct));
outdec = blockproc(out,[1 8],binvector2dec);

% write file
fid=fopen('/tmp/data.huf','w');
fwrite(fid,uint8(outdec),'uint8');
fclose(fid);

save('-binary','/tmp/huffdic.huf','dict','symbols');
system(cstrcat('cat /tmp/huffdic.huf > ',filename,'.huf'));
system(cstrcat('echo -n "###END_HD###" >> ',filename,'.huf'));
system(cstrcat('cat /tmp/data.huf >> ',filename,'.huf'));
system('rm /tmp/huffdic.huf');
system('rm tmp/data.huf');

