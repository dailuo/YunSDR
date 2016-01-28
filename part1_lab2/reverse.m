function result = reverse(data)
datah = data(2:2:end);
datal = data(1:2:end);
datah_hex = dec2hex(datah,2);
datal_hex = dec2hex(datal,2);
data_hex(:,1:2) = datah_hex;
data_hex(:,3:4) = datal_hex;
dataun = hex2dec(data_hex);
result = dataun;
end