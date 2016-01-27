function varargout = YunSDR_transceiver(varargin)
% YUNSDR_TRANSCEIVER MATLAB code for YunSDR_transceiver.fig
%      YUNSDR_TRANSCEIVER, by itself, creates a new YUNSDR_TRANSCEIVER or raises the existing
%      singleton*.
%
%      H = YUNSDR_TRANSCEIVER returns the handle to a new YUNSDR_TRANSCEIVER or the handle to
%      the existing singleton*.
%
%      YUNSDR_TRANSCEIVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in YUNSDR_TRANSCEIVER.M with the given input arguments.
%
%      YUNSDR_TRANSCEIVER('Property','Value',...) creates a new YUNSDR_TRANSCEIVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before YunSDR_transceiver_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to YunSDR_transceiver_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help YunSDR_transceiver

% Last Modified by GUIDE v2.5 12-Feb-2015 11:26:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @YunSDR_transceiver_OpeningFcn, ...
    'gui_OutputFcn',  @YunSDR_transceiver_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before YunSDR_transceiver is made visible.
function YunSDR_transceiver_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to YunSDR_transceiver (see VARARGIN)

% Choose default command line output for YunSDR_transceiver
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes YunSDR_transceiver wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global rx_signal;
global data_link;
global ctrl_link;
global C;
global F;
global filename;
global pathname;
global flag;
global plot_flag;
global tx_signal1;
flag=0;

im=imread('QPSK_b.jpg');
axes(handles.axes1);
imshow(im);
set(handles.code_rate,'string','R1/2');
set(handles.speed,'string',12);

set(handles.only_tx,'Value',1);
set(handles.only_rx,'Value',1);


