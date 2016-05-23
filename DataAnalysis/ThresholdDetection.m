% Function ThresholdDetection.m

%This function this function develops the calculation of total power 
%of a input signal , the relative potency of each of the specified frequency
%bands and the ratio between them . This aims to define the thresholds 
%that define the limits to overcome for an observed frequency dectección .

% Inputs:
% v_Sig: input signal 
% v_StimFreqsHz: Stimulation Frequencies
% s_Delta: 
% v_Freq: Frequency vector from BATW2
% s_FreqLimitIniHz: Initial Frequency Limit in Hz
% s_FreqLimitFinHz: Final Frequency Limit in Hz
% 
% Outputs:
% v_thresholds: Threshold Values
% 
% Author: Mario Valderrama & Andres M. Peña
% Date: May. 2015


function [v_thresholds] = ThresholdDetection (v_Sig,v_StimFreqsHz,s_Delta,v_Freq,s_FreqLimitIniHz ,s_FreqLimitFinHz) 

%Frequencies of Stimulation
s_StimFreq_1 = v_StimFreqsHz(1,1);
s_StimFreq_2 = v_StimFreqsHz(1,2);
s_StimFreq_3 = v_StimFreqsHz(1,3);
s_StimFreq_4 = v_StimFreqsHz(1,4);

%v_Sig = v_Sig(:);
%v_Sig = v_Sig - mean(v_Sig);

%     if (max(v_Sig)-min(v_Sig) < 0.02)

% Measured FFT Signal
v_FFTWhite = v_Sig;

v_FreqLimsHz = [s_FreqLimitIniHz s_FreqLimitFinHz];
s_FirstFreqInd = find(v_Freq >= v_FreqLimsHz(1), 1);
s_LastFreqInd = find(v_Freq >= v_FreqLimsHz(2), 1);

%Total Power of the Signal
s_TotalPow = sum(abs(v_FFTWhite(s_FirstFreqInd:s_LastFreqInd)));

%Frequency Limits - Frequency Indexes for each Band Frequency
v_FreqLimsTest8Hz     = [s_StimFreq_1-s_Delta s_StimFreq_1+s_Delta];
s_FirstFreqIndTest8Hz = find(v_Freq >= v_FreqLimsTest8Hz(1), 1);
s_LastFreqIndTest8Hz  = find(v_Freq >= v_FreqLimsTest8Hz(2), 1);

v_FreqLimsTest10Hz = [s_StimFreq_2-s_Delta s_StimFreq_2+s_Delta];
s_FirstFreqIndTest10Hz = find(v_Freq >= v_FreqLimsTest10Hz(1), 1);
s_LastFreqIndTest10Hz = find(v_Freq >= v_FreqLimsTest10Hz(2), 1);

v_FreqLimsTest12Hz = [s_StimFreq_3-s_Delta s_StimFreq_3+s_Delta];
s_FirstFreqIndTest12Hz = find(v_Freq >= v_FreqLimsTest12Hz(1), 1);
s_LastFreqIndTest12Hz = find(v_Freq >= v_FreqLimsTest12Hz(2), 1);

v_FreqLimsTest15Hz = [s_StimFreq_4-s_Delta s_StimFreq_4+s_Delta];
s_FirstFreqIndTest15Hz = find(v_Freq >= v_FreqLimsTest15Hz(1), 1);
s_LastFreqIndTest15Hz = find(v_Freq >= v_FreqLimsTest15Hz(2), 1);

% Total Power for each Frecueny Band & Relative Power of each Band Frequency
s_PowTest_8Hz = sum((v_FFTWhite(s_FirstFreqIndTest8Hz:s_LastFreqIndTest8Hz)));
s_RelPowTest_8Hz = (s_PowTest_8Hz / s_TotalPow) * 100;

s_PowTest_10Hz = sum((v_FFTWhite(s_FirstFreqIndTest10Hz:s_LastFreqIndTest10Hz)));
s_RelPowTest_10Hz = (s_PowTest_10Hz / s_TotalPow) * 100;

s_PowTest_12Hz = sum((v_FFTWhite(s_FirstFreqIndTest12Hz:s_LastFreqIndTest12Hz)));
s_RelPowTest_12Hz = (s_PowTest_12Hz / s_TotalPow) * 100;

s_PowTest_15Hz = sum((v_FFTWhite(s_FirstFreqIndTest15Hz:s_LastFreqIndTest15Hz)));
s_RelPowTest_15Hz = (s_PowTest_15Hz / s_TotalPow) * 100;


s_threshold8Hz =  s_RelPowTest_8Hz;
s_threshold10Hz = s_RelPowTest_10Hz;
s_threshold12Hz = s_RelPowTest_12Hz;
s_threshold15Hz = s_RelPowTest_15Hz;

%Threshold Vector 
v_thresholds = [s_threshold8Hz, s_threshold10Hz, s_threshold12Hz, s_threshold15Hz];
end
      

      

 


