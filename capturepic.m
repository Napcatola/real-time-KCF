function capturepic
%<span style="font-size:18px;">
clc  
close all  
clear all
  
vidobj = videoinput('winvideo',1,'YUY2_320x240');  
triggerconfig(vidobj,'manual');  
start(vidobj);  
tic    
fig=figure;
stopcap=false;

for i = 1:10
     if stopcap
         break;
     end
     snapshot = getsnapshot(vidobj);  
     frame = ycbcr2rgb(snapshot);  
     a=imshow(frame);  
     pause(0.053);  
    
     set(fig,'windowkeypressfcn',@keypressfcn);
       
	 %if strcmp(key, 'escape'),  %stop on 'Esc'

   
     image_name=strcat(num2str(i),'.jpg'); 
     %{
     if length(image_name)==5
         image_name=strcat('00',image_name);
     end
     if length(image_name)==6
         image_name=strcat('0',image_name);
     end
    %}
     imwrite(frame,strcat('.\sypic\',image_name),'jpg');
     
end  

    function keypressfcn(h,evt)  
        if strcmp(evt.Key, 'escape')
            stopcap=true;
            fprintf('Esc press \n');
        end             
    end

elapsedTime = toc  
timePerFrame = elapsedTime/200  
effectiveFrameRate = 1/timePerFrame  
  
stop(vidobj);  
delete(vidobj);  


end