%%%% 1.Prepare data
Train_dataset=Traindata_sample1_Zstand;  
N_total=length(Traindata_sample1_Zstand(:,1));
test_label=cell(N,1);  
Beta=[];
N_classA=length(find(Traindata_sample1_Zstand(:,1)==1));
N_classB=length(find(Traindata_sample1_Zstand(:,1)==2));

%%%% 2.Training SVM model with leave-one-out cross validation
for i=1:N_total
    z=ones(N_total,1);
    z(i)=0;
    zz= z==1; 
    
    train=Train_dataset(zz,[1]);
    numlabel=Train_dataset(zz,2);
    a=find(numlabel==-1);
    b=find(numlabel==1);
    group_label=blanks(N-1);group_label=group_label';
    group_label(a)='A'; 
    group_label(b)='B';
    group_label=cellstr(group_label);
    
    weight=zeros(N-1,1);
    weight(a)=1/N_classA;weight(b)=1/N_classB;

    Model=fitcsvm(train,group_label,'KernelFunction','linear','ClassNames',{'A','B'},'BoxConstraint',0.1,'weights',weight,'Standardize',true,'ShrinkagePeriod', 1000);
    Beta=[Beta;Model.Beta'];   
    test_data=Train_dataset(i,[1]);
    test_label(i)=predict(Model,test_data);
end

  c=0;
  a=find(Train_dataset(:,4)==-1);b=find(Train_dataset(:,4)==1);
  real_label=blanks(44);real_label=real_label';
  real_label(a)='A'; 
  real_label(b)='B';
  real_label=cellstr(real_label);

% Get overall accuracy
for i=1:length(real_label) 
    if real_label{i}==test_label{i}
        c=c+1;
    end
end
[real_label test_label]
OverallACC_sample1_leave_one_out=c/length(test_label)

%%%% 3.Permutation test for overall accuracy(H0:Accuracy = 50%, chance level)
perm_ACC=[];times=1000;
for j=1:times
for i=1:N
    z=ones(N,1);
    z(i)=0;
    zz= z==1;
    train=Train_dataset(zz,1);
    numlabel=Train_dataset(zz,2);
    a=find(numlabel==-1);
    b=find(numlabel==1);
    group_label=blanks(N-1);group_label=group_label';
    group_label(a)='A'; 
    group_label(b)='B';
    perm_label=shuffle(group_label);
    perm_label=cellstr(perm_label);
    weight_PERM=zeros(N-1,1);
    weight_PERM(a)=1/N_classA; weight_PERM(b)=1/N_classB;
    perm_Model=fitcsvm(train,perm_label,'KernelFunction','linear','ClassNames',{'A','B'},'BoxConstraint',0.1,'weights',weight,'Standardize',true);

    test_data=Train_dataset(i,1);
    test_label(i)=predict(perm_Model,test_data);
end

  c=0;
for i=1:length(real_label) 
    if real_label{i}==test_label{i}% cell如果要访问具体值的话，要用{}而不是()
        c=c+1;
    end
end
perm_ACC=[perm_ACC;c/N];

j %Indicate the progress (Iteration times) of Permutation
end

% Get the permutation-based p value and plot the distribution of 
% overall accuracy in random conditions
Adjusted_p_value=sum(perm_ACC>Overall_svm_ACC)/times;
histogram(perm_ACC,20)


%%%% 4.Get Confusion Matrix and Evaluation Indexes
confusion=zeros(44,1);
for i=1:length(test_label)
    if test_label{i}=='A'
       confusion(i)=-1;
    else
       confusion(i)=1;
    end
end
[A,~] = confusionmat(Train_dataset(:,4),confusion);
 
c1_precise = A(1,1)/(A(1,1) + A(2,1));
c1_recall = A(1,1)/(A(1,1) + A(1,2));
c1_F1 = 2 * c1_precise * c1_recall/(c1_precise + c1_recall);
c1_F2= (1+2*2)* c1_precise * c1_recall/(2*2*c1_precise + c1_recall);

c2_precise = A(2,2)/(A(1,2) + A(2,2));
c2_recall = A(2,2)/(A(2,1) + A(2,2));
c2_F1 = 2 * c2_precise * c2_recall/(c2_precise + c2_recall);
c2_F2= (1+2*2)* c2_precise * c2_recall/(2*2*c2_precise + c2_recall);


%%%% 5.plot Receiver Operator Characteristic Curve (ROC curve)
Model=fitcsvm(Traindata_sample1_Zstand(:,1),Traindata_sample1_Zstand(:,2),'KernelFunction','linear','ClassNames',{'Control','RD'},'BoxConstraint',0.1,'weights',weight,'Standardize',true,'ShrinkagePeriod',10);
[ScoreSVMModel,ScoreTransform] = fitPosterior(Model);   
[predict_label,scores] = resubPredict(Model);
[~,postProbs] = resubPredict(ScoreSVMModel);
%table(true_label,predict_label,scores(:,2),postProbs(:,2),'VariableNames',...
%{'TrueLabel','PredictedLabel','Score','PosteriorProbability'});

Thresholds=sort(postProbs(:,2),'descend');%阈值必须从大到小排好序，使得到的FPR,TPR从小到大排列，方便后面按顺序计算AUC
PProbs=postProbs(:,2)
TPR=zeros(N,1);FPR=zeros(N,1); Loop_predictLabel=strings(53,1);
loop_precise=zeros(N,1);loop_recall=zeros(53,1);

for i=1:N
 Predict_DD_index=find(PProbs>=Thresholds(i));
 Predict_Control_index=find(PProbs<Thresholds(i));
 Loop_predictLabel(Predict_DD_index)='RD';
 Loop_predictLabel(Predict_Control_index)='Control';

 confusion= cellstr(Loop_predictLabel);
 [A,order] = confusionmat(true_label,confusion);
 TPR(i) = A(2,2)/N_classA; %TPR= TP/All actual Positive
 FPR(i)= A(1,2)/N_classB;
 loop_precise(i) = A(2,2)/(A(1,2) + A(2,2));
 loop_recall(i) = A(2,2)/(A(2,1) + A(2,2));
end

[ascend_recall,index]=sort(loop_recall,'ascend');% Recall是X轴，Precision是Y轴。
[FPR TPR] %X axis is FPR，Y axis is TPR
k=plot(FPR,TPR,'b.-',[0:0.05:1],[0:0.05:1],'r--','MarkerSize',6,'MarkerFaceColor','red');

xlabel('False Positive Rate (1-specificity)');
ylabel('True Positive Rate (sensitivity)');
title('Receiver Operator Characteristic Curve');


% Calculate area under curve (AUC) of ROC
AUC_ROC = sum((FPR(2:end) - FPR(1:end-1)).*((TPR(1:end-1)+TPR(2:end))/2));


%%%% 6.plot precison-recall curve (P-R curve)
corresponding_precision=sort(loop_precise,'descend')
plot(ascend_recall,corresponding_precision,'g.-',[0:0.05:1],[1:-0.05:0],'r--');
xlabel('Recall');
ylabel('Precision');
title('Precision-Recall Curve');
AUC_PR = sum((ascend_recall(2:end) - ascend_recall(1:end-1)).*((corresponding_precision(1:end-1)+corresponding_precision(2:end))/2));


