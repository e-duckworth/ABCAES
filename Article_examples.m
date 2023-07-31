%% 
% In this document we recreate all the examples from the article as well as 
% demonstrate/test the code given in the article.  Some examples are done twice, 
% once "by hand" and once using a function that is more automatic, i.e. it combines 
% all the needed steps.  "By hand" means breaking it down into steps that use 
% Matlab functions but not any custom functions (to the degree possible).  
% 
% 
%% 
% 
%% Example 2.1 Sbox for ABCAES1
% All Sbox values for ABCAES1

h=unique([25 28 23 4 2 15 10 19 26 16 22 25])
[~,hinv,~]=gcd(h,29); 
[h;mod(hinv,29)]
Sbox=[h;mod(10.*hinv+17,29)]
%% Proof of Lemma 2.2 no fix pts Sbox ABCAES1
% Analytic approach to showing that Sbox has no fixed points.  
% 
% $$a h^{-1} + b =h \iff a+bh=h^2 \iff h^2-bh-a=0 \iff \sqrt{b^2+4a} \in Z_{29}$$
% 
% Matlab has the Jacobi symbol, which returns 1 if something is quadratic residue, 
% and $-1$ if it is not.

a=10;
b=17;
mod(b^2+4*a,29)
jacobiSymbol(b^2+4*a,29)
%% 
% 
%% Example 2.2 MixColumns for ABCAES1

MC=[1 4;4 1]
State=[22 08;16 18]
MC*State
mod(MC*State,29)
%% Key expansion ABCAES1

W0 = [11 05];
W1 = [25 28];
rcon = [9 0];
rotword=[W1(2) W1(1)]
[~,hinv,~]=gcd(rotword,29); 
subrot=mod(10.*hinv+17,29)
W2 = mod(W0+rcon+subrot,29)
W3=mod(W1+W2,29)
rcon = [23 0];
rotword=[W3(2) W3(1)]
[~,hinv,~]=gcd(rotword,29); 
subrot=mod(10.*hinv+17,29)
W4 = mod(W2+rcon+subrot,29)
W5 = mod(W3+W4,29)
K0 = [W0 W1]
K1 = [W2 W3]
K2 = [W4 W5]
%% ABCAES1 two rounds step by step

K0 = [11 25; 5 28];
K1 = [27 23; 5 4];
K2 = [26 20; 1 5];
state = [20 19; 5 20];
state = mod(state+K0,29) % add key
[~,hinv,~]=gcd(state,29); 
state = mod(10.*hinv+17,29)
state = [22 8; 16 18] % manually shift second row
state = [28 22; 17 21] % look up MC results from above
state = mod(state+K1,29)
[~,hinv,~]=gcd(state,29); 
state = mod(10.*hinv+17,29)
state = [4 14; 0 28] % manually apply shift second row
state = mod(state+K2,29)
%% ABCAES1 decryption: Finding Aff inv and MC inv 

a=10;
b=17;
[~,ainv,~]=gcd(10,29)
mod(-ainv*b,29)
MCex = [1 4; 4 1];
[~,detinv,~]=gcd(det(MCex),29)
MCinv=mod(detinv*[1 -4; -4 1],29)
mod(MCex*MCinv,29)
%% Example 5.1 Sbox calculations for ABCAES4
% We do the first polynomial using steps that can be verified by hand

syms x
f= x^4 + 2*x^2 +15*x +2;
a = x^3+2*x^2+3*x+4;
b = 5*x^3+6*x^2+7*x+8;
h = 9*x^3+10*x^2+11*x+12
[~,hinv,~]=gcd(h,f);
hinv=pmod(hinv,29);
aff = expand(a*hinv+b)
aff = pmod(aff,29)
aff = polynomialReduce(aff,x^4+1)
sbox =pmod(aff,29)
%% 
% Now we do all the polynomials at once and combine steps

syms x
f= x^4 + 2*x^2 +15*x +2;
a = x^3+2*x^2+3*x+4;
b = 5*x^3+6*x^2+7*x+8;

h = [9*x^3+10*x^2+11*x+12, 13*x^3+14*x^2+15*x+16,
    10*x^3+20*x^2+26*x+24, 01*x^3+26*x^2+13*x+16,
    21*x^3+10*x^2+12*x+23, 05*x^3+15*x^2+26*x+08,
    22*x^3+15*x^2+01*x+02, 14*x^3+21*x^2+20*x+14,
    02*x^3+01*x^2+23*x+10, 26*x^3+10*x^2+07*x+01,
    04*x^3+27*x^2+22*x+19, 15*x^3+13*x^2+07*x+00];
