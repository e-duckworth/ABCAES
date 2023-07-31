function p = pmod(f,m)
% PMOD reduces the coefficients of a symbolic polynomial f by the positive
% integer m. It can handle coefficients that are rational numbers,
% interpreting a/b as a*b\inv and then calculating b\inv using Matlab's gcd
% function.
[c,t]=coeffs(f);
[num, denom]=numden(sym(c));
[grcd, moddenom,~]=gcd(denom,m);
if any(grcd~=1) 
        error('Error: Denominator not invertible modulo %s.',m)
end
c = mod(num.*moddenom,m);
p=sum(c.*t);
end
