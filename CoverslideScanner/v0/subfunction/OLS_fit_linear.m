function [m,y0] = OLS_fit_linear(t,b,y0)
%solve linear system for f(x) = m*t+y0
%
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014

%input validation
objParser = inputParser;
objParser.addRequired('t',@(x) isvector(x))
objParser.addRequired('b')

if nargin == 2
    A = [t(:),ones(numel(t),1)];
    x = A\b;
    m = x(1,:);
    y0 = x(2,:);    
elseif nargin == 3
    A = t(:);
    x = A\(b-y0);
    m = x(1,:);
end %if
end %fun