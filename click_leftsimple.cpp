#include<windows.h>  
#include "mex.h"  
 
void mexFunction(void)
{  
    mexPrintf("左键点击\n");  
    mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
    Sleep(10);//反应时间
    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
      
}  