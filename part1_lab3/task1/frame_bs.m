function frame = frame_bs(bs)
    if length(bs) <= 1280
        frame = zeros(1,length(bs)+2);
        frame(2:length(bs)+1) = bs;
        frame(1) = 1;
        frame(end) = 0;
    else 
        number = ceil(length(bs)/ 1280);
        for i = 1:number
            if i ~= number
                temp = zeros(1,1282);
                temp(2:1281) = bs(1280*(i-1)+1:1280*i);
                temp(1) = 1;
                temp(1282) = 0;
            else
                temp = zeros(1,mod(length(bs),1280)+2);
                temp(2:mod(length(bs),1280)+1) = bs((number-1)*1280:end);
                temp(1) = 1;
                temp(end) = 0;
            end
            frame{i} = temp;
        end
    end
    return frame;
end