function GetParameters_PairedComparison
% To get parameters of the paried-Comparison experiment:
% Two videos/images are shown on the screen, participants rate their
% comparable properties on a rating scale.

% This code enables experimenter to change the lines of title, sclaing range (0~100), 
% video/Image size, Screen size.
%  


%% 00. Define Color
  color_red = [255 0 0];
  color_grey = [184 184 184];
  color_white = [255 255 255];
%  
%  
%% LISTS of SAVED & Changable PARAMETERS:
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Environment variable
% 
% # [X,Y]: screen center;
% # textRect_26(4): height of textsize 26;
% # textRect_24(4): height of textsize 24;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Fixation
% 
  FixCross_w = 1; % change to larger number if want widder fixation;
  FixCross_h = 40; % change to larger number if want taller fixation; 
% # FixCross_v: vertical line of the fixation;
% # FixCross_p: parellel line of the fixation;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Video/Image stimuli
%
% # video_width: width of the rescaled video stimuli (calculated from "original_video_width", default 1280);
% # video_height: height of the rescaled video stimuli (calculated from "original_video_height", default 720);
% # resize_video:   % If the video is too large to the screen, can resize the video size here.
  distance_mid = 50;  % "intervalBetweenVideos", change this value to make two videos closer.
% # rect1: position of the left video ([top-left-x,top-left-y,bottom-right-x, bottom-right-y]);
% # rect2: position of the right video ([top-left-x,top-left-y,bottom-right-x, bottom-right-y]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. "Left","Right" marker
%
% # (left_x,left_y): position of the "Left" marker;
% # (right_x,right_y): position of the "Right" marker;
  marker_size = 26;  % change the size of the "left"/"right" marker here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Question Title
%   
% # title_size: Font size of the question title (input, default 26);
% # titlefontHeight: height of the title in pixel;
% # nlines: how many lines of title (input, default 3);
% # (title_x(i),title_y(i)): (x,y) position of i-th line of the title.
  title_x_position=10;  % The title will starts at position x=10, change to larger number to move right.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 6. Rating Scale
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.1]."NEXT" button: 
%  
  % Set up the letter "NEXT":
  % # next_button_letter_size   % font size of the letter "NEXT" (input);
  % # (next_button_letter_x, next_button_letter_y): (x,y) position of the letter "Next";
  next_button_letter_color = color_red;   % color of the letter "NEXT"; 
     
  % Set up background(border):
  % # next_button_rect: rect of next button 
  next_button_border_color = color_white;    % background color of "Next" button;
  nextButtonBottom_to_ScreenBottom = 20;  % change to larger number to move "Next" button up.
  next_button_width = 60;   % width of "Next" button;
  next_button_height = 60;  % height of "Next button; 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.2]. Rating bar: 
% 
  % # slider_rect: rect of the long-thin rating bar.
  sliderHeight = 3;  % height of the slider bar, change to smaller number if you want thinner bar(in y position).
  slider_color = color_white;  % color of the rating bar.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.3]. Ticks on rating bar:  
  distance_from_slidertop_to_videobottom = 30;  % change to larger number if you want the slider bar to move lower.
  % # numTicks: number of ratings (e.g. Input 3 if you have three ratings: not likely, don't know, likely);
  tics_color = color_white;  % color of the ticks. 
  % # scale_range: range of the tics (e.g. 0,1,2).
  % # slider_tics: [4*scale_range] matrixs, stands for the rect of all ticks;
  %          1st row: top-left-x, 2st row: top-left-y, 3rd row: bottom-right-x; 4th row: bottom-right-y
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.4]. Sliding rating button:
  % # rating_button_rect: rect of the sliding rating button.
  rating_button_color = color_red;
  rating_button_w = 10;
  rating_button_h = 10;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.5].  Scale label:
%
%  # scale_label_low_x,  scale_label_high_x,  scale_label_middle_x:
%              x position of the low, middle, high scale label. (e.g. very not likely, don't know, very likely)
%  # scale_label_y: y position of the scale label.
   scale_label_color = color_red;
   scale_label_size = 20;
   distance_from_ticsbottom_to_labeltop = 40; % Change to larger number if you want the scale label move lower.
   scale_label_x_to_left = 80;     % Change to larger number if you want the scale label move left.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.6]. Gray rect
