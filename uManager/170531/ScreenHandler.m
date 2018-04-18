classdef ScreenHandler < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties
        JavaRobot
        
        ScreenShot
        ScreenSize
    end %properties
    
    methods
        %constructor
        function this = ScreenHandler
            import java.awt.Robot;
            this.JavaRobot = Robot;
            this.JavaRobot.delay(0)
            this.JavaRobot.setAutoDelay(0)
            this.JavaRobot.setAutoWaitForIdle(1)
            
            %             monitorPos = get(0,'MonitorPositions');
            %             if size(monitorPos,1) == 1
            %             elseif size(monitorPos,1) == 2 % more than one monitor
            %                 %select monitor
            %                 [~,idxLeftMonitor] = min(monitorPos(:,1));
            %             elseif size(get(0,'MonitorPositions'),1) > 2
            %                 %no implementation yet
            %             end %if
            
            update_screen_shot(this)
        end %fun
        
        %%
        function update_screen_shot(this)
            ROI = get(0,'ScreenSize');
            rect = java.awt.Rectangle(ROI(1), ROI(2), ROI(3), ROI(4));
            jImage = this.JavaRobot.createScreenCapture(rect);
            
            h = jImage.getHeight;
            w = jImage.getWidth;
            
            pixelsData = reshape(typecast(...
                jImage.getData.getDataStorage, 'uint8'), 4, w, h);
            this.ScreenShot = cat(3, ...
                transpose(reshape(pixelsData(3, :, :), w, h)), ...
                transpose(reshape(pixelsData(2, :, :), w, h)), ...
                transpose(reshape(pixelsData(1, :, :), w, h)));
            this.ScreenSize = size(this.ScreenShot);
        end %fun
        function [x,y] = get_screen_coordinate(this)
            hFig = figure(...
                'Units','normalized',...
                'NumberTitle', 'off',...
                'DockControls', 'off',...
                'MenuBar','none',...
                'Toolbar','none',...
                'Color','w',...
                'Position',[0 0 1 1],...
                'IntegerHandle','off',...
                'Visible','on');
            
            hAx = axes(...
                'Parent',hFig,...
                'Units','normalized',...
                'Position',[0 0 1 1]);
            
            imagesc(...
                'Parent',hAx,...
                'xdata',1:this.ScreenSize(2),...
                'ydata',1:this.ScreenSize(1),...
                'cdata',this.ScreenShot)
            
            axis(hAx,'ij','equal','off')
            
            iter = true;
            while iter
                [x,y] = ginput(1);
                if (x >= 1 && x <= this.ScreenSize(2) && ...
                        y >= 1 && y <= this.ScreenSize(1))
                    iter = false;
                end %if
            end %while
            close(hFig)
        end %fun
        
        function left_mouse_click(this,x,y)
            import java.awt.event.*;
            
            this.JavaRobot.mouseMove(x,y);
            this.JavaRobot.mousePress(InputEvent.BUTTON1_MASK);
            this.JavaRobot.mouseRelease(InputEvent.BUTTON1_MASK);
        end %fun
        
        function double_to_key_event(this,num)
            import java.awt.event.*;
            
            numChars = cellstr(transpose(num2str(num,'%.3f')));
            for iChar = 1:numel(numChars)
                switch numChars{iChar}
                    case '0'
                        this.JavaRobot.keyPress(KeyEvent.VK_0);
                        this.JavaRobot.keyRelease(KeyEvent.VK_0);
                    case '1'
                        this.JavaRobot.keyPress(KeyEvent.VK_1);
                        this.JavaRobot.keyRelease(KeyEvent.VK_1);
                    case '2'
                        this.JavaRobot.keyPress(KeyEvent.VK_2);
                        this.JavaRobot.keyRelease(KeyEvent.VK_2);
                    case '3'
                        this.JavaRobot.keyPress(KeyEvent.VK_3);
                        this.JavaRobot.keyRelease(KeyEvent.VK_3);
                    case '4'
                        this.JavaRobot.keyPress(KeyEvent.VK_4);
                        this.JavaRobot.keyRelease(KeyEvent.VK_4);
                    case '5'
                        this.JavaRobot.keyPress(KeyEvent.VK_5);
                        this.JavaRobot.keyRelease(KeyEvent.VK_5);
                    case '6'
                        this.JavaRobot.keyPress(KeyEvent.VK_6);
                        this.JavaRobot.keyRelease(KeyEvent.VK_6);
                    case '7'
                        this.JavaRobot.keyPress(KeyEvent.VK_7);
                        this.JavaRobot.keyRelease(KeyEvent.VK_7);
                    case '8'
                        this.JavaRobot.keyPress(KeyEvent.VK_8);
                        this.JavaRobot.keyRelease(KeyEvent.VK_8);
                    case '9'
                        this.JavaRobot.keyPress(KeyEvent.VK_9);
                        this.JavaRobot.keyRelease(KeyEvent.VK_9);
                    case '.'
                        this.JavaRobot.keyPress(KeyEvent.VK_COMMA);
                        this.JavaRobot.keyRelease(KeyEvent.VK_COMMA);
                end %switch
            end %for
        end %fun
    end %methods
end %class