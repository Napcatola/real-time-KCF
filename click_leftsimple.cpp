#include<windows.h>  
#include "mex.h"  
 
void mexFunction(void)
{  
    mexPrintf("������\n");  
    mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
    Sleep(10);//��Ӧʱ��
    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
      
}  