clc
clear 
%% appearance feature extraction in M. Hirzer, et al ECCV 2012
load 'Dataset\iLIDSVID_Images_Tracklets_l15.mat';

imsz = [128 64];
step = [4,8];
BBoxsz = [8 16];
LBP_Mapping = getmapping(8,'riu2');

[region_idx, BBox] =GenerateGridBBox(imsz, BBoxsz, step);
tmpF = zeros(numel(I),numel(region_idx)*(6+LBP_Mapping.num));
for i = 1:numel(I)
    i
    tmpSeq = I{i};
    tmpfeat = zeros(numel(tmpSeq),numel(region_idx)*(6+LBP_Mapping.num));
    for n = 1:numel(tmpSeq)
        tmpI = tmpSeq{n};
        tmpHSV = zeros(1,numel(region_idx)*3);
        tmpLab = zeros(1,numel(region_idx)*3);
        imHSV = rgb2hsv(uint8(tmpI));
        imLab = rgb2lab(uint8(tmpI));
        for bb = 1:numel(region_idx)
            imH = imHSV(:,:,1);
            imS = imHSV(:,:,2);
            imV = imHSV(:,:,3);
            tmpHSV((bb-1)*3+1) = mean(imH(region_idx{bb}));
            tmpHSV((bb-1)*3+2) = mean(imS(region_idx{bb}));
            tmpHSV((bb-1)*3+3) = mean(imV(region_idx{bb}));
        end
        tmpHSV = (tmpHSV./max(tmpHSV))*40;
        for bb = 1:numel(region_idx)
            imL = imLab(:,:,1);
            imA = imLab(:,:,2);
            imB = imLab(:,:,3);
            tmpLab((bb-1)+1) = mean(imL(region_idx{bb}));
            tmpLab((bb-1)+2) = mean(imA(region_idx{bb}));
            tmpLab((bb-1)+3) = mean(imB(region_idx{bb}));
        end
        tmpLab = (tmpLab./max(tmpLab))*40;
        
        % lbp
        tmpGary = rgb2gray(uint8(tmpI));        
        tmpLBP = zeros(1,numel(region_idx)*LBP_Mapping.num);
        for bb = 1:size(BBox,1)
            tmpLBP((bb-1)*LBP_Mapping.num+1:bb*LBP_Mapping.num) = ...
                lbp(tmpGary(BBox(bb,2):BBox(bb,4), BBox(bb,1):BBox(bb,3),:),2,LBP_Mapping.samples,LBP_Mapping,'nh');
        end
        tmpfeat(n,:) = [tmpHSV,tmpLab,tmpLBP];
    end
    tmpF(i,:) = mean(tmpfeat,1);
end
FeatureAppearence = tmpF;
save('iLIDSVID_ColorLBP.mat','FeatureAppearence');