% --- Outputs from this function are returned to the command line.
function varargout = YunSDR_transceiver_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in rx_operator.
function rx_operator_Callback(hObject, eventdata, handles)
% hObject    handle to rx_operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.connect,'Enable','off');
set(handles.disconnect,'Enable','on');
global rx_signal;
global data_link;
global ctrl_link;
global C;
global F;
global flag;
global filename;
global pathname;
sim_consts = set_sim_consts;
cyc=1;err_cyc=0;
while (1)
    if C==1
        
        %         out_net=get(handles.checkbox3,'Value');
        %         if out_net==1
        %             if rx_chan==1
        %                 a2=datain(1:4:end);
        %                 a1=datain(2:4:end);
        %             elseif rx_chan==2
        %                 a4=datain(3:4:end);
        %                 a3=datain(4:4:end);
        %             end
        %         else
        %             if rx_chan==1
        %                 a1=datain(1:4:end);
        %                 a2=datain(2:4:end);
        %             elseif rx_chan==2
        %                 a3=datain(3:4:end);
        %                 a4=datain(4:4:end);
        %             end
        %         end
        %%
        Chan=get(handles.popupmenu3,'string');
        value=get(handles.popupmenu3,'Value');
        chan_c = Chan{value} ;
        if strcmp(chan_c,'Channel 1')==1
            rx_chan=1;
        elseif strcmp(chan_c,'Channel 2')==1
            rx_chan=2;
        end
        %% read data from host
        buff_size=32;
        %% send handshake2 cmd to start adc thread(通知PS要采集的数据量并开始采集)
        size_hex=dec2hex(buff_size*1024,8);
        handshake=[2 1 hex2dec('17') hex2dec('f0') hex2dec(size_hex(7:8)) hex2dec(size_hex(5:6)) hex2dec(size_hex(3:4)) hex2dec(size_hex(1:2))];
        fwrite(ctrl_link,handshake,'uint8');
        
        data = fread(data_link,buff_size*1024,'uint8');
        %% receive
        datah=data(2:2:end);
        datal=data(1:2:end);
        datah_hex=dec2hex(datah,2);
        datal_hex=dec2hex(datal,2);
        data_hex(:,1:2)=datah_hex;
        data_hex(:,3:4)=datal_hex;
        dataun=hex2dec(data_hex);
        datain=dataun-(dataun>32767)*65536;
        if rx_chan==1
            a1=datain(1:2:end);
            a2=datain(2:2:end);
            a3=zeros(1,length(a1));
            a4=zeros(1,length(a1));
        elseif rx_chan==2
            a3=datain(1:2:end);
            a4=datain(2:2:end);
            a1=zeros(1,length(a3));
            a2=zeros(1,length(a3));
        elseif rx_chan==3
            a1=datain(1:4:end);
            a2=datain(2:4:end);
            a3=datain(3:4:end);
            a4=datain(4:4:end);
        end
        if rx_chan==1
            rx_signal_40m=(a1+1i*a2);
        elseif rx_chan==2
            rx_signal_40m=(a3+1i*a4);
        end
        rx_signal=rx_signal_40m(1:2:end).';
    end
    if F==1
        dmp=strfind(filename,'.dmp');
        prn=strfind(filename,'.prn');
        if dmp > 1
            fpath=[pathname filename];
            fid1=fopen(fpath,'r');
            data=fread(fid1,'int16');
            fclose('all');
            datadmp=reshape(data,64,length(data)/64);
            datao=datadmp(9:64,:);
            dataos=datao(:);
            out_dmp=get(handles.checkbox3,'Value');
            if out_dmp==1
                a2=dataos(1:2:end/16);
                a1=dataos(2:2:end/16);
            else
                a1=dataos(1:2:end/16);
                a2=dataos(2:2:end/16);
            end
            rx_singal_40m=(a1+1i*a2);
            rx_signal =rx_singal_40m(1:2:end).';
        elseif prn > 1
            fpath=[pathname filename];
            [a1,a2,a3,a4]=textread(fpath,'%f%f%f%f','headerlines',1);
            mean(a3);
            mean(a4);
            out_prn=get(handles.checkbox3,'Value');
            if out_prn==1
                rx_signal_40m =a3+1i*a4;
            else
                rx_signal_40m =a4+1i*a3;
            end
            rx_signal=rx_signal_40m(1:2:end).';
        else
            fpath=[pathname filename];
            fpath=[pathname filename];
            fid1=fopen(fpath,'r');
            A=fread(fid1,'int16');
            fclose('all');
            out=get(handles.checkbox3,'Value');
            if out==1
                a2=A(1:2:end);
                a1=A(2:2:end);
            else
                a1=A(1:2:end);
                a2=A(2:2:end);
            end
            rx_signal_40m =a1+1i*a2;
            rx_signal=rx_signal_40m(1:2:end).';
            rx_signal=[zeros(1,100) rx_signal zeros(1,100) ];
        end
    end
    %% plot pwelch
    zoom on;
    rx1=get(handles.only_rx,'Value');
    tx1=get(handles.only_tx,'Value');
    if rx1==1 &&tx1==1
        axes(handles.axes11);
        plot(abs(rx_signal(1:end)));
        set(handles.axes11,'XGrid','on');
    end
    axes(handles.axes9);
    plot(abs(rx_signal(1:end)));
    set(handles.axes9,'XGrid','on');
    title('原始信号时域波形');
    axes(handles.axes3);
    % cla(handles.axes2);
    pwelch(rx_signal,[],[],512,20e6,'centered','psd');
    grid on;
    title('原始信号功率谱密度');
    %% packet search
    thres_idx = rx_find_packet_edge_lc4(rx_signal);
    if thres_idx>length(rx_signal)-500
        err_cyc=err_cyc+1;
        continue;
    end
    rx_signal_coarse_sync = rx_signal(thres_idx:end);
    axes(handles.axes4);
    % cla(handles.axes3);
    plot(abs(rx_signal_coarse_sync(1:220)));
    set(handles.axes4,'XGrid','on');
    title('粗同步能量检测');
    %% short Frequency error estimation and correction
    [rx_signal_coarse, freq_est_short] = rx_frequency_sync_short(rx_signal_coarse_sync);
    %% Fine time synchronization
    thres_idx_fine = rx_fine_time_sync_long(rx_signal_coarse);
    rx_signal_fine_sync = rx_signal_coarse(thres_idx_fine+32:end);
    % % %     axes(handles.axes5);
    % % %     % cla(handles.axes4);
    % % %     plot(abs(rx_signal_fine_sync(1:320)));
    % % %     title('精同步信号时域波形');
    %% Frequency error estimation and correction
    [rx_signal_fine, freq_est] = rx_frequency_sync(rx_signal_fine_sync);
    %% Return to frequency domain
    [freq_tr_syms,  freq_data] = rx_timed_to_freqd(rx_signal_fine);
    %% Channel estimation
    channel_est = rx_estimate_channel(freq_tr_syms);
    axes(handles.axes6);
    plot(abs(channel_est));
    set(handles.axes6,'XGrid','on');
    title('信道估计图');
    channel_est_data=repmat(channel_est,1,size(freq_data,2));
    freq_data=freq_data.*conj(channel_est_data)./(abs(channel_est_data).^2);
    freq_data_syms=freq_data(sim_consts.DataSubcIdx,:);
    freq_pilot_syms=freq_data(sim_consts.PilotSubcIdx,:);
    %% Phase tracker, returns phase error corrected symbols
    correction_phases = rx_pilot_phase_est(freq_data_syms,freq_pilot_syms);
    freq_data_syms = conj(correction_phases)./abs(correction_phases).*freq_data_syms;%exp(-j*correction_phases)
    % freq_data_syms = freq_data_syms;
    %% OFDM按照48个分组，第一组SIGNAL,其他是DATA
    %% signal
    %get the signal part
    freq_signal_syms=freq_data_syms(:,1);
    % Demodulate
    [signal_soft_bits,evm_signal]=rx_demodulate(freq_signal_syms,'BPSK');
    % Deinterleave
    signal_deint_bits = rx_deinterleave(signal_soft_bits,'BPSK');
    % depuncture
    signal_depunc_bits = rx_depuncture(signal_deint_bits,'R1/2');
    % Vitervi decoding
    signal_bits = rx_viterbi_decode(signal_depunc_bits,'R1/2');
    %get RATE and LENGTH from signal_bits
    [RATE,LENGTH,signal_error]=rate_length(signal_bits);
    if signal_error==1
        err_cyc=err_cyc+1;
        continue;
    end
    %get data parameters
    [Modulation,ConvCodeRate,data_symbols_number,data_bits_number]=rx_get_data_parameter(RATE,LENGTH);
    if data_symbols_number>size(correction_phases,2)
        err_cyc=err_cyc+1;
        continue;
    end
    % % % %     axes(handles.axes7);
    % % % %     % cla(handles.axes6);
    % % % %     plot(angle(correction_phases(1,1:data_symbols_number))*180/pi);
    % % % %     title('相位校正');
    %% data
    axes(handles.axes8);
    freq_signal_ser=reshape(freq_data_syms(:,1),48,1);
    plot(real(freq_signal_ser),imag(freq_signal_ser),'*r');
    axis([-2,2,-2,2]);
    hold on;
    %get the data part
    freq_data_syms_ser=reshape(freq_data_syms(:,2:1+data_symbols_number),48*data_symbols_number,1);
    cla(handles.axes8);
    plot(real(freq_data_syms_ser),imag(freq_data_syms_ser),'.');
    axis([-1.5,1.5,-1.5,1.5]);
    title('相位补偿后星座图');
    % Demodulate
    [data_soft_bits,evm_data] =rx_demodulate(freq_data_syms_ser,Modulation);
    % Deinterleave
    data_deint_bits = rx_deinterleave(data_soft_bits,Modulation);
    % depuncture
    data_depunc_bits = rx_depuncture(data_deint_bits,ConvCodeRate);
    % Viterbi decoding
    data_descramble_bits = rx_viterbi_decode(data_depunc_bits,ConvCodeRate);
    %desramble
    data_bits=rx_descramble(data_descramble_bits);
    %get inf_bits
    if data_bits_number>=length(data_bits)
        err_cyc=err_cyc+1;
        continue;
    end
    inf_bits=data_bits(16+1:16+data_bits_number);
    %use crc to detect the "receiving" inf_bits
    ret=rx_crc32(inf_bits(1:length(inf_bits)-32)).';
    crc_bits=inf_bits(length(inf_bits)-31:length(inf_bits));
    crc_outputs=sum(xor(ret,crc_bits),2);
    if crc_outputs==0
        crc_ok='YES';
    else
        crc_ok='NO';
    end
    [uV sV] = memory;
    mem=round(uV.MemUsedMATLAB/2^20);
    
    str1 = '粗同步检测';
    str2 = '频 偏 估 计';
    str3 = '精同步检测';
    str4 = '码  速  率';
    str5 = '调 制 方 式';
    str6 = 'FEC 码 率';
    str7 = '数据长度';
    str8 = 'CRC校验';
    str9 = '信号域EVM';
    str10 = '数据域EVM';
    set(handles.text17,'string',str1);
    set(handles.text18,'string',str2);
    set(handles.text19,'string',str3);
    set(handles.text20,'string',str4);
    set(handles.text21,'string',str5);
    set(handles.text22,'string',str6);
    set(handles.text23,'string',str7);
    set(handles.text24,'string',str8);
    set(handles.text25,'string',str9);
    set(handles.text26,'string',str10);
    
    set(handles.text36,'string',num2str(thres_idx));
    set(handles.text27,'string',[num2str((freq_est+freq_est_short)/1e3,3),'KHz']);
    set(handles.text28,'string',num2str(thres_idx_fine));
    set(handles.text29,'string',[num2str(RATE),'Mbps']);
    set(handles.text30,'string',Modulation);
    set(handles.text31,'string',ConvCodeRate);
    %     set(handles.text32,'string',[num2str(LENGTH),'byte ,' ,num2str(data_symbols_number),'ofdms']);
    set(handles.text32,'string',[num2str(LENGTH),'byte']);
    set(handles.text33,'string',crc_ok);
    set(handles.text34,'string',[num2str(evm_signal*100,2),'%,',num2str(20*log10(evm_signal),3),'dB']);
    set(handles.text35,'string',[num2str(evm_data*100,2),'%,',num2str(20*log10(evm_data),3),'dB']);
    %     set(handles.text16,'string',['cyc=',num2str(cyc),';err=',num2str(err_cyc),';mem=',num2str(mem),'MB']);
    cyc=cyc+1;
    F=0;
    if F||flag==1
        set(handles.connect,'Enable','on');
        break;
    end
