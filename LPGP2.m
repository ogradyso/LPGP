% Adapted          code
% 

sca
Screen('Preference','SkipSyncTests', 2);
KbName('UnifyKeyNames');
clc
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));% reset the random seed

% %%% Enter particpiant info %%%
fail1='Program aborted. Participant number or age not entered';% errormessage which is printed to command window
prompt = {'Enter participant number:' 'Enter your age' 'Session_1_2' 'Condition_1low_2high' 'Order_1_2'};
dlg_title ='New Participant';
num_lines = 1;
def = {'0' '0' '0' '0' '0'};        
answer = inputdlg(prompt,dlg_title,num_lines,def);%presents box to enterdata into
switch isempty(answer)
    case 1%deals with both cancel and X presses
        error(fail1)
    case 0
        thissub = (answer{1}); %participant ID number
        age = (answer{2});
        age = str2double(age); % participant age(estimate)
        session = str2double(answer{3}); %session 1 or 2
        condition = str2double(answer{4});% High conflict or low conflict
        order=str2double(answer{5}); % order 1 or 2
end

HideCursor;

%%% define global constants:
ResultsFolder ='/Users/shaunogrady/desktop/LPGP2/SubData/';
Outputfile = [ResultsFolder 'LPGP2_' thissub '.mat'];

switch session
    case 1
        phase = 1;
        Assessment_Results = assessmentPhase(thissub, age, condition, order,phase,Outputfile);
        save(Outputfile,'Assessment_Results');
        ShowCursor;
        sca
    case 2
        Conflict_Results = conflictPhase(thissub, condition, order, Outputfile);
        phase = 3;
        Test_Results = assessmentPhase(thissub, age, condition, order, phase, Outputfile);
        Test_Results.data(:,20)=3;
        Conflict_Results.data = vertcat(Conflict_Results.data, Test_Results.data);
        save(Outputfile, 'Conflict_Results');
        RestrictKeysForKbCheck([]);
        ShowCursor;
        sca
end
%Define function for the assessment phase:
function[Assessment_Results] = assessmentPhase(thissub, age, condition, order, phase, Outputfile)
ListenChar(2);
preference = '';
CompScreen = get(0,'ScreenSize');% Find out the size of this computerscreen
win = Screen('OpenWindow',0, [900 900 1000], CompScreen); % Full sizedscreen
strategy=1;
stratScore = 0;

switch order
    case 1
        StimuliFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order1/';
    case 2
        StimuliFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order2/';
end

FileName = '/Users/shaunogrady/desktop/LPGP2/Images/startScreen.jpg';% select the filename for the current trial
Stim = imread(FileName);% read in the image
Texture = Screen('MakeTexture', win, Stim);% read in the image
% Helper functions (help PsychRects) allow to manipulate rectangles,
% e.g., shift a rect 'r1' around by an x,y offset:
Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
% Present Image
Screen('DrawText', win,'Press space bar to start.', 600, 700, [0, 0, 0]);
Screen('Flip', win, 1);% present to the screen
KbWait;% Wait for a key press

