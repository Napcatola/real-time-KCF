function []=run_mousetracker(initobject)

    clc;
    
    
    kernel_type = 'gaussian';
    feature_type = 'hog';

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


    pos=[105,181];
    if strcmp(initobject,'hand')
        target_sz=[106,65];   %hand tracker
        fprintf('\n');
        fprintf('hand tracker\n');
    end
    
    if strcmp(initobject,'head')
        target_sz=[116,100];   %head tracker
        fprintf('\n');
        fprintf('head tracker\n');
    end
    
    if strcmp(initobject,'finger')
        target_sz=[20,20];   %head tracker
        fprintf('\n');
        fprintf('finger tracker\n');
    end
    

    %call tracker function with all the relevant parameters
    [positions, time,frames] = tracker(  pos, target_sz, ...
                padding, kernel, lambda, output_sigma_factor, interp_factor, ...
                cell_size, features);


    %calculate and show precision plot, as well as frames-per-second
    %precisions = precision_plot(positions, ground_truth, video, show_plots);
    fps = frames / time;
    precisions(20)=0;%没有参照
    fprintf('%12s -FPS:% 4.2f\n', ' real-time ', fps)

    if nargout > 0,
        %return precisions at a 20 pixels threshold
        precision = precisions(20);
    end

end