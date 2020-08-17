clear
clc

addpath(genpath('D:/MATLAB/NIFTI'));
%addpath(genpath('D:/MATLAB/GRETNA_master'));
path='F:\....';
load(['F:\....' 'parcellist_200_craddock_Vis.mat']);

S1_Tmaps=dir([path '/S1/' '*.nii']);
S2_Tmaps=dir([path '/S2/' '*.nii']);

M=200;% # of regions of interest



%%%% Calculate neual stability(Pearson's r)for Craddock parcels (M=200)
parcel_corr_Vis_LexFix=zeros(M,length(S1_Tmaps));
for i=1:length(S1_Tmaps)
    for j=1:M
        a=load_nii([path '/S1/' S1_Tmaps(i).name]);a=a.img; 
        b=load_nii([path '/S2/' S2_Tmaps(i).name]);b=b.img;
        parcel_corr_Vis_LexFix(j,i)=corr(a(parcel{j}),b(parcel{j}));
    end
end


%%%%% Transform Pearson's r into Fisher's z
r=parcel_corr_Vis_LexFix;
t=(1+r)./(1-r);
parcel_Fz_Vis_perFix=0.5*log(t);

save([path '/' 'parcel_Fz_Vis' '.mat'],'parcel_Fz_Vis_perFix');
