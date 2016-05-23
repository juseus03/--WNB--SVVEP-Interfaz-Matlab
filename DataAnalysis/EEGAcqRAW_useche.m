function f_EEGAcqWNB
clc
%clear all
close all hidden


dbstop if error

file_id = fopen('TestAMM_vel_resp_15HZ_3.data','w');

%     addpath('./Functions/');
%     addpath('./AudioFuncs/');
%     addpath('../../MATLAB/Functions/');
%     addpath('F:\valderrama\Projects\MATLAB\Functions');
%     addpath('C:\Documents and Settings\labadmin\Mis documentos\MicromedRT\MicromedIP\Matlab'); % This is required for Micromed Functions

    % % % % % % % % % % % % % INITIALIZATION % % % % % % % % % % % % % 
    
  
    s_Technology = 4; % 1 Neurosky; 2 Emotiv; 3 Micromed; 4 WirelessUniandes
    
    s_BuffSizeSec = 10.1;
%     s_BuffSizeSec = 5.1;
    s_PlotRefreshSec = 0.2;
    s_RecUpdateSec = 2.0; % This value must be less than s_BuffSizeSec
    s_AcqOn = 0;
    s_Exit = 0;
    s_Threshold = 0;
    
% WirelessUniandes
            s_Portnum1 = 5;   %COM Port #5
            str_ComPortName1 = sprintf('COM%d', s_Portnum1);
            
%             s_Portnum1 = 0;   %COM Port #5
%             str_ComPortName1 = sprintf('/dev/ttyUSB%d', s_Portnum1);
            
            s_SRate = 250;
            
            s_TotalAcqChannNum = 9; % Including the 'state' channel
            s_BytesPerChann = 3;
            s_BitsPerChann = 8 * s_BytesPerChann;
            s_DataAcqTimerSec = 0.03;
            s_FrameSizeBytes = s_TotalAcqChannNum * s_BytesPerChann;
            s_FrameSizeBits = s_TotalAcqChannNum * s_BitsPerChann;
            s_SamplesNum = round(s_DataAcqTimerSec * s_SRate);
            s_BitsToRead = s_SamplesNum * s_FrameSizeBits;
            s_BuffSizeSam = round(s_BuffSizeSec * s_SRate);
            v_DataChannelsInd = 5;% PARA TOMA DE DATOS PORT6 Channel 1 is always the 'state', %channel 2 - square signal, %chnnel 8 - square signal spindle
           
            s_InputBufferSize = 5 * s_BitsToRead;
            s_BaudRate = 230400;%460800%921600;
            str_Parity = 'none';
            s_StopBits = 1;
            s_FlowControl = 'none';
            
            v_ControlSig = [192;0;0];
            v_ControlFilt = ones(1, numel(v_ControlSig));
            s_ControlSigSum = sum(v_ControlSig);
            s_NumSeqToCheckSync = 6; % This must be an even number (not odd!)
            v_ControlFiltSeq = (1 / s_FrameSizeBytes)./ ...
                ones(1, s_NumSeqToCheckSync);
            v_ControlFiltSeq(1:2:end) = v_ControlFiltSeq(1:2:end).* -1;
            
                        
            v_Data = zeros(s_BuffSizeSam, numel(v_DataChannelsInd));    %preallocate buffer
            v_Time = (0:size(v_Data, 1) - 1)./ s_SRate;
            s_MinPlotLim = -2000;
            s_MaxPlotLim = 2000;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%Frequency Detection Parameters Initialization
            
            %Frequency Band
            s_MinFreq = 5;                              %Minimum Frequency Value in Hz 
            s_MaxFreq = 25;                             %Maximum Frequency Value in Hz
            s_dW = 0.5;                                 %Frequency Resolution Step in Hz
            
            s_FreqLimitIniHz  = s_MinFreq  ;
            s_FreqLimitFinHz = s_MaxFreq ;    
            v_FreqLimsHz = [s_FreqLimitIniHz s_FreqLimitFinHz]; %Frequency Limits Vector
            
            v_StimFreqsHz = [8, 10, 12, 15];              % Stimulus Frequencies
            s_Delta = 1;                                  % Delta
            v_Thresholds = [8,21,22.5,22.5];              % Thresholds values (pre-calculated)

            %Sound FeedBack Parameters 
            
            [s_yForward, s_FsForward] = audioread ('Ganar.wav'); %10hz
            [s_yBackward, s_FsBackward] = audioread ('Concentracion.wav');
            [s_yLeft, s_FsLeft] = audioread ('Concentracion.wav');
            [s_yRight, s_FsRight] = audioread ('Perder.wav'); %15hz

            % Threshold Matrix Initialization. The measured values for
            % threshold detection will be saved in this matrix
            s_K = 1; 
            s_KMax = 1000;                                %Maximum number of rows
            m_Thresholds = zeros(s_KMax,4);               %Matrix dimensions
                        
          
     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
