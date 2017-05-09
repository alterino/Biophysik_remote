function [listFile,numFile] = scan_and_list_folder_for_specific_file_format(...
    folder,targetFormat,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 31.10.2014: multiple positive & negative keywords

ip = inputParser;
ip.KeepUnmatched = true;
addParamValue(ip,...
    'PosKeyword', [], @(x)isvector(x) | isempty(x));
addParamValue(ip,...
    'NegKeyword', [], @(x)isvector(x) | isempty(x));
parse(ip,varargin{:});
input = ip.Results;

[listFolder,listFile] = get_subfolders_and_files(cellstr(folder),[]);
while not(isempty(listFolder))
    [listFolder,listFile] = get_subfolders_and_files(listFolder,listFile);
end %while

take = false;
numFile = numel(listFile);
for idxFile = numFile:-1:1    
    [~,filename,fileFormat] = fileparts(listFile{idxFile});
    hasFormat = strcmp(fileFormat,targetFormat);
    
    %%
    if not(isempty(input.PosKeyword))
        for idxPosKey = 1:numel(input.PosKeyword)
            hasPosKeyword(:,idxPosKey) = not(isempty(strfind(filename,input.PosKeyword{idxPosKey})));
        end
        hasPosKeyword = all(hasPosKeyword,2);
    else
        hasPosKeyword = true;
    end %if
    
    %%
    if not(isempty(input.NegKeyword))
        for idxNegKey = 1:numel(input.NegKeyword)
            hasNegKeyword(:,idxNegKey) = not(isempty(strfind(filename,input.NegKeyword{idxNegKey})));
        end
        hasNegKeyword = any(hasNegKeyword,2);
    else
        hasNegKeyword = false;
    end %if
    
    take(idxFile,1) = hasFormat && hasPosKeyword && not(hasNegKeyword);
end %fun

listFile = listFile(take);
numFile = sum(take);
end %fun