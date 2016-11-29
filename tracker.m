function [positions, time,frames] = tracker( pos, target_sz, ...
	padding, kernel, lambda, output_sigma_factor, interp_factor, cell_size, ...
	features)

    
    vidobj = videoinput('winvideo',1,'YUY2_320x240');  
    triggerconfig(vidobj,'manual');  
    start(vidobj);      
    fig=figure;
    mymouse=java.awt.Robot;
    screen = get(0,'ScreenSize');
    
    
    %目标对齐
    pos=pos([2,1]);
    target_sz=target_sz([2,1]);
        
    pos2dipm=pos(2)-3;
    pos2dipp=pos(2)+3;
    pos1ls=pos(1);
		
    pos1dipm=pos(1)-3;
    pos1dipp=pos(1)+3;
    pos2ls=pos(2);

    pos2m=round(pos(2)-target_sz(2)/2);
    pos2p=pos2m+target_sz(2);
    pos1m=round(pos(1)-target_sz(1)/2);
    pos1p=pos1m+target_sz(1);
     
    pos=pos([2,1]);
    target_sz=target_sz([2,1]);
    
    stopprepare=false; %停止准备
    stoptracking=false;%停止整个追踪程序
    fprintf('按1键开始，注意切换成英文输入法');
    
    while 1
        if stopprepare
            break;
        end
        if stoptracking
            break;
        end
        
        snapshot = getsnapshot(vidobj);  
        im = ycbcr2rgb(snapshot);
   
		im(pos2dipm:pos2dipp,pos1ls,:)=0;   
        im(pos2ls,pos1dipm:pos1dipp,:)=0;
        im(pos2m:pos2p,pos1m,:)=0;
        im(pos2m:pos2p,pos1p,:)=0;
        im(pos2m,pos1m:pos1p,:)=0;
        im(pos2p,pos1m:pos1p,:)=0;
        
        im=im(:,end:-1:1,:);
		imshow(im);  
        set(fig,'windowkeypressfcn',@keypressfcn);
    end
    
    %倒计时开始
    for i=1:1:50
        if stoptracking
            break;
        end
        
        snapshot = getsnapshot(vidobj);  
        im = ycbcr2rgb(snapshot);
   
		im(pos2dipm:pos2dipp,pos1ls,:)=0;   
        im(pos2ls,pos1dipm:pos1dipp,:)=0;
        im(pos2m:pos2p,pos1m,:)=0;
        im(pos2m:pos2p,pos1p,:)=0;
        im(pos2m,pos1m:pos1p,:)=0;
        im(pos2p,pos1m:pos1p,:)=0;
        
        im=im(:,end:-1:1,:);
		imshow(im);  
        set(fig,'windowkeypressfcn',@keypressfcn);
    end
    
    
    
    
	%search window size
	window_sz = floor(target_sz * (1 + padding));
	
	%create regression labels, gaussian shaped, with a bandwidth
	%proportional to target size
	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));

	%store pre-computed cosine window
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	


    fprintf('\n');
    fprintf('开始跟踪......\n'); 
    
	time = 0;  %to calculate FPS
    frame=0;
    
    pos_history=zeros(30,2);
    pos_point=30;
    
    i=1;
    while 1
        if stoptracking
            frames=frame;
            break;
        end
        frame=frame+1;
        
		%load image
        snapshot = getsnapshot(vidobj);  
        im = ycbcr2rgb(snapshot);  
        
		if size(im,3) > 1,
			imgray = rgb2gray(im);
        end

		tic()

		if frame > 1,
			patch = get_subwindow(imgray, pos, window_sz);
			zf = fft2(get_features(patch, features, cell_size, cos_window));
			
			%calculate response of the classifier at all shifts
			switch kernel.type
			case 'gaussian',
				kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
			case 'polynomial',
				kzf = polynomial_correlation(zf, model_xf, kernel.poly_a, kernel.poly_b);
			case 'linear',
				kzf = linear_correlation(zf, model_xf);
			end
			response = real(ifft2(model_alphaf .* kzf));  

			[vert_delta, horiz_delta] = find(response == max(response(:)), 1);
           
           
            
            
			if vert_delta > size(zf,1) / 2,  
				vert_delta = vert_delta - size(zf,1);
			end
			if horiz_delta > size(zf,2) / 2,  
				horiz_delta = horiz_delta - size(zf,2);
			end
            
			pos = pos + cell_size * [vert_delta - 1,horiz_delta - 1,];
		end

		%obtain a subwindow for training at newly estimated target position
		patch = get_subwindow(imgray, pos, window_sz);
		xf = fft2(get_features(patch, features, cell_size, cos_window));

		%Kernel Ridge Regression, calculate alphas (in Fourier domain)
		switch kernel.type
		case 'gaussian',
			kf = gaussian_correlation(xf, xf, kernel.sigma);
		case 'polynomial',
			kf = polynomial_correlation(xf, xf, kernel.poly_a, kernel.poly_b);
		case 'linear',
			kf = linear_correlation(xf, xf);
		end
		alphaf = yf ./ (kf + lambda);   %equation for fast training

		if frame == 1,  %first frame, train with a single image
			model_alphaf = alphaf;
			model_xf = xf;
		else
			%subsequent frames, interpolate model
			model_alphaf = (1 - interp_factor) * model_alphaf + interp_factor * alphaf;
			model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;
		end

		%save position and timing
		positions(frame,:) = pos;
		time = time + toc();

        
		%visualization		
        pos=pos([2,1]);
        target_sz=target_sz([2,1]);
        
        posdipm=pos(2)-3;
        posdipp=pos(2)+3;
        posdipm(posdipm<1)=1;
        posdipp(posdipp<1)=1;
        pos1ls=pos(1);
        pos1ls(pos1ls<1)=1;
		im(posdipm:posdipp,pos1ls,:)=0;   
        
        posdipm=pos(1)-3;
        posdipp=pos(1)+3;
        posdipm(posdipm<1)=1;
        posdipp(posdipp<1)=1;
        pos2ls=pos(2);
        pos2ls(pos2ls<1)=1;
        im(pos2ls,posdipm:posdipp,:)=0;
        
        pos2m=round(pos(2)-target_sz(2)/2);
        pos2p=pos2m+target_sz(2);
        pos1m=round(pos(1)-target_sz(1)/2);
        pos1p=pos1m+target_sz(1);
        
        pos2m(pos2m<1)=1;
        pos2p(pos2p<1)=1;
        pos1m(pos1m<1)=1;
        pos1p(pos1p<1)=1;
       
        im(pos2m:pos2p,pos1m,:)=0;
        im(pos2m:pos2p,pos1p,:)=0;
        im(pos2m,pos1m:pos1p,:)=0;
        im(pos2p,pos1m:pos1p,:)=0;
        
        im=im(:,end:-1:1,:);
		imshow(im);
        
        pos=pos([2,1]);
        target_sz=target_sz([2,1]);
        
        mymouse.mouseMove(screen(3)-pos(2)*screen(3)/320, pos(1)*screen(4)/240);
