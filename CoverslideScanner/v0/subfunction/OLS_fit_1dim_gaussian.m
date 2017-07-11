function [thetaEst,thetaEstSE,resnorm,residual,exitflag,output,modelFun] = ...
    OLS_fit_1dim_gaussian(xdata,ydata,theta0,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 01.05.2014

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'xdata')
addRequired(ip,'ydata',@isvector)
addRequired(ip,'theta0',@isvector)

addParamValue(ip,'N',1,@(x)isscalar(x))
addParamValue(ip,'Offset',false,@(x)isscalar(x) && islogical(x))

addParamValue(ip,'lb',[],@isvector)
addParamValue(ip,'ub',[],@isvector)
addParamValue(ip,'Aineq',[])
addParamValue(ip,'bineq',[])
addParamValue(ip,'nonlcon',[])

addParamValue(ip,'GlobalSearch',false, @(x)islogical(x));
addParamValue(ip,'NumTrialPoints',50, @(x)isscalar(x));
addParamValue(ip,'NumStageOnePoints',20, @(x)isscalar(x));
addParamValue(ip,'TolFun',10^-6, @(x)isscalar(x));
addParamValue(ip,'TolX',10^-6, @(x)isscalar(x));
addParamValue(ip,'TypicalX',[]);
addParamValue(ip,'Verbose',false);
parse(ip,xdata,ydata,theta0,varargin{:});
input = ip.Results;

N = ip.Results.N;

lb = ip.Results.lb;
ub = ip.Results.ub;
aineq = ip.Results.Aineq;
bineq = ip.Results.bineq;
nonlcon = ip.Results.nonlcon;

tolFun = ip.Results.TolFun;
tolX = ip.Results.TolX;

typicalX = ip.Results.TypicalX;
if isempty(typicalX)
    typicalX = theta0;
end %if

verbose = ip.Results.Verbose;

%%
xdata = xdata(:);
ydata = ydata(:);

isBad = isnan(ydata) | isinf(ydata);
if any(isBad)
    ydata(isBad) = [];
    xdata(isBad,:) = [];
end

if input.Offset
    if N == 1
        %theta = [area std | offset]
        modelFun = @(theta,xdata)model_1dim_gaussian(theta(1:2),xdata)+theta(3);
    elseif N == 2
    else
    end %if
else
    if N == 1
        %theta = [area std]
        modelFun = @(theta,xdata)model_1dim_gaussian(theta(1:2),xdata);
    elseif N == 2
    else
    end %if
end %if

%%
if input.GlobalSearch
    options = optimoptions(@fmincon,...
        'Algorithm','interior-point',...
        'TypicalX',typicalX);
    problem = createOptimProblem(...
        'fmincon',...
        'x0',theta0,...
        'lb',lb,...
        'ub',ub,...
        'Aineq',aineq,...
        'bineq',bineq,...
        'nonlcon',nonlcon,...
        'options',options);
    gs = GlobalSearch(...
        'NumTrialPoints',input.NumTrialPoints,...
        'NumStageOnePoints',input.NumStageOnePoints,...
        'StartPointsToRun','bounds-ineqs',...
        'MaxWaitCycle',ceil(input.NumStageOnePoints/3),...
        'TolFun',tolFun,...
        'TolX',tolX,...
        'Display','off');
    
    %%
    problem.objective = @(theta)sum((ydata-modelFun(theta,xdata)).^2);
    
    %%
    [thetaEst,resnorm,exitflag,output] = run(gs,problem);
    thetaEstSE = thetaEst;
    residual = ydata - modelFun(thetaEst,xdata);
    
else
    options = optimoptions(@lsqcurvefit,...
        'Display','off',...
        'TolFun', tolFun,...
        'TolX', tolX,...
        'Diagnostics', 'off');
    
    [thetaEst,resnorm,residual,exitflag,output,~,jacobian] = ...
        lsqcurvefit(@(theta,xdata)modelFun(theta,xdata),theta0,xdata,ydata,lb,ub,options);
    thetaEstSE = reshape(diff(nlparci(thetaEst,residual,'jacobian',jacobian),1,2),1,[])/3.92;
% thetaEstSE = thetaEst;
end %end %fun

%%
if verbose
    hFig = figure('Color','w'); hold on
    
    plot(xdata,ydata,'k.','markersize',20)
    plot(xdata,modelFun(thetaEst,xdata),'r','linewidth',2)
    xlabel('x','FontSize',20)
    ylabel('PDF','FontSize',20)
    box on
    grid on
    set(gca(hFig),'FontSize',20)
end %if
end %fun