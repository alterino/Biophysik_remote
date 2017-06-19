function [idx,period,pntsIn,edges,ctrs,n] = PNT_grid_idx(X,N,lim)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 11.12.2015
%modified 22.02.2017: edges get included!

for idxDim = size(X,2):-1:1
    %grid generation
    [edges{idxDim},ctrs{idxDim},period(idxDim)] = line_seg(lim{idxDim},N(idxDim));
    
    %points on the edges get included!
    pntsIn(:,idxDim) = X(:,idxDim) >= lim{idxDim}(1) &  X(:,idxDim) <= lim{idxDim}(2);
    [n{idxDim},idx(pntsIn(:,idxDim),idxDim)] = histc(X(pntsIn(:,idxDim),idxDim),edges{idxDim});
    n{idxDim}(end) = [];
    idx(not(pntsIn(:,idxDim)),idxDim) = nan; %marker for out of box points
end %for
end %fun