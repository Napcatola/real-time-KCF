base_path='.\data\Benchmark';
video='sypic2';

kernel_type = 'gaussian';
feature_type = 'hog';
show_visualization = ~strcmp(video, 'all');
show_plots = ~strcmp(video, 'all');

kernel.type = kernel_type;
features.gray = false;	 
padding =1.5;  %extra area surrounding the target  原始：1.5
lambda = 1e-4;  %regularization
output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)

interp_factor = 0.02;
kernel.sigma = 0.5;
kernel.poly_a = 1;
kernel.poly_b = 9;
features.hog = true;
features.hog_orientations = 9;
cell_size = 4;


[img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video);
		
		
%call tracker function with all the relevant parameters
[positions, time] = tracker(video_path, img_files, pos, target_sz, ...
			padding, kernel, lambda, output_sigma_factor, interp_factor, ...
			cell_size, features, show_visualization);
		
		
%calculate and show precision plot, as well as frames-per-second
%precisions = precision_plot(positions, ground_truth, video, show_plots);
fps = numel(img_files) / time;
precisions(20)=0;%没有参照
fprintf('%12s - Precision (20px):% 1.3f, FPS:% 4.2f\n', video, precisions(20), fps)

if nargout > 0,
    %return precisions at a 20 pixels threshold
    precision = precisions(20);
end