% 
% # gray_rect: ract of a gray bar to hide the update of the sliding button;
  gray_rect_W = 20;   % change to smaller number to reduce width (x direction);
  gray_rect_H = 20;   % change to smaller number to reduce height (y direction);
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%
% % === [6.7]. concatenation
  % # all_slider_rect: 
  % # all_slider_color:
%
%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
%% 1. Get font size and center of the screen: [X,Y],textRect_26,textRect_24
% Get screenNumber of stimulation display. We choose the display with
% the maximum index, which is usually the right one, e.g., the external
% display on a Laptop:
Screen('Preference', 'SkipSyncTests', 1)
screenNumber = max(Screen('Screens'));
% Returns as default the mean gray value of screen:
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow',screenNumber, gray);
[X,Y] = RectCenter(wRect);
% Check Textsize in pixel: this code checked textsize 24 and 26,
% Here we're obtaining the h of the textsize (REMINDER: width is used for "Next" button).
myText = 'Next';
Screen('TextSize',w,26);
textRect_26 = Screen('TextBounds',w,myText);
Screen('TextSize',w,24);
textRect_24 = Screen('TextBounds',w,myText);

% clear up
clear mex myText;


%% 2. Fixation: FixCross_v,FixCross_p
% vertical line: FixCross_v = [top-left-x,top-left-y,bottom-right-x,bottom-right-y]
FixCross_v = [X-FixCross_w,Y-FixCross_h,X+FixCross_w,Y+FixCross_h];
% parallel line: 
FixCross_p = [X-FixCross_h,Y-FixCross_w,X+FixCross_h,Y+FixCross_w];

% clear up
clear FixCross_w FixCross_h;

%% 3. Position of the two video stimuli: video_width, video_height, rect1,rect2
% Get size of the original video;
 warning ('Initializing video stimuli ...');
 default_original_video_width = 1280; 
 default_original_video_height = 720;
 
 original_video_width = input('What is the width of the video stimuli (defult 1280)?\n');
 if (isempty(original_video_width))
     original_video_width = default_original_video_width;
 end 
 
 
 original_video_height=input('What is the height of the video stimuli (defult 720)?\n');
 if (isempty(original_video_height))
     original_video_height = default_original_video_height;
 end 
 
 
 clear default_original_video_width default_original_video_height;
 
%
resize_video=[];
default_resize_video=0.5;

while (isempty(resize_video))
      if (isempty(resize_video))
            resize_video=input('Do you want to resize the video? Put a number between 0~1 (default 0.5: resize by half). \n');
            if (isempty(resize_video))
                resize_video = default_resize_video;
            end 
      end
      
      % Get the size of the rescaled video that suits the screen 
      video_width= resize_video * original_video_width;
      video_height = resize_video * original_video_height;
      
      % Set up interval between the two video stimuli: intervalBetweenVideos
      if (wRect(3)-20-2*video_width)<=0
          intervalBetweenVideos = distance_mid;
      elseif (wRect(3)-20-2*video_width)>0
          intervalBetweenVideos = min(distance_mid,(wRect(3)-20-2*video_width));
      end
      
      if (video_width*2+intervalBetweenVideos)> wRect(3)
          fprintf ('WARNING: Video is too wide for the current sceen, change the <resize_video> to smaller number!!\n');
          resize_video=[];
      end

      if video_height > wRect(4)
         fprintf ('WARNING: Video is too high for the current sceen, change the <resize_video> to smaller number!!\n');
         resize_video=[];
      end
end
      


% rect1 is the rect of the left video; rect2 is the rect of the right video.                   
rect1 = [X-intervalBetweenVideos/2-video_width, Y-video_height/2, X-intervalBetweenVideos/2,Y+video_height/2];
rect2 = [X+intervalBetweenVideos/2, Y-video_height/2, X+intervalBetweenVideos/2+video_width,Y+video_height/2];

% clear up
clear distance_mid default_video_width default_video_height resize_video intervalBetweenVideos;


%% 4. "Left""Right" markers: (left_x,left_y), (right_x,right_y)
left_x=rect1(1);
left_y=rect1(2) - 5;
right_x=rect2(1);
right_y=rect2(2) - 5;

%% 5. Title of rating questions: titlefontHeight, nlines, title_x(i), title_y(i) 
% font size
warning ('Initializing title of rating questions ...');
default_title_size = 26;
title_size = input('What is the font size of the title? 24 or 26? (If you want other font size, edit part 1. in this code\n');

