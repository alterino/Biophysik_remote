classdef classTirfAdjustmentWrapper < handle
    
    properties
        Parent
        TemplatePanel
        PanelPos
        ObsPanel
    end %properties
    properties(Access=private)
        TemplateCheckboxOn = rgb2gray(uint8(cat(3,...
            [142 142 142 142 142 142 142 142 142 142 142 142 142;142 244 244 244 244 244 244 244 248 249 246 244 142;142 244 174 174 174 174 174 201 157 119 220 245 142;142 244 174 203 203 203 204 237 87 68 185 246 142;142 244 174 203 203 205 224 175 69 101 231 244 142;142 244 174 213 223 213 242 94 71 188 219 244 142;142 244 197 201 163 237 186 73 100 248 213 244 142;142 244 222 110 71 207 103 75 183 246 220 244 142;142 244 205 222 72 73 75 97 248 244 225 244 142;142 244 198 234 139 74 76 176 249 246 230 244 142;142 244 202 218 223 140 144 242 236 235 233 244 142;142 244 244 244 245 249 248 245 244 244 244 244 142;142 142 142 142 142 142 142 142 142 142 142 142 142],...
            [143 143 143 143 143 143 143 143 143 143 143 143 143;143 244 244 244 244 244 244 244 248 249 246 244 143;143 244 179 179 179 179 179 204 167 134 223 245 143;143 244 179 207 207 207 208 238 106 90 191 246 143;143 244 179 207 207 209 226 184 90 119 231 244 143;143 244 179 217 226 216 243 113 92 195 220 244 143;143 244 201 207 174 238 193 94 118 248 213 244 143;143 244 224 127 92 212 120 96 191 246 221 244 143;143 244 207 225 93 95 96 115 249 244 226 244 143;143 244 200 236 153 95 97 185 249 246 230 244 143;143 244 203 218 226 153 157 243 237 235 233 244 143;143 244 244 244 245 249 248 245 244 244 244 244 143;143 143 143 143 143 143 143 143 143 143 143 143 143],...
            [143 143 143 143 143 143 143 143 143 143 143 143 143;143 244 244 244 244 244 244 244 248 249 246 244 143;143 244 185 185 185 185 185 208 192 171 228 245 143;143 244 185 213 213 213 214 241 157 146 208 246 143;143 244 185 213 213 214 230 207 146 165 232 244 143;143 244 185 221 229 220 244 161 148 214 220 244 143;143 244 205 221 200 238 213 150 165 248 214 244 143;143 244 225 170 148 226 167 151 213 246 222 244 143;143 244 209 233 149 150 151 164 250 244 226 244 143;143 244 202 240 187 151 152 209 249 246 230 244 143;143 244 204 219 233 186 189 246 237 236 234 244 143;143 244 244 244 245 249 248 245 244 244 244 244 143;143 143 143 143 143 143 143 143 143 143 143 143 143])));
        TemplateCheckboxOff = rgb2gray(uint8(cat(3,...
            [142 142 142 142 142 142 142 142 142 142 142 142 142;142 244 244 244 244 244 244 244 244 244 244 244 142;142 244 174 174 174 174 174 174 175 180 187 244 142;142 244 174 203 203 203 203 208 213 219 193 244 142;142 244 174 203 203 205 210 216 221 226 198 244 142;142 244 174 205 208 212 219 225 229 232 204 244 142;142 244 178 213 218 224 232 236 237 237 212 244 142;142 244 184 221 228 234 239 242 242 242 220 244 142;142 244 188 227 233 237 242 244 245 244 225 244 142;142 244 194 233 237 240 244 246 246 246 230 244 142;142 244 202 212 219 224 230 234 235 235 233 244 142;142 244 244 244 244 244 244 244 244 244 244 244 142;142 142 142 142 142 142 142 142 142 142 142 142 142],...
            [143 143 143 143 143 143 143 143 143 143 143 143 143;143 244 244 244 244 244 244 244 244 244 244 244 143;143 244 179 179 179 179 179 179 180 185 190 244 143;143 244 179 207 207 207 207 211 216 221 195 244 143;143 244 179 207 207 209 213 219 223 227 199 244 143;143 244 179 209 212 215 221 226 230 232 205 244 143;143 244 183 216 220 225 232 236 237 237 213 244 143;143 244 187 223 229 234 239 242 242 242 221 244 143;143 244 191 228 233 237 242 244 245 244 226 244 143;143 244 196 233 237 240 244 246 246 246 230 244 143;143 244 203 212 219 225 231 235 236 235 233 244 143;143 244 244 244 244 244 244 244 244 244 244 244 143;143 143 143 143 143 143 143 143 143 143 143 143 143],...
            [143 143 143 143 143 143 143 143 143 143 143 143 143;143 244 244 244 244 244 244 244 244 244 244 244 143;143 244 185 185 185 185 185 185 186 189 193 244 143;143 244 185 213 213 213 213 216 220 223 197 244 143;143 244 185 213 213 214 218 222 225 228 200 244 143;143 244 185 215 217 219 223 227 230 232 205 244 143;143 244 188 220 223 227 232 236 237 237 214 244 143;143 244 191 225 229 234 239 242 242 242 222 244 143;143 244 194 229 233 237 242 244 245 244 226 244 143;143 244 198 233 237 240 244 246 246 246 230 244 143;143 244 204 213 220 225 231 235 236 236 234 244 143;143 244 244 244 244 244 244 244 244 244 244 244 143;143 143 143 143 143 143 143 143 143 143 143 143 143])));
    end %properties
    
    methods
        %% constructor
        function this = classTirfAdjustmentWrapper(parent)
            this.Parent = parent;
            this.TemplatePanel = imread('TIRF_Adjustment_Panel.tif');
        end %fun
        
        function initialize(this)
            get_panel(this);
        end %fun
        
        %% getter
        function get_panel(this)
            screenShot = rgb2gray(get_screen_shot);
            
            corrMap = normxcorr2(this.TemplatePanel, screenShot);
            [valMaxCorr, posMaxCorr] = max(corrMap(:));
            
            if valMaxCorr < 0.9
                this.PanelPos = [];
                this.ObsPanel = [];
                fprintf('\nTIRF Panel not detectable.\n')
            else %panel was identified
                [i0,j0] = ind2sub(size(corrMap),posMaxCorr(1));
                panelHeight = size(this.TemplatePanel,1);
                i0 = i0-panelHeight;
                panelWidth = size(this.TemplatePanel,2);
                j0 = j0-panelWidth;
                
                this.PanelPos = [j0+1,i0+1,panelWidth,panelHeight];
                this.ObsPanel = screenShot(i0+1:i0+panelHeight,j0+1:j0+panelWidth,:);
                %             figure;imagesc(screenShot); hold on; plot(j0,i0,'rx')
            end %if
        end %fun
        function update_panel(this)
            if isempty(this.PanelPos)
                get_panel(this)
                return
            end %if
            
            this.ObsPanel = rgb2gray(get_screen_shot(this.PanelPos));
            
            %check consistency (in case the panel was moved)
            templatePanel = double(this.TemplatePanel);
            obsPanel = double(this.ObsPanel);
            
            numTemplate = numel(templatePanel);
            muTemplate = sum(sum(sum(templatePanel)))/numTemplate;
            ssTemplate = sum(sum(sum(templatePanel.^2)));
            muObs = sum(sum(sum(obsPanel)))/numTemplate;
            ssObs = sum(sum(sum(obsPanel.^2)));
            
            CC = (sum(sum(sum(templatePanel.*obsPanel)))-numTemplate*muTemplate*muObs)/...
                (sqrt(ssTemplate-numTemplate*muTemplate^2)*sqrt(ssObs-numTemplate*muObs^2));
            
            if CC < 0.9
                get_panel(this)
            end %if
        end %fun
        
        function [state,posCheckbox,posEditbox] = get_fiber_state(this,fiber)
            switch fiber
                case 405
                    template = this.TemplatePanel(55:65,43:79,:);
                case 488
                    template = this.TemplatePanel(88:98,43:79,:);
                case 561
                    template = this.TemplatePanel(121:131,43:79,:);
                case 640
                    template = this.TemplatePanel(154:164,43:79,:);
            end %switch
            
            update_panel(this)
            corrMap = normxcorr2(template, this.ObsPanel);
            [valMaxCorr, posMaxCorr] = max(corrMap(:));
            
            if valMaxCorr < 0.9
                state = [];
                fprintf('\n%.0f Fiber state not detectable.\n',fiber)
            else
                [i0,j0] = ind2sub(size(corrMap),posMaxCorr(1));
                panelHeight = size(template,1);
                i0 = i0-panelHeight;
                panelWidth = size(template,2);
                j0 = j0-panelWidth;
                %             figure;imagesc(this.ObsPanel); hold on; plot(j0,i0,'rx')
                
                posCheckbox = [j0-13,i0+1,13,13];
                posEditbox = [j0+228,i0-3,62,20];
                
                obsCheckbox = this.ObsPanel(i0+1:i0+1+13-1,j0-13:j0-13+13-1,:);
                state = get_checkbox_state(this,obsCheckbox);
            end %if
        end %fun
        
        %% setter
        function set_fiber_state(this,fiber,state)
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> %.0fnm Fiber OFF \n1 ==> %.0fnm Fiber ON\n',fiber,fiber)
                return
            end %if
            
            [currentState,posCheckbox] = get_fiber_state(this,fiber);
            if isempty(currentState)
                %error
                return
            end %if
            
            if state == currentState
                %no change in current state
                return
            end %if
            
            %save current mouse position
            screenSize = get(0,'ScreenSize');
            currentMousePos = get(0,'PointerLocation');
            currentMousePos(2) = screenSize(4) - currentMousePos(2) + 1;
            
            import java.awt.event.*;
            xCtrCheckbox = this.PanelPos(1)+posCheckbox(1)+posCheckbox(3)/2;
            yCtrCheckbox = this.PanelPos(2)+posCheckbox(2)+posCheckbox(4)/2;
            this.Parent.JavaRobot.mouseMove(xCtrCheckbox, yCtrCheckbox);
            this.Parent.JavaRobot.mousePress(InputEvent.BUTTON1_MASK);
            this.Parent.JavaRobot.mouseRelease(InputEvent.BUTTON1_MASK);
            
            %restore current mouse position
            newMousePos = get(0,'PointerLocation');
            newMousePos(2) = screenSize(4) - newMousePos(2) + 1;
            
            dr = newMousePos - currentMousePos;
            this.Parent.JavaRobot.mouseMove(xCtrCheckbox-dr(1), yCtrCheckbox-dr(2));
        end %fun
        
        function set_fiber_position(this,fiber,pos)
            [currentState,~,posEditbox] = get_fiber_state(this,fiber);
            if not(currentState == 1)
                set_fiber_state(this,fiber,1)
            end %if
            
            %save current mouse position
            screenSize = get(0,'ScreenSize');
            currentMousePos = get(0,'PointerLocation');
            currentMousePos(2) = screenSize(4) - currentMousePos(2) + 1;
            
            import java.awt.event.*;
            xCtrCheckbox = this.PanelPos(1)+posEditbox(1)+posEditbox(3)/2;
            yCtrCheckbox = this.PanelPos(2)+posEditbox(2)+posEditbox(4)/2;
            this.Parent.JavaRobot.mouseMove(xCtrCheckbox, yCtrCheckbox);
            %double-click
            this.Parent.JavaRobot.mousePress(InputEvent.BUTTON1_MASK);
            this.Parent.JavaRobot.mouseRelease(InputEvent.BUTTON1_MASK);
            this.Parent.JavaRobot.mousePress(InputEvent.BUTTON1_MASK);
            this.Parent.JavaRobot.mouseRelease(InputEvent.BUTTON1_MASK);
            
            double_to_key_event(this,pos)
            this.Parent.JavaRobot.keyPress(KeyEvent.VK_ENTER);
            this.Parent.JavaRobot.keyRelease(KeyEvent.VK_ENTER);
            
            %restore current mouse position
            newMousePos = get(0,'PointerLocation');
            newMousePos(2) = screenSize(4) - newMousePos(2) + 1;
            
            dr = newMousePos - currentMousePos;
            this.Parent.JavaRobot.mouseMove(xCtrCheckbox-dr(1), yCtrCheckbox-dr(2));
        end %fun
        
        %%
        function stateCheckbox = get_checkbox_state(this,obsCheckbox)
            sseOn = sum((obsCheckbox(:)-this.TemplateCheckboxOn(:)).^2);
            sseOff = sum((obsCheckbox(:)-this.TemplateCheckboxOff(:)).^2);
            
            critSSE = 0;
            if min([sseOn sseOff]) > critSSE
                fprintf('\nError in identification of checkbox state!\n')
                stateCheckbox = nan;
            else
                if sseOn < sseOff
                    stateCheckbox = 1;
                elseif sseOff < sseOn
                    stateCheckbox = 0;
                else
                    fprintf('\nError in identification of checkbox state!\n')
                    stateCheckbox = nan;
                end %if
            end %if
        end %fun
        function double_to_key_event(this,num)
            import java.awt.event.*;
            
            numChars = cellstr(transpose(num2str(num,'%.3f')));
            for iChar = 1:numel(numChars)
                switch numChars{iChar}
                    case '0'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_0);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_0);
                    case '1'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_1);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_1);
                    case '2'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_2);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_2);
                    case '3'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_3);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_3);
                    case '4'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_4);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_4);
                    case '5'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_5);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_5);
                    case '6'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_6);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_6);
                    case '7'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_7);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_7);
                    case '8'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_8);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_8);
                    case '9'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_9);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_9);
                    case '.'
                        this.Parent.JavaRobot.keyPress(KeyEvent.VK_COMMA);
                        this.Parent.JavaRobot.keyRelease(KeyEvent.VK_COMMA);
                end %switch
            end %for
        end %fun
    end %methods
end %classdef

%% TEST
% clear all; clear classes
% objMM = classMicroManagerWrapper;
% objTIRF = classTirfAdjustmentWrapper(objMM);
% initialize(objTIRF)
% 
% state = get_fiber_state(objTIRF,405)
% state = get_fiber_state(objTIRF,488)
% state = get_fiber_state(objTIRF,561)
% state = get_fiber_state(objTIRF,640)
% 
% set_fiber_state(objTIRF,405,0);
% set_fiber_state(objTIRF,488,0);
% set_fiber_state(objTIRF,561,0);
% set_fiber_state(objTIRF,640,0);
% 
% set_fiber_state(objTIRF,405,1);
% set_fiber_state(objTIRF,488,1);
% set_fiber_state(objTIRF,561,1);
% set_fiber_state(objTIRF,640,1);
% 
% set_fiber_position(objTIRF,405,0)
% set_fiber_position(objTIRF,488,0)
% set_fiber_position(objTIRF,561,0)
% set_fiber_position(objTIRF,640,0)