[~,hinv,~]=gcd(h,f);
hinv=arrayfun(@(h) pmod(h,29),hinv);
aff = a*hinv+b;
aff = arrayfun(@(h) polynomialReduce(h,x^4+1),aff);
Sbox = arrayfun(@(h) pmod(h,29),aff)
%% 
% Next couple lines are for getting just the coefficients of the Sbox calculations.  

hcoeffs = arrayfun(@(h) coeffs(h,'All'),h,'UniformOutput',false);
Sboxcoeffs = arrayfun(@(h) coeffs(h,'All'),Sbox,'UniformOutput',false);
%% 
% Pad any list of coefficients that have fewer than 4 entries 

for n = 1:12
    Sboxcoeffs{n} = [zeros(4-length(Sboxcoeffs{n}),1) Sboxcoeffs{n}];
end
%% 
% Print the coefficients of each $h$, and then the Sbox output, in format ready 
% to be pasted into LaTeX

for n=1:12
   fprintf('%02i%02i%02i%02i & ',double(hcoeffs{n})); 
end
for n=1:12
   fprintf('%02i%02i%02i%02i & ',double(Sboxcoeffs{n})); 
end
%% The BIG calculation: checking ABCAES4 Sbox for fixed points

f = [1 0 2 15 2]; % conway polynomial
a = 1:4; % from the affine map
b= 5:8; % from the affine map
BCwords = fliplr(gftuple([-1:29^4-2]',fliplr(f),29)); 
BCinvs=[BCwords(1:2,:); flipud(BCwords(3:end,:))];
BCsbox = zeros(size(words));
for n = 1:29^4
    ahinv=mod(conv(invs(n,:),a),29); % a*h^{-1}
    [~,ahinv]=deconv(ahinv,[1 0 0 0 1]); % reduce mod x^4+1
    ahinv = ahinv(4:7); 
    BCsbox(n,:)=mod(ahinv+b,29); % add b
end
equalrows = zeros(1,29^4);
for n = 1:29^4 
    equalrows(n)=isequal(BCwords(n,:),BCsbox(n,:)); 
end
idx=find(equalrows==1); 
length(idx) % if this is >0 then we have a fixed point.
%% Double checking the big calculation
% To run this section we need to have first run the previous section to fill 
% "BCwords" and "BCsbox".

%% WARNING this takes about 1.5min to run.
tic
syms x
N = 1e3; % number of calculations we'll double check
idx = randi(29^4-1,1,N)+1;
BC_word_polys = BCwords(idx,:)*[x^3 x^2 x 1].'; % convert some random word inputs to polynomials
BC_sbox_polys = BCsbox(idx,:)*[x^3 x^2 x 1].'; % convert the results of sbox calculations in previous section to polynomials
f= x^4 + 2*x^2 +15*x +2; % start to take random word inputs and symbolically calculate sbox
a = x^3+2*x^2+3*x+4;
b = 5*x^3+6*x^2+7*x+8;
h = BC_word_polys;
[~,hinv,~]=gcd(h,f);
hinv=arrayfun(@(h) pmod(h,29),hinv);
aff = a*hinv+b;
aff = arrayfun(@(h) polynomialReduce(h,x^4+1),aff);
Sbox = arrayfun(@(h) pmod(h,29),aff); % outputs of symbolic sbox calculation
isequal(BC_sbox_polys,Sbox)
idx = randi(N,1,5); % let's look at 5 of them at random
BC_sbox_polys(idx) % the results of the previous section, converted to polynomials
Sbox(idx) % the symbolic double check we've done in this section
toc
%% Example 4.2 ABCAES4 Mix Columns
% We do the calculations step by step so someone can check by hand

syms x
f = x^4+2*x^2+15*x+2;
M = [1 13*x^2; -13*x^2 1];

S = [x^3+03*x^2+22*x+1 x^3+05*x^2+4*x+10;...
    8*x^3+28*x^2+7*x+10 11*x^3+24*x^2+8*x+28];
MixCol = expand(M*S)
MixCol = arrayfun(@(h) pmod(h,29), MixCol)
MixCol = arrayfun(@(h) polynomialReduce(h,f),MixCol)
MixCol = arrayfun(@(h) pmod(h,29), MixCol)
%% 
% Next few lines are to extract the coefficients.

MCcoeffs = arrayfun(@(h) coeffs(h,'All'),MixCol,'UniformOutput',false);
MCcoeffs{1,1}=[0 MCcoeffs{1,1}];
[double(MCcoeffs{1,1}) double(MCcoeffs{1,2}) ;
    double(MCcoeffs{2,1}) double(MCcoeffs{2,2})]
%% Key expansion ABCAES4

W0 = 1:8;
W1 = 9:16;
rcon = [0 0 1 0 zeros(1,4)];
subrot = [0 8 11 8 12 6 20 21]% Look up Sbox of W1(5:8) and W1(1:4) 
W2 = mod(W0+rcon+subrot,29)
W3=mod(W1+W2,29);
rcon = [0 1 0 0 zeros(1,4)];
subrot=[22 7 11 5 22 23 9 24] % Look up Sbox of W3(5:8) and W3(1:4)
W4 = mod(W2+rcon+subrot,29)
W5 = mod(W3+W4,29)
K0 = [W0 W1]
K1 = [W2 W3]
K2 = [W4 W5]
%% ABCAES4 two rounds step by step
% In this section we do the final assembly of parts for the complete encryption.  
% Above we did the Sbox and Mix Column calculations.  We use those here now, but 
% just fill them in by hand as needed.  The rest is key expansion, then adding  
% the keys, and decoding the numbers into letters.  

% we assume W0, W1, W2, W3, W4 and W5 have been calculated above
K0 = [W0(1:4) W1(1:4); 
      W0(5:8) W1(5:8)]
K1 = [W2(1:4) W3(1:4); 
      W2(5:8) W3(5:8)]
K2 = [W4(1:4) W5(1:4); 
      W4(5:8) W5(5:8)]
state = encode("this is message.");
state = [state(1:4) state(9:12);
    state(5:8) state(13:16)]
state = mod(state+K0,29) % add key
state = [1 3 22 1 1 5 4 10;
    11 24 8 28 8 28 7 10] % look up Sbox values from above
state(2,:) = [state(2,5:8) state(2,1:4)] % manually shift second row
state = [0 20 9 27 22 7 26 24;
    9 27 9 1 14 16 23 13]%  look up MC results from above
state = mod(state+K1,29) % add K1
state = [2 17 13 9 11 15 0 28;
    6 3 19 27 26 24 5 17] % look up Sbox results above
state(2,:) = [state(2,5:8) state(2,1:4)] % manually apply shift second row
state = mod(state+K2,29)
state = [state(1,1:4) state(2,1:4) state(1,5:8) state(2,5:8)]
decode(state)
%% ABCAES4 decryption: Finding Aff inv and MC inv

syms x
a = x^3+2*x^2+3*x+4;
b = 5*x^3+6*x^2+7*x+8;
[~,ainv,~]=gcd(a,x^4+1);
ainv = pmod(ainv,29)
pmod(polynomialReduce(-ainv*b,x^4+1),29)
MCmat = [1 13*x^2; -13*x^2 1];
% find the determinant, reduced mod f, and then mod 29
MCdet = pmod(polynomialReduce(det(MCmat),f),29)
% get the inverse, and then reduce again mod 29
[~,detinv,~]=gcd(MCdet,f);
detinv = pmod(detinv,29)
% Multiply the determinant inverse, then reduce mod f and 29
MCinv=arrayfun(@(h) pmod(polynomialReduce(h,f),29),detinv*[1 -13*x^2; 13*x^2 1])
% double check product to get identity
arrayfun(@(h) pmod(polynomialReduce(h,f),29), MCmat*MCinv)
%% ABCAES4 Single Matlab function for Encryption Verbose mode
% This tests the MATLAB functions we have created that create a full encryption 
% in a single function call. 'verbose' mode displays each step of the process. 
% Later we use this function repeatedly to look at confusion and diffusion, etc., 
% but here we show the verbose output.  

ABCstream("this is message.",[1:16],'verbose')
%% ABCAES Single Matlab function for decryption

plaintext="this is message.";
key = 1:16;
cipher = ABCstream(plaintext,key)
ABCinv(cipher,key)
%% Extra examples and observations
% ABCAES4, message = Zs, key = As

key = ones(1,16);
plain = 26*ones(1,16);
decode(plain),decode(key)
ABCstream(plain,key)
% ABCAES4, message = Zs, key = As + 1

key = ones(1,16);key(16)=2;
message = 26*ones(1,16);
decode(message),decode(key)
ABCstream(message,key)
% ABCAES4, message = Zs+1, key = As

key = ones(1,16);
message = 26*ones(1,16);message(16)=25;
decode(message),decode(key)
ABCstream(message,key)
% ABCAES4 with extra MC, message = Zs, message = Zs+1

key = ones(1,16);
message = 26*ones(1,16);
decode(message),decode(key)
ABCstream_extraMC(message,key)
key = ones(1,16);
message = 26*ones(1,16);message(16)=25;
decode(message),decode(key)
ABCstream_extraMC(message,key)
% ABCAES4 with three rounds, message = Zs, message = Zs+1

key = ones(1,16);
message = 26*ones(1,16);
decode(message),decode(key)
ABCstream_r3(message,key)
key = ones(1,16);
message = 26*ones(1,16);message(16)=25;
decode(message),decode(key)
ABCstream_r3(message,key)
% Lee Metric basics

abs_lee([3,16,28,-60]) % the lee absolute value
A = [1,2,3];
B = [1,1,1];
%% WARNING: d_Lee needs inputs that are numbers, not letters
d_lee(A,B)
% Numerical evidence for Lee distances between random elements and vectors
% Distance between two random elements of $Z_{29}$

N = 1e6;
data = zeros(1,N);
for n = 1:N
v = mod(randi(29,1,1),29); 
w = mod(randi(29,1,1),29);
%% WARNING: d_Lee needs inputs that are numbers, not letters
data(n)=d_lee(v,w);
end
mean(data)
%% 
% Distance between two random elements of $Z_{29}^{16}$

N = 1e6;
data = zeros(1,N);
for n = 1:N
v = mod(randi(29,1,16),29); 
w = mod(randi(29,1,16),29);
%% WARNING: d_Lee needs inputs that are numbers, not letters
data(n)=d_lee(v,w);
end
mean(data)
% Average Lee distance for all constant keys and constant plaintext
% This calculates the average Lee distance between a plaintext and the resulting 
% ciphertext, where the plaintext is allowed to vary over all constant messages 
% and the key varies also over all constant keys.  

%%%%%%%%%%% WARNING this takes about 7.5 minutes to run.
results = zeros(29,29);
tic 
for n=  1:29
    for m = 1:29
        key = mod(n*ones(1,16),29);
        plain = mod(m*ones(1,16),29);
        cipher=encode(ABCstream(plain,key)); % encode returns numbers
%% WARNING: d_Lee needs inputs that are numbers, not letters
        results(n,m) = d_lee(cipher,plain);
    end
end
toc
mean(results,'all') 
% Average Lee distance for confusion starting with all constant keys, one fixed plaintext.
% This calculates the average Lee distance between two ciphertexts, which are 
% produced by keys as close together as possible, one key being a constant key, 
% and the plaintext is fixed at Zs. This shows that the amount of confusion created, 
% even with such week keys and plaintext, is optimal.  

%%%%%%%%%%% WARNING this takes about 8 minutes to run.
results = zeros(29,32);
tic 
plain = 26*ones(1,16);
for n=  1:29
    key1 = mod(n*ones(1,16),29);
    cipher1 = encode(ABCstream(plain,key1)); % encode returns numbers
        for m = 1:32
        key2 = key1;
        idx = ceil(m/2);
        key2(idx)=mod(key2(idx)+(-1)^(m+1),29);
        cipher2=encode(ABCstream(plain,key2)); % encode returns numbers
        %% WARNING: d_Lee needs inputs that are numbers, not letters
        results(n,m) = d_lee(cipher1,cipher2);
    end
end
toc
mean(results,'all') 
% Average Lee distance for diffusion starting with all constant plaintext, and using one fixed key.
% This calculates the average Lee distance between two ciphertexts, which are 
% produced by plaintext as close together as possible, one plaintext being a constant 
% set of letters, and with a single key fixed at As. This shows that the amount 
% of diffusion created, even with such week keys and plaintext, is optimal.  

%%%%%%%%%%% WARNING this takes about 8 minutes to run.
results = zeros(29,32);
tic 
key = ones(1,16);
for n=  1:29
    plain1 = mod(n*ones(1,16),29);
    cipher1 = encode(ABCstream(plain1,key)); % encode returns numbers
        for m = 1:32
        plain2 = plain1;
        idx = ceil(m/2);
        plain2(idx)=mod(plain2(idx)+(-1)^(m+1),29);
        cipher2=encode(ABCstream(plain2,key)); % encode returns numbers
        %% WARNING: d_Lee needs inputs that are numbers, not letters
    results(n,m) = d_lee(cipher1,cipher2);
    end
end
toc
mean(results,'all') 

%%
function z = abs_lee(x)
x = mod(x,29);
z = min(x,29-x); % this works for vectors
end

function z = d_lee(x,y)
z = sum(abs_lee(x-y));
end
%% 
%