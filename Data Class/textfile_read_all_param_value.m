function [param,value] = textfile_read_all_param_value(fid,delimiter)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 24.09.2014

i = 1;
frewind(fid)
while not(feof(fid)) %end of file
    %read successive file line
    string = fgetl(fid);
    string = string(2:2:end);
    if not(isempty(string))
        if not(isempty(regexp(string,delimiter))) %#ok
        list(i,:) = strsplit(string,delimiter); %#ok
        i = i + 1;
        end %if
    end %if
end %while

param = list(:,1);
value = list(:,2);
end %fun