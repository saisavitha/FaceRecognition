function [myDatabase,minmax] = Create_Dataset()
% 
warning off;
eps=.000001;
FilterBank_Pars = [1 5 6 8 10];

Dataset_Dir = dir ('./data');
myDatabase = cell(0,0);
Prsn_Idx = 0;
Dual_Tree_max_coeffs = [-Inf -Inf -Inf];
Dual_Tree_min_coeffs = [ Inf  0  0];
h = waitbar(0,'Please wait...');
for Prsn_Count=1:size(Dataset_Dir,1);
    
    waitbar(Prsn_Count/ size(Dataset_Dir,1));
    if (strcmp(Dataset_Dir(Prsn_Count,1).name,'.') || ...
        strcmp(Dataset_Dir(Prsn_Count,1).name,'..') || ...
        (Dataset_Dir(Prsn_Count,1).isdir == 0))
        continue;
    end
    Prsn_Idx = Prsn_Idx+1;
    User_Name = Dataset_Dir(Prsn_Count,1).name;
    myDatabase{1,Prsn_Idx} = User_Name;
    fprintf([User_Name,' ']);
    person_folder_contents = dir(['./data/',User_Name,'/*.pgm']);    
    blk_cell = cell(0,0);
    for face_index=1:5
        I = imread(['./data/',User_Name,'/',person_folder_contents(FilterBank_Pars(face_index),1).name]);
        I = imresize(I,[56 46]);
        I = ordfilt2(I,1,true(3));        
        Dual_Tree_blk_index = 0;
        for blk_begin=1:52
            Dual_Tree_blk_index=Dual_Tree_blk_index+1;
            blk_Parms = I(blk_begin:blk_begin+4,:);            
            [U_Decomposed,S_Decomposed,V_Decomposed] = svd(double(blk_Parms));
            blk_coeffs = [U_Decomposed(1,1) S_Decomposed(1,1) S_Decomposed(2,2)];
            Dual_Tree_max_coeffs = max([Dual_Tree_max_coeffs;blk_coeffs]);
            Dual_Tree_min_coeffs = min([Dual_Tree_min_coeffs;blk_coeffs]);
            blk_cell{Dual_Tree_blk_index,face_index} = blk_coeffs;
        end
    end
    myDatabase{2,Prsn_Idx} = blk_cell;
    if (mod(Prsn_Idx,10)==0)
        fprintf('\n');
    end
end
Threshold_val = (Dual_Tree_max_coeffs-Dual_Tree_min_coeffs)./([18 10 7]-eps);
minmax = [Dual_Tree_min_coeffs;Dual_Tree_max_coeffs;Threshold_val];
for Prsn_Idx=1:40
    for image_index=1:5
        for block_index=1:52
            blk_coeffs = myDatabase{2,Prsn_Idx}{block_index,image_index};
            Dual_Tree_min_coeffs = minmax(1,:);
            delta_coeffs = minmax(3,:);
            qt = floor((blk_coeffs-Dual_Tree_min_coeffs)./delta_coeffs);
            myDatabase{3,Prsn_Idx}{block_index,image_index} = qt;
            label = qt(1)*10*7+qt(2)*7+qt(3)+1;            
            myDatabase{4,Prsn_Idx}{block_index,image_index} = label;
        end
        myDatabase{5,Prsn_Idx}{1,image_index} = cell2mat(myDatabase{4,Prsn_Idx}(:,image_index));
    end
end

TRGUESS = ones(7,7) * eps;
TRGUESS(7,7) = 1;
for r=1:6
        TRGUESS(r,r) = 0.6;
        TRGUESS(r,r+1) = 0.4;    
end

EMITGUESS = (1/1260)*ones(7,1260);
close(h)
fprintf('\nTraining ...\n');
h = waitbar(0,'Please wait! Training Faces');
for Prsn_Idx=1:40
    waitbar(Prsn_Idx/40)
    fprintf([myDatabase{1,Prsn_Idx},' ']);
    seqmat = cell2mat(myDatabase{5,Prsn_Idx})';
    [ESTTR,ESTEMIT]=hmmtrain(seqmat,TRGUESS,EMITGUESS,'Tolerance',.01,'Maxiterations',10,'Algorithm', 'BaumWelch');
    ESTTR = max(ESTTR,eps);
    ESTEMIT = max(ESTEMIT,eps);
    myDatabase{6,Prsn_Idx}{1,1} = ESTTR;
    myDatabase{6,Prsn_Idx}{1,2} = ESTEMIT;
    if (mod(Prsn_Idx,10)==0)
        fprintf('\n');
    end
end
fprintf('done.\n');
save DATABASE myDatabase minmax
close (h)