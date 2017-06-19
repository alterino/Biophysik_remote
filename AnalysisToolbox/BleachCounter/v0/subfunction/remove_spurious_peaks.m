function xout = remove_spurious_peaks(xin,minSize,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 02.11.2014

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'xin',@isvector) % observation
addRequired(ip,'minSize',@isscalar) % minimum allowed peak length
addParamValue(ip,'mode',[],@(x)isempty(x) || numel(x) == 1) % mode = 1 -> remove only transient peaks; mode = 2 -> remove only transient truncs; else remove both
addParamValue(ip,'verbose',false)
parse(ip,xin,minSize,varargin{:});

mode = ip.Results.mode;
verbose = ip.Results.verbose;

%%
if iscolumn(xin)
    xin = transpose(xin);
end %if
xout = xin;
take = ones(size(xin));

iter = true;
while iter
    dX = diff(xout);
    if not(any(dX)) %trace shows no intensity change
        break
    end %if
    idxNZ = find(dX); %position of intensity change
    
    ddX = diff(sign(dX(idxNZ))); %sign function is used as we are only interested in the direction of change
%     ddX(diff(abs(dX(idxNZ))) ~= 0) = 0; %only work on peaks with flanks of the same intensity level
    
    %peak = ascend immediately followed by descend
    if isempty(mode) || mode == 1
        peak = (ddX == -2);
        idxPeak = idxNZ(peak); %beginn
    else
        peak = [];
        idxPeak = [];
        idxNZ(ddX == -2) = [];
    end
    
    %trunc = descend immediately followed by ascend
    if isempty(mode) || mode == 2
        trunc = (ddX == 2);
        idxTrunc = idxNZ(trunc); %beginn
    else
        trunc = [];
        idxTrunc = [];
        idxNZ(ddX == 2) = [];
    end
    
    sizeNZ = diff(idxNZ);
    
    isPeak = find(ismembc(idxNZ,idxPeak));
    sizePeak = sizeNZ(isPeak);
    isTrunc = find(ismembc(idxNZ,idxTrunc));
    sizeTrunc = sizeNZ(isTrunc);
    
    sizeEdge = [idxNZ(1) numel(xout)-idxNZ(end)];
    
    %% check for transient peaks
    peakTake = find(sizePeak < minSize);
    if any(peakTake)
        hasMinPeak = true;
        valMinPeak = sizePeak(peakTake);
    else
        hasMinPeak = false;
        valMinPeak = [];
    end %if
    
    truncTake = sizeTrunc < minSize;
    if any(truncTake)
        hasMinTrunc = true;
        valMinTrunc = sizeTrunc(truncTake);
    else
        hasMinTrunc = false;
        valMinTrunc = [];
    end %if
    
    %% fill starting with the narrowest
    if hasMinPeak && hasMinTrunc
        if min(valMinPeak) < min(valMinTrunc)
            idxMin = sizePeak == min(valMinPeak);
            if sum(idxMin) == 1
                take(idxPeak(idxMin)+1:idxPeak(idxMin)+sizePeak(idxMin)) = 0;
                xout(idxPeak(idxMin)+1:idxPeak(idxMin)+sizePeak(idxMin)) = xout(idxPeak(idxMin));
            else %multiple minima present
                multiple_problem
            end %if
        elseif min(valMinTrunc) < min(valMinPeak)
            idxMin = sizeTrunc == min(valMinTrunc);
            if sum(idxMin) == 1
                take(idxTrunc(idxMin)+1:idxTrunc(idxMin)+sizeTrunc(idxMin)) = 0;
                xout(idxTrunc(idxMin)+1:idxTrunc(idxMin)+sizeTrunc(idxMin)) = xout(idxTrunc(idxMin));
            else %multiple minima present
                multiple_problem
            end %if
        else %multiple minima -> choose the one with biggest flanks
            multiple_problem
        end %if
    elseif  hasMinPeak && not(hasMinTrunc)
        idxMin = sizePeak == min(valMinPeak);
        if sum(idxMin) == 1
            take(idxPeak(idxMin)+1:idxPeak(idxMin)+sizePeak(idxMin)) = 0;
            xout(idxPeak(idxMin)+1:idxPeak(idxMin)+sizePeak(idxMin)) = xout(idxPeak(idxMin));
        else %multiple minima present
            multiple_problem
        end %if
    elseif not(hasMinPeak) && hasMinTrunc
        idxMin = sizeTrunc == min(valMinTrunc);
        if sum(idxMin) == 1
            take(idxTrunc(idxMin)+1:idxTrunc(idxMin)+sizeTrunc(idxMin)) = 0;
            xout(idxTrunc(idxMin)+1:idxTrunc(idxMin)+sizeTrunc(idxMin)) = xout(idxTrunc(idxMin));
        else %multiple minima present
            multiple_problem
        end %if
    else
        %no minimum sizes
        iter = false;
    end %if
    
