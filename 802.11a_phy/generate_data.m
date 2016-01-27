%函数generate_data()
%输入参数：1.信息比特流个数inf_bits_length 
%          2.信息比特流数组
%          3.RATE
%输出参数：1.完整的DATA字段数据比特流比特个数
%          2.完整的DATA字段数据比特流数组
function [data_bits_length,data_bits]=generate_data(inf_bits_length,inf_bits,RATE)
	Npad=(4*RATE)*ceil((16+inf_bits_length+6)/(4*RATE))-(16+inf_bits_length+6);%计算data字段填充比特的个数
    data_bits_length=16+inf_bits_length+6+Npad;%计算data字段数据比特流比特个数
    data_bits=zeros(1,data_bits_length);
    for i=(16+1):1:(16+inf_bits_length)  
        data_bits(1,i)=inf_bits(1,(i-16));
    end

