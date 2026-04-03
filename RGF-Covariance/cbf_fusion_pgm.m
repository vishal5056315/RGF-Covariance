
% This script is the main file for running the experiments from:
%   <Author Names:Vishal, Ayush Dogra,Vinay Kukreja, Bhawna Goyal>
%   "Microvascular Structure Preservation in Multi-Patch Photoacoustic Image Fusion via Four-Directional Covariance Eigenanalysis"
%
% It demonstrates:
%   - loads multi-wavelength photoacoustic (PA) source patches
%   - performs hierarchical pairwise fusion (Fusion I–III)
%   - calls RollingGuidanceFilter.m for base–detail decomposition
%   - computes directional covariance-based saliency weights
%   - applies normalized weighted fusion to obtain S1–S7
%   - evaluates the fused outputs using Petrovic and NABF metrics

% This implementation also makes use of:
%
%   - Rolling Guidance Filter:
%       Q. Zhang et al., "Rolling Guidance Filter",
%       European Conference on Computer Vision (ECCV), 2014.
%
%   - CBF filter 
%       B. K. Shreyamsha Kumar, "Image fusion based on visual
%       information", 2011–2012.

% If you use this script or the associated fusion method in your work,
% please cite this paper and the relevant baseline references.
%
% -------------------------------------------------------------------------



close all;
clear all;
clc;

%%% Fusion Method Parameters.
cov_wsize=5;

%%% Bilateral Filter Parameters.
%sigmas=1.8;  %%% Spatial (Geometric) Sigma. 1.8
%sigmar=25; %%% Range (Photometric/Radiometric) Sigma.25 256/10
%ksize=11;   %%% Kernal Size  (should be odd).

arr=['A';'B'];
for m=1:2
   string=arr(m);
%    inp_image=strcat('images\med256',string,'.jpg');
   inp_image=strcat('images\3_',string,'.png');
%    inp_image=strcat('images\gun',string,'.gif');

   x{m}=imread(inp_image);
   if(size(x{m},3)==3)
      x{m}=rgb2gray(x{m});
   end
end
[M,N]=size(x{m});

%%% Cross Bilateral Filter.
tic

%cbf_out{1}=cross_bilateral_filt2Df(x{1},x{2},sigmas,sigmar,ksize);
%detail{1}=double(x{1})-cbf_out{1};
%cbf_out{2}= cross_bilateral_filt2Df(x{2},x{1},sigmas,sigmar,ksize);
%detail{2}=double(x{2})-cbf_out{2};


% --- Rolling Guidance Filter ---
sigma_s_rgf = 5;  

sigma_r_rgf = 0.05; 
iteration_rgf = 1;  
GaussianPrecision = 0.10;
% 1) Normalize inputs to [0,1] ONLY for RGF 
I1n = im2double(x{1});
I2n = im2double(x{2});

% 2) Run RGF on normalized images
out1n = RollingGuidanceFilter(I1n, sigma_s_rgf, sigma_r_rgf, iteration_rgf, GaussianPrecision);
out2n = RollingGuidanceFilter(I2n, sigma_s_rgf, sigma_r_rgf, iteration_rgf, GaussianPrecision);

% 3) Bring filtered outputs back to 0–255 scale for your CBF detail computation
cbf_out{1} = 255 * out1n;
cbf_out{2} = 255 * out2n;

% 4) Detail images in 0–255 scale (consistent with original CBF pipeline)
detail{1} = double(x{1}) - cbf_out{1};
detail{2} = double(x{2}) - cbf_out{2};



%%% Fusion Rule (IEEE Conf 2011).
%xfused=cbf_ieeeconf2011f(x,detail,cov_wsize);
xfused = cbf_ieeeconf2011f_diagonal(x,detail,cov_wsize);

toc


xfused8=uint8(xfused);

if(strncmp(inp_image,'gun',3))
   figure,imagesc(x{1}),colormap gray
   figure,imagesc(x{2}),colormap gray
   figure,imagesc(xfused8),colormap gray
else
   figure,imshow(x{1})
   figure,imshow(x{2})   
   figure,imshow(xfused8)  
end


%imwrite(xfused8,'S7.png');

fusion_perform_fn(xfused8,x);
