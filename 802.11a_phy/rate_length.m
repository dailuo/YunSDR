function [data_rate,data_length,signal_error]=rate_length(signal)
ecc=signal(1);
signal_error=0;
data_rate=6;
data_length=0;
for i=2:17
    ecc=xor(ecc,signal(i));
end
if(signal(18)==ecc)
  rate=signal(1:4);
  if (rate(1)==1 && rate(2)==1 && rate(3)==0 && rate(4)==1)
      data_rate=6; 
  elseif (rate(1)==1 && rate(2)==1 && rate(3)==1 && rate(4)==1)
      data_rate=9;
  elseif (rate(1)==0 && rate(2)==1 && rate(3)==0 && rate(4)==1)
      data_rate=12;
  elseif (rate(1)==0 && rate(2)==1 && rate(3)==1 && rate(4)==1)
      data_rate=18;
  elseif (rate(1)==1 && rate(2)==0 && rate(3)==0 && rate(4)==1)
      data_rate=24;
  elseif (rate(1)==1 && rate(2)==0 && rate(3)==1 && rate(4)==1)
      data_rate=36;
  elseif (rate(1)==0 && rate(2)==0 && rate(3)==0 && rate(4)==1)
      data_rate=48;
  elseif (rate(1)==0 && rate(2)==0 && rate(3)==1 && rate(4)==1)
      data_rate=54;
  else
      disp('Error data_rate');
      signal_error=1;
  end
  datalength=signal(6:17);
  for i=1:length(datalength)
      data_length=data_length+2^(i-1)*datalength(i);
  end
else
    disp('Error signal');
    signal_error=1;
end

    