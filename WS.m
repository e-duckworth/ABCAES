function stateout = WS(statein)
% applies sbox to each word in the state, which is 2x2 set of words. Since
% each word is 4 letters, input state is actually 2x8 set of numbers.
stateout=[sbox(statein(1,1:4)) sbox(statein(1,5:8));...
    sbox(statein(2,1:4)) sbox(statein(2,5:8))];
end