% % %  % % % % % % % % % % % % % % % % % 
% WirelessUniandes
            
            delete(instrfind);
            
            s_SerialHdl = serial(str_ComPortName1);
            set(s_SerialHdl, 'InputBufferSize', s_InputBufferSize);
            set(s_SerialHdl,'BaudRate', s_BaudRate);
            set(s_SerialHdl,'Parity', str_Parity);
            set(s_SerialHdl,'StopBits', s_StopBits);
            set(s_SerialHdl,'FlowControl', s_FlowControl);
            
%             
            display(sprintf('[f_EEGAcqRAW] - Opening serial port %s...', str_ComPortName1));
            fopen(s_SerialHdl);
            display('[f_EEGAcqRAW] - Serial port successfully open!');


    
%%
% % % % FIGURE CONTROL PANEL
    str_StartActionStr = 'Start Detect.';
    str_StopActionStr = 'Stop Detect.';
    
    s_BottomMarg  = 0.50;        %INICIALMENTE 0.14
    s_TopMarg     = 0.05;           %original 0.11
    s_LeftMarg    = 0.04;          %Margen izquierdo de la figura mod (original 0.13)
    s_RightMarg   = 0.5;          %Margen derecho de la figura mod (original 0.12)
    s_VerSpace    = 0.09;         %ORIGINAL 0.1
    s_HorSpace    = 0.005;
    s_FigCols     = 5;
    s_FigRows     = 2;            %Varia el grosor vertical de la figura original 2
    
%     ADITIONAL PARAMETERS FOR CONTROL PANEL (ANDRES MODIFICATION)

    s_BottomMarg_2 =  0.08;  %Manipula la posición en Y del eje (independiente de los botones)
    s_TopMarg_2    =  0.05;
    s_LeftMarg_2   =  0.04; %0.02
    s_RightMarg_2  =  0.5;   %Margen derecho de la figura mod (original 0.12)
    s_VerSpace_2   =  0.09;  %ORIGINAL 0.1
    s_HorSpace_2   =  0.005;
    s_FigCols_2    =  8;
    s_FigRows_2    =  5;
    
    s_BottomMarg_3 = 0.08;
    s_TopMarg_3    = 0.05;
    s_LeftMarg_3   = 0.55;
    s_RightMarg_3  = 0.02; %Margen derecho de la figura mod (original 0.12)
    s_VerSpace_3   = 0.09;  %ORIGINAL 0.1
    s_HorSpace_3   = 0.005;
    s_FigCols_3    = 8;
    s_FigRows_3    = 5;  
    
    s_BottomMarg_4 = 0.60;
    s_TopMarg_4    = 0.05;
    s_LeftMarg_4   = 0.52;
    s_RightMarg_4  = 0.02; %Margen derecho de la figura mod (original 0.12)
    s_VerSpace_4   = 0.12;  %ORIGINAL 0.1
    s_HorSpace_4   = 0.005;
    s_FigCols_4    = 5;
    s_FigRows_4    = 2;  
    
    s_Height = (1 - (s_TopMarg + s_BottomMarg + s_VerSpace * (s_FigRows - 1)));
    v_HeightPer = [0.7 0.15];
    v_Height = s_Height.* v_HeightPer;
    s_Width = (1 - (s_LeftMarg + s_RightMarg +  s_HorSpace * (s_FigCols - 1)));
    v_WidthPer = [0.2 0.2 0.2 0.2 0.2];
    v_Width = s_Width.* v_WidthPer;
    
    s_FontSize = 8;
    s_FigWidth = 15;
    s_FigHeight = 10;

    
% % % ADITIONAL PARAMETERS FOR CONTROL PANEL (ANDRES MODIFICATION)

