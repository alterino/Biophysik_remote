function txt = TXT_raw_read(filename)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 24.09.2014

if nargin == 0
    [fileName,filePath] = uigetfile('*.txt');
    [filePath,fileName,fileExt] = fileparts(fullfile(filePath,fileName));
    filename = fullfile(filePath,[fileName fileExt]);
end %if
fid = fopen(filename);

%%
cnt = 0;
while not(feof(fid)) %end of file
    cnt = cnt + 1;
    %read successive file line
    txt(cnt,1) = cellstr(fgetl(fid));
end %while
end %fun