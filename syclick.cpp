#include<windows.h>  
#include "mex.h"  
  
#define CLICK 1  
#define DOWN 2  
#define UP 3  
#define LEFT 1  
#define MIDDLE 2  
#define RIGHT 3  

void mexFunction(void)
{  
   
   
            mexPrintf("������\n");  
            mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);  
            Sleep(10);//Ҫ����ĳЩӦ�õķ�Ӧʱ��
            mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);  
     
}  
