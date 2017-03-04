close all, clear all, clc

fileXT = 'T:\Marino\Microscopy\150718\PNGs\data_archive\learningdata\data1_150720.csv';

lineArray = read_mixed_csv(fileXT,';');
lineArray(:,11) = [];

i = 1;

while i<=size(lineArray,1)
    if(isempty(lineArray{i,2}))
        lineArray(i,:) = [];
    else
        i=i+1;
    end
end

colLabels = lineArray(1,:);
colData = lineArray(2:end,:);
liveData_cell = cell(1,10);
deadData_cell = cell(1,10);
multData_cell = cell(1,10);

for i=1:size(colData,1)
    
    currStat = str2num(colData{i,10});    
    switch currStat
        case 0
            deadData_cell(size(deadData_cell,1)+1,:) = colData(i,:);
        case 1
            liveData_cell(size(liveData_cell,1)+1,:) = colData(i,:);
        case 2
            multData_cell(size(multData_cell,1)+1,:) = colData(i,:);
        otherwise
    end
end

% eliminate first line of empty cells and convert from cell array
liveData_cell = liveData_cell(2:end,:);
deadData_cell = deadData_cell(2:end,:);
multData_cell = multData_cell(2:end,:);

liveDims = size(liveData_cell);
deadDims = size(deadData_cell);
multDims = size(multData_cell);

liveData = zeros(liveDims(1), liveDims(2));
deadData = zeros(deadDims(1), deadDims(2));
multData = zeros(multDims(1), multDims(2));

for j=1:liveDims(2)
    for i=1:liveDims(1)
        liveData(i,j) = str2double(liveData_cell{i,j});
    end
    
    for i=1:deadDims(1)
        deadData(i,j) = str2double(deadData_cell{i,j});
    end

    for i=1:multDims(1)
        multData(i,j) = str2double(multData_cell{i,j});
    end
end

% processing data to determine distributions of the modalities of each
% dataset

% histograms for area data
figure, hist(liveData(:,4),15), title('live cell area'), grid on
figure, hist(deadData(:,4),20), title('dead cell area'), grid on
figure, hist(multData(:,4)), title('multiple cells area'), grid on


% histograms for eccentricity data
figure, hist(liveData(:,6),15), title('live cell eccentricity'), grid on
figure, hist(deadData(:,6),20), title('dead cell eccentricity'), grid on
figure, hist(multData(:,6)), title('multiple cells eccentricity'), grid on

% histograms for area divided by convex area
figure, hist(liveData(:,8),15), title('live cell area/convex area'), grid on
axis([0 1 0 12]), hold on, plot([.8 .8], [0 12], 'r-')
figure, hist(deadData(:,8),20), title('dead cell area/convex area'), grid on
axis([0 1 0 12]), hold on, plot([.8 .8], [0 12], 'r-')
figure, hist(multData(:,8)), title('multiple area/cells convex area'), grid on


