function stateout = MCinv(statein)
% MCinv applies the inverse mix column operation to a state, one column at
% a time. Note that each column of the state consists of 4 numbers, so from
% MATLAB's perspective the state is 2x8.   In other words the first column
% of words is statein(:,1:4) and the second column is statin(:,5:8)

% the actual multiplication is done by MCconv, i.e. convolution.
stateout = [MCconv(statein(:,1:4)) MCconv(statein(:,5:8))];

    function colout = MCconv(colin)
    % this manually recreates matrix multiplication that takes a column
    % [h1;h2] to
    %  [ (3x^3+17x^2+26x+6)h1+(x^3+21x^2+7)*h2;
    %    (28x^3+8x^2+22)h1+(3x^3+17x^2+26x+6)h2-13*x^2*h1+h2]
    % where h1 and h2 are polynomials. We calculate this as 
    % [a*h1+b*h2;
    %  c*h1+d*h2]
    % for appropriate values of a, b, c, d
    a = [3 17 26 6];
    b = [1 21 0 7];
    c = [28 8 0 22];
    d = [3 17 26 6];
    h1 = colin(1,:);
    h2 = colin(2,:);
    f = [1 0 2 15 2];
    % row 1 = mod(a*h1 + b*h2,29) where "*" = conv, followed by deconv,
    % followed by normalizing the length to be 4.  Similarly with row 2.
    [~,ah1] = deconv(conv(a,h1),f);
    ah1=normalize(ah1);
    [~,bh2] = deconv(conv(b,h2),f);
    bh2=normalize(bh2);
    [~,ch1] = deconv(conv(c,h1),f);
    ch1=normalize(ch1);
    [~,dh2] = deconv(conv(d,h2),f);
    dh2=normalize(dh2);
    colout=[mod(ah1+bh2,29); mod(ch1+dh2,29)];
    end

    function y = normalize(x)
    % makes sure x is a vector of length 4.
    if length(x) < 4
        y=[zeros(1,4-length(x)) x];
    elseif length(x) > 4
        y=x(end-3:end);
    end
    end


end

