function [positions, time] = tracker2(video_path, img_files, pos, target_sz, ...
	padding, kernel, lambda, output_sigma_factor, interp_factor, cell_size, ...
	features, show_visualization)
%TRACKER Kernelized/Dual Correlation Filter (KCF/DCF) tracking.
%   This function implements the pipeline for tracking with the KCF (by
%   choosing a non-linear kernel) and DCF (by choosing a linear kernel).
%
%   It is meant to be called by the interface function RUN_TRACKER, which
%   sets up the parameters and loads the video information.
%
%   Parameters:
%     VIDEO_PATH is the location of the image files (must end with a slash
%      '/' or '\').
%     IMG_FILES is a cell array of image file names.
%     POS and TARGET_SZ are the initial position and size of the target
%      (both in format [rows, columns]).
%     PADDING is the additional tracked region, for context, relative to 
%      the target size.
%     KERNEL is a struct describing the kernel. The field TYPE must be one
%      of 'gaussian', 'polynomial' or 'linear'. The optional fields SIGMA,
%      POLY_A and POLY_B are the parameters for the Gaussian and Polynomial
%      kernels.
%     OUTPUT_SIGMA_FACTOR is the spatial bandwidth of the regression
%      target, relative to the target size.
%     INTERP_FACTOR is the adaptation rate of the tracker.
%     CELL_SIZE is the number of pixels per cell (must be 1 if using raw
%      pixels).
%     FEATURES is a struct describing the used features (see GET_FEATURES).
%     SHOW_VISUALIZATION will show an interactive video if set to true.
%
%   Outputs:
%    POSITIONS is an Nx2 matrix of target positions over time (in the
%     format [rows, columns]).
%    TIME is the tracker execution time, without video loading/rendering.
%
%   Joao F. Henriques, 2014


	%if the target is large, lower the resolution, we don't need that much
	%detail
	resize_image = (sqrt(prod(target_sz)) >= 100);  %diagonal size >= threshold
	if resize_image,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
	end


	%window size, taking padding into account
	window_sz = floor(target_sz * (1 + padding));
    threshold_delta=2000;
    flag_scale=1;
    scale=1;r=1.05;
    imscale_iframe=1;
	
% 	%we could choose a size that is a power of two, for better FFT
% 	%performance. in practice it is slower, due to the larger window size.
% 	window_sz = 2 .^ nextpow2(window_sz);

	
	%create regression labels, gaussian shaped, with a bandwidth
	%proportional to target size
	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));

	%store pre-computed cosine window
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
	
	
	if show_visualization,  %create video interface
		update_visualization = show_video(img_files, video_path, resize_image);
	end
	
	
	%note: variables ending with 'f' are in the Fourier domain.

	time = 0;  %to calculate FPS
	positions = zeros(numel(img_files), 2);  %to calculate precision

    pos_scale_real=pos;%在原来大小的图像中box的position
    pos_scale_patch=pos;%在scale后取patch的图片中的position
    
	for frame = 1:numel(img_files),
		%load image
		im = imread([video_path img_files{frame}]);
		if size(im,3) > 1,
			im = rgb2gray(im);
		end
		if resize_image,
			im = imresize(im, 0.5);
        end
        
        im=imresize(im,imscale_iframe,'bilinear');

		tic()

		if frame > 1,
			%obtain a subwindow for detection at the position from last
			%frame, and convert to Fourier domain (its size is unchanged)
			patch = get_subwindow(im, pos_scale_patch, window_sz);
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
			response = real(ifft2(model_alphaf .* kzf));  %equation for fast detection   .*点乘

			%target location is at the maximum response. we must take into
			%account the fact that, if the target doesn't move, the peak
			%will appear at the top-left corner, not at the center (this is
			%discussed in the paper). the responses wrap around cyclically. 
            maxresp=max(response(:));
			[vert_delta, horiz_delta] = find(response ==maxresp, 1); 
            scale_maxresp=1;

            
			if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
				vert_delta = vert_delta - size(zf,1);
			end
			if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
				horiz_delta = horiz_delta - size(zf,2);
            end
            
            last_pos_patch=pos_scale_patch;
            pos_scale_patch=pos_scale_patch + cell_size * [vert_delta - 1, horiz_delta - 1];
			center_pos_patch=pos_scale_patch;
            pos_scale_real=round(pos_scale_patch/imscale_iframe);
            
            fprintf('\n');
            fprintf('frame=%d scale=%d maxresp=%d \n' ,frame,1,maxresp);
            
            
            for i_scale=-scale:1:scale
                if (i_scale~=0)&&(flag_scale)
                    scale_window_sz=round(window_sz*(r^i_scale));
                    ls_pos_scale_patch=center_pos_patch*(r^i_scale);   %用center 还是用last效果待验证
                    patch=get_subwindow(im,ls_pos_scale_patch, scale_window_sz);
                    patch=imresize(patch,window_sz,'bilinear');

                    zf = fft2(get_features(patch, features, cell_size, cos_window));

                    switch kernel.type
                        case 'gaussian',
                            kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
                        case 'polynomial',
                            kzf = polynomial_correlation(zf, model_xf, kernel.poly_a, kernel.poly_b);
                        case 'linear',
                            kzf = linear_correlation(zf, model_xf);
                    end
                    response = real(ifft2(model_alphaf .* kzf));  %equation for fast detection   .*点乘
   
                    

                    if (i_scale>0)
                        rectify=1;
                    else
                        rectify=r^(i_scale*0.3);
                    end
                    ls=max(response(:))/rectify;
                    [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
                    fprintf('frame=%d scale=%d maxresp=%d \n' ,frame,r^i_scale,ls);
           
                    if ls>maxresp
                        if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
                            vert_delta = vert_delta - size(zf,1);
                        end
                        if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
                            horiz_delta = horiz_delta - size(zf,2);
                        end
                        if (vert_delta<threshold_delta)&&(horiz_delta<threshold_delta)  
                            pos_scale_patch = ls_pos_scale_patch + cell_size * [vert_delta - 1, horiz_delta - 1];
                            pos_scale_real=round(ls_pos_scale_patch/(r^i_scale)/imscale_iframe);
                            %pos_scale_patch的处理可能有问题  10.12 tips

                            maxresp=ls;
                            scale_maxresp=r^i_scale;
                        end
                       
                    end  
                    
            

                
                    
                end   
            end
            
            
           fprintf('frame=%d  scale_max=%d   ',frame,scale_maxresp); 
           if (scale_maxresp~=1)
               im=imresize(im,1.0/scale_maxresp,'bilinear');
               imscale_iframe=imscale_iframe/scale_maxresp;
           end 
           
        end

		%obtain a subwindow for training at newly estimated target position
	
        patch = get_subwindow(im, pos_scale_patch, window_sz);
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
			model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;    %0.02；
		end

		%save position and timing
		time = time + toc();

		%visualization
        positions(frame,:) = pos_scale_real;
        fprintf('imscale_frame=%d',imscale_iframe);
		if show_visualization,
            box = [pos_scale_real([2,1]) - round(target_sz([2,1])/imscale_iframe/2), round(target_sz([2,1])/imscale_iframe)];
            
			stop = update_visualization(frame, box);
			if stop, break, end  %user pressed Esc, stop early
			
			drawnow
% 			pause(0.05)  %uncomment to run slower
		end
		
	end

	if resize_image,
		positions = positions * 2;
	end
end

