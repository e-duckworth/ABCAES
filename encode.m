% convert letters to numbers
function y = encode(x);
        y = lower(x);
        y=double(char(y));
        % delete non-letters
        idxa = y>=97 & y<=122;
        idxpunc = y==32 | y==46 | y==63;
        y(~idxa & ~idxpunc)=[];
        y(y>96)=y(y>96)-96; % 97 = ASCII a
        y(y==32)=0; % ASCII space = 32
        y(y==46)=27; % ASCII period = 46
        y(y==63)=28; % ASCII question mark = 63
end