%     s_Height_2 = (1 - (s_TopMarg_2 + s_BottomMarg_2 + s_VerSpace_2 * (s_FigRows_2 - 1)));
%     v_HeightPer_2 = [0.7 0.3]; %Posicion del eje respecto a Y
%     v_Height_2 = (s_Height_2.* v_HeightPer_2);
%     s_Width_2 = (1 - (s_LeftMarg_2 + s_RightMarg_2 + s_HorSpace_2 * (s_FigCols_2 - 1)));
%     v_Width_2 = (s_Width_2.* v_WidthPer);
%     s_CurrLeft_2 = s_LeftMarg_2 ;
%     s_Width_2 = sum(v_Width_2) + s_HorSpace * (numel(v_Width_2) - 1);    
% 
%     s_Height_3 = (1 - (s_TopMarg_3 + s_BottomMarg_3 + s_VerSpace_3 * (s_FigRows_3 - 1)));
%     v_HeightPer_3 = [0.7 0.15]; %Posicion del eje respecto a Y
%     v_Height_3 = s_Height_3.* v_HeightPer_3;
%     s_Width_3 = (1 - (s_LeftMarg_3 + s_RightMarg_3 + s_HorSpace_3 * (s_FigCols_3 - 1)));
%     v_Width_3 = (s_Width_3.* v_WidthPer);
%     s_CurrLeft_3 = s_LeftMarg_3 ;
%     s_Width_3 = sum(v_Width_3) + s_HorSpace * (numel(v_Width_3) - 1);
%     
%     s_Height_4 = (1 - (s_TopMarg_4 + s_BottomMarg_4 + s_VerSpace_4 * (s_FigRows_4 - 1)));
%     v_HeightPer_4 = [1.5 0.3]; %Posicion del eje respecto a Y
%     v_Height_4 = (s_Height_4.* v_HeightPer_4);
%     s_Width_4 = (1 - (s_LeftMarg_4 + s_RightMarg_4 + s_HorSpace_4 * (s_FigCols_4 - 1)));
%     v_Width_4 = s_Width_4.* v_WidthPer;
%     s_CurrLeft_4 = s_LeftMarg_4 ;
%     s_Width_4 = sum(v_Width_4) + s_HorSpace * (numel(v_Width_4) - 1);
    
       
%         s_Width = sum(v_Width) + s_HorSpace * (numel(v_Width) - 1);
%         
%     s_MainFig = figure;
%     set(s_MainFig, 'Color', 'w');
%     f_MaximizeFig(s_MainFig);
%     %     f_ReSizeImage(s_MainFig, s_FigWidth, s_FigHeight, [], [], [], 'centimeters');
%     
%     s_CurrLeft = s_LeftMarg;
%     s_CurrBott = 1 - s_TopMarg - v_Height(1);
   
   % ADITIONAL AXES (s_Axe_Threshold, s_Axe_Fourier, s_Axe_TimeFreq)
   
