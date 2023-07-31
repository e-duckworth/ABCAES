% combines all steps for ABCAES4 to take ciphertext, and key and do
% the whole decryption. There is an optional flag, argument 3, for
% verbose mode, in which case it prints a description of which step is
% being done and then prints the output of each step.  Note that
% "ciphertext" and "plaintext" are used below in a reverse
% sense. That's because the code was copy and pasted from the
% encryption algorithm, and then we just changed a couple of the
% intermediate functions.
function ciphertext = ABCinv(plaintext,key,verbose)

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
if debug,
    [K0 K1 K2]=keyexpand(key,verbose);
else
    [K0 K1 K2]=keyexpand(key);
end    

if debug,K0,K1,K2,disp('Next add -K2'),end
ciphertext=addkey(plaintext,-K2);
   if debug,ciphertext,disp('Next apply SRinv'),end
ciphertext=SRinv(ciphertext);
   if debug ciphertext,disp('Next apply WSinv'),end
ciphertext=WSinv(ciphertext);
   if debug,ciphertext,disp('Next add -K1'),end
ciphertext=addkey(ciphertext,-K1);
   if debug
       ciphertext
       disp('Next apply MCinv')
       ciphertext=MCinv(ciphertext);
   else
       ciphertext=MCinv(ciphertext);
   end
   if debug,ciphertext,disp('Next apply SRinv'),end
ciphertext=SRinv(ciphertext);
   if debug,ciphertext,disp('Next apply WSinv'),end
ciphertext=WSinv(ciphertext);
   if debug,ciphertext,disp('Next add -K0'),end
ciphertext=addkey(ciphertext,-K0);
   if debug,ciphertext,disp('Next decode'),end
ciphertext=decode(ciphertext);
ciphertext=[ciphertext(1,1:4) ciphertext(2,1:4) ...
    ciphertext(1,5:8) ciphertext(2,5:8)];
end


function y = encode(x);
        y = lower(x);
        y=double(char(y));
        % delete non-letters
        idxa = y>=97 & y<=122; % index for letters
        idxpunc = y==32 | y==46 | y==63; % index for punctuation
        y(~idxa & ~idxpunc)=[]; % delete things \ne letters or punct
        y(y>96)=y(y>96)-96; % 97 = ASCII a
        y(y==32)=0; % ASCII space = 32
        y(y==46)=27; % ASCII period = 46
        y(y==63)=28; % ASCII question mark = 63
end

function y = decode(x);
        y = x+64; % 65 = ASCII A
        y (y==28+64) = 63; % set ASCII question mark
        y (y==27+64) = 46; % set ASCII period
        y (y==64) = 32; % set ASCII space
        y=char(y);
end
end
