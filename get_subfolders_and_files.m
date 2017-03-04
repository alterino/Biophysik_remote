function [listFolderNew,listFile] = get_subfolders_and_files(listFolder,listFile)
listFolderNew = {};
for idxFolder = 1:numel(listFolder)
    folderContent = dir(listFolder{idxFolder});
    for idxContent = 3:numel(folderContent) %ignore first two entries ('.' and '..')
        if folderContent(idxContent).isdir
            listFolderNew{end+1,1} = fullfile(listFolder{idxFolder},folderContent(idxContent).name); %#ok
        else
            listFile{end+1,1} = fullfile(listFolder{idxFolder},folderContent(idxContent).name); %#ok
        end %if
    end %for
end %for
end %fun