if (isempty(title_size))
   title_size = default_title_size;
end

titlerect = eval(['textRect_' num2str(title_size)]);
titlefontHeight = titlerect(4);
    
% how many lines of titles: input
default_nlines = 3;
nlines = input('What many lines of question title (default 3)?\n');
if (isempty(nlines))
   nlines = default_nlines;
end

% (x,y) position of all lines of titles
default_title_y = titlefontHeight * 1.7; % y positon of the first line of the title
for i = 1: nlines
    title_x(i)= title_x_position;  % The title will starts at position x=title_x_position
    title_y(i)= default_title_y + titlefontHeight * 1.5 * (i-1);
end


if rect1(2) < title_y(nlines)
   clear mex;
   close all;
   error ('Not enough space to display the titles. Either resize the video or decrease the title font!');
end


% clear up
clear i default_nlines titlerect default_title_size default_title_y title_x_position;

    

%% 6. Scaling bar
%% === [6.1]."NEXT" button: next_button_border
  warning ('Initializing "Next" button ...');
% 6.1.1. border/background of "NEXT" button: next_button_rect
  next_button_bottom = wRect(4) - nextButtonBottom_to_ScreenBottom;   
  next_button_top = next_button_bottom - next_button_height;
  next_button_left = X - next_button_width/2;
  next_button_right = X + next_button_width/2;
  next_button_rect = [next_button_left, next_button_top, next_button_right, next_button_bottom];


% 6.1.2 Letter of "NEXT" Button: next_button_letter_size,(next_button_letter_x, next_button_letter_y)
  next_button_letter = 'Next';
  default_next_button_letter_size =26;
  next_button_letter_size = input('What is the size of the letter "Next" in next button? 24 or 26?\n (If you want other font size, edit 1. part in this code.)\n');
  if (isempty(next_button_letter_size))
      next_button_letter_size = default_next_button_letter_size;
  end

  next_button_letter_rect = eval(['textRect_' num2str(next_button_letter_size)]);
  next_button_letter_H = next_button_letter_rect(4);   % height of the letter "Next";
  next_button_letter_W = next_button_letter_rect(3);   % width of the letter "Next";
 
  % (x,y) position of next_button_letter;
  if (next_button_right-next_button_left-next_button_letter_W) < 0
      close all;
      error ('The letter "Next" is too wide for the next_button_border, enlarge "next_button_width".\n');
  end
  
  
  if (next_button_bottom - next_button_top - next_button_letter_H) < 0
      close all;
      error ('The letter "Next" is too tall for the next_button_border, enlarge "next_button_height".\n');
  end
        
  next_button_letter_x = (next_button_left + ((next_button_right - next_button_left - next_button_letter_W)/2));
  next_button_letter_y = (next_button_top + (next_button_bottom - next_button_top)/2 + next_button_letter_H/4);

  
% clear up
clear next_button_letter_rect default_next_button_letter_size nextButtonBottom_to_ScreenBottom next_button_bottom ...
    next_button_top next_button_right next_button_left;


%% === [6.2]. Rating bar: slider_rect
    warning ('Initializing slider bar parameters ...');
    
  % y position  
    slider_top = rect1(4) + distance_from_slidertop_to_videobottom;
    slider_bottom = slider_top + sliderHeight;
    
  % x position  
    default_sliderWidth = rect2(3) - rect1(1);   % by default, the slider bar is as wide as the two video stimuli, change this number if you want the bar to be narrower or wider in x position.
    fprintf('What is the length of the slider?  (default is %d, as wide as the two video stimuli).', default_sliderWidth);
    
    sliderWidth = input('\n');
    if (isempty(sliderWidth))
        sliderWidth = default_sliderWidth;
    end
    
    slider_left = X-sliderWidth/2;
    slider_right = X+sliderWidth/2;

    slider_rect = [slider_left slider_top slider_right slider_bottom]; 

  % clear up
  clear default_sliderWidth;
 
  