%      s_Axe_Threshold = axes('Position', [s_CurrLeft_4 ...
%         s_BottomMarg_4 s_Width_4 v_Height_4(1)]);
%     set(s_Axe_Threshold, 'box', 'off', 'YTick', [], 'YTickLabel', [], 'YColor', 'w','Visible','off');
%     title('Pololu Direction','Color','r','FontWeight','bold')
% 
%          
%     s_Axe_Fourier = axes('Position', [s_CurrLeft_3 ...
%         s_BottomMarg_3 s_Width_3 v_Height_3(1)]);
%     set(s_Axe_Fourier, 'box', 'off', 'YTick', [], 'YTickLabel', [], 'YColor', 'w');
%     title('Fourier Spectre Mean','Color','r','FontWeight','bold') 
%     xlabel('Frequency[Hz]')
%     ylabel('Amplitude[ ]');
%    
%   
%     s_Axe_TimeFreq = axes('Position', [s_CurrLeft_2 ...
%         s_BottomMarg_2 s_Width_2 v_Height_2(1)]);
%     set(s_Axe_TimeFreq, 'box', 'off', 'YTick', [], 'YTickLabel', [], 'YColor', 'w','HandleVisibility','on');
%     title('Time-Frecuency Representation','Color','r','FontWeight','bold') 
%     xlabel('Time[s]');
%     ylabel('Frequency[Hz]');
%    
%     s_AxeSig = axes('Position', [s_CurrLeft ...
%         s_CurrBott s_Width v_Height(1)]);
%     set(s_AxeSig, 'box', 'off', 'YTick', [], 'YTickLabel', [], 'YColor', 'w');
%     title('EEG Signal','Color','r','FontWeight','bold') 
%     xlabel('Time[s]')
%     ylabel('Amplitude[uV]');
%   
%     
%     s_CurrBott = s_CurrBott - s_VerSpace - v_Height(2);
%     s_StartAcqButton = uicontrol(s_MainFig, 'Style', 'pushbutton', ...
%         'Units', 'normalized', 'String', 'Start Acq.', 'Position', ...
%         [s_CurrLeft s_CurrBott v_Width(1) v_Height(2)], ...
%         'Visible', 'on', 'Callback', {@OnAcqStart, s_AxeSig});
% 
%     s_CurrLeft = s_CurrLeft + v_Width(1) + s_HorSpace;
%     s_StopAcqButton = uicontrol(s_MainFig, 'Style', 'pushbutton', ...
%         'Units', 'normalized', 'String', 'Stop Acq.', 'Position', ...
%         [s_CurrLeft s_CurrBott v_Width(2) v_Height(2)], ...
%         'Visible', 'on', 'Callback', {@OnAcqStop, s_AxeSig});
% 
%     s_CurrLeft = s_CurrLeft + v_Width(2) + s_HorSpace;
%     s_OnThresholdButton = uicontrol(s_MainFig, 'Style', 'pushbutton', ...
%         'Units', 'normalized', 'String', str_StartActionStr, 'Position', ...
%         [s_CurrLeft s_CurrBott v_Width(3) v_Height(2)], ...
%         'Visible', 'on', 'Callback', {@OnThreshold, s_AxeSig},'Value',[1]);
% 
%     s_CurrLeft = s_CurrLeft + v_Width(3) + s_HorSpace;
%     s_OffThresholdButton = uicontrol(s_MainFig, 'Style', 'pushbutton', ...
%         'Units', 'normalized', 'String', str_StopActionStr, 'Position', ...
%         [s_CurrLeft s_CurrBott v_Width(4) v_Height(2)], ...
%         'Visible', 'on', 'Callback', {@OffThreshold, s_AxeSig});
%     
%     s_CurrLeft = s_CurrLeft + v_Width(4) + s_HorSpace;
%     s_ExitButton = uicontrol(s_MainFig, 'Style', 'pushbutton', ...
%         'Units', 'normalized', 'String', 'Exit', 'Position', ...
%         [s_CurrLeft s_CurrBott v_Width(4) v_Height(2)], ...
%       'Visible', 'on', 'Callback', {@OnExit, s_AxeSig});
    start=tic;
    duration=45;
     while ~s_Exit
        if ~s_AcqOn
           % WirelessUniandes
                    v_Data = zeros(s_BuffSizeSam, numel(v_DataChannelsInd));    %preallocate buffer
                    s_DataAcqTimer = tic;
                    s_FirstSamSync = 0;
                    s_CountWin = 1;
                    v_ChannelDataBuff = [];

                    (s_SerialHdl);
                    s_AcqCountNum = 0;

            s_CurrBuffInd = 0;
            s_LastBuffInd = 1;
            str_RecFileName = [];
            s_RecFileId = -1;
            s_ActionOn = 0;
            s_RecMatId = 0;
            s_PlotTimer = tic;
            s_RecUpdateTimer = tic;
            pause(0.1);
            s_AcqOn=1;
            continue;
            
        end
 % WirelessUniandes
                if (toc(s_DataAcqTimer) < s_DataAcqTimerSec)
                    continue;
                end
                
                s_DataAcqTimer = tic;
                [v_ChannelData, s_ValCount] = fread(s_SerialHdl, s_BitsToRead);
                fwrite(file_id, v_ChannelData);
%                 v_rawData = v_ChannelData;
                
%                 if s_ValCount < s_BitsToRead
%                     display('[f_EEGAcqRAW] - WirelessUniandes: WARNING s_ValCount <= s_BitsToRead!');
%                     continue;
%                 end
                
                s_AcqCountNum = s_AcqCountNum + 1;
                
