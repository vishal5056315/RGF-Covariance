# RGF–Covariance-Based Multi-Patch Photoacoustic Image Fusion (MATLAB)

This repository contains the MATLAB implementation of a structure-aware, multi-patch photoacoustic (PA) image fusion algorithm based on Rolling Guidance Filter (RGF) base–detail decomposition and directional covariance analysis. The code reproduces the fusion and evaluation pipeline described in our manuscript:



The main script for running the proposed fusion algorithm is:

- **`cbf_fusion_pgm.m`** — main driver script that loads the multi-wavelength PA patches, performs hierarchical RGF–covariance fusion, and computes objective fusion metrics.

---

## Repository Structure

The key files included in this repository are:

- **Main algorithm**
  - `cbf_fusion_pgm.m`  
    Main entry point. Implements the hierarchical multi-patch PA fusion pipeline (Fusion I–III), calls the Rolling Guidance Filter for base–detail decomposition, directional covariance-based saliency computation, normalized weighted fusion, and objective metric evaluation.

- **Rolling Guidance Filter (base–detail decomposition)**
  - `RollingGuidanceFilter.m` / `RollingGuidanceFilter-4.m` / `RollingGuidanceFilter-13.m`  
    Implementation of the Rolling Guidance Filter used to obtain scale-aware base layers while preserving vessel boundaries in the residual detail images.[file:465]
 

- **Directional covariance and support utilities**
  - `cbf_ieeeconf2011f_diagonal`  
    Computes the sample covariance matrix for a given window; used as the core building block for directional covariance analysis.
  - `per_extn_im_fn.m`  
    Periodic extension of an image in all four directions to avoid border artifacts when computing local windows.

- **Objective fusion quality metrics**
  - `fusion_perform_fn.m`  
    Computes a suite of fusion quality measures: Average Pixel Intensity (API), Standard Deviation (SD), Average Gradient (AG), Entropy, Mutual Information (MIF), Fusion Symmetry (FS1), correlation, and Spatial Frequency (SF), and then calls `

  - `objective_fusion_perform_fn.m`  
    Implements Petrovic’s gradient- and orientation-based edge preservation metric (QABF), fusion loss (LABF), and fusion artifact metrics (NABF, NABF1), including the modified NABF measure by B. K. Shreyamsha Kumar.
  

- **Low-level image operators**
  - `sobel_fn.m`  
    Computes vertical and horizontal gradients using the Sobel operator; used by the Petrovic metrics.
  - `imhist_fn.m`  
    Computes the gray-level histogram of an image, used in entropy and mutual information calculations.
  - `joint_hist_fn.m`  
    Computes the joint histogram between two images, used for mutual information between sources and fused image.

- **Baseline / competing methods**
  - `cbf_ieeeconf2011f_diagonal.m`  
    Implementation of a cross/bilateral filtering-based image fusion method used as a baseline for comparison in the manuscript.[file:467]



---

## Getting Started

### Requirements

- MATLAB 
- Image Processing Toolbox (recommended)
- Tested on Windows 11; should also work on Linux/macOS with minor path adjustments.

### Running the Fusion Algorithm

1. **Place your input images**

   - Prepare the registered multi-wavelength PA patches as grayscale images.
   - Ensure they are in the expected folder / filenames referenced inside `cbf_fusion_pgm.m`.

2. **Configure parameters in `cbf_fusion_pgm.m`**

   Inside `cbf_fusion_pgm.m`, set:
   - Paths and filenames for the source images
   - RGF parameters (`sigma_s`, `sigma_r`, number of iterations, Gaussian precision)
   - Covariance window size and hierarchical fusion settings

3. **Run the main script**

   In MATLAB:

   ```matlab
   >> cbf_fusion_pgm
   ```

   The script will:
   - Load the source PA patches
   - Perform hierarchical multi-level fusion (Fusion I–III)
   - Generate intermediate outputs S1–S6 and final fused image S7
   - Compute objective metrics (API, SD, AG, Entropy, MIF, FS1, corr, SF, QABF, LABF, NABF, NABF1)
   - Display / save the fused images and metrics

4. **Evaluating other fusion methods**

   If you also run baseline methods (e.g., `cbf_ieeeconf2011f_diagonal.m`), you can feed each method’s fused result into `fusion_perform_fn.m` and `objective_fusion_perform_fn.m` to compute comparable metrics.

---

## Rolling Guidance Filter Usage

The Rolling Guidance Filter can be used independently for general edge-preserving smoothing:

```matlab
imageFile = 'image.png';
I = im2double(imread(imageFile));

sigma_s = 4;           % spatial scale
sigma_r = 0.1;         % range sensitivity
iteration = 4;         % number of iterations
GaussianPrecision = 0.05;

result = RollingGuidanceFilter(I, sigma_s, sigma_r, iteration, GaussianPrecision);

figure, imshow(I), title('Input');
figure, imshow(result), title('RGF Smoothed');
```

This filter is used in the fusion pipeline to obtain base layers and residual detail layers that preserve PA vessel boundaries.

---



- **Rolling Guidance Filter (original method)**  
  
Q. Zhang, X. Shen, L. Xu, and J. Jia, “Rolling guidance filter,” in European conference on computer vision, 2014, pp. 815–830.

- B. K. Shreyamsha Kumar, “Image fusion based on pixel significance using cross bilateral filter,” Signal, image video Process., vol. 9, no. 5, pp. 1193–1204, 2015.

---

