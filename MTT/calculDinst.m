function Dinst = calculDinst(msddata,diff_window,printout)

% calcule D pour chaque traj, par reg lineaire ax+b
% sur les points 1 à diff_window du MSD (diff_window=5 par défaut, et non plus 2, 3, 4 de Kusum)  
% renvoie la matrice [#trace, D, erreurD, offset] 
% msddata = [n t r2 dr2] (ou [t r2 dr2])
%
% *****  Dinst=b +/- erreurb ****

% cf Maxime (ex Kusumi)
% AS 17/6/4

% NB verif ds excel sur qq tests OK :o), 7/10/4

if nargin < 2, diff_window = 5; end
if nargin < 3, printout = 1; end 
if isempty(msddata), Dinst = [-1 -1 -1 -1]; return, end
if size(msddata,2)<4
    msddata = [ones(size(msddata,1),1), msddata]; % (1:size(msddata,1))', 
end

t = (1:diff_window)';
n = length(t);
A = [ones(size(t))  t];
ntrc = msddata(end,1);
Dinst = zeros(ntrc,4);
ii = 1;

for i=1:ntrc % boucle sur les trajs
    ind = find(msddata(:,1)==i);
    if length(ind)>=diff_window
        msdi = msddata(ind(t),3);
        p = A\msdi;   %%%%%%   p = lscov(A,msdi,weight); %%%%%%%%%
        msdfit = A*p; %msdfit=p(1)+p(2)*t
        Vr = sum((msdi-msdfit).^2)/(n-2); % var residuelle
        err = sqrt(Vr*[sum(t.^2), n]/(n*sum(t.^2)-sum(t)^2));
        offset = mean(msdi(1:diff_window,1))-p(2)*mean(1:diff_window);
        Dinst(ii,:) = [i p(2)/4 err(2)/4 offset];
        ii = ii+1;
    end
end
if ii<=size(Dinst,1),  Dinst(ii:end,:) = []; end % BUG [ii,end] corr 13/8/7!!!!!

if isempty(Dinst)
    Dinst = [1,-1,-1,-1];
    if printout, fprintf(' Trajs too short for calcul of Dinst\r             '), end
end
