function [TTest2_T, TTest2_P] = TTest2(DependentFiles, Covariates)

% Perform two sample t test.
% Input:
%   DependentFiles - the metric file of dependent variable. 1 by n cell
%   OutputName - the output name.
%   Covariates - The other covariates. 1 by n cell 
%   ** Each cell of DependentFiles or Coraviates corresponds to 
%   ** the data of one gruop (n group = 1 × n cell). So, each cell should 
%   ** be a two-dimension matrix, with 
%   ** participants(rows)×values of variables(columns)

% Output:
%   TTest1_T - the T value, also write image file out indicated by OutputName


%___________________________________________________________________________
%   This code is adapted from "GRETNA_master" toolbox
%   2019/7

GroupNumber=length(DependentFiles);% 是cell的个数，cell里面一个矩阵代表一个组的数据
GroupLabel=[];

DependentMatrix=[];
CovariatesMatrix=[];

for i=1:GroupNumber
    if ischar(DependentFiles{i})
        Matrix=load(DependentFiles{i});
        fprintf('\n\tGroup %.1d: Load File %s:\n', i, DependentFiles{i});        
    else
        Matrix=DependentFiles{i};
    end
    DependentMatrix=cat(1, DependentMatrix, Matrix); % cat(1,A,B) 垂直串联(1是垂直，2是水平)A B两个矩阵，即[A ; B]
    
    if exist('Covariates','var') && ~isempty(Covariates)
        CovariatesMatrix=cat(1, CovariatesMatrix, Covariates{i});
    end
    
    GroupLabel=cat(1, GroupLabel, ones(size(Matrix, 1), 1)*i);
end

GroupLabel(GroupLabel==2)=-1;

NumOfSample=size(DependentMatrix, 1);

Regressors=[GroupLabel, ones(NumOfSample, 1), CovariatesMatrix];

Contrast=zeros(1, size(Regressors, 2));
Contrast(1)=1;

[b_OLS_metric, t_OLS_metric, TTest2_T, r_OLS_metric] = gretna_GroupAnalysis(DependentMatrix, Regressors, Contrast, 'T');

DOF=NumOfSample-size(Regressors, 2);
TTest2_P=2*(1-tcdf(abs(TTest2_T), DOF));

fprintf('\n\tTwo Sample T Test Calculation finished.\n');