#include<windows.h>  
#include "mex.h"  
 
void mexFunction(void)
{  
    mexPrintf("左键双击\n");  
    mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
    Sleep(10);//反应时间
    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
    Sleep(20);//间隔
    mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
    Sleep(10);//反应时间
    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
      
}  