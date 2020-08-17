clear
clc
addpath(genpath('D:/MATLAB/NIFTI/'));
%addpath(genpath('D:\MATLAB/BrainNetViewer/'));
workpath='E:\Ë«ÓïÕÏ°­_Êý¾Ý';
cd(workpath);

ROI=load_nii([workpath '\' 'ADHD200_parcellate_200.nii']);
ROI=ROI.img;

M=200; %number of parcellations within the ROI

mask=load([workpath,'/','Vis','/','exclude_skull_voxels_3mm_template.mat']); 

   for k=1:M
        ID=find(ROI==k & mask==1);
        parcel{k}=ID;
        parcel=parcel';
   end
   
   save([workpath,'/','Vis','/parcellist_200_craddock_Vis_3mm.mat'],'parcel');