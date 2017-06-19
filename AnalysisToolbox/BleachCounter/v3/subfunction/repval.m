function x = repval(i,n)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

cn = [0;cumsum(n(:))];
x = nan(sum(n),1);
for idx = 1:numel(i)
    x(cn(idx)+1:cn(idx+1)) = i(idx);
end %for
end %fun