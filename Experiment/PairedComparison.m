function PairedComparison
% This is a paried-Comparison experiment. 
% Observer is asked to compare two videos of fabrics 
% and judge the relative material properties on a scale from 0 to 8.
%
  
  Screen('Preference', 'SkipSyncTests', 1)
  screenNumber = max(Screen('Screens'));
  gray=GrayIndex(screenNumber);
  [w, wRect]=Screen('OpenWindow',screenNumber, gray);
    
% 
% get all paths. 
load('SAP2016_Path.mat');  

% get all parameters
 try
     load(['GetParameters_PairedComparison_',num2str(wRect(3)),'*',num2str(wRect(4)),'.mat']);
 catch
     clear mex;
     clear all;
     error ('Run <GetParameters_PairedComparison.m> to get parameters for this display screen first!!')
 end


% Results data file
  dataFileName = [theSbj, '_', exptName,'_',num2str(blockNumber),'_',expDate(1:6), expDate(10:11), '_',...
    num2str(expTime(4)), '_', num2str(expTime(5)), '.txt'];


%% =================  Instruction Screen =================================% 
% Read instrucion from file:
  fd = fopen('Instruction.m');

  Intro = '';
  tl = fgets(fd);
  lcount = 0;
  while lcount < 48
        Intro = [Intro tl]; 
        tl = fgets(fd);
        lcount = lcount + 1;
  end

  fclose(fd);
  Intro = [Intro char(10)];
% Get rid of '% ' symbols at the start of each line:
  Intro = strrep(Intro, '% ', '');
  Intro = strrep(Intro, '%', '');

  
  Screen ('TextSize', w, 26);
% Define test start postion (x,y)=(0.0078*wRect(3),0.0250*wRect(4))
  DrawFormattedText(w, Intro,0.0078*wRect(3),0.0250*wRect(4));
  Screen('Flip', w);

  
% Press q to move on
  flag = true;
  while flag
        KbWait();
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck; % Wait for and checkwhich key was pressed
        Intro_response = KbName(keyCode);   
        if Intro_response == 'q'
            flag = false;
        end
         
        if (keyCode(targetexit))==1
            Screen('CloseAll');
            ShowCursor;
            fclose('all');
            fprintf('Quit.\n');
            return;
        end
  end


 %% =================  Experiment ========================================%    
