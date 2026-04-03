function fuse_im=cbf_ieeeconf2011f_diagonal(inp,detail,cov_wsize)



half_wsize=(cov_wsize-1)/2;
temp1=per_extn_im_fn(detail{1},cov_wsize);
temp2=per_extn_im_fn(detail{2},cov_wsize);
[MM,NN]=size(temp1);

% Directional weight maps for debugging/visualization
outM = MM - (cov_wsize-1);
outN = NN - (cov_wsize-1);

wtH1 = zeros(outM, outN); wtV1 = zeros(outM, outN); wtD45_1 = zeros(outM, outN); wtD135_1 = zeros(outM, outN);
wtH2 = zeros(outM, outN); wtV2 = zeros(outM, outN); wtD45_2 = zeros(outM, outN); wtD135_2 = zeros(outM, outN);


for ii=half_wsize+1:MM-half_wsize
    for jj=half_wsize+1:NN-half_wsize
        
        %%% ============ 1st Detail Image ============
        tt1=temp1(ii-half_wsize:ii+half_wsize,jj-half_wsize:jj+half_wsize);
        
        % ORIGINAL: Horizontal and Vertical only
        hr_cov_mat1=covarf(tt1,cov_wsize);
        ver_cov_mat1=covarf(tt1',cov_wsize);
        hor_es1=sum(eig(hr_cov_mat1));
        ver_es1=sum(eig(ver_cov_mat1));
        
        % ===== NEW: Add Diagonal 1 (45° direction) =====
        % Extract main diagonal 
        diag1_data = extract_diagonal_45_v2(tt1);
        diag1_cov_mat = covarf(diag1_data, size(diag1_data,1));
        diag1_es = sum(eig(diag1_cov_mat));
        
        % ===== NEW: Add Diagonal 2 (135° direction) =====
        diag2_data = extract_diagonal_135_v2(tt1);
        diag2_cov_mat = covarf(diag2_data, size(diag2_data,1));
        diag2_es = sum(eig(diag2_cov_mat));

        ii0 = ii - half_wsize;
jj0 = jj - half_wsize;

wtH1(ii0,jj0)    = hor_es1;
wtV1(ii0,jj0)    = ver_es1;
wtD45_1(ii0,jj0) = diag1_es;
wtD135_1(ii0,jj0)= diag2_es;
        

        % Combined weight: H + V + D1 + D2 (4 directions)
        wt1(ii-half_wsize,jj-half_wsize) = hor_es1 + ver_es1 + diag1_es + diag2_es;
        %%% ============ 2nd Detail Image ============
        tt2=temp2(ii-half_wsize:ii+half_wsize,jj-half_wsize:jj+half_wsize);
        
        % Original
        hr_cov_mat2=covarf(tt2,cov_wsize);
        ver_cov_mat2=covarf(tt2',cov_wsize);
        hor_es2=sum(eig(hr_cov_mat2));
        ver_es2=sum(eig(ver_cov_mat2));

        
        
        % NEW: Diagonals
        diag1_data2 = extract_diagonal_45_v2(tt2);
        diag1_cov_mat2 = covarf(diag1_data2, size(diag1_data2,1));
        diag1_es2 = sum(eig(diag1_cov_mat2));
        
        diag2_data2 = extract_diagonal_135_v2(tt2);
        diag2_cov_mat2 = covarf(diag2_data2, size(diag2_data2,1));
        diag2_es2 = sum(eig(diag2_cov_mat2));

        wtH2(ii0,jj0)     = hor_es2;
wtV2(ii0,jj0)     = ver_es2;
wtD45_2(ii0,jj0)  = diag1_es2;
wtD135_2(ii0,jj0) = diag2_es2;

        
        % Combined
        wt2(ii-half_wsize,jj-half_wsize) = hor_es2 + ver_es2 + diag1_es2 + diag2_es2;
        
    end
end

% Handle zeros (same as original)
[a,b]=find(wt1==0);
for kk=1:length(a)
    wt1(a(kk),b(kk))=eps;
end

[a,b]=find(wt2==0);
for kk=1:length(a)
    wt2(a(kk),b(kk))=eps;
end

figure; 
subplot(2,2,1); imagesc(wtH1); axis image off; colormap jet;  title('wtH1 (Horizontal)');
subplot(2,2,2); imagesc(wtV1); axis image off; colormap jet;  title('wtV1 (Vertical)');
subplot(2,2,3); imagesc(wtD45_1); axis image off; colormap jet;  title('wtD45\_1 (45°)');
subplot(2,2,4); imagesc(wtD135_1); axis image off; colormap jet;  title('wtD135\_1 (135°)');

figure; 
subplot(2,2,1); imagesc(wtH2); axis image off; colormap turbo; title('wtH2 (Horizontal)');
subplot(2,2,2); imagesc(wtV2); axis image off; colormap turbo; title('wtV2 (Vertical)');
subplot(2,2,3); imagesc(wtD45_2); axis image off; colormap turbo; title('wtD45\_2 (45°)');
subplot(2,2,4); imagesc(wtD135_2); axis image off; colormap turbo; title('wtD135\_2 (135°)');

fprintf('Image1: H[%g,%g] V[%g,%g] D45[%g,%g] D135[%g,%g]\n', ...
    min(wtH1(:)),max(wtH1(:)), min(wtV1(:)),max(wtV1(:)), min(wtD45_1(:)),max(wtD45_1(:)), min(wtD135_1(:)),max(wtD135_1(:)));

fprintf('Image2: H[%g,%g] V[%g,%g] D45[%g,%g] D135[%g,%g]\n', ...
    min(wtH2(:)),max(wtH2(:)), min(wtV2(:)),max(wtV2(:)), min(wtD45_2(:)),max(wtD45_2(:)), min(wtD135_2(:)),max(wtD135_2(:)));

figure; 
subplot(2,2,1); imagesc(wt1); axis image off; colormap turbo; title('wtH1');
figure; 
subplot(2,2,1); imagesc(wt2); axis image off; colormap turbo; title('wtH2');
% Fusion (same as original) 
fuse_im=(double(inp{1}).*wt1+double(inp{2}).*wt2)./(wt1+wt2);



end

%%% ============ HELPER FUNCTIONS ============

function diag_matrix = extract_diagonal_45_v2(window)
% Extract diagonal data for 45° direction analysis
% This extracts all diagonals parallel to main diagonal
[m,n] = size(window);
num_diagonals = m; % For square window

diag_matrix = zeros(num_diagonals, m);
for k = 1:num_diagonals
    diag_vals = diag(window, k - ceil(m/2));
    diag_matrix(k, 1:length(diag_vals)) = diag_vals';
end
end

function diag_matrix = extract_diagonal_135_v2(window)
% Extract diagonal data for 135° direction analysis  
% This extracts all diagonals parallel to anti-diagonal
[m,n] = size(window);
window_flipped = fliplr(window); % Flip to get anti-diagonals
num_diagonals = m;

diag_matrix = zeros(num_diagonals, m);
for k = 1:num_diagonals
    diag_vals = diag(window_flipped, k - ceil(m/2));
    diag_matrix(k, 1:length(diag_vals)) = diag_vals';
end
end
