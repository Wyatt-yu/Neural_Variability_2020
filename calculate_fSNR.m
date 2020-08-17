% Functional signal-to-noise ratio has several definitions and variants,
% this code is based on the "Definition 2" in the article entitled "On the 
% Definition of Signal-To-Noise Ratio and Contrast-To-Noise Ratio 
% for fMRI Data" published on Plos One. 

addpath(genpath('D:/MATLAB/NIFTI'));
path='F:\字形加工中的神经噪音\analyses_neural noise\Vis\Lex_per_spmT_1st';
load(['F:\字形加工中的神经噪音\analyses_neural noise/Vis/' 'parcellist_200_craddock_Vis.mat']);

DD_LexPer=dir([path '/S2/DD/' '*Lex_Percep.nii']);
AC_LexPer=dir([path '/S2/AC/' '*Lex_Percep.nii']);
RC_LexPer=dir([path '/S2/RC/' '*Lex_Percep.nii']);

DD_rawPer=dir([path '/S2/DD/' '*raw_Percep.nii']);
AC_rawPer=dir([path '/S2/AC/' '*raw_Percep.nii']);
RC_rawPer=dir([path '/S2/RC/' '*raw_Percep.nii']);

fSNR_DD=zeros(16,1);fSNR_AC=zeros(14,1);fSNR_RC=zeros(14,1);

for i=1:16 %DD fSNR
    a=load_nii([DD_LexPer(i).folder '/' DD_LexPer(i).name]);a=a.img; 
    b=load_nii([DD_rawPer(i).folder '/' DD_rawPer(i).name]);b=b.img; 
    fSNR_DD(i)=(max(a(:))-mean(b(:)))/std(b(:));
end

for i=1:14 %AC fSNR
    a=load_nii([AC_LexPer(i).folder '/' AC_LexPer(i).name]);a=a.img; 
    b=load_nii([AC_rawPer(i).folder '/' AC_rawPer(i).name]);b=b.img; 
    fSNR_AC(i)=(max(a(:))-mean(b(:)))/std(b(:));
end

for i=1:14 %RC fSNR
    a=load_nii([RC_LexPer(i).folder '/' RC_LexPer(i).name]);a=a.img; 
    b=load_nii([RC_rawPer(i).folder '/' RC_rawPer(i).name]);b=b.img; 
    fSNR_RC(i)=(max(a(:))-mean(b(:)))/std(b(:));
end