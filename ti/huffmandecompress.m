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

cmd = cstrcat("SPLITPOS=$(grep -abo '###END_HD###' ",filename," | cut -d: -f1) && head -c $SPLITPOS ",filename," > /tmp/huffdic && tail -c +`expr $SPLITPOS + 13` ",filename," > /tmp/data");
system (cmd);
load ('/tmp/huffdic');

fid = fopen ('/tmp/data', 'r');
x = fread (fid, Inf, 'uint8');
fclose (fid);

xbin = de2bi(x,8);
xbin = xbin(:);
back  = huffmandeco (xbin, dict);
id = find (back == -1);
back(id)=[];
decode = char (symbols(back));

fid = fopen(cstrcat(filename,'_decoded'),'w');
fwrite (fid, decode, 'char');
fclose(fid);
