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
            mexPrintf("������\n");  
            mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
            Sleep(10);//��Ӧʱ��
            mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            mexPrintf("�������\n");  
            mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            mexPrintf("����ɿ�\n");  
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
            //mexPrintf("�м����\n");  
            mouse_event(MOUSEEVENTF_MIDDLEDOWN,0,0,0,0); 
            Sleep(10);//��Ӧʱ��
            mouse_event(MOUSEEVENTF_MIDDLEUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            //mexPrintf("�м�����\n");  
            mouse_event(MOUSEEVENTF_MIDDLEDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            //mexPrintf("�м��ɿ�\n");  
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
            //mexPrintf("�Ҽ����\n");  
            mouse_event(MOUSEEVENTF_RIGHTDOWN,0,0,0,0);  
            Sleep(10);//Ҫ����ĳЩӦ�õķ�Ӧʱ��
            mouse_event(MOUSEEVENTF_RIGHTUP,0,0,0,0);  
        }  
        else if (mode == DOWN)  
        {  
            //mexPrintf("�Ҽ�����\n");  
            mouse_event(MOUSEEVENTF_RIGHTDOWN,0,0,0,0);  
        }  
        else if (mode == UP)  
        {  
            //mexPrintf("�Ҽ��ɿ�\n");  
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