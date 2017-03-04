close all, clear all, clc

noizFiles =...
    dir( 'T:\Marino\Microscopy\150904\FL_eval\run_02\noiz_imgs\*.tif' );
noizNames = {noizFiles.name}';
stripFiles =...
    dir( 'T:\Marino\Microscopy\150904\FL_eval\run_02\stripe_imgs\*.tif' );
stripNames = {stripFiles.name}';

csvString = ...
    'T:\Marino\Microscopy\150902\FL_eval\archived\second_run\data.csv]';

mnN = cell(min(numel(noizNames), numel(stripNames))+1,1);
mnS = cell(min(numel(noizNames), numel(stripNames))+1,1);
varN = cell(min(numel(noizNames), numel(stripNames))+1,1);
varS = cell(min(numel(noizNames), numel(stripNames))+1,1);
skewN = cell(min(numel(noizNames), numel(stripNames))+1,1);
skewS = cell(min(numel(noizNames), numel(stripNames))+1,1);
minN = cell(min(numel(noizNames), numel(stripNames))+1,1);
minS = cell(min(numel(noizNames), numel(stripNames))+1,1);
maxN = cell(min(numel(noizNames), numel(stripNames))+1,1);
maxS = cell(min(numel(noizNames), numel(stripNames))+1,1);

mnN{1} = 'meanN';
varN{1} = 'VarianceN';
skewN{1} = 'SkewnessN';
minN{1} = 'minN';
maxN{1} = 'maxN';
mnS{1} = 'meanS';
varS{1} = 'VarianceS';
skewS{1} = 'SkewnessS';
minS{1} = 'minS';
maxS{1} = 'maxS';

addpath(genpath('T:\Marino\Microscopy\150904\FL_eval\run_02'));

for i=1:numel(noizNames)
    imgN = double(imread(noizNames{i}));
    
    imgN_vec = imgN(:);
    
%     figure, histogram(imgN_vec, 100), title('Noisey Image Histogram');
%     figure, histogram(imgS_vec, 100), title('Pattern Histogram');
    
    mnN{i+1} = mean(imgN_vec);
    varN{i+1} = var(imgN_vec);
    skewN{i+1} = skewness(imgN_vec);
    minN{i+1} = min(imgN_vec);
    maxN{i+1} = max(imgN_vec);
        
    
end


for i=1:numel(stripNames)
    imgS = double(imread(stripNames{i}));
    
    imgS_vec = imgS(:);
    
%     figure, histogram(imgN_vec, 100), title('Noisey Image Histogram');
%     figure, histogram(imgS_vec, 100), title('Pattern Histogram');
    
    mnS{i+1} = mean(imgS_vec);
    varS{i+1} = var(imgS_vec);
    skewS{i+1} = skewness(imgS_vec);
    minS{i+1} = min(imgS_vec);
    maxS{i+1} = max(imgS_vec);
%     pause   
    
end

histMatN = cell2mat([mnN(2:end), varN(2:end), skewN(2:end), minN(2:end), maxN(2:end)]);
histMatS = cell2mat([mnS(2:end), varS(2:end), skewS(2:end), minS(2:end), maxS(2:end)]);

lengthDiff = length(mnS) - length(mnN);

if (lengthDiff > 0)
   mnN = [mnN; cell(lengthDiff, 1)];
   varN = [varN; cell(lengthDiff, 1)];
   skewN = [skewN; cell(lengthDiff, 1)];
   minN = [minN; cell(lengthDiff, 1)];
   maxN = [maxN; cell(lengthDiff, 1)];
   noizNames = [noizNames; cell(lengthDiff, 1)];
elseif (lengthDiff < 0)
   lengthDiff = -lengthDiff;
   mnS = [mnS; cell(lengthDiff, 1)];
   varS = [varS; cell(lengthDiff, 1)];
   skewS = [skewS; cell(lengthDiff, 1)];
   minS = [minS; cell(lengthDiff, 1)];
   maxS = [maxS; cell(lengthDiff, 1)];
   stripNames = [stripNames; cell(lengthDiff, 1)];
end
noizNames = ['noizNames'; noizNames];
stripNames = ['stripNames'; stripNames];

csvMat = [mnN, mnS, varN, varS, minN, minS, maxN, maxS, skewN, skewS,...
                                                stripNames, noizNames ]; 
                                            
figure, hist(cell2mat(varN(2:end)), 50);
figure, hist(cell2mat(varS(2:end)), 50);