end %while

if verbose
    figure('color','w'); hold on
    imagesc(transpose(horzcat(xout(:),xin(:))))
    ylabel('','FontSize',20)
    xlabel('Time','FontSize',20)
    title('Filter','FontSize',20)
    set(gca,'FontSize',20,'Linewidth',3)
    box on
    axis tight
    colormap gray
end %if

    function multiple_problem
        sizeNZ_ = [sizeEdge(1) sizeNZ sizeEdge(end)];
        
        if isempty(valMinPeak)
            maxFlankPeak = 0;
        else
            idxMinPeak = (sizePeak == min(valMinPeak));
            sizeFlankPeak(idxMinPeak) = sizeNZ_(isPeak(idxMinPeak))+sizeNZ_(isPeak(idxMinPeak)+2);
            maxFlankPeak = max(sizeFlankPeak);
            idxMaxFlankPeak = find(sizeFlankPeak == maxFlankPeak);
            
            cnt = 0;
            while numel(idxMaxFlankPeak) > 1 %multiple equally sized flanks
                %look at the next flanks
                cnt = cnt + 1;
                sizeFlankPeak = sizeFlankPeak(sizeFlankPeak == maxFlankPeak);
                sizeFlankPeak = sizeFlankPeak + ...
                    sizeNZ_(max(1,isPeak(idxMaxFlankPeak)-cnt)) + ...
                    sizeNZ_(min(numel(sizeNZ_),isPeak(idxMaxFlankPeak)+cnt+2));
                maxFlankPeak = max(sizeFlankPeak);
                idxMaxFlankPeak = idxMaxFlankPeak(sizeFlankPeak == maxFlankPeak);
                if cnt == numel(sizeNZ_) %exhausted flanks
                    %choose last one (in the sense of time)
                    idxMaxFlankPeak = idxMaxFlankPeak(end);
                end %if
            end %if
        end %if
        
        if isempty(valMinTrunc)
            maxFlankTrunc = 0;
        else
            idxMinTrunc = sizeTrunc == min(valMinTrunc);
            sizeFlankTrunc(idxMinTrunc) = sizeNZ_(isTrunc(idxMinTrunc))+sizeNZ_(isTrunc(idxMinTrunc)+2);
            maxFlankTrunc = max(sizeFlankTrunc);
            idxMaxFlankTrunc = find(sizeFlankTrunc == maxFlankTrunc);
            
            cnt = 0;
            while numel(idxMaxFlankTrunc) > 1 %multiple equally sized flanks
                %look at the next flanks
                cnt = cnt + 1;
                sizeFlankTrunc = sizeFlankTrunc(sizeFlankTrunc == maxFlankTrunc);
                sizeFlankTrunc = sizeFlankTrunc + ...
                    sizeNZ_(max(1,isTrunc(idxMaxFlankTrunc)-cnt)) + ...
                    sizeNZ_(min(numel(sizeNZ_),isTrunc(idxMaxFlankTrunc)+cnt+2));
                maxFlankTrunc = max(sizeFlankTrunc);
                idxMaxFlankTrunc = idxMaxFlankTrunc(sizeFlankTrunc == maxFlankTrunc);
                if cnt == numel(sizeNZ_) %exhausted flanks
                    %choose last one (in the sense of time)
                    idxMaxFlankTrunc = idxMaxFlankTrunc(end);
                end %if
            end %if
        end %if
        
        if maxFlankPeak > maxFlankTrunc
            take(idxPeak(idxMaxFlankPeak)+1:idxPeak(idxMaxFlankPeak)+sizePeak(idxMaxFlankPeak)) = 0;
            xout(idxPeak(idxMaxFlankPeak)+1:idxPeak(idxMaxFlankPeak)+sizePeak(idxMaxFlankPeak)) = xout(idxPeak(idxMaxFlankPeak));
        else
            take(idxTrunc(idxMaxFlankTrunc)+1:idxTrunc(idxMaxFlankTrunc)+sizeTrunc(idxMaxFlankTrunc)) = 0;
            xout(idxTrunc(idxMaxFlankTrunc)+1:idxTrunc(idxMaxFlankTrunc)+sizeTrunc(idxMaxFlankTrunc)) = xout(idxTrunc(idxMaxFlankTrunc));
        end %if
    end %nested
end %fun