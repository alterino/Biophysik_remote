function Z = insert(X,Y,idxInsert)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

newLength = numel(X)+numel(Y);
if isrow(X)
%     Z = nan(1,newLength);
    Z = horzcat(X,Y);
else %is column vector
%     Z = nan(newLength,1);
    Z = vertcat(X,Y);
end %if

idxNew = ismembc(1:newLength,idxInsert);
Z(idxNew) = Y;
Z(not(idxNew)) = X;
end %fun