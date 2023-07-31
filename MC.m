function stateout = MC(statein,verbose)
% MC applies the mix column operation to a state, one column at a time.
% This operation can be described using a linear map over a polynomial
% ring. Matlab can do this as a matrix operation if you are using matrices
% of symbolic polynomials.  Otherwise we have to deconstruct matrix
% multiplication where the underlying ring operations are defined using
% convolution.
% 
% note that "column" in the state sense is words, so in the matrix sense
% it's the first 4 columns and the last 4 columns.  In other words the
% first column of words is statein(:,1:4).  

% set flag for verbose mode
if nargin < 2
    debug = false;
elseif strcmp(verbose,'verbose')
    debug = true;
else 
    error('Second argument unrecognized, can only be "verbose".')
end

if debug
    disp('First column of words, input = [h1;h2]')
    stateout(:,1:4) = MCconv(statein(:,1:4));
    disp('2nd column of words')
    stateout(:,5:8) = MCconv(statein(:,5:8));
else
    stateout = [MCconv(statein(:,1:4)) MCconv(statein(:,5:8))];
end

function colout = MCconv(colin)
% this manually recreates matrix multiplication that takes a column [h1;h2]
% to [h1+13*x^2*h2; -13*x^2*h1+h2] where h1 and h2 are polynomials. 
if debug
disp('Row 1')
disp('multiply 13*x^2*h2'), row1=conv(13*[0 1 0 0],colin(2,:))
disp('reduce this modulo x^4+2x^2+15x+2'),[~,row1]=deconv(row1,[1 0 2 15 2])
else
    [~,row1] = deconv(conv(13*[0 1 0 0],colin(2,:)),[1 0 2 15 2]);
end

if length(row1) < 4
    row1=[zeros(1,4-length(row1)) row1];
elseif length(row1) > 4
    row1=row1(end-3:end);
end
if debug,disp('normalize length of 13*x^2*h2'),row1,end


row1=mod(colin(1,:)+row1,29);
if debug, disp('add h1, and reduce mod 29'),row1,end

if debug
disp('Row 2 of output (in one column)')
disp('multiply -13*x^2*h1'), row2=conv(-13*[0 1 0 0],colin(1,:))
disp('reduce this modulo x^4+2x^2+15x+2'),[~,row2]=deconv(row2,[1 0 2 15 2])
else
[~,row2] = deconv(conv(-13*[0 1 0 0],colin(1,:)),[1 0 2 15 2]);
end

if debug,disp('normalize length of -13*x^2*h1'),end

if length(row2) < 4
    row2=[zeros(1,4-length(row2)) row2];
elseif length(row2) > 4
    row2=row2(end-3:end);
end
row2=mod(colin(2,:)+row2,29);
if debug,disp('add h2, and reduce mod 29'),row2,end
colout=[row1; row2];
if debug,disp('final result for this column'),colout,end
end
end