ntrials = nConditions;
for trial=1:ntrials        
    % wait a bit between trials
      WaitSecs(0.5);
    
    % ===== Draw Fixation Cross ======%
      Screen('FillRect', w, color_white, FixCross_v);
      Screen('FillRect', w, color_white, FixCross_p);
      Screen('Flip', w);
      % Fixation lasts for 800ms
      WaitSecs(0.8);
      
    % ===== Place the sliding rating bar at a random place  
      a = slider_rect(1);
      b = slider_rect(3);
      r = (b-a).*rand(1,1) + a;
      random_clickX = round(r);
      rating_button_rect = [random_clickX-rating_button_w/2,rating_button_top,random_clickX+rating_button_w/2,rating_button_bottom];
      all_slider_rect = [slider_rect',next_button_rect',slider_tics, rating_button_rect'];

    % ===== Show Stimuli ============= %
    %% ===== 1.  read video stimulus  
      objName1 = [conditionNameRoot ,num2str(conditionStruct(trial).sample1),'.mov'];
      stimfilename1=strcat(char(objName1));   % assume stims are in subfolder "stims"
      moviename{1} = fullfile(stimDir, stimfilename1);
      
      objName2 = [conditionNameRoot ,num2str(conditionStruct(trial).sample2),'.mov'];
      stimfilename2=strcat(char(objName2));   % assume stims are in subfolder "stims"
      moviename{2} = fullfile(stimDir, stimfilename2);

      permvals = randperm(2);
      movie1 = Screen('OpenMovie', w, moviename{permvals(1)});
      movie2 = Screen('OpenMovie', w, moviename{permvals(2)});

    % play sound: indicates that video stimuli will come
      Snd('Play', sin(0:800), 8000);
      [VBLTimestamp, startrt]= Screen('Flip', w);
    
    
    %% ===== 2.  display All Stimuli
      % Display two videos
      Screen('PlayMovie', movie1, 1, 1, 0);
      Screen('PlayMovie', movie2, 1, 1, 0); 
    
    % Playback loop: Runs until end of movie or keypress: 
      % Start recording reaction time
      startrt=GetSecs();
      tic;
      res = 5;
      numClicks = 0;
      exitFlag = 0;
    % won't move to next trial when: 
        % 1) looking time <=5s; 2) number of clicks <2; 
      while (toc<res || numClicks<2 || exitFlag~=1)
            % Wait for next movie frame, retrieve texture handle to it
            texture1 = Screen('GetMovieImage', w, movie1);
            texture2 = Screen('GetMovieImage', w, movie2);
            % Valid texture returned? A negative value means end of movie reached:
            if texture1>0
               % Draw the new texture immediately to screen:
               Screen('DrawTexture', w, texture1, [], rect1);
               % Release texture, save memory;
               Screen('Close', texture1); 
               % Marker size
               Screen('TextSize', w, marker_size);
               DrawFormattedText(w, 'Left', left_x, left_y, WhiteIndex(w)); % Show Marker "Left"
            end          
            % Valid texture returned? A negative value means end of movie reached:
            if texture2>0
                % Draw the new texture immediately to screen:
                Screen('DrawTexture', w, texture2, [], rect2);
                % Release texture, save memory:
                Screen('Close', texture2);
                % Marker size
                Screen('TextSize', w, marker_size);
                DrawFormattedText(w, 'Right', right_x, right_y, WhiteIndex(w)); % Show Marker "Right"
            end
          
          
            % ===== Draw title of the task.
              Screen('TextSize', w, title_size);
              messagetitle1 = 'Please judge the difference in material properties of the two fabrics\n.';
              DrawFormattedText(w, messagetitle1, title_x(1), title_y(1), WhiteIndex(w));
              messagetitle2 = sprintf('Block %d, Trial %d / %d. Press "Next" after a judgement has been made and you are ready to move on to the next trial.\n',blockNumber,trial, ntrials);
              DrawFormattedText(w, messagetitle2, title_x(2), title_y(2), WhiteIndex(w));
              messagetitle3 = 'For each pair of videos you must indicate which video contains the stiffer material.';
              DrawFormattedText(w, messagetitle3, title_x(3), title_y(3), WhiteIndex(w));
            

            % ===== Draw all rating scales
              Screen('FillRect', w, all_slider_color,all_slider_rect);
              % Draw "NEXT" button
              Screen('TextSize', w, next_button_letter_size); 
              DrawFormattedText(w, next_button_letter,next_button_letter_x,next_button_letter_y, next_button_letter_color);  
              
  
            % ===== Draw scale_label
              Screen('TextSize', w, scale_label_size); 
              scale_low_label = 'Left is much stiffer';
              scale_hi_label = 'Right is much stiffer';
              scale_middle_label = 'About the same';
              
              DrawFormattedText(w, scale_low_label, scale_label_low_x,scale_label_y, scale_label_color);
              DrawFormattedText(w, scale_hi_label, scale_label_high_x,scale_label_y, scale_label_color);
              DrawFormattedText(w, scale_middle_label, scale_label_middle_x,scale_label_y, scale_label_color);
            
                        
            % ===== Draw & Update the sliding rating button       
              [xpos,ypos,buttons] = GetMouse(w);
              
              %clickX is the x position that the observer clicked
              clickX = round(xpos);
              
              % if clicked && the click is inside the range of bar
              if (buttons(1) > 0 && round(ypos)> rating_button_top && round(ypos) < rating_button_bottom && clickX-rating_button_w < slider_right && clickX+rating_button_w > slider_left)
                  response = round((clickX-slider_rect(1))/(sliderWidth/numTicks))
                  
                  % show a gray frame to cover the updated position
                  Screen('FillRect', w, gray,gray_rect);
                  % update the button rect position  
                  rating_button_rect = [clickX-rating_button_w/2,rating_button_top,clickX+rating_button_w/2,rating_button_bottom];
                  all_slider_rect = [slider_rect',next_button_rect',slider_tics, rating_button_rect'];
                  % display the slider with new button
                  Screen('FillRect', w, all_slider_color,all_slider_rect);
                  numClicks = numClicks + 1;
              end
              
              
              if  (xpos> next_button_rect(1)) && (xpos<next_button_rect(3)) && (ypos>next_button_rect(2)) && (ypos<next_button_rect(4) && buttons(1)~=0 && numClicks>1)
                  % If clicked the "next_button", exist
                  endrt = GetSecs();
                  exitFlag = 1;
                  Snd('Play', sin(0:400), 7000);
                  trialResp = response;
                  fprintf('%d',trialResp);
              end
              
              % If input 'e', quit the experiment.
              [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
              if (keyCode(targetexit))==1
                  Screen('CloseAll');
                  ShowCursor;
                  fclose('all');
                  fprintf('Quit.\n');
                  return;
              end
                  
            if (texture1>0 || texture2>0)
                vbl=Screen('Flip', w, 0, 1);
            end        
      end
      
      % Reaction Time
      rt=round(1000*(endrt-startrt));
    
      
      
     % Stop playback:
       Screen('PlayMovie', movie1, 0);
       Screen('PlayMovie', movie2, 0);
     % Close movie:
       Screen('CloseMovie', movie1);
       Screen('CloseMovie', movie2);       
     % Play sound: indicates end of displaying a trial.
       Snd('Play', sin(0:800), 10000)
       Screen('Flip', w);
        
     %============== Write trial result to a structure ================%
       subjectData(trial).subNo = theSbj;
       subjectData(trial).experimentName = exptName;
       subjectData(trial).taskName = taskName;
       subjectData(trial).nBlocks = blockNumber;
       subjectData(trial).trial = int2str(trial);
       subjectData(trial).stim1 = moviename{permvals(1)}(end-9:end);
       subjectData(trial).stim2 = moviename{permvals(2)}(end-9:end);
       subjectData(trial).response = trialResp;
       subjectData(trial).reactionTime = rt;
       subjectData(trial).numClicks = numClicks;
       subjectData(trial).stimOrder1 = num2str(permvals(1));
       subjectData(trial).stimOrder2 = num2str(permvals(2));
       fprintf('trial number %s\n',num2str(trial+1));
      % write data for each trial, in case the procedure freze halfway
       WriteStructsToText(fullfile(subjectDir, dataFileName), subjectData);
       fprintf('write data file for subject,%s\n',theSbj);      
end  % Forloop each trial
    
 
    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch Matlab/Octave back to priority 0 -- normal
    % priority:
       Screen('Flip', w);
       WaitSecs(0.500);
       Screen('CloseAll');
       ShowCursor;
       fclose('all');
       Priority(0);
       cd(curDir);
    % End of experiment:
       return;
 end