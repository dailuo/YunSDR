%����generate_data()
%���������1.��Ϣ����������inf_bits_length 
%          2.��Ϣ����������
%          3.RATE
%���������1.������DATA�ֶ����ݱ��������ظ���
%          2.������DATA�ֶ����ݱ���������
function [data_bits_length,data_bits]=generate_data(inf_bits_length,inf_bits,RATE)
	Npad=(4*RATE)*ceil((16+inf_bits_length+6)/(4*RATE))-(16+inf_bits_length+6);%����data�ֶ������صĸ���
    data_bits_length=16+inf_bits_length+6+Npad;%����data�ֶ����ݱ��������ظ���
    data_bits=zeros(1,data_bits_length);
    for i=(16+1):1:(16+inf_bits_length)  
        data_bits(1,i)=inf_bits(1,(i-16));
    end

