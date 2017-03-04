function q = nanquantile(X,Q)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 18.11.2015

isNaN = isnan(X);

if any(isNaN(:))
    q = quantile(X(not(isNaN)),Q);
else
    q = quantile(double(X(:)),Q);
end %if
end %fun