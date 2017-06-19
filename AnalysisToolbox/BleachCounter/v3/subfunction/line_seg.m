function [edges,ctrs,period] = line_seg(lim,numSeg)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 17.02.2016

edges = linspace(lim(1),lim(2),numSeg+1);
period = abs(edges(2)-edges(1));
ctrs = edges(1:numSeg)+period/2;
end %fun