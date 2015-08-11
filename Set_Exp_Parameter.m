% Set the experiment parameters for the test script
%% load feature
flag_preFilter = 0;
partition_name = 'Random';  %'Random'; %'SDALF'; % cam3ref

Featurename = [dataset_name '_HistMoment' num2str(num_patch) 'Patch'];
if flag_preFilter
    fname = [dataset_name '_HistMoment' num2str(num_patch) 'Patch_wPreFiltering.mat'];
else
    fname = [dataset_name '_HistMoment' num2str(num_patch) 'Patch_woPreFiltering.mat'];
end

load([dropbox_folder '/Feature/' fname]);
%% picking the useful features
if 1
featurename = fieldnames(DataSet.idxfeature);
idx_feat =[];
if strcmp(algoname ,'oLFDA')
    % setting features for paper "Local Fisher Discriminant Analysis for 
    % Pedestrian Re-Identification". The major difference is not using
    % kernel technique and PCA is applied for preprocessing.
    Feature =[];
    chanl_name ={'YUV','HSV','RGB','n8u2r1','n16u2r2'};
    for j =1: length(chanl_name)
        idx_feat =[];
        for i = 1: 21%length(featurename)
            % do not use the V channel in HSV. Because it is redundant and
            % the same as Y channel in YUV
            if strcmp(featurename{i}, 'HSVv') 
                continue;
            end
            temp = getfield(DataSet.idxfeature, featurename{i});
            if ~isempty(strfind(featurename{i}, chanl_name{j}))
                idx_feat = [idx_feat; temp(:)];
            end
        end
        ftemp = single(DataSet.data(:, idx_feat));
        % PCA
        [COEFF,pc,latent,tsquare] = princomp(ftemp,'econ');
        pcadim = 80;
%         pcadim =  sum(cumsum(latent)/sum(latent)<0.95);
        Feature = [Feature  pc(:, 1:pcadim)];
        AlgoOption.doPCA = 1; % flag for PCA preprocessing
    end
    
else
    % color histogram
    for i = [1 2 3 7 8 4 5 6] %1: 9%length(featurename)
         % do not use the V channel in HSV. Because it is redundant and
            % the same as Y channel in YUV
%         if strcmp(featurename{i}, 'HSVv')
%             continue;
%         end
        temp = getfield(DataSet.idxfeature, featurename{i});
        idx_feat = [idx_feat; temp(:)];
    end
    % LBP histogram
    for i = 10: 21%length(featurename)        
        if 	strcmp(featurename{i},'n8u2r1') || strcmp(featurename{i},'n16u2r2')
            temp = getfield(DataSet.idxfeature, featurename{i});
            idx_feat = [idx_feat; temp(:)];
        end
    end
        
    if num_patch ==341 && ~strcmp(algoname ,'oLFDA') &&...
            ~strcmp(algoname ,'svmml') && ~strcmp(algoname ,'KISSME')
        Feature = sparse(double(DataSet.data(:, idx_feat)));
    else
        Feature = single(DataSet.data(:, idx_feat));
    end
    
    AlgoOption.doPCA = 0;  % flag for PCA preprocessing
    if strcmp(algoname ,'svmml')% apply PCA for svmml and PRDC algorithm
%             ||(strcmp(algoname ,'PRDC') && num_patch > 14)
        [COEFF,pc,latent,tsquare] = princomp(Feature,'econ');
        pcadim =  sum(cumsum(latent)/sum(latent)<0.95); %80;%
        Feature = pc(:, 1:pcadim);
        AlgoOption.doPCA = 1;
    end
    if strcmp(algoname ,'KISSME')
        [COEFF,pc,latent,tsquare] = princomp(Feature,'econ');
%         pcadim =  sum(cumsum(latent)/sum(latent)<0.95); %80;%
        Feature = pc(:, 1:pcadim);
        AlgoOption.doPCA = 1;
    end
end

else
    fname = [dataset_name '_Hist' num2str(num_patch) 'Patch'];
    load([dropbox_folder '/Feature/' fname]);
    AlgoOption.doPCA = 0; 
    Feature = FeatureAppearence;
end
clear DataSet;
%% load dataset partition
load([dropbox_folder '/Feature/' dataset_name '_Partition_' partition_name '.mat']);
load([dropbox_folder '/Dataset/' dataset_name '_Images.mat'], 'gID', 'camID')
Partition = Partition(1:10);
%%
% The number of test times with the same train/test partition.
% In each test, the gallery and prob set partion is randomly divided.
num_itr =10; 
np_ratio =10; % The ratio of number of negative and positive pairs. Used in PCCA
% default algorithm option setting
AlgoOption.name = algoname;
AlgoOption.func = algoname; % note 'rPCCA' use PCCA function also.
AlgoOption.npratio = np_ratio; % negative to positive pair ratio
AlgoOption.beta =3;  % different algorithm have different meaning, refer to PCCA and LFDA paper.
AlgoOption.d =40; % projection dimension
AlgoOption.epsilon =1e-4;
AlgoOption.lambda =0;
AlgoOption.w = [];
AlgoOption.dataname = fname;
AlgoOption.partitionname = partition_name;
AlgoOption.num_itr=num_itr;
% customize in different case
switch  algoname
    case {'LFDA'}
        AlgoOption.npratio =0; % npratio is not required.
        AlgoOption.beta =0.01;
        AlgoOption.d =40;
        AlgoOption.LocalScalingNeighbor =6; % local scaling affinity matrix parameter.
        AlgoOption.num_itr= 10;
    case {'oLFDA'}
        AlgoOption.npratio =0; % npratio is not required.
        AlgoOption.beta =0.15; % regularization parameter
        AlgoOption.d = 40;
        AlgoOption.LocalScalingNeighbor =6; % local scaling affinity matrix parameter.
        AlgoOption.num_itr= 10;
    case {'rPCCA'}
        AlgoOption.func = 'PCCA';
        AlgoOption.lambda =0.01;
    case {'svmml'}
        AlgoOption.p = []; % learn full rank projection matrix
        AlgoOption.lambda1 = 1e-8;
        AlgoOption.lambda2 = 1e-6;
        AlgoOption.maxit = 300;
        AlgoOption.verbose = 1;
    case {'MFA'}
        AlgoOption.Nw = 0; % 0--use all within class samples
        AlgoOption.Nb = 12;
        AlgoOption.d = 30;
        AlgoOption.beta = 0.01;
%     case {'PRDC'} % To be added in the future
%         AlgoOption.Maxloop = 100;
%         AlgoOption.Dimension = 1000;
%         AlgoOption.npratio = 0;
    case {'KISSME'}
        AlgoOption.PCAdim = pcadim;
        AlgoOption.npratio = 10;
        AlgoOption.nFold = 20;
end

if strfind(Featurename, 'COV')
    AlgoOption.isCOV = 1;
    kname={'COV'};
else
    AlgoOption.isCOV = 0;

    kname={'linear'}; % , 'linear', 'chi2''chi2-rbf'
    if strcmp(algoname ,'oLFDA')|| strcmp(algoname ,'svmml') || strcmp(algoname ,'KISSME')
        kname = {'linear'};
    end
end

