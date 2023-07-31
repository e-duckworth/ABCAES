function wout = sbox(win)
% SBOX, this Matlab function, applies the sbox function as defined in our 4
% letter ABCAES encryption.  The input "win" is a single word, i.e. a group
% of 4 letters, encoded as a vector of 4 integers with each integer
% interpreted modulo 29. The output has the same format.  It uses Matlab's
% @sym/gcd to find inverses, so it converts the word to a symbolic
% polynomial, and then converts the result back to a vector of integers. 
if ~isvector(win)
    error("Input word is not a vector")
else
    if length(win) ~= 4
    error("Input word does not have correct number of letters.")
    end
end
syms x
% convert input word to symbolic polynomial
win = (win.*[x^3,x^2,x,1])*ones(4,1);
% calculate inverse.  Note that MATLAB returns 0 if win = 0
[~,winv,~]=gcd(win,x^4+2*x^2+15*x+2);
% reduce mod p
winv = pmod(winv,29);
% apply the affine map
winv = (x^3+2*x^2+3*x+4)*winv+(5*x^3+6*x^2+7*x+8);
% reduce mod 29, and mod x^4+1, and mod 29 again
wout=double(coeffs(pmod(polynomialReduce(pmod(winv,29),x^4+1),29),'all'));
if length(wout) < 4
    wout = [zeros(1,4-length(wout)) wout];
end
end
