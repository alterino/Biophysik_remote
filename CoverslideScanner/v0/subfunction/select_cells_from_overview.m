function listCoordIJ = select_cells_from_overview(imgScan,ROI)
hFig = figure;
hAx = axes('Parent',hFig);
image('XData',[1 12000],'YData',[1 12000],'CData',imgScan);
axis image
colormap(gray)

[imgWidth,imgHeight,~] = size(imgScan);

cnt = 0;
repeat = true;
while repeat
    %zoom
    figure(hFig)
%     jGuess = nan; iGuess = nan;
%     iLimit = get(gca,'ylim');
%     jLimit = get(gca,'xlim');
%     while not(iGuess > iLimit(1)-0.5 && iGuess < iLimit(2)-0.5 && ...
%             jGuess > jLimit(1)-0.5 && jGuess < jLimit(2)-0.5)
        [jGuess,iGuess] = ginput(1);
%     end %while
    axis([jGuess-ROI(3)/2,jGuess+ROI(3)/2,iGuess-ROI(4)/2,iGuess+ROI(4)/2])
    
    [jGuess,iGuess] = ginput(1);    
    answer = questdlg('Accept Cell?','','Yes','No','Yes');
    switch answer
        case 'Yes'
            cnt = cnt + 1;
            listCoordIJ(cnt,:) = [iGuess jGuess]; %[px]
            
%             line(jGuess,iGuess,'color','r','marker','o','Parent',hAx)
            text(jGuess+15,iGuess+15,num2str(cnt,'%d'),...
                'color','r','Parent',hAx)
        case 'No'
    end %switch
%     caxis(satLimFull)
    axis([0.5,imgWidth+0.5,0.5,imgHeight+0.5])
    %     close(hFigFit); close(hFigRes);
    
    answer = questdlg('Additional Cell?','','Yes','No','Yes');
    switch answer
        case 'Yes'
            repeat = true;
        case 'No'
            repeat = false;
    end %switch
end %while
end %fun