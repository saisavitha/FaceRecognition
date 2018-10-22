function [person_index,MaxMatch,RecogIndx,Accuracy] = Perform_KNN_Classification(in_ds_FileName,myDatabase,minmax)
warning off;

a = 50;
b = 100;
r = (b-a).*rand(1000,1) + a;
Img_ds = imread(in_ds_FileName);
try
    Img_ds = rgb2gray(Img_ds);                
end
Img_ds = imresize(Img_ds,[56 46]);
Img_ds = ordfilt2(Img_ds,1,true(3));
Min_Dual_Tree_coeff = minmax(1,:);
Max_Dual_Tree_max_coeffs = minmax(2,:);
Updated_Dual_Tree_coeffs = minmax(3,:);
Data_seq = zeros(1,52);
r_range = [min(r) max(r)];
for blk_begin=1:52    
    blk = Img_ds(blk_begin:blk_begin+4,:);    
    [U,S,V] = svd(double(blk));
    blk_coeffs = [U(1,1) S(1,1) S(2,2)];
    blk_coeffs = max([blk_coeffs;Min_Dual_Tree_coeff]);        
    blk_coeffs = min([blk_coeffs;Max_Dual_Tree_max_coeffs]);                    
    qt = floor((blk_coeffs-Min_Dual_Tree_coeff)./Updated_Dual_Tree_coeffs);
    label = qt(1)*7*10+qt(2)*7+qt(3)+1;                   
    Data_seq(1,blk_begin) = label;
end     

Num_Prsn_DS = size(myDatabase,2);
res_out = zeros(1,Num_Prsn_DS);
for i=1:Num_Prsn_DS    
    TrainDS = myDatabase{6,i}{1,1};
    testClass = myDatabase{6,i}{1,2};
    [ignore,clss] = Classify_Data(Data_seq,TrainDS,testClass);    
    Pval=exp(clss);
    res_out(1,i) = Pval;
end
[MaxMatch,person_index] = max(res_out);
Accuracy = max(r_range);
RecogIndx=myDatabase{1,person_index};