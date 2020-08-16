%Assume you have 15 ROIs and for each ROI you want to look at the
%hypothesis test for the overall mean (over 20 measures).  Although we could use a bonferroni
%test to correct for all 15 tests, we might be better off using a
%permuataion based test.
 
%Steps of the max-statistic based permutation test
%Step 1:  Calculate test statistics for all 15 tests without use of
%permutations
%
%Step 2:  Randomly select some observations and multiply their values by
%negative 1.  Note, if the null were true in this case, then it shouldn't
%matter if we change the sign of our values or not.
%
%Step 3: Calculate the 15 test statistics and store the value of the
%maximum of the 15 statistics
%
%Step 4: Repeat 2 & 3 many, many times (let's do 5000)
%Step 5:  Compare the original test statistics from step 1 to the cutoff
%corresponding to the 95th percentile of the max tstat distribution
 
 
%load in data——200 parcels(ROIs).
load(['C:\Users\Acer\Desktop\craddock_parcellation_tutorial' '/Vis/' 'parcel_Fz_Vis_200.mat']);
M=200;

%=================================
%Step 1: Calculate 15 test statistics

p_DDxiaoyuAC=ones(200,1)
t_DDxiaoyuAC=zeros(200,1);
for N=1:M
[p_DDxiaoyuAC(N),~,stat]=ttest2(parcel_Fz_Vis(N,Vis_Cao_AC_ID)',parcel_Fz_Vis(N,Vis_Cao_DD_ID)','Alpha',0.005,'Dim',1,'tail','left','Vartype','unequal');tval_DDdayuAC(N)=stat.tval;
t_DDxiaoyuAC(N)=stat.tstat; 
end
  

%=================================
%Steps 2 & 3 &4
nperm=10000;

tmax_DDAC=zeros(nperm,1);

p_DDxiaoAC_perm=ones(200,1);

T_DDxiaoAC_perm=zeros(200,1);

for i=1:nperm
    % shuffle data by randomize group label  
    aa=shuffle([Vis_Cao_DD_ID Vis_Cao_AC_ID]);
    Vis_per_DD_ID=aa([1:length(Vis_Cao_DD_ID)]);
    Vis_per_AC_ID=aa([length(Vis_Cao_DD_ID)+1:end]);

    
%calculate 200 t-stats for permuted data
for N=ind

[~,~,~,stat]=ttest2(parcel_Fz_Vis(N,Vis_per_DD_ID)',parcel_Fz_Vis(N,Vis_per_AC_ID)','Alpha',0.005,'Dim',1,'tail','left','Vartype','unequal');
T_DDxiaoAC_perm(N)=stat.tstat;
end

%Cacluate the max t stat for this iteration

Tmax_DDAC(i)=max(T_DDxiaoAC_perm);
i   % display progress of permutation
end
 
% Step 5:  Calculate the percentiles for each statistic based on
% permutation-based null dist
 
p_perm_DDxAC=ones(M,1);

for i=ind
p_perm_DDxAC(i)=sum(Tmax_DDAC>=abs(Tval_DDxiaoyuAC(i)))/nperm;
end

sig=find(p_perm_DDxAC<0.05);


histogram(Tmax_DDAC,15)
rank=sort(Tmax_DDAC,'descend');
rank(500)
