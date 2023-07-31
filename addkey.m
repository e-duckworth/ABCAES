function stateout = addkey(statein,subkey)
% ADDKEY takes as input a state, i.e. an array of 2 x 2 words.  Each word
% is 4 letters so it actually takes a 2x8  matrix, and interprets it as a
% state.
if length(subkey)==16
    subkey = [subkey(1:4) subkey(9:12); subkey(5:8) subkey(13:16)];
end
stateout = mod(statein+subkey,29);
end