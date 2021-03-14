%     % Generate histogram %hist_RG = [imhist(Blurred_img(:,:,:,1))
%     imhist(Blurred_img(:,:,:,2))];
%     
%     % Normalize avg_R = mean(Blurred_img(:,:,:,1),'all'); avg_G =
%     mean(Blurred_img(:,:,:,2),'all'); min_R =
%     min(Blurred_img(:,:,:,1),[],'all'); min_G =
%     min(Blurred_img(:,:,:,2),[],'all');
%     
%     % Unweigthed tic norm_img(:,:,:,1) =
%     (Blurred_img(:,:,:,1)-min_R)./(avg_R-min_R); norm_img(:,:,:,2) =
%     (Blurred_img(:,:,:,2)-min_G)./(avg_G-min_G); norm_img(:,:,:,3) =
%     Blurred_img(:,:,:,3); figure,
%     loglog(1:256,imhist(norm_img(:,:,:,1))); figure,
%     loglog(1:256,imhist(norm_img(:,:,:,2))); toc %% % Weigthed % Find
%     maximums and minimums f_max_R =
%     double(repelem(max(Blurred_img(:,:,:,1),[],'all'),256)); f_max_G =
%     double(repelem(max(Blurred_img(:,:,:,2),[],'all'),256)); min_R =
%     min(Blurred_img(:,:,:,1),[],'all'); min_G =
%     min(Blurred_img(:,:,:,2),[],'all');
%     
%     % Histogram rescale [hist_R_count, bins_R]  =
%     imhist(Blurred_img(:,:,:,1)); [hist_G_count, bins_G]  =
%     imhist(Blurred_img(:,:,:,2));
%     
%     % Get weighting function g_R = (f_max_R - bins_R)*hist_R_count.^2;
%     g_G = (f_max_G - bins_G)*hist_G_count.^2;
%     
%     % Calculate weigths w_R = g_R/sum(g_R); w_G = g_G/sum(g_G);
%     
%     % Calculate means w_avg_R = sum(w_R.*double([1:256]')); w_avg_G =
%     sum(w_R.*double([1:256]'));
%     
%     %% tic norm_img(:,:,:,1) =
%     (Blurred_img(:,:,:,1)-min_R)./(w_avg_R-min_R); norm_img(:,:,:,2) =
%     (Blurred_img(:,:,:,2)-min_G)./(w_avg_G-min_G); norm_img(:,:,:,3) =
%     Blurred_img(:,:,:,3); figure,
%     loglog(1:256,imhist(norm_img(:,:,:,1))); figure,
%     loglog(1:256,imhist(norm_img(:,:,:,2))); toc