% Skip Sync Tests (use with caution)
Screen('Preference', 'SkipSyncTests', 1);
clc;
clear all;

% Initialization
n = 20;
totalVideos = 11*n; % 11 videos*20
participantName = input('Enter the participant name: ', 's');
rng(42); % Sets the random seed to 42

zoomFactor = 1.5; % Define the zoom factor (e.g., 2 for doubling the size)
np_init = 0;
temp_np = 0;
np = 0;

% Psychtoolbox setup
AssertOpenGL;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);

% Define key codes for up and down arrow keys
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');


% Load the video * 20
videoFile = [];
videoList = ["15.mp4", "22.mp4", "29.mp4", "36.mp4", "43.mp4", "50.mp4", "-57.mp4", "-64.mp4", "-71.mp4", "-78.mp4", "-85.mp4"];

for i = 1:n
    videoFile = [videoFile, videoList];
end
shuffledVideoFiles = videoFile(randperm(length(videoFile)));

% Initialize variables
Response = cell(1, totalVideos);
ReactionTime = cell(1, totalVideos);

try
    % Loop through all videos
    for j = 1:totalVideos
        [Response{j}, ReactionTime{j}, temp_np] = playVideoAndCaptureResponse(window, windowRect, shuffledVideoFiles{j}, upKey, downKey, zoomFactor, np_init);
        temp_np = temp_np + 1;
    end

    % Check for unanswered videos
    for k = 1:totalVideos
        while strcmp(Response{k}, 'not answered')
            [Response{k}, ReactionTime{k}, np] = playVideoAndCaptureResponse(window, windowRect, shuffledVideoFiles{k}, upKey, downKey, zoomFactor, temp_np);
            np = np + 1;
        end
    end
    % Final message
    finalMessage = 'All videos completed! Well Done^^';
    Screen('FillRect', window, [0 0 0]); % Clear screen with black color
    DrawFormattedText(window, finalMessage, 'center', 'center', [255 255 255]); % Draw white text
    Screen('Flip', window);
    WaitSecs(3); % Wait for 3 seconds to show the final message
catch ME
    disp(ME.message);
end % try

% Close the image texture and the window
Screen('CloseAll');

% Save results to a file with the participant number
filename = sprintf('%s_nonbiological_results.mat', participantName);
save(filename, 'Response', 'ReactionTime');


% Function to play video and capture response
function [response, reactionTime, negativePoint] = playVideoAndCaptureResponse(window, windowRect, videoFile, upKey, downKey, zoomFactor, negative_init)
    keyPressed = false;
    negativePoint = negative_init;
    video = VideoReader(videoFile);
    frameDuration = 1 / video.FrameRate;
    frameCount = 0;
    vbl = Screen('Flip', window);

    % Display a fixation cross before the video
    drawFixationCross(window, windowRect);
    WaitSecs(1); % Show the fixation point for 1 second
    
    while (hasFrame(video) && frameCount * frameDuration <= 5)
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(upKey) 
                response = '-';
                reactionTime = frameCount * frameDuration;
                keyPressed = true;
                break;
            elseif keyCode(downKey)
                response = '+';
                reactionTime = frameCount * frameDuration;
                keyPressed = true;
                break;
            end
        end
        frame = readFrame(video);
        texture = Screen('MakeTexture', window, frame);

        srcRect = CenterRectOnPoint([0, 0, size(frame, 2)/zoomFactor, size(frame, 1)/zoomFactor], ...
                                    size(frame, 2)/2, size(frame, 1)/2);
        dstRect = CenterRectOnPoint([0, 0, size(frame, 2), size(frame, 1)], ...
                                    windowRect(3)/2, windowRect(4)/2);

 
        Screen('DrawTexture', window, texture, srcRect, dstRect);
        vbl = Screen('Flip', window, vbl + frameDuration - 0.5 * Screen('GetFlipInterval', window));
        Screen('Close', texture);
        frameCount = frameCount + 1;
    end
    if keyPressed == false
        response = 'not answered';
        reactionTime = frameCount * frameDuration;
        negativePoint = negativePoint + 1;
    end
%     % Correct the comparison logic for the response
%     if contains(videoFile, '-')
%         if strcmp(response, '-')
%             message = 'Correct!';
%         else
%             message = 'Not Correct!';
%         end
%     else
%         if strcmp(response, '+')
%             message = 'Correct!';
%         else
%             message = 'Not Correct!';
%         end
%     end
%
%     % Display feedback message
%     Screen('FillRect', window, [0 0 0]);
%     DrawFormattedText(window, message, 'center', 'center', [255 255 255]);
%     Screen('Flip', window);
%     WaitSecs(1);
      % Display a black screen for 1 second after feedback
      Screen('FillRect', window, [0 0 0]); % Black screen
      Screen('Flip', window);
      WaitSecs(1); % Show black screen for 1 second
end


% Function to draw a fixation cross at the center of the screen
function drawFixationCross(window, windowRect)
    % Define the coordinates for the fixation cross
    [xCenter, yCenter] = RectCenter(windowRect);
    crossLength = 20; % Length of the cross arms
    lineWidth = 3;    % Line thickness

    % Horizontal line (x-axis)
    Screen('DrawLine', window, [255 255 255], xCenter - crossLength, yCenter, ...
           xCenter + crossLength, yCenter, lineWidth);
    
    % Vertical line (y-axis)
    Screen('DrawLine', window, [255 255 255], xCenter, yCenter - crossLength, ...
           xCenter, yCenter + crossLength, lineWidth);
    
    % Flip to the screen
    Screen('Flip', window);

end
