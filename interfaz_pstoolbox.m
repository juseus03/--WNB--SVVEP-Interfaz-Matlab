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
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white/2);
HideCursor
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
ifi = Screen('GetFlipInterval', window);
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

%Shows the user the operation to perform
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);
%Choose an operation to make randomly
operacion=randi(3); 
%Load de images depending on the operation
if(operacion==1)
    n1=3;
    n2=2;
    img=imread('numero_5.jpg'); 
    img_c=imread('numero_5_c.jpg'); 
elseif(operacion==2)
    n1=5;
    n2=1;
    img=imread('numero_6.jpg'); 
    img_c=imread('numero_6_c.jpg'); 
else
    n1=2;
    n2=2;
    img=imread('numero_4.jpg'); 
    img_c=imread('numero_4_c.jpg'); 
end
%Shows in the screen the text with the operation to perform
text_string_operation=['Resuelve: \n' num2str(n1) '+' num2str(n2)];
DrawFormattedText(window, text_string_operation, 'center', yCenter*0.5, white);
Screen('Flip', window);

%Read and prepare the images to flick
%%Answer 1
[sy sx sz] = size(img); 
[sy_c sx_c sz_c] = size(img_c); 
%%Answer 2
img2=imread('numero_7.jpg'); 
img_2c=imread('numero_7_c.jpg'); 
[sy2 sx2 sz2] = size(img2); 
[sy_2c sx_2c sz_2c] = size(img_2c); 

%Texture definition and flickering time
%%Answer 1
flick_r1 = 1;
flick_time_r1 = 0;
start_time_r1 = GetSecs;
flicker_freq_r1 = 10;   % full cycle flicker frequency (Hz)
flick_dur_r1 = 1/flicker_freq_r1/2;
t(1) = Screen('MakeTexture', window, img);
t(2) = Screen('MakeTexture', window, img_c); % reversed contrast

%%Answer 2
flick_r2 = 3;
flick_time_r2 = 0;
start_time_r2 = GetSecs;
flicker_freq_r2 = 15;   % full cycle flicker frequency (Hz)
flick_dur_r2 = 1/flicker_freq_r2/2;
t(3) = Screen('MakeTexture', window, img2);
t(4) = Screen('MakeTexture', window, img_2c); % reversed contrast

%Rectangle with the position of the images
dest_rect_r1 = [xCenter*0.5-sx/2,yCenter-sy/2,xCenter*0.5+sx/2,yCenter+sy/2]; %[xCenter-sx/2,yCenter-sy/2,xCenter+sx/2,yCenter+sy/2]; 
dest_rect_r2 = [xCenter*1.5-sx/2,yCenter-sy/2,xCenter*1.5+sx/2,yCenter+sy/2]; 

%Starts the animation
current_interval=0;
now=0; 
displayTime1=40; %Time of the study
start=GetSecs;
while (now<start+displayTime1) % animation loop
        %Calculates the flick of the first image
        thetime_r1 = GetSecs - start_time_r1; % time (sec) since loop started           
        if thetime_r1 > flick_time_r1     % time to reverse contrast?
            flick_time_r1 = flick_time_r1 + flick_dur_r1; % set next flicker time
            flick_r1 = 3 - flick_r1;
        end
        %Calculates the flick of the second image
        thetime_r2 = GetSecs - start_time_r2; % time (sec) since loop started           
        if thetime_r2 > flick_time_r2     % time to reverse contrast?
            flick_time_r2 = flick_time_r2 + flick_dur_r2; % set next flicker time
            flick_r2 = 7 - flick_r2;
        end
        %Draw the images and the text in the screen
        Screen('DrawTexture', window, t(flick_r1),[],dest_rect_r1);
        Screen('DrawTexture', window, t(flick_r2),[],dest_rect_r2);
        DrawFormattedText(window, text_string_operation, 'center', yCenter*0.5, white);
        Screen('Flip', window);
        %Time to end the animation
        now=GetSecs;
        detected=now-start; %Actual duration of the test
        text_string_time=['Tiempo: ' num2str(detected)];
        DrawFormattedText(window, text_string_time, 100, 100, white);
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