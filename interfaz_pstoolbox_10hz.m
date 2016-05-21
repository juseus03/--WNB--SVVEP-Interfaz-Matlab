% Clear the workspace and the screen
sca;
close all;
clearvars;
clc;
Screen('Preference', 'SkipSyncTests', 1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white/2);
HideCursor
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
ifi = Screen('GetFlipInterval', window);
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

%Read the image to show
img=imread('numero_5.jpg'); 
img_c=imread('numero_5_c.jpg'); 
[sy sx sz] = size(img); 
[sy_c sx_c sz_c] = size(img_c); 

%Define textures and flicker time
flick_r1 = 1;
flick_time_r1 = 0;
start_time_r1 = GetSecs;
flicker_freq_r1 = 10;   % full cycle flicker frequency (Hz)
flick_dur_r1 = 1/flicker_freq_r1/2;
t(1) = Screen('MakeTexture', window, img);
t(2) = Screen('MakeTexture', window, img_c); % reversed contrast

%rectangulo de posición de las imagenes
dest_rect_r1 = [xCenter-sx/2,yCenter-sy/2,xCenter+sx/2,yCenter+sy/2];

%Starts the animation
current_interval=0;
now=0;
displayTime=40;
start=GetSecs;
while (now<start+displayTime) % animation loop
    %Calculates the flick of the first image
    thetime_r1 = GetSecs - start_time_r1; % time (sec) since loop started           
    if thetime_r1 > flick_time_r1     % time to reverse contrast?
        flick_time_r1 = flick_time_r1 + flick_dur_r1; % set next flicker time
        flick_r1 = 3 - flick_r1;
    end
 
    Screen('DrawTexture', window, t(flick_r1),[],dest_rect_r1);
  
    Screen('Flip', window);
    
    %Time to end the animation
    now=GetSecs;  
    if KbCheck
        break % exit loop upon key press
    end
end

% Shows the end of the game screen
ganador=1;
%Setup the text
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);
if(ganador==1)
    text_string=['Has Ganado!!'];
    Screen('FillRect', window, [0 0.6 0]);
else
    text_string=['Has Perdido!!'];
    Screen('FillRect', window, [0.6 0 0]);
end
DrawFormattedText(window, text_string, 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

% Clear the screen
sca;