%% === [6.3]. Ticks on rating bar: numTicks, scale_range, ticksW, ticksH, slider_tics
    warning ('Initializing ticks ...');
    
    % == 1) Number of Ticks
    default_numTicks = 9;
    numTicks=input('How many ratings do you have? (default 9)\n');
    if (isempty(numTicks))
        numTicks = default_numTicks;
    end
    
    numTicks = numTicks-1;
    scale_range = 0:1:numTicks; % scales
    % == 2) Color of the Ticks
    % == 3) Position of the Ticks
    flag = true;
    default_ticksW = 10;
    default_ticksH = 20; 
    ticksW = [];
    ticksH = [];

    while flag
        if (isempty(ticksW))
            ticksW=input('What is the width of the ticks? (default 10) \n');
            if (isempty(ticksW))
                ticksW = default_ticksW;
            end 
        end
          
        if (isempty(ticksH))
            ticksH=input('What is the height of the ticks? (default 20) \n');
            if (isempty(ticksH))
                ticksH = default_ticksH;
            end
        end
       
        tick_top = slider_top - ticksH/2;
        tick_bottom = slider_bottom + ticksH/2;
    
        % this is the slider tic 
        for i = 1:length(scale_range)
           slider_tics(:,i) = [slider_rect(1) + round((sliderWidth/numTicks) * (i-1)), tick_top, slider_rect(1) + round((sliderWidth/numTicks) * (i-1) + ticksW), tick_bottom];
        end
        % The set of slider tic is ok only when 
        % 1) height exceed the screen;  2) length not exceed the screen;  3) not overlap with each other.
        
        if slider_tics(4,1)<wRect(4) && slider_tics(3,length(scale_range))<wRect(3) && slider_tics(3,1)<slider_tics(1,2)
            flag = false;
        elseif tick_bottom > wRect(4)
            warning('You need to decrese the height of the ticks!\n');
            ticksH =[];
        elseif slider_tics(3, length(scale_range)) > wRect(3)
            warning('You need to decrese the width of the ticks!\n');
            ticksW =[];
        elseif slider_tics(3, 1) > slider_tics(1,2)
            warning('You need to decrese the width of the ticks!\n');
            ticksW =[];
        end
    end
    
    clear i default_numTicks flag default_ticksW default_ticksH;  
 
    
%% === [6.4]. Sliding rating button
    rating_button_left = slider_tics(1,1)- rating_button_w/2;
    rating_button_right = slider_tics(3,1) + rating_button_w/2;
    rating_button_top = slider_tics(2,1) - rating_button_h/2;
    rating_button_bottom = slider_tics(4,1) + rating_button_h/2;

    rating_button_rect = [rating_button_left,rating_button_top,rating_button_right,rating_button_bottom];
      
%% === [6.5]. scale label location: scale_label_low_x,scale_label_high_x,scale_label_middle_x,scale_label_y    
    scale_label_low_x= slider_tics(1,1) - scale_label_x_to_left;
    scale_label_high_x = slider_tics(1,length(scale_range)) - scale_label_x_to_left;
    scale_label_middle_x = scale_label_low_x + (scale_label_high_x - scale_label_low_x)/2;
    scale_label_y = tick_bottom + distance_from_ticsbottom_to_labeltop;
    
    clear distance_from_ticsbottom_to_labeltop scale_label_x_to_left;
    
%% === [6.6]. gray_rect is used to cover the updated rating scale
    gray_rect = [slider_tics(1,1)-gray_rect_W, tick_top-gray_rect_H, slider_tics(3,length(scale_range))+gray_rect_W, tick_bottom+gray_rect_H];
    
    clear gray_rect_W gray_rect_H;
    
%% === [6.7].concatenation
    % the later one will cover the former one
    all_slider_rect = [slider_rect',next_button_rect',slider_tics, rating_button_rect'];
    all_slider_color  = [slider_color',next_button_border_color',repmat(tics_color,numTicks+1,1)',rating_button_color'];
        
%% clear up all useless variables.    
 clear screenNumber gray default_resize_video distance_mid distance_from_slidertop_to_videobottom next_button_height ...
     next_button_letter_H next_button_letter_W next_button_width next_button_bottom rating_button_h rating_button_left ...
     rating_button_right slider_bottom slider_top sliderHeight tick_bottom tick_top ticksH ticksW titlefontHeight ...
     ans default_original_video_width default_original_video_height;


 warning ('You can change other parameters in <LISTS of SAVED & Changable PARAMETERS> setion of this code if you want.');

 save(['GetParameters_PairedComparison_',num2str(wRect(3)),'*',num2str(wRect(4)),'.mat']);
end
