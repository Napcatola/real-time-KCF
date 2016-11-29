本代码原环境为（win8，Matlab2014a x86）
在64位Matlab上运行需要重新编译“click_leftdouble.cpp”，“click_leftsimple.cpp”，“gradientMex.cpp”


输入命令run_mousetracker head或run_mousetracker hand进行跟踪。根据命令行的提示进行操作，键盘操作在选中对象为图像框时有效。
双击和单击操作需要的较快速度点头或者向左摆头/手两次，可在tracker.m中调整识别的摆动频率。


如果摄像头调取失败，则需手动获取电脑摄像头的id并在tracker.m中的“vidobj = videoinput('winvideo', 1, 'YUY2_320x240');”中修改。


tracker2.m为带尺度的跟踪，但是由于会有小幅抖动故实时控制采用tracker.m

20161101 Wu.
