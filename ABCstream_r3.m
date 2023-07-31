% this function applies the ABCAES4 algorithm, but with an extra
% round, i.e. three rounds.
function ciphertext = ABCstream_r3(plaintext,key,verbose)

% set flag for verbose mode
if nargin < 3
    debug = false;
elseif strcmp(verbose,'verbose')
    debug = true;
else 
    error('Third argument unrecognized, can only be "verbose".')
end

% if the key and/or plaintext are already only numbers and only between 0
% and 29 then we assume that they have already been encoded and do nothing.  
if isstring(plaintext) | ischar(plaintext)
    plaintext=encode(plaintext);
elseif ~(isnumeric(plaintext) && all(plaintext>=0) && all(plaintext<=29) && all(floor(plaintext)==plaintext))
    error("Plaintext is not in correct format. Must be either string, or character array, or integers between 0 and 29.")
end

if isstring(key) | ischar(key)
    key=encode(key);
elseif ~(isnumeric(key) && all(key>=0) && all(key<=29) && all(floor(key)==key))
    error("Key is not in correct format. Must be either string, or character array, or integers between 0 and 29.")
end

if debug,plaintext,end
if debug,key,end

% pad plaintext, which now consists of integers only, with 0s to get
% total length equal to multiple of 16.
multiple16 = 16*ceil(length(plaintext)/16);
plaintext=[plaintext,zeros(1,multiple16-length(plaintext))];

if length(key) < 16
    warning("Key is shorter than 16. Key will be padded with As.")
    key=[key,ones(1,16-length(key))];
elseif length(key)>16
    warning("Key is longer than 16. Key will be truncated.")
    key=key(1:16);
end

if debug,disp("plaintext after encoding and padding"),plaintext,end
if debug,key,end

for n= 1:length(plaintext)/16
    ciphertext(16*(n-1)+1:16*n)=ABCinternal(plaintext(16*(n-1)+1:16*n),key);
end

function ciphertext=ABCinternal(plaintext,key)
plaintext=[plaintext(1:4) plaintext(9:12);...
    plaintext(5:8) plaintext(13:16)];
if debug
    [K0 K1 K2 K3]=keyexpand_r3(key,verbose);
else
    [K0 K1 K2 K3]=keyexpand_r3(key);
end    

if debug,K0,K1,K2,K3,disp('Next add K0'),end
% round 0
ciphertext=addkey(plaintext,K0);
% round 1
if debug ciphertext,disp('Next apply WS'),end
ciphertext=WS(ciphertext);
   if debug,ciphertext,disp('Next apply SR'),end
ciphertext=SR(ciphertext);
   if debug,ciphertext,disp('Next apply MC'),end
ciphertext=MC(ciphertext);
    if debug,ciphertext,disp('Next add K1'),end
ciphertext=addkey(ciphertext,K1);
% round 2
   if debug,ciphertext,disp('Next apply WS'),end
ciphertext=WS(ciphertext);
   if debug,ciphertext,disp('Next apply SR'),end
ciphertext=SR(ciphertext);
   if debug,ciphertext,disp('Next apply MC'),end
ciphertext=MC(ciphertext);
   if debug,ciphertext,disp('Next add K2'),end
ciphertext=addkey(ciphertext,K2);
% round 3
   if debug,ciphertext,disp('Next apply WS'),end
ciphertext=WS(ciphertext);
   if debug,ciphertext,disp('Next apply SR'),end
ciphertext=SR(ciphertext);
   if debug,ciphertext,disp('Next add K3'),end
ciphertext=addkey(ciphertext,K3);
% after rounds
if debug,ciphertext,disp('Next decode'),end
ciphertext=decode(ciphertext);
ciphertext=[ciphertext(1,1:4) ciphertext(2,1:4) ...
    ciphertext(1,5:8) ciphertext(2,5:8)];
end



end
