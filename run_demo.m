clc
clear
warning off
dropbox_folder =  pwd;%'C:\Users\Goo\Dropbox\Fei_Mengran\Matlab Code\ReID';
addpath(genpath('Assistant Code'));
mkdir('Feature');
%%
% name of metric learning algorithm 
algoname = 'LFDA'; %'oLFDA'; 'PCCA'; 'rPCCA'; 'LFDA'; 'MFA'; 'KISSME'; 'svmml' 
% dataset name
dataset_name = 'iLIDS'; %{'VIPeR' 'iLIDS' 'CAVIAR' '3DPeS'};
% number of patches(stripes)
num_patch = 6; %6, 14, 75, 341
% PCA dimension, ONLY used in KISSME
pcadim = 65; %[77 45 65 70];
        
% if ~exist(['Feature/' dataset_name '_HistMoment' num2str(num_patch) 'Patch_woPreFiltering.mat'],'file')
%     Script_Feature_Extraction;
% end
% 
% if ~exist(['Feature/' dataset_name '_Partition_Random.mat'],'file')
%     Set_Partition(dataset_name);
% end

test_Ranking

% Script_demo_result;