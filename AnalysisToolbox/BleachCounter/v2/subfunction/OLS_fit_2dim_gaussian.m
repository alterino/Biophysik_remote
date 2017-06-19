function [thetaEst,thetaEstSE,resnorm,residual,exitflag,output,modelFun] = ...
    OLS_fit_2dim_gaussian(xdata,ydata,theta0,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 28.04.2014
%modified 28.05.2014
%modified 08.01.2015
%modified 22.02.2015: handling of nan-values in the data
%modified 15.06.2015: error output changed to SE (standard error of the mean s = sigma/sqrt(n))
%modified 26.02.2015: pre-defined orientation of gaussian (angle_with_j_axis[CCW])
%modified 26.02.2015: Multiple Gaussian Fit
%modified 15.01.2017: Fit offset 

%input validation
ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'xdata')
addRequired(ip,'ydata',@isvector)
addRequired(ip,'theta0',@isvector)

addParamValue(ip,'N',1,@(x)isscalar(x))
addParamValue(ip,'elliptic',false,@(x)isscalar(x) && islogical(x))
addParamValue(ip,'oriented',false,@(x)isscalar(x) && islogical(x))
addParamValue(ip,'centered',true,@(x)isscalar(x) && islogical(x))
addParamValue(ip,'discrete',false,@(x)isscalar(x) && islogical(x))
addParamValue(ip,'offset',false,@(x)isscalar(x) && islogical(x))

addParamValue(ip,'lb',[],@isvector)
addParamValue(ip,'ub',[],@isvector)
addParamValue(ip,'Aeq',[])
addParamValue(ip,'beq',[])
addParamValue(ip,'Aineq',[])
addParamValue(ip,'bineq',[])
addParamValue(ip,'nonlcon',[])

addParamValue(ip,'GlobalSearch',false, @(x)islogical(x));
addParamValue(ip,'NumTrialPoints',50, @(x)isscalar(x));
addParamValue(ip,'NumStageOnePoints',20, @(x)isscalar(x));
addParamValue(ip,'TolFun',10^-6, @(x)isscalar(x));
addParamValue(ip,'TolX',10^-6, @(x)isscalar(x));
addParamValue(ip,'TypicalX',[]);
parse(ip,xdata,ydata,theta0,varargin{:});
input = ip.Results;

N = ip.Results.N;
% oriented = ip.Results.oriented;

lb = ip.Results.lb;
ub = ip.Results.ub;
aeq = ip.Results.Aeq;
beq = ip.Results.beq;
aineq = ip.Results.Aineq;
bineq = ip.Results.bineq;
nonlcon = ip.Results.nonlcon;

tolFun = ip.Results.TolFun;
tolX = ip.Results.TolX;
typicalX = ip.Results.TypicalX;
if isempty(typicalX)
    typicalX = theta0;
end %if

%%
isBad = isnan(ydata) | isinf(ydata);
if any(isBad)
    ydata(isBad) = [];
    xdata(isBad,:) = [];
end

