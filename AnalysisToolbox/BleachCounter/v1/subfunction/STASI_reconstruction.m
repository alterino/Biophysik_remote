function [estState,MDL,sd] = STASI_reconstruction(signal,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 10.12.2014

objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'signal')
addParamValue(objParser,'MaxLvl',10,@(x)isscalar(x) && x > 0);
parse(objParser,signal,varargin{:});
input = objParser.Results;

%%
if not(all(size(signal) > 1))
    if not(isrow(signal))
        signal = reshape(signal,1,[]);
    end %if
end %if

%%
X = [];
groups = [];
breaks = [];

for n = 1:size(signal,1);
    X_ = double(signal(n,:));
    T1 = numel(X)+1;
    sd(n) = w1_noise(diff(X_))/1.4;% estimate the noise level
    points = change_point_detection(X_);% change points detection
    X = [X, X_];% group traces together
    T2 = numel(X);
    breaks(end+1) = T2;
    groups = cat(2,groups,[T1, points+T1; points+T1-1, T2]);
end

sd = max(sd);% use the maximum noise level among these traces as the global noise level
[G, Ij, Tj] = clustering_GCP(X, groups);
G = G(end:-1:1);% flip the G
n_mdl = min(input.MaxLvl, numel(G));% calculate up to 30 states
MDL = zeros(1,n_mdl);
estState = zeros(n_mdl, numel(X));
for i = 1:n_mdl;
    [MDL(i), estState(i,:)] = MDL_piecewise(Ij, Tj, G(i), X, groups, sd, breaks);
end
end %fun