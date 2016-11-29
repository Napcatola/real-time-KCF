clc;
clear;
close all;


mymouse=java.awt.Robot;

screen = get(0,'ScreenSize');
i=0;

while(i<640)
    i=i+1;
    mymouse.mouseMove(i*screen(3)/640, 240*screen(4)/480);
    pause(0.1);
end