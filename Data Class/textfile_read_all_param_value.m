function [param,value] = textfile_read_all_param_value(fid,delimiter)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 24.09.2014
%modified 20.06.2017

i = 1;
frewind(fid)
while not(feof(fid)) %end of file
    %read successive file line
    curr_line = string(fgetl(fid));
%     string = string(2:2:end);
%     curr_line(ismember(curr_line, ' ')) = [];
%     curr_line = regexprep(curr_line,'[^\w=_[]~#%\\.(),]','');
    if not(isempty(curr_line))
        if not(isempty(regexp(curr_line,delimiter))) %#ok
            list(i,:) = strtrim(strsplit(curr_line,delimiter)); %#ok
            i = i + 1;
        end %if
    end %if
end %while

param = list(:,1);
value = list(:,2);
end %fun