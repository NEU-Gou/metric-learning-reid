clc
% clear 
%%
% load cuhk-03.mat
camID = [];
camPair = [];
gID = [];
I = {};
img_path = {};

image = detected; % labeled; detected
cnt = 1;
for cp = 1:numel(image) % number of camera pairs
    for id = 1:size(image{cp},1)
        tmp_iden = image{cp}(id,:);
        for n = 1:numel(tmp_iden)
            if isempty(tmp_iden{n})
                continue;
            end
            I{cnt} = tmp_iden{n};
            gID(cnt) = id;
            camID(cnt) = ceil(n/5);
            camPair(cnt) = cp;
            cnt = cnt + 1;
        end
    end
end
        
%%
save('cuhk_03_detected.mat','I','camID','camPair','gID');