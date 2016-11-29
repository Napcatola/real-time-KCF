ex_data=importdata('.\data\Benchmark\vedio8\vedioResult.txt');
datawhole=ex_data.data;
reshape_data=datawhole(:,1:8);
left_data=datawhole(:,1:4);
right_data=datawhole(:,5:8);

left_data(:,1)=round(left_data(:,1)-left_data(:,3)/2.0);
left_data(:,2)=round(left_data(:,2)-left_data(:,4)/2.0);
right_data(:,1)=round(right_data(:,1)-right_data(:,3)/2.0);
right_data(:,2)=round(right_data(:,2)-right_data(:,4)/2.0);

dlmwrite('vedio8_lefthand_result.txt',left_data, '\t');
dlmwrite('vedio8_righthand_result.txt',right_data, '\t');


%数据集演示
%{
file_path='.\data\Benchmark\vedio2\';% 图像文件夹路径  
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有bmp格式的图像  
img_num = length(img_path_list);%获取图像总数量  
if img_num > 0 %有满足条件的图像  
    for i = 1:500 %逐一读取图像  
        if (i>0)     %65,10,165
            image_name = img_path_list(i).name;% 图像名  
            im =  imread(strcat(file_path,image_name));  
            [h,w,rgb] = size(im);
            j=i;  %65,10,165
            cut_w=double(reshape_data(j,3))/2.0;
            cut_h=double(reshape_data(j,4))/2.0;
            
            x=round(double(reshape_data(j,1))+cut_w);
            y=round(double(reshape_data(j,2))+cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241)
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,1))-cut_w);
            y=round(double(reshape_data(j,2))-cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,1))-cut_h);
            y=round(double(reshape_data(j,2))+cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,1))+cut_w);
            y=round(double(reshape_data(j,2))-cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
            
            
            cut_w=double(reshape_data(j,7))/2.0;
            cut_h=double(reshape_data(j,8))/2.0;
            
            x=round(double(reshape_data(j,5))+cut_w);
            y=round(double(reshape_data(j,6))+cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241)
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,5))-cut_w);
            y=round(double(reshape_data(j,6))-cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,5))-cut_h);
            y=round(double(reshape_data(j,6))+cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
            x=round(double(reshape_data(j,5))+cut_w);
            y=round(double(reshape_data(j,6))-cut_h);
            if (x>0)&&(x<321)&&(y>0)&&(y<241) 
                im(y,x,:)=255;
            end
            
                
            imshow(im);    
            pause(0.03);
        end
        
    end  

end
%}


%裁切数据集vedio2，仅剩一只手
%{
file_path='.\data\Benchmark\vedio2\img\';% 图像文件夹路径  
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有bmp格式的图像  
img_num = length(img_path_list);%获取图像总数量  
if img_num > 0 %有满足条件的图像  
    for i = 1:img_num %逐一读取图像  
        if (i>0)     
            image_name = img_path_list(i).name;% 图像名  
            im =  imread(strcat(file_path,image_name));  
            [h,w,rgb] = size(im);
            
            imcut=im(:,1:180,:);
            imwrite(imcut,strcat('.\data\Benchmark\vedio2cut\',image_name),'png');
        end
        
    end  
end
%}