%%
if input.elliptic
    if input.centered
        if input.oriented
            if N == 1
                if input.offset
                    %theta = [volume std_i std_j angle_with_j_axis[CCW] offset]
                    modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                        [cos(theta(4)) -sin(theta(4));sin(theta(4)) cos(theta(4))])+theta(5);
                    aineq = [aineq;[0 1 -1 0 0]]; %[std_i < std_j]
                else
                    %theta = [volume std_i std_j angle_with_j_axis[CCW]]
                    modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                        [cos(theta(4)) -sin(theta(4));sin(theta(4)) cos(theta(4))]);
                    aineq = [aineq;[0 1 -1 0]]; %[std_i < std_j]
                end %if
                bineq = [bineq;0];
            elseif N == 2
            elseif N == 3
            else
            end %if
        else % anisotropic, aligned
            if input.discrete
                if N == 1
                    if input.offset
                        %theta = [volume std_i std_j offset]
                        modelFun = @(theta,xdata)model_discrete_elliptic_2dim_gaussian(theta,xdata)+theta(4);
                    else
                        %theta = [volume std_i std_j]
                        modelFun = @(theta,xdata)model_discrete_elliptic_2dim_gaussian(theta,xdata);
                    end %if
                elseif N == 2
                elseif N == 3
                else
                end %if
            else % anisotropic, aligned, continuous
                if N == 1
                    if input.offset
                        %theta = [volume std_i std_j offset]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata)+theta(4);
                    else
                        %theta = [volume std_i std_j]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata);
                    end %if
                elseif N == 2
                    if input.offset
                        %theta = [volume std_i std_j volume std_i std_j offset]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata)+...
                            model_elliptic_2dim_gaussian(theta,xdata)+theta(7);
                    else
                        %theta = [volume std_i std_j volume std_i std_j]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata)+...
                            model_elliptic_2dim_gaussian(theta,xdata);
                    end %if
                elseif N == 3
                else
                end %if
            end %if
        end %if
    else % anisotropic, non-centered
        if input.oriented
            if N == 1
                if input.offset
                    %theta = [volume std_i std_j muI muJ angle_with_j_axis[CCW] offset]
                    modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                        [cos(theta(6)) -sin(theta(6));sin(theta(6)) cos(theta(6));-theta(4) -theta(5)])+theta(7);
                    aineq = [aineq;[0 1 -1 0 0 0 0]]; %[std_i < std_j]
                else
                    %theta = [volume std_i std_j muI muJ angle_with_j_axis[CCW]]
                    modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                        [cos(theta(6)) -sin(theta(6));sin(theta(6)) cos(theta(6));-theta(4) -theta(5)]);
                    aineq = [aineq;[0 1 -1 0 0 0]]; %[std_i < std_j]
                end %if
                bineq = [bineq;0];
            elseif N == 2
            elseif N == 3
            else
            end %if
        else % anisotropic, non-centered, aligned
            if input.discrete
                if N == 1
                    if input.offset
                        %theta = [volume std_i std_j muI muJ offset]
                        modelFun = @(theta,xdata)model_discrete_elliptic_2dim_gaussian(theta,xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+theta(6);
                    else
                        %theta = [volume std_i std_j muI muJ]
                        modelFun = @(theta,xdata)model_discrete_elliptic_2dim_gaussian(theta,xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)]);
                    end %if
                elseif N == 2
                    if input.offset
                        %theta = [volume std_i std_j muI muJ | volume std_i std_j muI muJ | offset]
                        modelFun = @(theta,xdata)...
                            model_discrete_elliptic_2dim_gaussian(theta(1:3),xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+...
                            model_discrete_elliptic_2dim_gaussian(theta(6:8),xdata*...
                            [1 0 ;0 1;-theta(9) -theta(10)])+...
                            theta(11);
                    else
                        %theta = [volume std_i std_j muI muJ | volume std_i std_j muI muJ]
                        modelFun = @(theta,xdata)...
                            model_discrete_elliptic_2dim_gaussian(theta(1:3),xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+...
                            model_discrete_elliptic_2dim_gaussian(theta(6:8),xdata*...
                            [1 0 ;0 1;-theta(9) -theta(10)]);
                    end %if
                elseif N == 3
                else
                end %if
            else % anisotropic, non-centered, aligned, continuous
                if N == 1
                    if input.offset
                        %theta = [volume std_i std_j muI muJ offset]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+theta(6);
                    else
                        %theta = [volume std_i std_j muI muJ]
                        modelFun = @(theta,xdata)model_elliptic_2dim_gaussian(theta,xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)]);
                    end %if
                elseif N == 2
                    if input.offset
                        %theta = [volume std_i std_j muI muJ | volume std_i std_j muI muJ | offset]
                        modelFun = @(theta,xdata)...
                            model_elliptic_2dim_gaussian(theta(1:3),xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+...
                            model_elliptic_2dim_gaussian(theta(6:8),xdata*...
                            [1 0 ;0 1;-theta(9) -theta(10)])+...
                            theta(11);
                    else
                        %theta = [volume std_i std_j muI muJ | volume std_i std_j muI muJ]
                        modelFun = @(theta,xdata)...
                            model_elliptic_2dim_gaussian(theta(1:3),xdata*...
                            [1 0 ;0 1;-theta(4) -theta(5)])+...
                            model_elliptic_2dim_gaussian(theta(6:8),xdata*...
                            [1 0 ;0 1;-theta(9) -theta(10)]);
                    end %if
                elseif N == 3
                else
                end %if
            end %if
        end %if
    end %if
else %isotropic
    if input.centered
        if input.offset
            %theta = [volume std]
            modelFun = @(theta,xdata)model_2dim_gaussian(theta,xdata);
        else
            %theta = [volume std offset]
            modelFun = @(theta,xdata)model_2dim_gaussian(theta,xdata)+theta(3);
        end %if
    else %non-centered
        if input.offset
            %theta = [volume std muI muJ]
            modelFun = @(theta,xdata)model_2dim_gaussian(theta,xdata*...
                [1 0 ;0 1;-theta(3) -theta(4)]);
        else
            %theta = [volume std muI muJ offset]
            modelFun = @(theta,xdata)model_2dim_gaussian(theta,xdata*...
                [1 0 ;0 1;-theta(3) -theta(4)])+theta(5);
        end %if
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
        'Aeq',aeq,...
        'beq',beq,...
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
    
    residual = -residual;
end %if
end %fun