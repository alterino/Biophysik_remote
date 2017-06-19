function [dy,dx,i0,i1] = ndiff(x,y)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 23.01.2017

%construct index vectors for subsequent calculation
%of position displacement at increasing scales

N = numel(x);
if N < 2^8
    X = uint8(1:N);
elseif N < 2^16
    X = uint16(1:N);
else %double precision
    X = 1:N;
end
A = repmat(X(:),1,N);
take = tril(true(N),-1);
i1 = A(take);
i0 = A(take(N:-1:1,:));

dx = x(i1)-x(i0);
dy = y(i1)-y(i0);
end %fun