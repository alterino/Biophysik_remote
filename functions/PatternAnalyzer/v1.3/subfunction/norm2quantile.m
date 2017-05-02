function X = norm2quantile(X,Q)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 19.11.2015

lim = nanquantile(X,Q);
X = min(1,max(0,(X-lim(1))/(lim(2)-lim(1))));
end %fun