end


% --- Executes on button press in connect.
function connect_Callback(hObject, eventdata, handles)
% hObject    handle to connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_link;
global ctrl_link;
global C;
global F;
global plot_flag;
global tx_signal1;
plot_flag = 1;
C=1;
F=0;
tx=get(handles.only_tx,'Value');
rx=get(handles.only_rx,'Value');
if tx==1 && rx==0
    tx_operator_Callback(hObject, eventdata, handles);
    set(handles.connect,'Enable','on');
    axes(handles.axes11);
    pwelch(tx_signal1,[],[],512,20e6,'centered','psd');
elseif rx==1 && tx==0
    %% open control port
    ctrl_link = udp('192.168.1.10', 5006);
    fopen(ctrl_link);
    %% open data port
    data_link = tcpip('192.168.1.10', 5004);
    set(data_link,'InputBufferSize',256*1024);
    set(data_link,'OutputBufferSize',16*1024);
    fopen(data_link);
    %% rx bandwidth rate
    bw_hex=dec2hex(10e6,8);
    bw=[0 19 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
    fwrite(ctrl_link,bw,'uint8');
    %% rx samp rate
    samp_hex=dec2hex(10e6,8);
    samp=[0 17 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
    fwrite(ctrl_link,samp,'uint8');
    %% send rx freq
    freq_str=get(handles.rx_freq,'string');
    freq=str2num(freq_str);
    freq=freq*1000000;
    freq_hex=dec2hex(freq,8);
    rx_freq=[0 15 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4)) hex2dec(freq_hex(1:2))];
    fwrite(ctrl_link,rx_freq,'uint8');
    %% agc mode
    agc_mode=[0 21 hex2dec('22') hex2dec('f0') 0 0 0 0];  %定义RX1的增益控制模式 0-MGC 1-FGC 2-SGC
    fwrite(ctrl_link,agc_mode,'uint8');
    agc_mode=[0 23 hex2dec('22') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,agc_mode,'uint8');
    %% send rx vga
    gain_str=get(handles.rx_gain,'string');
    gain_dec=str2num(gain_str);
    rx_vga=[0 25 hex2dec('22') hex2dec('f0') gain_dec 0 0 0];
    fwrite(ctrl_link,rx_vga,'uint8');
    rx_vga=[0 27 hex2dec('22') hex2dec('f0') gain_dec 0 0 0];
    fwrite(ctrl_link,rx_vga,'uint8');
    %% send rx channel set cmd
    Chan=get(handles.popupmenu3,'string');
    value=get(handles.popupmenu3,'Value');
    chan_c = Chan{value} ;
    if strcmp(chan_c,'Channel 1')==1
        rx_chan=1;
    elseif strcmp(chan_c,'Channel 2')==1
        rx_chan=2;
    end
    channel=[rx_chan 0 hex2dec('21') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,channel,'uint8');
    %% send handshake cmd(通知PS启动matlab工作模式)
    handshake=[2 1 hex2dec('16') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,handshake,'uint8');
    pause(0.5);
    rx_operator_Callback(hObject, eventdata, handles);
    C=0;