% 		pause(0.05) 
        
        
        
        %save the pos
        pos_point=pos_point+1;
        pos_point(pos_point>30)=1;
        pos_history(pos_point,:)=pos;
        
        %双击判断
        historyframe1=pos_point-2;
        historyframe1(historyframe1<1)=historyframe1+30;
        historyframe2=pos_point-3;
        historyframe2(historyframe2<1)=historyframe2+30;
        
        
        historyframe3=pos_point-4;
        historyframe3(historyframe3<1)=historyframe3+30;
        historyframe4=pos_point-5;
        historyframe4(historyframe4<1)=historyframe4+30;
        
        
        move1=pos(1)-pos_history(historyframe1,1);    %抬头动作
        move2=pos_history(historyframe1,1)-pos_history(historyframe2,1); %低头动作
        move3=pos_history(historyframe2,1)-pos_history(historyframe3,1);   %抬头动作
        move4=pos_history(historyframe3,1)-pos_history(historyframe4,1); %低头动作
        
        %{
        fprintf('move1=%d\n',move1);
        fprintf('move2=%d\n',move2);
        fprintf('move3=%d\n',move3);
        fprintf('move4=%d\n',move4);
        %}
        
        if (move1>-9)&&(move1<-3)&&(move2<9)&&(move2>3)
            if (move3>-9)&&(move3<-3)&&(move4<9)&&(move4>3)
                fprintf('*************click***********\n')
                click_leftdouble();
                fprintf('move1=%d\n',move1);
                fprintf('move2=%d\n',move2);
                fprintf('move3=%d\n',move3);
                fprintf('move4=%d\n',move4);
            end
        end
        
        %单击判断
        historyframe1=pos_point-2;
        historyframe1(historyframe1<1)=historyframe1+30;
        historyframe2=pos_point-3;
        historyframe2(historyframe2<1)=historyframe2+30;
        
        
        historyframe3=pos_point-4;
        historyframe3(historyframe3<1)=historyframe3+30;
        historyframe4=pos_point-5;
        historyframe4(historyframe4<1)=historyframe4+30;
        
        
        move1=pos(2)-pos_history(historyframe1,2);    %抬头动作
        move2=pos_history(historyframe1,2)-pos_history(historyframe2,2); %低头动作
        move3=pos_history(historyframe2,2)-pos_history(historyframe3,2);   %抬头动作
        move4=pos_history(historyframe3,2)-pos_history(historyframe4,2); %低头动作
        
        %{
        fprintf('move1=%d\n',move1);
        fprintf('move2=%d\n',move2);
        fprintf('move3=%d\n',move3);
        fprintf('move4=%d\n',move4);
        %}
        
        if (move1>-9)&&(move1<-3)&&(move2<9)&&(move2>3)
            if (move3>-9)&&(move3<-3)&&(move4<9)&&(move4>3)
                fprintf('*************click***********\n')
                click_leftsimple();
                fprintf('move1=%d\n',move1);
                fprintf('move2=%d\n',move2);
                fprintf('move3=%d\n',move3);
                fprintf('move4=%d\n',move4);
            end
        end
        
        %{
        %导出图片检验
        if (i<1000) 
            i=i+1;
        end
        namestr=strcat(num2str(i),'.bmp');
        if (namestr==5) 
            namestr=strcat('000',namestr);
        end
        if (namestr==6) 
            namestr=strcat('00',namestr);
        end
        if (namestr==7) 
            namestr=strcat('0',namestr);
        end
        
        imwrite(im,strcat('.\sypic\',namestr),'bmp');
        %}

        set(fig,'windowkeypressfcn',@keypressfcn);
		
    end
    
    
    
    function keypressfcn(h,evt)  
        if strcmp(evt.Key, 'escape')
            stoptracking=true;
            fprintf('Esc press \n');
            fprintf('正在退出 \n');
        end   
        if strcmp(evt.Key, '1')
            stopprepare=true;
            fprintf('start press \n');
            fprintf('倒计时两秒后开始..... \n');
            fprintf('按ESC退出  press Esc to escape from tracking \n');
        end  
        if strcmp(evt.Key, '2')
            fprintf('press 2......\n');
            fprintf('move1=%d\n',move1);
            fprintf('move2=%d\n',move2);
            fprintf('move3=%d\n',move3);
            fprintf('move4=%d\n',move4);
        end 
    end
    
    stop(vidobj);
    delete(vidobj);
	
end