switch phase
    case 1
        % %%%% start preference test
        % % Load image file into matlab
        FileName = '/Users/shaunogrady/desktop/LPGP2/Images/prefCheck.jpg';% select the filename for the current trial
        Stim = imread(FileName);% read in the image
        Texture = Screen('MakeTexture', win, Stim);% read in the image
        % % % Present Image
        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
        Screen('DrawText', win,'In this game, you will collect marbles like the ones on the screen.', 400, 50, [0, 0, 0]);
        Screen('DrawText', win,'Before we begin please tell me which color marble you like best:', 400, 100, [0, 0, 0]);
        Screen('DrawText', win,'Press ''G'' if you like green marbles.', 200, 800, [0, 0, 0]);
        Screen('DrawText', win,'Press ''P'' if you like purple marbles.', 800, 800, [0, 0, 0]);
        %Restrict keys
        RestrictKeysForKbCheck([10 19]);
        Screen('Flip', win, 1);% present to the screen
        WaitSecs(.5);
        KbWait;% Wait for a key press
        % % % Collect keyboard      response
        [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
        response=KbName(keyCode);
        % get filenames:
        switch response
            case 'p'
                StimList= dir([StimuliFolder 'Purple_*.jpg']);
                preference = 'p';
            case 'g'
                StimList = dir([StimuliFolder 'Green_*.jpg']);
                preference = 'g';
        end
    case 3
        load(Outputfile);
        preference = Assessment_Results.data(1,2);
        switch preference
            case 1
                StimList= dir([StimuliFolder 'Purple_*.jpg']);
                preference = 'p';
            case 0
                StimList = dir([StimuliFolder 'Green_*.jpg']);
                preference = 'g';
        end
end

% Begin instructions:
% In this game you will collect your favorite color marble by choosing one
% of these gumball machines. We will play the first round together so I can show you how to play
FileName = '/Users/shaunogrady/desktop/LPGP2/Images/emptyMachines.jpg';% select the filename for the current trial
Stim = imread(FileName);% read in the image
Texture = Screen('MakeTexture', win, Stim);% read in the image
% Present Image
Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
Screen('DrawText', win,'Try to collect your favorite marble by choosing one of the gumball machines.', 250, 75, [0, 0, 0]);
Screen('DrawText', win,'Press ''Z'' for this machine.', 450, 750, [0, 0, 0]);
Screen('DrawText', win,'Press ''M'' for this machine.', 750, 750, [0, 0, 0]);
Screen('Flip', win, 1);% present to the screen
RestrictKeysForKbCheck([]);
WaitSecs(.5);
KbWait;% Wait for a key press

trials= randperm(length(StimList));
% for loop should start here
for trial=1:length(StimList)
    %Load image file into matlab
    FileName = StimList(trials(trial)).name;% select the filename for the current trial
    countOrder = randperm(4);
    Stim = imread([StimuliFolder FileName]);% read in the image
    Texture = Screen('MakeTexture', win, Stim);% read in the image
    for countQ = 1:length(countOrder)
        count=countOrder(countQ);
        RestrictKeysForKbCheck([30 31 32 33 34 35 36 37 38 39]);
        switch count
            case 1 % get kids count for green on left side
                %Present Image
                %number of green marbles on left side:
                if (preference == 'p')
                    ActualCount = FileName((length(FileName)-10):(length(FileName)-10));
                else
                    ActualCount = FileName((length(FileName)-12):(length(FileName)-12));
                end
                Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                x2 = trial*60;
                r1 = [0 0 x2 50];
                Screen('FillRect',win, [128, 128, 0], r1, 1);
                Screen('DrawText', win,'How many             marbles are on this side?', 200, 800, [0, 0, 0]);
                Screen('DrawText', win,'                   green                          ', 200, 800, [0, 128, 0]);
                Screen('Flip', win, 1);% present to the screen
                WaitSecs(.5);
                KbWait;% Wait for a key press
                % Collect keyboard response
                [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                response=KbName(keyCode);
                check1 = str2double(response(1));
                WaitSecs(.5);
                % this statement ensures that the child knows the exact number
                if (check1 ~=str2double(ActualCount))
                    keyRest= str2double(strcat('3',ActualCount))-1;
                    RestrictKeysForKbCheck(keyRest);
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win, 'Actually, there are ', 200, 725, [0, 0, 0]);
                    phrase1=strcat(ActualCount, ' green marble(s) are on this side.');
                    Screen('DrawText', win,phrase1, 200, 775, [0, 0, 0]);
                    phrase2a=['Please press ', num2str(ActualCount)];
                    phrase2b=strcat(phrase2a, ' to continue.');
                    Screen('DrawText', win,phrase2b, 200, 825, [0, 0, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check1 = str2double(response(1));
                    WaitSecs(.5);
                    RestrictKeysForKbCheck([]);
                end
            case 2 % get kids count for purple on left side
                %number of green marbles on left side:
                %number of green marbles on left side:
                if (preference == 'p')
                    ActualCount = FileName((length(FileName)-12):(length(FileName)-12));
                else
                    ActualCount = FileName((length(FileName)-10):(length(FileName)-10));
                end
                %Present Image
                Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                x2 = trial*60;
                r1 = [0 0 x2 50];
                Screen('FillRect',win, [128, 128, 0], r1, 1);
                Screen('DrawText', win,'How many              marbles are on this side?', 200, 800, [0, 0, 0]);
                Screen('DrawText', win,'                   purple                          ', 200, 800, [128, 0, 128]);
                Screen('Flip', win, 1);% present to the screen
                WaitSecs(.5);
                KbWait;% Wait for a key press
                % Collect keyboard response
                [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                response=KbName(keyCode);
                check2 = str2double(response(1));
                WaitSecs(.5);
                % this statement ensures that the child knows the exact number
                if (check2 ~=str2double(ActualCount))
                    keyRest= str2double(strcat('3',ActualCount))-1;
                    RestrictKeysForKbCheck(keyRest);
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win, 'Actually, there are ', 200, 725, [0, 0, 0]);
                    phrase1=strcat(ActualCount, ' purple marble(s) are on this side.');
                    Screen('DrawText', win,phrase1, 200, 775, [0, 0, 0]);
                    phrase2a=['Please press ', num2str(ActualCount)];
                    phrase2b=strcat(phrase2a, ' to continue.');
                    Screen('DrawText', win,phrase2b, 200, 825, [0, 0, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check1 = str2double(response(1));
                    WaitSecs(.5);
                    RestrictKeysForKbCheck([]);
                end
            case 3 % get kids count for green on right side
                %number of green marbles on left side:
                %number of green marbles on left side:
                if (preference == 'p')
                    ActualCount = FileName((length(FileName)-6):(length(FileName)-6));
                else
                    ActualCount = FileName((length(FileName)-8):(length(FileName)-8));
                end
                %Present Image
                Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                x2 = trial*60;
                r1 = [0 0 x2 50];
                Screen('FillRect',win, [128, 128, 0], r1, 1);
                Screen('DrawText', win,'How many             marbles are on this side?', 800, 800, [0, 0, 0]);
                Screen('DrawText', win,'                   green                          ', 800, 800, [0, 128, 0]);
                Screen('Flip', win, 1);% present to the screen
                WaitSecs(.5);
                KbWait;% Wait for a key press
                % Collect keyboard response
                [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                response=KbName(keyCode);
                check3 = str2double(response(1));
                WaitSecs(.5);
                % this statement ensures that the child knows the exact number
                if (check3 ~=str2double(ActualCount))
                    keyRest= str2double(strcat('3',ActualCount))-1;
                    RestrictKeysForKbCheck(keyRest);
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win, 'Actually, there are ', 800, 725, [0, 0, 0]);
                    phrase1=strcat(ActualCount, ' green marble(s) are on this side.');
                    Screen('DrawText', win,phrase1, 800, 775, [0, 0, 0]);
                    phrase2a=['Please press ', num2str(ActualCount)];
                    phrase2b=strcat(phrase2a, ' to continue.');
                    Screen('DrawText', win,phrase2b, 800, 825, [0, 0, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check1 = str2double(response(1));
                    WaitSecs(.5);
                    RestrictKeysForKbCheck([]);
                end
            case 4 % get kids count for purple on right side
                %number of green marbles on left side:
                %number of green marbles on left side:
                if (preference == 'p')
                    ActualCount = FileName((length(FileName)-8):(length(FileName)-8));
                else
                    ActualCount = FileName((length(FileName)-6):(length(FileName)-6));
                end%Present Image
                Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                x2 = trial*60;
                r1 = [0 0 x2 50];
                Screen('FillRect',win, [128, 128, 0], r1, 1);
                Screen('DrawText', win,'How many              marbles are on this side?', 800, 800, [0, 0, 0]);
                Screen('DrawText', win,'                   purple                          ', 800, 800, [128, 0, 128]);
                Screen('Flip', win, 1);% present to the screen
                WaitSecs(.5);
                KbWait;% Wait for a key press
                % Collect keyboard response
                [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                response=KbName(keyCode);
                check4 = str2double(response(1));
                WaitSecs(.5);
                % this statement ensures that the child knows the exact number
                if (check4 ~=str2double(ActualCount))
                    keyRest= str2double(strcat('3',ActualCount))-1;
                    RestrictKeysForKbCheck(keyRest);
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win, 'Actually, there are ', 800, 725, [0, 0, 0]);
                    phrase1=strcat(ActualCount, ' purple marble(s) are on this side.');
                    Screen('DrawText', win,phrase1, 800, 775, [0, 0, 0]);
                    phrase2a=['Please press ', num2str(ActualCount)];
                    phrase2b=strcat(phrase2a, ' to continue.');
                    Screen('DrawText', win,phrase2b, 800, 825, [0, 0, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check1 = str2double(response(1));
                    WaitSecs(.5);
                    RestrictKeysForKbCheck([]);
                end
        end
    end
    RestrictKeysForKbCheck([]);
    
    %Present Image
    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
    x2 = trial*60;
    r1 = [0 0 x2 50];
    Screen('FillRect',win, [128, 128, 0], r1, 1);
    RestrictKeysForKbCheck([29 16]);% Restrict keys to 'z' (29) and'm' (16)
    Screen('DrawText', win,'Which would you pick to get a              marble?', 250, 75, [0, 0, 0]);
        if (preference == 'g') 
            Screen('DrawText', win,'                                                 green             ', 250, 75, [0, 128, 0]);
        else
            Screen('DrawText', win,'                                                 purple             ', 250, 75, [128, 0, 128]);
        end
    Screen('DrawText', win,'Press ''Z'' for this machine.', 450, 750, [0, 0, 0]);
    Screen('DrawText', win,'Press ''M'' for this machine.', 750, 750, [0, 0, 0]);
    Screen('Flip', win, 1);% present to th  m3514e screen
    WaitSecs(.5);
    KbWait;% Wait for a key press
    % Collect keyboard response
    [~, ~, keyCode, ~] = KbCheck;% Wait for and checkwhich key was pressed
    response=KbName(keyCode);
    responsenumber=KbName(response);
    % record data & Create results file:
    trialName=StimList(trials(trial)).name;
    % Turn trials(trial) indicator into a numeric variable for recording into results
    % file
    trialIndicator = trialName((length(trialName)-17):(length(trialName)-14));
    switch trialIndicator
        case 'GGGG'
            trialInd= 2222;
        case 'SSSS'
            trialInd= 1111;
        case 'SSSG'
            trialInd= 1112;
        case 'GGGS'
            trialInd= 2221;
    end
    side = trialName((length(trialName)-4):(length(trialName)-4));
    switch side
        case 'R'
            switch preference
                case 'g'
                    CorrectGreen = trialName((length(trialName)-8):(length(trialName)-8));
                    CorrectPurple = trialName((length(trialName)-6):(length(trialName)-6));
                    InCorrectGreen = trialName((length(trialName)-12):(length(trialName)-12));
                    InCorrectPurple = trialName((length(trialName)-10):(length(trialName)-10));
                    sideNum = 1;
                    prefNum = 0;
                case 'p'
                    CorrectPurple = trialName((length(trialName)-8):(length(trialName)-8));
                    CorrectGreen = trialName((length(trialName)-6):(length(trialName)-6));
                    InCorrectPurple = trialName((length(trialName)-12):(length(trialName)-12));
                    InCorrectGreen = trialName((length(trialName)-10):(length(trialName)-10));
                    sideNum = 1;
                    prefNum = 1;
            end
        case 'L'
            switch preference
                case 'g'
                    CorrectGreen = trialName((length(trialName)-12):(length(trialName)-12));
                    CorrectPurple = trialName((length(trialName)-10):(length(trialName)-10));
                    InCorrectGreen = trialName((length(trialName)-8):(length(trialName)-8));
                    InCorrectPurple = trialName((length(trialName)-6):(length(trialName)-6));
                    sideNum = 0;
                    prefNum = 0;
                case 'p'
                    CorrectPurple = trialName((length(trialName)-12):(length(trialName)-12));
                    CorrectGreen = trialName((length(trialName)-10):(length(trialName)-10));
                    InCorrectPurple = trialName((length(trialName)-8):(length(trialName)-8));
                    InCorrectGreen = trialName((length(trialName)-6):(length(trialName)-6));
                    sideNum = 0;
                    prefNum = 1;
            end
    end
    Assessment_Results.data(trial,:)=[str2double(thissub) prefNum strategy stratScore condition order trial str2double(CorrectGreen) str2double(CorrectPurple) str2double(InCorrectGreen) str2double(InCorrectPurple) check1 check2 check3 check4 sideNum responsenumber age trialInd phase];
    Assessment_Results.headers='thissub preference(0=green;1=purple) strategy strategy_score condition order trial CorrectGreen CorrectPurple InCorrectGreen InCorrectPurple CountGreenCorrect CountPurpleCorrect CountGreenInCorrect CountPurpleInCorrect side(0=left;1=right) responsenumber(29=z/16=m) ParticipantAge trialInd phase';
    % Present background
    NextImage =   'startScreen.jpg'  ;% projects the image of two bags and Big Bird
    Stim = imread(['/Users/shaunogrady/desktop/LPGP2/Images/' NextImage]);% read in the image
    Texture = Screen('MakeTexture', win, Stim);% read in the image
    Screen('DrawTexture', win, Texture);
    Screen('Flip', win, 1);% present to the screen
    WaitSecs(.5);
    
    %%% Break
    if trial == 12% When the number of trials reaches half the totalmm2222
        RestrictKeysForKbCheck([]);% Restrict keys to no key i.e., norestrictions  zz zz
        name = 'Kiwi1.mov';
        moviename = ['/Users/shaunogrady/desktop/LPGP2/Images/' name];
        try
            % Open movie file:
            movie = Screen('OpenMovie', win, moviename);
            % Start playback engine:
            Screen('PlayMovie', movie, 1);
            % Playback loop: Runs until end of movie or keypress:
            while ~KbCheck
                % Wait for next movie frame, retrieve texture handle to it
                tex = Screen('GetMovieImage', win, movie);
                % Valid texture returned? A negative value means end of movie reached:
                if tex<=0
                    %We're done, break out of loop:
                    break;
                end
                % Draw the new texture immediately to screen:
                Screen('DrawTexture', win, tex);
                % Update display:
                Screen('Flip', win);
                % Release texture:
                Screen('Close', tex);
            end
            % Stop playback:
            Screen('PlayMovie', movie, 0);
            % Close movie:
            Screen('CloseMovie', movie);
        catch
            psychrethrow(psychlasterror);
            sca;
        end
        WaitSecs(.5);
        RestrictKeysForKbCheck([]);% Restrict keys to no key i.e., norestrictions
        NextImage =   'startScreen.jpg'  ;% projects the image of two bags and Big Bird
        Stim = imread(['/Users/shaunogrady/desktop/LPGP2/Images/' NextImage]);% read in the image
        Texture = Screen('MakeTexture', win, Stim);% read in the image
        Screen('DrawTexture', win, Texture);
        Screen('Flip', win, 1);% present to the screen
        WaitSecs(.5);
        KbWait; % Wait for a key press
    end
end
% % % Thank you Screen % % %
RestrictKeysForKbCheck([]);
white=WhiteIndex(win);
Screen('FillRect', win, white);
Screen('TextSize',win, 30);
Screen('TextFont',win,'Courier New');
Screen('TextStyle', win, 1);
Screen('DrawText', win,'Thank you for playing our game!', 200, 225, [0, 0, 0]);
Screen('TextSize',win, 25);
Screen(win,'Flip');% present to the screen. This is the command toactually present whatever you have made 'win'
WaitSecs(.5);
KbWait;
% identifies the strategy used by the participant:
W_to_L_score = 0; % pick the one with a larger number of target marbles
L_to_W_score  = 0;  % pick the one with a smaller number of losing marbles
W_minus_L_score = 0; % pick the one with a greater difference W-L
proportion  = 0;    % correct proportional strategy
thisParticipant = Assessment_Results;
for trial=1:24
    trialInd= num2str(thisParticipant.data(trial,19));
    %## greater win strategy (greater target number)
    %identifies 'gggg' trials:
    if (trialInd(1)=='2' && ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==29) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==16)))
        W_to_L_score = W_to_L_score+1;
    end
    %identifies 'ssss' trials:
    if (trialInd(1)=='1' && ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==16) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==29)))
        W_to_L_score = W_to_L_score+1;
    end
    %  ## smaller Loss: strategy (smaller non-target number)
    if (trialInd(1)=='1' && ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==29) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==16)))
        L_to_W_score = L_to_W_score+1;
        %trial;
    end
    if (trialInd(1)=='2' && ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==16) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==29)))
        L_to_W_score = L_to_W_score+1;
        %trial;
    end
    % ## greater difference: strategy (larger difference between win and loss)
    if (trialInd(4) == '2' && ((thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==16) || (thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==29)))
        W_minus_L_score = W_minus_L_score+1;
    end
    if (trialInd(4) == '1'&& ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==16) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==29)))
        W_minus_L_score = W_minus_L_score+1;
    end
    %   ## proportional strategy
    if ((thisParticipant.data(trial,16)==0 && thisParticipant.data(trial,17)==29) || (thisParticipant.data(trial,16)==1 && thisParticipant.data(trial,17)==16))
        proportion = proportion + 1;
    end