elseif tx==1 && rx==1
    tx_operator_Callback(hObject, eventdata, handles);
    %% open control port
    ctrl_link = udp('192.168.1.10', 5006);
    fopen(ctrl_link);
    %% open data port
    data_link = tcpip('192.168.1.10', 5004);
    set(data_link,'InputBufferSize',256*1024);
    set(data_link,'OutputBufferSize',16*1024);
    fopen(data_link);
    %% rx bandwidth rate
    bw_hex=dec2hex(10e6,8);
    bw=[0 19 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
    fwrite(ctrl_link,bw,'uint8');
    %% rx samp rate
    samp_hex=dec2hex(10e6,8);
    samp=[0 17 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
    fwrite(ctrl_link,samp,'uint8');
    %% send rx freq
    freq_str=get(handles.rx_freq,'string');
    freq=str2num(freq_str);
    freq=freq*1000000;
    freq_hex=dec2hex(freq,8);
    rx_freq=[0 15 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4)) hex2dec(freq_hex(1:2))];
    fwrite(ctrl_link,rx_freq,'uint8');
    %% agc mode
    agc_mode=[0 21 hex2dec('22') hex2dec('f0') 0 0 0 0];  %定义RX1的增益控制模式 0-MGC 1-FGC 2-SGC
    fwrite(ctrl_link,agc_mode,'uint8');
    agc_mode=[0 23 hex2dec('22') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,agc_mode,'uint8');
    %% send rx vga
    gain_str=get(handles.rx_gain,'string');
    gain_dec=str2num(gain_str);
    rx_vga=[0 25 hex2dec('22') hex2dec('f0') gain_dec 0 0 0];
    fwrite(ctrl_link,rx_vga,'uint8');
    rx_vga=[0 27 hex2dec('22') hex2dec('f0') gain_dec 0 0 0];
    fwrite(ctrl_link,rx_vga,'uint8');
    %% send rx channel set cmd
    Chan=get(handles.popupmenu3,'string');
    value=get(handles.popupmenu3,'Value');
    chan_c = Chan{value} ;
    if strcmp(chan_c,'Channel 1')==1
        rx_chan=1;
    elseif strcmp(chan_c,'Channel 2')==1
        rx_chan=2;
    end
    channel=[rx_chan 0 hex2dec('21') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,channel,'uint8');
    %% send handshake cmd(通知PS启动matlab工作模式)
    handshake=[2 1 hex2dec('16') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,handshake,'uint8');
    pause(0.5);
    rx_operator_Callback(hObject, eventdata, handles);
    C=0;
end

