function x = rnd2dec(x,i)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

k = 10^i;
x = round(x*k)/k;
end %fun