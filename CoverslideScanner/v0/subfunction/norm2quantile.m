function X = norm2quantile(X,Q)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 19.11.2015
%modified 21.11.2016: [0 1] -> min-max-normalization

if diff(Q) == 1
    X = (X-min(X(:)))/(max(X(:))-min(X(:)));
else
    lim = nanquantile(X,Q);
    X = min(1,max(0,(X-lim(1))/(lim(2)-lim(1))));
end %if
end %fun