% --- Executes on button press in disconnect.
function disconnect_Callback(hObject, eventdata, handles)
% hObject    handle to disconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_link;
global ctrl_link;
global plot_flag;
plot_flag=0;
%% send handshake2 cmd to stop adc thread (用以结束采集线程，不发送此条命令，下次程序会执行不成功)
handshake=[hex2dec('ff') 1 hex2dec('17') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,handshake,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;

fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;
set(handles.connect,'Enable','on');
set(handles.disconnect,'Enable','off');

% --- Executes on button press in tx_operator.
function tx_operator_Callback(hObject, eventdata, handles)
% global tx_signal1;
global ctrl_link;
global data_link;
global tx_signal1;
% -------------------------------------------------------------------%
sim_consts = tx_set_sim_consts;
val_str=get(handles.data_length,'string');
val=str2num(val_str);
sim_options.PacketLength=val;
sim_options.InterleaveBits=1;
sim_options.UseTxDiv=0;
sim_options.UsePhaseNoise=0;
sim_options.UseTxPA=0;
sim_options.TxPowerSpectrum=0;
sim_options.UseRxDiv=0;
sim_options.ExpDecayTrms=50;
sim_options.ChannelModel='ExponentialDecay';
signal_options.Modulation='BPSK';
signal_options.UseTxDiv=0;
rate_str=get(handles.mod_style,'string');
va=get(handles.mod_style,'Value');
mode = rate_str{va} ;
sim_options.Modulation = mode;
sim_options.upsample=2;
if  strcmp(sim_options.Modulation,'BPSK')==1;
    sim_options.ConvCodeRate='R1/2';
    sim_options.rate = 6;
elseif  strcmp(sim_options.Modulation,'QPSK')==1;
    sim_options.ConvCodeRate='R1/2';
    sim_options.rate = 12;
elseif strcmp(sim_options.Modulation,'16QAM')==1;
    sim_options.ConvCodeRate='R1/2';
    sim_options.rate = 24;
elseif strcmp(sim_options.Modulation,'64QAM')==1;
    sim_options.ConvCodeRate='R2/3';
    sim_options.rate = 48;
end

%--------------------------------------------------------------------%

%% data generation
[inf_bits_length,inf_bits]=prbs15_lc(sim_options.PacketLength);
[data_bits_length,data_bits]=generate_data(inf_bits_length,inf_bits,sim_options.rate);
%% scramble
scramble_bits=scramble_lc(data_bits_length,data_bits,sim_options);
%% rs coding and punc
coded_bit_stream = tx_conv_encoder(scramble_bits);
tx_bits = tx_puncture(coded_bit_stream(1:length(scramble_bits)*2), sim_options.ConvCodeRate);
rdy_to_mod_bits =tx_bits;
%% interleave
if sim_options.InterleaveBits == 1
    rdy_to_mod_bits = tx_interleaver(rdy_to_mod_bits, sim_options);
end
%% Modulate
mod_syms = tx_modulate(rdy_to_mod_bits, sim_options.Modulation);
%% Transmit diversity
mod_syms = tx_diversity(mod_syms, sim_options);
%% Add pilot symbols
if ~sim_options.UseTxDiv
    mod_ofdm_syms = tx_add_pilot_syms(mod_syms, sim_options);
else
    mod_ofdm_syms(1,:) = tx_add_pilot_syms(mod_syms(1,:), sim_options);
    mod_ofdm_syms(2,:) = tx_add_pilot_syms(mod_syms(2,:), sim_options);
end
%% Tx symbols to time domain
[time_syms,mod_data] = tx_freqd_to_timed(mod_ofdm_syms,sim_options.upsample);
time_syms=round(time_syms.*2^7);
%% Add cyclic prefix
time_signal = tx_add_cyclic_prefix(time_syms,sim_options.upsample);
%% Construction of the preamble
preamble = tx_gen_preamble(sim_options);
preamble16=round(preamble.*2^17);
%% signal generate
mysignal=signal(sim_options);
mysignala=tx_conv_encoder(mysignal);
mysignalb=mysignala(1:length(mysignal)*2);
mysignalc=tx_interleaver(mysignalb,signal_options);
mysignald=tx_modulate(mysignalc,signal_options.Modulation);
mysignale=tx_diversity(mysignald, sim_options);
mysignalf=tx_add_pilot_syms(mysignale, sim_options);
[mysignalg,mod_signal]=tx_freqd_to_timed(mysignalf,sim_options.upsample);
mysignalg=round(mysignalg.*2^7);
mysignalh=tx_add_cyclic_prefix(mysignalg,sim_options.upsample);
%% joint frame
tx_signal1=[preamble16 mysignalh time_signal];
value=get(handles.popupmenu2,'Value');
if value==1
    tx_chan=1;
elseif value==2
    tx_chan=2;
end
%% copy to 2chanel
if tx_chan==1 || tx_chan==2
    txdata2=tx_signal1;
elseif tx_chan==3
    txdata2=zeros(1,length(tx_signal1)*2);
    txdata2(1:2:end)=tx_signal1;
    txdata2(2:2:end)=tx_signal1;
end
%% iq mux
txdatas=zeros(1,length(txdata2)*2);
txdatas(1:2:end)=real(txdata2);
txdatas(2:2:end)=imag(txdata2);
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end
txdata1=[txdatas zeros(1,rem)];
txd1=(txdata1<0)*65536+txdata1;
txd2=dec2hex(txd1,4);
txd3=txd2(:,1:2);
txd4=txd2(:,3:4);
txd5=hex2dec(txd3);
txd6=hex2dec(txd4);
txd7=zeros(length(txd6)*2,1);
txd7(1:2:end)=txd6;
txd7(2:2:end)=txd5;
%%
check1=get(handles.checkbox1,'Value');
check2=get(handles.checkbox2,'Value');
if check1==1||check2==1
    tx_signal1=[zeros(1,2000) tx_signal1 zeros(1,2000) tx_signal1 zeros(1,2000)];
    %% add path
    if check1==1
        r=3;%多径数
        a=[0.1 0.2 0.3];%多径的幅度
        d=[10 20 30];%各径的延迟
        rx1=tx_signal1;
        channel1=zeros(1,length(rx1));
        channel1(1+d(1):end)=a(1)*rx1(1:end-d(1));
        channel2=zeros(1,length(rx1));
        channel2(1+d(2):end)=a(2)*rx1(1:end-d(2));
        channel3=zeros(1,length(rx1));
        channel3(1+d(3):end)=a(3)*rx1(1:end-d(3));
        tx_signal1=rx1+channel1+channel2+channel3;
        tx_signal1=tx_signal1.*1;
    end
    %% add noise
    if check2==1
        nos_str=get(handles.noise,'string');
        nos=str2num(nos_str);
        tx_signal1=awgn(tx_signal1,nos,'measured');
        axes(handles.axes1);
        pwelch(tx_signal1(1,:),[],[],[],20e6*sim_options.upsample,'centered','psd');
    end
else
    %%
    ctrl_link = udp('192.168.1.10', 5006);
    fopen(ctrl_link);
    
    ip=get(handles.ip,'string');
    port_str=get(handles.port,'string');
    port=str2num(port_str);
    data_link = tcpip(ip, port);
    set(data_link,'InputBufferSize',16*1024);
    set(data_link,'OutputBufferSize',64*1024);
    fopen(data_link);
    
%     ref_hex=dec2hex(1,8);
%     vco_cal_hex=dec2hex(1,8);
%     aux_dac1_hex=dec2hex(0,8);
%     fdd_tdd_hex=dec2hex(1,8);
    trx_sw_hex=dec2hex(1,8);
    
    aux_dac1=get(handles.edit22,'string');
    aux_dac1_val=str2num(aux_dac1);
    aux_dac1_hex=dec2hex(aux_dac1_val,8);
    
    pop_str=get(handles.reference,'string');
    va=get(handles.reference,'Value');
    refe = pop_str{va} ;
    if  strcmp(refe,'external')==1
        ref_hex=dec2hex(1,8);
    elseif strcmp(refe,'internal')==1
        ref_hex=dec2hex(0,8);
    end
    
    pop_str=get(handles.tdd_fdd,'string');
    va=get(handles.tdd_fdd,'Value');
    refe = pop_str{va} ;
    if  strcmp(refe,'FDD')==1
        fdd_tdd_hex=dec2hex(1,8);
    elseif strcmp(refe,'TDD')==1
        fdd_tdd_hex=dec2hex(0,8);
    end
    
    pop_str=get(handles.popupmenu7,'string');
    va=get(handles.popupmenu7,'Value');
    refe = pop_str{va} ;
    if  strcmp(refe,'AUXDAC1')==1
         vco_cal_hex=dec2hex(1,8);
    elseif strcmp(refe,'ADF4001')==1
         vco_cal_hex=dec2hex(0,8);
    end
    %% tx bandwidth rate
    bw_hex=dec2hex(10e6,8);
    bw=[0 7 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
    fwrite(ctrl_link,bw,'uint8');
    %% tx samp rate                %配置采样率
    samp_hex=dec2hex(10e6,8);
    samp=[0 5 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
    fwrite(ctrl_link,samp,'uint8');
    %% send tx freq set cmd        %配置频点
    freq_str=get(handles.FREQ,'string');
    freq=str2num(freq_str);
    freq=freq*1000000;
    freq_hex=dec2hex(freq,8); %%for ad9361
    tx_freq=[0 3 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4)) hex2dec(freq_hex(1:2))];
    fwrite(ctrl_link,tx_freq,'uint8');
    %% send tx vga set cmd         %配置衰减
    gain_str=get(handles.GAIN,'string');
    gain_dec=str2num(gain_str);
    gain_dec = gain_dec*1000;
    tx_att1=dec2hex(gain_dec,8);
    tx_att2=dec2hex(gain_dec,8);
    tx_vga=[0 9 hex2dec('22') hex2dec('f0') hex2dec(tx_att1(7:8)) hex2dec(tx_att1(5:6)) hex2dec(tx_att1(3:4)) hex2dec(tx_att1(1:2))];  %TX1
    fwrite(ctrl_link,tx_vga,'uint8');
    tx_vga=[0 11 hex2dec('22') hex2dec('f0') hex2dec(tx_att2(7:8)) hex2dec(tx_att2(5:6)) hex2dec(tx_att2(3:4)) hex2dec(tx_att2(1:2))]; %TX2
    fwrite(ctrl_link,tx_vga,'uint8');
    %% send tx channel set cmd     %通道选择
    channel=[tx_chan 0 hex2dec('20') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link,channel,'uint8');
    %% custom rf control command
    % ref_select                        %时钟选择
    ref_select=[0 40 hex2dec('22') hex2dec('f0') hex2dec(ref_hex(7:8)) hex2dec(ref_hex(5:6)) hex2dec(ref_hex(3:4)) hex2dec(ref_hex(1:2))];
    fwrite(ctrl_link,ref_select,'uint8');
    % vco_cal_select                    %VCO 校准选择
    vco_cal_select=[0 41 hex2dec('22') hex2dec('f0') hex2dec(vco_cal_hex(7:8)) hex2dec(vco_cal_hex(5:6)) hex2dec(vco_cal_hex(3:4)) hex2dec(vco_cal_hex(1:2))];
    fwrite(ctrl_link,vco_cal_select,'uint8');
    % fdd_tdd_select                    %双工方式选择
    fdd_tdd_select=[0 42 hex2dec('22') hex2dec('f0') hex2dec(fdd_tdd_hex(7:8)) hex2dec(fdd_tdd_hex(5:6)) hex2dec(fdd_tdd_hex(3:4)) hex2dec(fdd_tdd_hex(1:2))];
    fwrite(ctrl_link,fdd_tdd_select,'uint8');
    % trx_sw                            %TX/RX选择
    trx_sw=[0 43 hex2dec('22') hex2dec('f0') hex2dec(trx_sw_hex(7:8)) hex2dec(trx_sw_hex(5:6)) hex2dec(trx_sw_hex(3:4)) hex2dec(trx_sw_hex(1:2))];
    fwrite(ctrl_link,trx_sw,'uint8');
    % aux_dac1                          %若选择内部时钟校准VCO，则配置此参数
    aux_dac1=[0 44 hex2dec('22') hex2dec('f0') hex2dec(aux_dac1_hex(7:8)) hex2dec(aux_dac1_hex(5:6)) hex2dec(aux_dac1_hex(3:4)) hex2dec(aux_dac1_hex(1:2))];
    if hex2dec(vco_cal_hex) == 1
        fwrite(ctrl_link,aux_dac1,'uint8');
    end
    %% send handshake cmd          %握手信号
    handshake=[2 0 hex2dec('16') hex2dec('f0') 0 0 0 0];
    fwrite(ctrl_link ,handshake, 'uint8');
    pause(0.5);
    %% send handshake2 cmd  (通知PS要发送的数据量)
    data_length = dec2hex((2^(i-1)*2)*1024,8);
    handshake=[2 0 hex2dec('17') hex2dec('f0') hex2dec(data_length(7:8)) hex2dec(data_length(5:6)) hex2dec(data_length(3:4)) hex2dec(data_length(1:2))];
    fwrite(ctrl_link ,handshake, 'uint8');
    %% Write data to the zing and read from the host.
    fwrite(data_link,txd7,'uint8');    %向套接字中写数据
    % pause(10);
    % %% send handshake2 cmd to stop adc thread (用以结束发送线程)
    % handshake=[hex2dec('ff') 0 hex2dec('17') hex2dec('f0') 0 0 0 0];
    % fwrite(ctrl_link,handshake,'uint8');
    %% close all link              %断开连接
    fclose(data_link);
    delete(data_link);
    clear data_link;
    fclose(ctrl_link);
    delete(ctrl_link);
    clear ctrl_link;
    %%
    set(handles.connect,'Enable','off');
    set(handles.disconnect,'Enable','on');
end

function rx_ip_Callback(hObject, eventdata, handles)
% hObject    handle to rx_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rx_ip as text
%        str2double(get(hObject,'String')) returns contents of rx_ip as a double


% --- Executes during object creation, after setting all properties.
function rx_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rx_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rx_port_Callback(hObject, eventdata, handles)
% hObject    handle to rx_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rx_port as text
%        str2double(get(hObject,'String')) returns contents of rx_port as a double


% --- Executes during object creation, after setting all properties.
function rx_port_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rx_port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rx_buffer_Callback(hObject, eventdata, handles)
% hObject    handle to rx_buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rx_buffer as text
%        str2double(get(hObject,'String')) returns contents of rx_buffer as a double


% --- Executes during object creation, after setting all properties.
function rx_buffer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rx_buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3



function rx_freq_Callback(hObject, eventdata, handles)
% hObject    handle to rx_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rx_freq as text
%        str2double(get(hObject,'String')) returns contents of rx_freq as a double


% --- Executes during object creation, after setting all properties.
function rx_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rx_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rx_gain_Callback(hObject, eventdata, handles)
% hObject    handle to rx_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rx_gain as text
%        str2double(get(hObject,'String')) returns contents of rx_gain as a double


% --- Executes during object creation, after setting all properties.
function rx_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rx_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on selection change in mod_style.
function mod_style_Callback(hObject, eventdata, handles)
pop_str=get(handles.mod_style,'string');
va=get(handles.mod_style,'Value');
mode = pop_str{va} ;
if  strcmp(mode,'BPSK')==1
    sim_options.ConvCodeRate='R1/2';
    set(handles.code_rate,'string',sim_options.ConvCodeRate);
    sim_options.rate = 6;
    set(handles.speed,'string',sim_options.rate);
    im=imread('BPSK_1.png');
    axes(handles.axes1);
    imshow(im);
    
    
elseif  strcmp(mode,'QPSK')==1
    sim_options.ConvCodeRate='R1/2';
    set(handles.code_rate,'string',sim_options.ConvCodeRate);
    sim_options.rate = 12;
    set(handles.speed,'string',sim_options.rate);
    im=imread('QPSK_b.jpg');
    axes(handles.axes1);
    imshow(im);
    
elseif strcmp(mode,'16QAM')==1
    sim_options.ConvCodeRate='R1/2';
    set(handles.code_rate,'string',sim_options.ConvCodeRate);
    sim_options.rate = 24;
    set(handles.speed,'string',sim_options.rate);
    im=imread('16QAM_b.jpg');
    axes(handles.axes1);
    imshow(im);
    
elseif strcmp(mode,'64QAM')==1
    sim_options.ConvCodeRate='R2/3';
    set(handles.code_rate,'string',sim_options.ConvCodeRate);
    sim_options.rate = 48;
    set(handles.speed,'string', sim_options.rate);
    im=imread('64QAM_b.jpg');
    axes(handles.axes1);
    imshow(im);
    
end


% --- Executes during object creation, after setting all properties.
function mod_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mod_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function data_length_Callback(hObject, eventdata, handles)
% hObject    handle to data_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_length as text
%        str2double(get(hObject,'String')) returns contents of data_length as a double


% --- Executes during object creation, after setting all properties.
function data_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function code_rate_Callback(hObject, eventdata, handles)
% hObject    handle to code_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of code_rate as text
%        str2double(get(hObject,'String')) returns contents of code_rate as a double


% --- Executes during object creation, after setting all properties.
function code_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to code_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function speed_Callback(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed as text
%        str2double(get(hObject,'String')) returns contents of speed as a double


% --- Executes during object creation, after setting all properties.
function speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ip_Callback(hObject, eventdata, handles)
% hObject    handle to ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ip as text
%        str2double(get(hObject,'String')) returns contents of ip as a double


% --- Executes during object creation, after setting all properties.
function ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function port_Callback(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of port as text
%        str2double(get(hObject,'String')) returns contents of port as a double


% --- Executes during object creation, after setting all properties.
function port_CreateFcn(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FREQ_Callback(hObject, eventdata, handles)
% hObject    handle to FREQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FREQ as text
%        str2double(get(hObject,'String')) returns contents of FREQ as a double


% --- Executes during object creation, after setting all properties.
function FREQ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FREQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GAIN_Callback(hObject, eventdata, handles)
% hObject    handle to GAIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GAIN as text
%        str2double(get(hObject,'String')) returns contents of GAIN as a double


% --- Executes during object creation, after setting all properties.
function GAIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function buffer_Callback(hObject, eventdata, handles)
% hObject    handle to buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of buffer as text
%        str2double(get(hObject,'String')) returns contents of buffer as a double


% --- Executes during object creation, after setting all properties.
function buffer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buffer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in only_tx.
function only_tx_Callback(hObject, eventdata, handles)
% hObject    handle to only_tx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of only_tx


% --- Executes on button press in only_rx.
function only_rx_Callback(hObject, eventdata, handles)
% hObject    handle to only_rx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of only_rx


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function about_Callback(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg('802.11a_transceiver1.2','关于');

% --------------------------------------------------------------------
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global F;
global C;
global flag;
global filename;
global pathname;
F=1;
C=0;
flag=1;
[filename, pathname] = uigetfile( ...
    {'*.dat','Image Files(*.dat)';'*.prn;','Image Files(*.prn)';'*.dmp;','Image Files(*.dmp)';...
    '*.*',  'All Files (*.*)'}, ...
    'Pick an image');
rx_operator_Callback(hObject, eventdata, handles);
F=0;
flag=0;

% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);




% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in reference.
function reference_Callback(hObject, eventdata, handles)
% hObject    handle to reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns reference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from reference


% --- Executes during object creation, after setting all properties.
function reference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tdd_fdd.
function tdd_fdd_Callback(hObject, eventdata, handles)
% hObject    handle to tdd_fdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tdd_fdd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tdd_fdd


% --- Executes during object creation, after setting all properties.
function tdd_fdd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tdd_fdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in adxdac.
function adxdac_Callback(hObject, eventdata, handles)
% hObject    handle to adxdac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns adxdac contents as cell array
%        contents{get(hObject,'Value')} returns selected item from adxdac


% --- Executes during object creation, after setting all properties.
function adxdac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to adxdac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