end
strategyScores = [W_to_L_score L_to_W_score W_minus_L_score proportion];
% identify the child's strategy:
[M, I] = max(strategyScores);
Assessment_Results.data(:,4)=M;
Assessment_Results.data(:,3) = I;
end

function[Conflict_Results] =conflictPhase(thissub, condition, order, Outputfile)
ListenChar(2);
%%%% Now the    participant plays the Conflict game and is given trials
% %%% that conflict with their strategy  mm4162m
% %%% for now the outcomes are generated deterministically meaning
% %%% that every time the child makes the incorrect choice they
% %%% recieve the non-target marble color (purple)
% %%% the game continues until the child chooses correctly on 8-10
% %%% consecutive trials or until a total of 24 trials is completed.
try
    %load in child's data from Assessment phase
    load(Outputfile);
    age = Assessment_Results.data(1,18);
    stratScore= Assessment_Results.data(1,4);
    %identify strategy
    strategy = Assessment_Results.data(1,3);
    %identify preference
    preference = Assessment_Results.data(1,2);
    switch preference
        case 0
            preference = 'G';
        case 1
            preference = 'P';
    end
    %set stimuli folder
    switch strategy
        case 1 % greater win strategy
            switch condition
                case 1 % Low conflict
                    switch order % this line ensures that the 24 trials they recieve are
                        %from the opposite order to which they were assigned in the
                        %Assessment phase thus ensuring that the
                        %images they view in the conflict phase are
                        %new
                        case 1
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order2/';
                        case 2
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order1/';
                    end
                case 2 % High conflict
                    ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Conflict/Strat1/';
            end
        case 2 % lower loss strategy
            switch condition
                case 1 % Low conflict
                    switch order % this line ensures that the 24 trials they recieve are
                        %from the opposite order to which they were assigned in the
                        %Assessment phase thus ensuring that the
                        %images they view in the conflict phase are
                        %new
                        case 1
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order2/';
                        case 2
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order1/';
                    end
                case 2 % High conflict
                    ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Conflict/Strat2/';
            end
        case 3 % greater difference strategy
            switch condition
                case 1 % Low conflict
                    switch order % this line ensures that the 24 trials they recieve are
                        %from the opposite order to which they were assigned in the
                        %Assessment phase thus ensuring that the
                        %images they view in the conflict phase are
                        %new
                        case 1
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order2/';
                        case 2
                            ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order1/';
                    end
                case 2 % High conflict
                    ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Conflict/Strat3/';
            end
        case 4 % greater proporiton strategy
            switch order % this line ensures that the 24 trials they recieve are
                %from the opposite order to which they were assigned in the
                %Assessment phase thus ensuring that the
                %images they view in the conflict phase are
                %new
                case 1
                    ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order2/';
                case 2
                    ConflictFolder ='/Users/shaunogrady/desktop/LPGP2/Images/Order1/';
            end
    end
    switch preference
        case 'G'
            ConflictStimList = dir([ConflictFolder 'Green_*.jpg']);
            prefWord=' green ';
        case 'P'
            ConflictStimList = dir([ConflictFolder 'Purple_*.jpg']);
            prefWord=' purple ';
    end
    
    
    % % % Present Instruction Screen % % %sho
    CompScreen = get(0,'ScreenSize');% Find out the size of this computerscreen
    win = Screen('OpenWindow',0, [900 900 1000], CompScreen); % Full sizedscreen
    white=WhiteIndex(win);
    %first introduction screen:
    NextImage =   'emptyMachines.jpg'  ;% projects the image of the two boxes
    Stim = imread(['/Users/shaunogrady/desktop/LPGP2/Images/' NextImage]);% read in the image
    Texture = Screen('MakeTexture', win, Stim);% read in the image
    Screen('DrawTexture', win, Texture);
    Screen(win,'Flip');% present to the screen. This is the command toactually present whatever you have made 'win'
    WaitSecs(.5);
    KbWait;
    %
    %Sec    ond introduction screen:
    Screen('FillRect', win, white);
    Screen('DrawText', win,'Pick the side that you think', 200, 225, [0, 0, 0]);
    instructionPhrase=strcat(strcat('will give you a ',prefWord),' marble.');
    Screen('DrawText',  win, instructionPhrase, 400, 250, [0, 0, 0]);
    Screen('DrawText', win,'Ready?', 100, 375, [0, 0, 0]);
    Screen('DrawText', win,'< Press any key when ready >', 400, 475, [0, 130,150]);
    Screen(win,'Flip');% present to the screen. This is the command toactually present whatever you have made 'win'
    WaitSecs(.5);
    KbWait;
    RestrictKeysForKbCheck([29 16]);% Restrict keys to 'z' (29) and'm' (16)
    
    trials= randperm(length(ConflictStimList));
    %%% present conflict trials:
    for trial=1:length(ConflictStimList)
        FileName = ConflictStimList(trials(trial)).name;
        Stim = imread([ConflictFolder FileName]);% read in the image
        Texture = Screen('MakeTexture', win, Stim);% read in the image
        % Load image file into matlab  m m32145
        countOrder = randperm(4);
        for countQ = 1:length(countOrder)
            count=countOrder(countQ);
            RestrictKeysForKbCheck([30 31 32 33 34 35 36 37 38 39]);
            switch count
                case 1 % get kids count for green on left side
                    %Present Image
                    if (preference == 'P')
                        ActualCount = FileName((length(FileName)-10):(length(FileName)-10));
                    else
                        ActualCount = FileName((length(FileName)-12):(length(FileName)-12));
                    end
                    %number of green marbles on left side:
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win,'How many             marbles are on this side?', 200, 800, [0, 0, 0]);
                    Screen('DrawText', win,'                   green                          ', 200, 800, [0, 128, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check1 = str2double(response(1));
                    WaitSecs(.5);
                    % this statement ensures that the child knows the exact number
                    if (check1 ~=str2double(ActualCount))
                        keyRest= str2double(strcat('3',ActualCount))-1;
                        RestrictKeysForKbCheck(keyRest);
                        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                        x2 = trial*60;
                        r1 = [0 0 x2 50];
                        Screen('FillRect',win, [128, 128, 0], r1, 1);
                        Screen('DrawText', win, 'Actually, there are ', 200, 725, [0, 0, 0]);
                        phrase1=strcat(ActualCount, ' green marble(s) are on this side.');
                        Screen('DrawText', win,phrase1, 200, 775, [0, 0, 0]);
                        phrase2a=['Please press ', num2str(ActualCount)];
                        phrase2b=strcat(phrase2a, ' to continue.');
                        Screen('DrawText', win,phrase2b, 200, 825, [0, 0, 0]);
                        Screen('Flip', win, 1);% present to the screen
                        WaitSecs(.5);
                        KbWait;% Wait for a key press
                        % Collect keyboard response
                        [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                        response=KbName(keyCode);
                        check1 = str2double(response(1));
                        WaitSecs(.5);
                        RestrictKeysForKbCheck([]);
                    end
                case 2 % get kids count for purple on left side
                    %number of green marbles on left side:
                    if (preference == 'P')
                        ActualCount = FileName((length(FileName)-12):(length(FileName)-12));
                    else
                        ActualCount = FileName((length(FileName)-10):(length(FileName)-10));
                    end
                    %Present Image
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win,'How many              marbles are on this side?', 200, 800, [0, 0, 0]);
                    Screen('DrawText', win,'                   purple                          ', 200, 800, [128, 0, 128]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check2 = str2double(response(1));
                    WaitSecs(.5);
                    % this statement ensures that the child knows the exact number
                    if (check2 ~=str2double(ActualCount))
                        keyRest= str2double(strcat('3',ActualCount))-1;
                        RestrictKeysForKbCheck(keyRest);
                        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                        x2 = trial*60;
                        r1 = [0 0 x2 50];
                        Screen('FillRect',win, [128, 128, 0], r1, 1);
                        Screen('DrawText', win, 'Actually, there are ', 200, 725, [0, 0, 0]);
                        phrase1=strcat(ActualCount, ' purple marble(s) are on this side.');
                        Screen('DrawText', win,phrase1, 200, 775, [0, 0, 0]);
                        phrase2a=['Please press ', num2str(ActualCount)];
                        phrase2b=strcat(phrase2a, ' to continue.');
                        Screen('DrawText', win,phrase2b, 200, 825, [0, 0, 0]);
                        Screen('Flip', win, 1);% present to the screen
                        WaitSecs(.5);
                        KbWait;% Wait for a key press
                        % Collect keyboard response
                        [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                        response=KbName(keyCode);
                        check1 = str2double(response(1));
                        WaitSecs(.5);
                        RestrictKeysForKbCheck([]);
                    end
                case 3 % get kids count for green on right side
                    %number of green marbles on left side:
                    if (preference == 'P')
                        ActualCount = FileName((length(FileName)-6):(length(FileName)-6));
                    else
                        ActualCount = FileName((length(FileName)-8):(length(FileName)-8));
                    end
                    %Present Image
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win,'How many             marbles are on this side?', 800, 800, [0, 0, 0]);
                    Screen('DrawText', win,'                   green                          ', 800, 800, [0, 128, 0]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check3 = str2double(response(1));
                    WaitSecs(.5);
                    % this statement ensures that the child knows the exact number
                    if (check3 ~=str2double(ActualCount))
                        keyRest= str2double(strcat('3',ActualCount))-1;
                        RestrictKeysForKbCheck(keyRest);
                        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                        x2 = trial*60;
                        r1 = [0 0 x2 50];
                        Screen('FillRect',win, [128, 128, 0], r1, 1);
                        Screen('DrawText', win, 'Actually, there are ', 800, 725, [0, 0, 0]);
                        phrase1=strcat(ActualCount, ' green marble(s) are on this side.');
                        Screen('DrawText', win,phrase1, 800, 775, [0, 0, 0]);
                        phrase2a=['Please press ', num2str(ActualCount)];
                        phrase2b=strcat(phrase2a, ' to continue.');
                        Screen('DrawText', win,phrase2b, 800, 825, [0, 0, 0]);
                        Screen('Flip', win, 1);% present to the screen
                        WaitSecs(.5);
                        KbWait;% Wait for a key press
                        % Collect keyboard response
                        [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                        response=KbName(keyCode);
                        check1 = str2double(response(1));
                        WaitSecs(.5);
                        RestrictKeysForKbCheck([]);
                    end
                case 4 % get kids count for purple on right side
                    %number of green marbles on left side:
                    if (preference == 'P')
                        ActualCount = FileName((length(FileName)-8):(length(FileName)-8));
                    else
                        ActualCount = FileName((length(FileName)-6):(length(FileName)-6));
                    end%Present Image
                    Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                    x2 = trial*60;
                    r1 = [0 0 x2 50];
                    Screen('FillRect',win, [128, 128, 0], r1, 1);
                    Screen('DrawText', win,'How many              marbles are on this side?', 800, 800, [0, 0, 0]);
                    Screen('DrawText', win,'                   purple                          ', 800, 800, [128, 0, 128]);
                    Screen('Flip', win, 1);% present to the screen
                    WaitSecs(.5);
                    KbWait;% Wait for a key press
                    % Collect keyboard response
                    [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                    response=KbName(keyCode);
                    check4 = str2double(response(1));
                    WaitSecs(.5);
                    % this statement ensures that the child knows the exact number
                    if (check4 ~=str2double(ActualCount))
                        keyRest= str2double(strcat('3',ActualCount))-1;
                        RestrictKeysForKbCheck(keyRest);
                        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
                        x2 = trial*60;
                        r1 = [0 0 x2 50];
                        Screen('FillRect',win, [128, 128, 0], r1, 1);
                        Screen('DrawText', win, 'Actually, there are ', 800, 725, [0, 0, 0]);
                        phrase1=strcat(ActualCount, ' purple marble(s) are on this side.');
                        Screen('DrawText', win,phrase1, 800, 775, [0, 0, 0]);
                        phrase2a=['Please press ', num2str(ActualCount)];
                        phrase2b=strcat(phrase2a, ' to continue.');
                        Screen('DrawText', win,phrase2b, 800, 825, [0, 0, 0]);
                        Screen('Flip', win, 1);% present to the screen
                        WaitSecs(.5);
                        KbWait;% Wait for a key press
                        % Collect keyboard response
                        [~, ~, keyCode, ~] = KbCheck;% Wait for and check which key was pressed
                        response=KbName(keyCode);
                        check1 = str2double(response(1));
                        WaitSecs(.5);
                        RestrictKeysForKbCheck([]);
                    end
            end
        end
        RestrictKeysForKbCheck([]);
        Texture = Screen('MakeTexture', win, Stim);% read in the image
        %Present Image
        Screen('DrawTexture', win, Texture);% Draw the image to the screen'win'
        x2 = trial*60;
        r1 = [0 0 x2 50];
        Screen('FillRect',win, [128, 128, 0], r1, 1);      
        RestrictKeysForKbCheck([29 16]);% Restrict keys to 'z' (29) and'm' (16)
        Screen('DrawText', win,'Which would you pick to get a              marble?', 250, 75, [0, 0, 0]);
        if (strcmp(prefWord, ' green ')) 
            Screen('DrawText', win,'                                                 green             ', 250, 75, [0, 128, 0]);
        else
            Screen('DrawText', win,'                                                 purple             ', 250, 75, [128, 0, 128]);
        end 
        Screen('DrawText', win,'Press ''Z'' for this machine.', 450, 750, [0, 0, 0]);
        Screen('DrawText', win,'Press ''M'' for this machine.', 750, 750, [0, 0, 0]);
        Screen('Flip', win, 1);% present to th  m3514e screen
        WaitSecs(.5);
        KbWait;% Wait for a key press
        % Collect keyboard response
        [~, ~, keyCode, ~] = KbCheck;% Wait for and checkwhich key was pressed
        response=KbName(keyCode);
        responsenumber=KbName(response);
        % record data & Create results file:
        trialName=ConflictStimList(trials(trial)).name;
        % Turn trials(trial) indicator into a numeric variable for recording into results
        % file
        trialIndicator = trialName((length(trialName)-17):(length(trialName)-14));
        switch trialIndicator
            case 'GGGG'
                trialInd= 2222;
            case 'SSSS'
                trialInd= 1111;
            case 'SSSG'
                trialInd= 1112;
            case 'GGGS'
                trialInd= 2221;
        end
        side = trialName((length(trialName)-4):(length(trialName)-4));
        switch side
            case 'R'
                switch preference
                    case 'G'
                        CorrectGreen = trialName((length(trialName)-8):(length(trialName)-8));
                        CorrectPurple = trialName((length(trialName)-6):(length(trialName)-6));
                        InCorrectGreen = trialName((length(trialName)-12):(length(trialName)-12));
                        InCorrectPurple = trialName((length(trialName)-10):(length(trialName)-10));
                        sideNum = 1;
                        prefNum = 0;
                    case 'P'
                        CorrectPurple = trialName((length(trialName)-8):(length(trialName)-8));
                        CorrectGreen = trialName((length(trialName)-6):(length(trialName)-6));
                        InCorrectPurple = trialName((length(trialName)-12):(length(trialName)-12));
                        InCorrectGreen = trialName((length(trialName)-10):(length(trialName)-10));
                        sideNum = 1;
                        prefNum = 1;
                end
            case 'L'
                switch preference
                    case 'G'
                        CorrectGreen = trialName((length(trialName)-12):(length(trialName)-12));
                        CorrectPurple = trialName((length(trialName)-10):(length(trialName)-10));
                        InCorrectGreen = trialName((length(trialName)-8):(length(trialName)-8));
                        InCorrectPurple = trialName((length(trialName)-6):(length(trialName)-6));
                        sideNum = 0;
                        prefNum = 0;
                    case 'P'
                        CorrectPurple = trialName((length(trialName)-12):(length(trialName)-12));
                        CorrectGreen = trialName((length(trialName)-10):(length(trialName)-10));
                        InCorrectPurple = trialName((length(trialName)-8):(length(trialName)-8));
                        InCorrectGreen = trialName((length(trialName)-6):(length(trialName)-6));
                        sideNum = 0;
                        prefNum = 1;
                end
        end
        phase = 2;
        Conflict_Results.data(trial,:)=[str2double(thissub) prefNum strategy stratScore condition order trial str2double(CorrectGreen) str2double(CorrectPurple) str2double(InCorrectGreen) str2double(InCorrectPurple) check1 check2 check3 check4 sideNum responsenumber age trialInd phase];
        Conflict_Results.headers='thissub preference(0=green;1=purple) strategy strategy_score condition order trial CorrectGreen CorrectPurple InCorrectGreen InCorrectPurple CountGreenCorrect CountPurpleCorrect CountGreenInCorrect CountPurpleInCorrect side(0=left;1=right) responsenumber(29=z/16=m) ParticipantAge trialInd phase';
        % If the  participant chooses the wrong side, they are shown the non-target outcome
        correctSide = FileName((length(FileName)-4):(length(FileName)-4));
        if (responsenumber == 29 && correctSide=='L')
            switch preference
                case 'G'
                    NextImage = 'leftGreen.jpg';
                    marble='green';
                case 'P'
                    NextImage = 'leftPurple.jpg';
                    marble='purple';
            end
        end
        if (responsenumber == 29 && correctSide=='R')
            switch preference
                case 'P'
                    NextImage = 'leftGreen.jpg';
                    marble='green';
                case 'G'
                    NextImage = 'leftPurple.jpg';
                    marble='purple';
            end
        end
        if (responsenumber == 16 && correctSide=='L')
            switch preference
                case 'P'
                    NextImage = 'rightGreen.jpg';
                    marble='green';
                case 'G'
                    NextImage = 'rightPurple.jpg';
                    marble='purple';
            end
        end
        if (responsenumber == 16 && correctSide=='R')
            switch preference
                case 'G'
                    NextImage = 'rightGreen.jpg';
                    marble='green';
                case 'P'
                    NextImage = 'rightPurple.jpg';
                    marble='purple';
            end%
        end
        
        % Present feedback m m5132z
        Stim = imread(['/Users/shaunogrady/desktop/LPGP2/Images/' NextImage]);% read in the image
        Texture = Screen('MakeTexture', win, Stim);% read in the image
        Screen('DrawTexture', win, Texture);
        Screen('DrawText', win,['You got a ', marble, ' marble.'], 600, 800, [0, 0, 0]);
        Screen('Flip', win, 1);% present to the screen
        WaitSecs(.5);
        
        %%% Break
        if trial == 12% When the number of trials reaches half the totalmm2222
            RestrictKeysForKbCheck([]);% Restrict keys to no key i.e., norestrictions  zz zz
            name = 'Kiwi2.mov';
            moviename = ['/Users/shaunogrady/desktop/LPGP2/Images/' name];
            try
                % Open movie file:
                movie = Screen('OpenMovie', win, moviename);
                % Start playback engine:
                Screen('PlayMovie', movie, 1);
                % Playback loop: Runs until end of movie or keypress:
                while ~KbCheck
                    % Wait for next movie frame, retrieve texture handle to it
                    tex = Screen('GetMovieImage', win, movie);
                    % Valid texture returned? A negative value means end of movie reached:
                    if tex<=0
                        %We're done, break out of loop:
                        break;
                    end
                    % Draw the new texture immediately to screen:
                    Screen('DrawTexture', win, tex);
                    % Update display:
                    Screen('Flip', win);
                    % Release texture:
                    Screen('Close', tex);
                end
                % Stop playback:
                Screen('PlayMovie', movie, 0);
                % Close movie:
                Screen('CloseMovie', movie);
            catch
                psychrethrow(psychlasterror);
                sca;
            end
            WaitSecs(.5);
            RestrictKeysForKbCheck([]);% Restrict keys to no key i.e., norestrictions
            NextImage =   'startScreen.jpg'  ;% projects the image of two bags and Big Bird
            Stim = imread(['/Users/shaunogrady/desktop/LPGP2/Images/' NextImage]);% read in the image
            Texture = Screen('MakeTexture', win, Stim);% read in the image
            Screen('DrawTexture', win, Texture);
            Screen('Flip', win, 1);% present to the screen
            WaitSecs(.5);
            KbWait; % Wait for a key press
        end
    end
    % % % Thank you Screen % % %
    RestrictKeysForKbCheck([]);
    white=WhiteIndex(win);
    Screen('FillRect', win, white);
    Screen('TextSize',win, 30);
    Screen('TextFont',win,'Courier New');
    Screen('TextStyle', win, 1);
    Screen('DrawText', win,'Thank you for playing our game!', 200, 225, [0, 0, 0]);
    Screen('TextSize',win, 25);
    Screen(win,'Flip');% present to the screen. This is the command toactually present whatever you have made 'win'
    WaitSecs(.5);
    KbWait;
    Conflict_Results.data = vertcat(Assessment_Results.data, Conflict_Results.data);
    % % % Thank you Screen % % %
    Stim = imread('/Users/shaunogrady/desktop/LPGP2/Images/emptyMachines.jpg');% read in the image
    Texture = Screen('MakeTexture', win, Stim);% read in the image
    Screen('DrawTexture', win, Texture);
    Screen('Flip', win, 1);% present to the screen
    %present whatever you have made 'win'
    WaitSecs(.5);
    KbWait;
    sca;% S zcreen Close All %%% Important! %%%
    
catch
    psychrethrow(psychlasterror);
    sca;
end

end

