% convert numbers to letters
function y = decode(x);
        y = x+64; % 65 = ASCII A
        y (y==28+64) = 63; % set ASCII question mark
        y (y==27+64) = 46; % set ASCII period
        y (y==64) = 32; % set ASCII space
        y=char(y);
end
