function [Modulation,ConvCodeRate,data_symbols_number,data_bits_number]=rx_get_data_parameter(RATE,LENGTH)

if RATE==6;
    ConvCodeRate='R1/2';
    Modulation='BPSK';
elseif RATE==9;
    ConvCodeRate='R3/4';
    Modulation='BPSK';
elseif RATE==12;
    ConvCodeRate='R1/2';
    Modulation='QPSK';
elseif RATE==18;
    ConvCodeRate='R3/4';
    Modulation='QPSK';
elseif RATE==24;
    ConvCodeRate='R1/2';
    Modulation='16QAM';
elseif RATE==36;
    ConvCodeRate='R3/4';
    Modulation='16QAM';
elseif RATE==48;
    ConvCodeRate='R2/3';
    Modulation='64QAM';
elseif RATE==54;
    ConvCodeRate='R3/4';
    Modulation='64QAM';
end
    data_bits_number=LENGTH*8;
    data_symbols_number=ceil(data_bits_number/(4*RATE));
    if RATE==6
        data_symbols_number=data_symbols_number+1;
    else
        data_symbols_number=data_symbols_number;
end