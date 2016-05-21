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
img2=imread('numero_7.jpg'); 
img_2c=imread('numero_7_c.jpg'); 
[sy2 sx2 sz2] = size(img2); 
[sy_2c sx_2c sz_2c] = size(img_2c); 

%Define textures and flicker time
flick_r2 = 3;
flick_time_r2 = 0;
start_time_r2 = GetSecs;
flicker_freq_r2 = 15;   % full cycle flicker frequency (Hz)
flick_dur_r2 = 1/flicker_freq_r2/2;
t(3) = Screen('MakeTexture', window, img2);
t(4) = Screen('MakeTexture', window, img_2c); % reversed contrast

%Rectangle of position of the image
dest_rect_r1 = [xCenter-sx2/2,yCenter-sy2/2,xCenter+sx2/2,yCenter+sy2/2];

%Starts the animation
current_interval=0;
now=0;
displayTime=40;
start=GetSecs;
while (now<start+displayTime) % animation loop
    %Calculates the flick of the second image
    thetime_r2 = GetSecs - start_time_r2; % time (sec) since loop started           
    if thetime_r2 > flick_time_r2     % time to reverse contrast?
        flick_time_r2 = flick_time_r2 + flick_dur_r2; % set next flicker time
        flick_r2 = 7 - flick_r2;
    end
     Screen('DrawTexture', window, t(flick_r2),[],dest_rect_r1);
    Screen('Flip', window);
    
    %Time to end the animation
    now=GetSecs;
   
    if KbCheck
        break % exit loop upon key press
    end
end

% Shows the end of the game screen
ganador=2;
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