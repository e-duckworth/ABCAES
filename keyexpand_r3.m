% this applies the key expand schedule, but for a 3 round version of
% ABCAES4
function [K0,K1,K2,K3] = keyexpand_r3(key,verbose)
if nargin < 2
    debug = false;
elseif strcmp(verbose,'verbose')
    debug = true;
else 
    error('Second argument unrecognized, can only be "verbose".')
end
if debug,disp('keyexpand mode:'),end

W0 = key(1:8);
W1 = key(9:16);

if debug,W0,W1,end

RC1 = [0 0 1 0];
RC2 = [0 1 0 0];
RC3 = [1 0 0 0];

if debug,RC1,disp('sbox(rotword(W1))='),[sbox(W1(5:8)),sbox(W1(1:4))],end

W2 = mod(W0 + [RC1 0 0 0 0] + [sbox(W1(5:8)) sbox(W1(1:4))],29);
W3 = mod(W1+W2,29);

if debug,W2,W3,end
if debug,RC2,disp('sbox(rotword(W3))='),[sbox(W3(5:8)),sbox(W3(1:4))],end

W4 = mod(W2 + [RC2 0 0 0 0] + [sbox(W3(5:8)) sbox(W3(1:4))],29);
W5 = mod(W3+W4,29);

if debug,W4,W5,end

W6 = mod(W4 + [RC3 0 0 0 0] + [sbox(W5(5:8)) sbox(W5(1:4))],29);
W7 = mod(W5+W6,29);

if debug,W5,W6,end

K0 = key;
K1 = [W2 W3];
K2 = [W4 W5];
K3 = [W6 W7];

if debug, K0,K1,K2,disp('end keyexpand'),end
end
