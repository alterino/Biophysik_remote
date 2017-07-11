function [thetaEst,thetaEstSE,resnorm,residual,exitflag,output,modelFun] = ...
    global_OLS_fit_astig_calib(xdata,ydata,theta0,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 27.05.2014
%modified 15.06.2015

%input validation
objParser = inputParser;
addRequired(objParser,'xdata')
addRequired(objParser,'ydata',@isvector)
addRequired(objParser,'theta0',@isvector)

addParamValue(objParser,'lb',[],@isvector)
addParamValue(objParser,'ub',[],@isvector)
addParamValue(objParser,'Aineq',[])
addParamValue(objParser,'bineq',[])

addParamValue(objParser,'GlobalSearch',false, @(x)islogical(x));
addParamValue(objParser,'NumTrialPoints',50, @(x)isscalar(x));
addParamValue(objParser,'NumStageOnePoints',20, @(x)isscalar(x));
addParamValue(objParser,'TolFun',10^-6, @(x)isscalar(x));
addParamValue(objParser,'TolX',10^-6, @(x)isscalar(x));
addParamValue(objParser,'TypicalX',[]);
parse(objParser,xdata,ydata,theta0,varargin{:});
input = objParser.Results;

%%
isBad = isnan(ydata) | isinf(ydata);
if any(isBad)
    ydata(isBad) = [];
    xdata(isBad,:) = [];
end

%% theta = [w0 zr gamma A B]
%xdata = [z]
modelFun = @(theta,xdata)theta(1)*sqrt(...
    theta(5)*((xdata-theta(3))/theta(2)).^4 +...
    theta(4)*((xdata-theta(3))/theta(2)).^3 +...
    ((xdata-theta(3))/theta(2)).^2 + 1);

%%
if input.GlobalSearch
    options = optimoptions(@fmincon,...
        'Algorithm','interior-point',...
        'TypicalX',input.TypicalX);
    problem = createOptimProblem(...
        'fmincon',...
        'x0',theta0,...
        'lb',input.lb,...
        'ub',input.ub,...
        'Aineq',input.Aineq,...
        'bineq',input.bineq,...
        'options',options);
    gs = GlobalSearch(...
        'NumTrialPoints',input.NumTrialPoints,...
        'NumStageOnePoints',input.NumStageOnePoints,...
        'StartPointsToRun','bounds-ineqs',...
        'MaxWaitCycle',ceil(input.NumStageOnePoints/3),...
        'TolFun', input.TolFun,...
        'TolX', input.TolX,...
        'Display','off');
    
    %%
    problem.objective = @(theta)sum((ydata-modelFun(theta,xdata)).^2);
    
    %%
    [thetaEst,resnorm,exitflag,output] = run(gs,problem);
    thetaEstSE = thetaEst;
    residual = ydata - modelFun(thetaEst,xdata);
    
else
    options = optimoptions(@lsqcurvefit,...
        'Algorithm','trust-region-reflective',...
        'Display','off',...
        'TolFun', input.TolFun,...
        'TolX', input.TolX,...
        'Diagnostics', 'off');
    
    [thetaEst,resnorm,residual,exitflag,output,~,jacobian] = ...
        lsqcurvefit(@(theta,xdata)modelFun(theta,xdata),theta0,xdata,ydata,input.lb,input.ub,options);
    thetaEstSE = reshape(diff(nlparci(thetaEst,residual,'jacobian',jacobian),1,2),1,[])/3.92;
end %if
end %fun