%                 if s_AcqCountNum <= 8
%                     continue;
%                 end
                
                s_AcqCountNum = 8;
                
%                 while ~s_FirstSamSync
%                     v_DataAuxInd = filter(v_ControlFilt, 1, v_ChannelData);
%                     v_DataAuxInd = find(v_DataAuxInd == s_ControlSigSum);
%                     v_DataAuxInd1 = zeros(size(v_DataAuxInd));
%                     v_DataAuxInd1(2:end) = diff(v_DataAuxInd);
%                     v_DataAuxInd1 = filter(v_ControlFiltSeq, 1, v_DataAuxInd1);
%                     s_IndAux = find(v_DataAuxInd1(s_NumSeqToCheckSync + 1:end) == 0, 1);
%                     
%                         save('v_ChannelData.mat', 'v_ChannelData');
%                     if isempty(s_IndAux)
%                         
% %                         save('v_ChannelData.mat', 'v_ChannelData');
%                         display('[f_EEGAcqRAW] - WirelessUniandes: No synchronization signal found!');
% %                         return;
%                         break;
%                     end
%                     
%                     s_IndAux = s_IndAux + s_NumSeqToCheckSync;
%                     
%                     v_ChannelData = v_ChannelData(v_DataAuxInd(s_IndAux) - 2:end);
%                         save('v_ChannelData1.mat', 'v_ChannelData');
%                         
%                     if v_ChannelData(1) ~= 192
%                         display('No 192 - v_ChannelData - First');
%                     end                        
%                     
%                     clear v_DataAuxInd v_DataAuxInd1
%                     
%                     s_FirstSamSync = 1;
%                     
%                     break;
%                 end
%                 
%                 if ~isempty(v_ChannelDataBuff)
%                     
%                     if v_ChannelDataBuff(1) ~= 192
%                         display('No 192 - First');
%                     end
%                     
%                     
%                     v_DataAuxInd = v_ChannelData;
%                     v_ChannelData = zeros(numel(v_ChannelDataBuff) + numel(v_ChannelData), 1);
%                     v_ChannelData(1:numel(v_ChannelDataBuff)) = v_ChannelDataBuff;
%                     v_ChannelData(numel(v_ChannelDataBuff) + 1:end) = v_DataAuxInd;
%                     
%                     v_ChannelDataBuff = [];
% 
%                 end
%                     
%                     
%                 s_IndAux = floor(numel(v_ChannelData) / s_FrameSizeBytes);
%                 
%                 s_LastInd = s_IndAux * s_FrameSizeBytes;
%                 if s_LastInd ~= numel(v_ChannelData)
%                     v_ChannelDataBuff = v_ChannelData(s_LastInd + 1:end);
%                     
%                     if v_ChannelData(1) ~= 192
%                         display(['No 192 - v_ChannelData' num2str(s_AcqCountNum)]);
%                     end
%                     if v_ChannelDataBuff(1) ~= 192
%                         display('No 192');
%                     end
%                     v_ChannelData = v_ChannelData(1:s_LastInd);
%                 end
                
                v_ChannelData = dec2bin(v_ChannelData, 8);
                v_ChannelData = v_ChannelData';
                v_ChannelData = v_ChannelData(:);
                v_ChannelData = reshape(v_ChannelData', 24, []);
                v_ChannelData = v_ChannelData';
                v_Signs = v_ChannelData(:, 1);
                v_ChannelData = bin2dec(v_ChannelData(:, 2:end));
                v_Signs = (-2.^23).* bin2dec(v_Signs);
                v_ChannelData = v_ChannelData + v_Signs;
                v_ChannelData = reshape(v_ChannelData, s_TotalAcqChannNum, []);
                v_ChannelData = v_ChannelData(v_DataChannelsInd, :);
                v_ChannelData = v_ChannelData';
                
                s_CurrBuffInd = s_CurrBuffInd + 1;
                if s_CurrBuffInd > s_BuffSizeSam
                    s_CurrBuffInd = 1;
                end
                
                s_FirstInd = s_CurrBuffInd;
                s_LastInd = s_FirstInd + size(v_ChannelData, 1) - 1;
                if s_LastInd > s_BuffSizeSam
                    s_LastInd = s_LastInd - s_BuffSizeSam;
                    v_Ind = [s_FirstInd:s_BuffSizeSam 1:s_LastInd];
                else
                    v_Ind = s_FirstInd:s_LastInd;
                end
                
                s_CurrBuffInd = s_LastInd;
                
% % % % % % % % % This part simulates a signal                
%                 s_CurrSimBuffInd = s_CurrSimBuffInd + 1;
%                 if s_CurrSimBuffInd > numel(v_SimData)
%                     s_CurrSimBuffInd = 1;
%                 end
%                 
%                 s_FirstInd = s_CurrSimBuffInd;
%                 s_LastInd = s_CurrSimBuffInd + size(v_ChannelData, 1) - 1;                
%                 if s_LastInd > numel(v_SimData)
%                     s_LastInd = s_LastInd - numel(v_SimData);
%                     v_IndTemp = [s_FirstInd:numel(v_SimData) 1:s_LastInd];
%                 else
%                     v_IndTemp = s_FirstInd:s_LastInd;
%                 end
%                 
%                 v_ChannelData = v_SimData(v_IndTemp);
%                 s_CurrSimBuffInd = s_LastInd;
% % % % % % % % % % % % % % % % % % % % % % % % % 

              
                v_Data(v_Ind, :) = v_ChannelData;   
               

 
        
        % Time-Frequency Representation & fft signal spectre
                       
        [TFRC,time,v_Freq] =BAWT2(v_Data,s_MinFreq,s_MaxFreq,s_SRate,9,s_dW);
        TFR=abs(TFRC');
       
        spectre= mean(TFR(:,50:end-50)');
        spectre_det = detrend(spectre);   
        
   if (toc(s_PlotTimer) >= s_PlotRefreshSec)
%     THRESHOLD DETECTION
     v_Sig = spectre_det;

     [v_thresholds] = ...
       ThresholdDetection (v_Sig,v_StimFreqsHz,s_Delta,v_Freq,s_FreqLimitIniHz, s_FreqLimitFinHz) ;
  
%%
%   Threshold Matrix Definition
    m_Thresholds(s_K,:) = v_thresholds;
     s_K = s_K +1;
     if s_K > s_KMax
         s_K = 1;
     end
     
     % Threshold Condition for Detection       
     if  v_thresholds(1,2) >= v_Thresholds(1,2)
         display(sprintf('GANASTE >>>> 10[Hz]: %s %%' ,num2str(v_thresholds(1,2))));
         sound (s_yForward, s_FsForward);  
     elseif  v_thresholds(1,4) >= v_Thresholds(1,4)
             display(sprintf('PERDISTE >>>> 15[Hz]: %s %%' ,num2str(v_thresholds(1,4))));
             sound (s_yRight, s_FsRight); 
     else
         display('No Stimul Observed');
         display(num2str(v_thresholds));
     end
        
          
    end   
        
        if s_ActionOn && s_RecFileId > 0 && (toc(s_RecUpdateTimer) >= s_RecUpdateSec)
            s_FirstInd = s_LastBuffInd;
            s_LastInd = s_CurrBuffInd;
            if s_FirstInd > s_LastInd
                v_Ind = [s_FirstInd:s_BuffSizeSam 1:s_LastInd];
            else
                v_Ind = s_FirstInd:s_LastInd;
            end
            
            s_LastBuffInd = s_CurrBuffInd + 1;
            if s_LastBuffInd > s_BuffSizeSam
                s_LastBuffInd = 1;
            end
            
            m_RedDataBuff = v_Data(v_Ind, :)';
            
            switch s_Technology,
                
                case 1, %Neurosky
                    fwrite(s_RecFileId, int16(m_RedDataBuff(:)), 'int16');
                    
                case 2, %Emotiv
                    fwrite(s_RecFileId, double(m_RedDataBuff(:)), 'double');
                    
                    
                case 4 , %WirelessUniandes
                    fwrite(s_RecFileId, v_rawData); % , 'double');
                    
                otherwise,
                                   
                    
            end

            s_RecUpdateTimer = tic;
        end   
    if(toc(start)>duration)
        s_Exit=1;
    end
        
    end
    
    s_AcqOn = 0;
    % WirelessUniandes
            fclose(s_SerialHdl);
            delete(instrfind);          
end
% % % % % % % % % % % % % % % % % % %


