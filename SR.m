function stateout = SR(statein)
% SR applies the "ShiftRow" operation to a state.  The state consists of
% 2x2 array of words, but since each word is 4 numbers the state is a 2x8
% array of numbers.
stateout=[statein(1,1:4) statein(1,5:8);...
    statein(2,5:8) statein(2,1:4)];
end