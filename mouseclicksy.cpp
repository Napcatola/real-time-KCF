#include<windows.h>  
#include "mex.h"  
 
#define CLICK 1  
#define DOWN 2  
#define UP 3  
#define LEFT 1  
#define MIDDLE 2  
#define RIGHT 3  


//void mexFunction(int nrhs, const mxArray *prhs[])  
void mexFunction(int key,int mode)
{  
     
            
    if (key == 1)  
    {  
        if (mode == 1)  
        {  
            mexPrintf("左键点击\n");  
            mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
            Sleep(10);//反应时间
            mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            mexPrintf("左键按下\n");  
            mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            mexPrintf("左键松开\n");  
            mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
        }  
        else  
        {  
            //errmsg();  
        }  
    }  
    else if (key == MIDDLE)  
    {  
        if (mode == CLICK)  
        {  
            //mexPrintf("中键点击\n");  
            mouse_event(MOUSEEVENTF_MIDDLEDOWN,0,0,0,0); 
            Sleep(10);//反应时间
            mouse_event(MOUSEEVENTF_MIDDLEUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            //mexPrintf("中键按下\n");  
            mouse_event(MOUSEEVENTF_MIDDLEDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            //mexPrintf("中键松开\n");  
            mouse_event(MOUSEEVENTF_MIDDLEUP,0,0,0,0);  
        }  
        else  
        {  
           // errmsg();  
        }  
    }  
    else if (key == RIGHT)  
    {  
        if (mode == CLICK)  
        {  
            //mexPrintf("右键点击\n");  
            mouse_event(MOUSEEVENTF_RIGHTDOWN,0,0,0,0);  
            Sleep(10);//要留给某些应用的反应时间
            mouse_event(MOUSEEVENTF_RIGHTUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            //mexPrintf("右键按下\n");  
            mouse_event(MOUSEEVENTF_RIGHTDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            //mexPrintf("右键松开\n");  
            mouse_event(MOUSEEVENTF_RIGHTUP,0,0,0,0);  
        }  
        else  
        {  
            //errmsg();  
        }  
    }  
    else  
    {  
        //errmsg();  
    }  
}  