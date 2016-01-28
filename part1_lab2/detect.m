function result = detect(start,last,wave)
% wave是行向量
start_length = length(start);
last_length = length(last);
for i = 1:length(wave)-start_length+1
    temp_start = num2str((wave(i:i+start_length-1))');
    if strcmp(temp_start,start') == 1
        disp('find start!');
        break;
    else
        continue;
    end
end
if i == length(wave)-start_length+ 1
    disp('fail');
    result = 0;
    return;
end

start_position = i+start_length;

for i = start_position+1:length(wave)-start_length+1
    temp_end = num2str((wave(i:i+last_length-1))');
    if strcmp(temp_end,last') == 1
        disp('find end!');
        break;
    else
        continue;
    end
end
last_position = i - 1;

result = wave(start_position:last_position);
start_position
last_position

end