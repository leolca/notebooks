#!/usr/bin/octave -qf

arg_list = argv ();

if( length(arg_list) == 0), error('no input file was given!'); endif;
filename = arg_list{1};
if( exist(filename,'file') != 2 ), error('file does not exist!'); endif;
n = load(filename);
if( size(n,2) != 1), error('a row vector file must be provided!'); endif;
if( any(floor(n) != n) ), error('you must provide a vector of integers!'); endif


if length( find(n==0,1) > 0), 
   n += ones(size(n)); % add one smothing
endif

% mle
p = n./sum(n);
H = entropy(p);
printf('Entropy: %.2f bits\n',H);

