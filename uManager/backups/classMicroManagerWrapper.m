classdef classMicroManagerWrapper < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    %modification
    %17.04.2014
    %28.04.2014
    %30.04.2014
    %03.05.2014: piezo z-position getter
    %08.07.2015: additional hardware
    
    properties
        CoreAPI
        GuiAPI
        AcqAPI
        
        Core
        OlympusHub
        Camera
        ObjectiveStage
        Piezo
        XYStage
        ObjectiveRevolver
        LightPath
        FilterRevolver
        TransmissionLampShutter
        TransmissionLamp
        AutoFocus
        TIRF
        
        JavaRobot
    end %properties
    properties(Access=private)
        StageMinLimit = 5; %[µm]
        StageMaxLimit = 4000; %[µm]
        PiezoMinLimit = 0;
        PiezoMaxLimit = 99; %[µm]
        PxSatThresh = 2^16;
        PxSatExpRedFac = 0.5;
        
        XYStageCtr = [60895 41333]; %(x,y) [µm]
        XYStageMaxRadius = 2000; %[µm]
        
        XYStageMinSpeed = 0.000015; %[mm/s] %taken from Maerzhaeuser Manual
        XYStageMaxSpeed = 10; %[mm/s] %taken from Maerzhaeuser Manual; 100 mm/s possible, but at own risk
        
        XYStageMinAcceleration = 0.0001; %[m/s^2] %taken from Maerzhaeuser Manual
        XYStageMaxAcceleration = 20; %[m/s^2] %taken from Maerzhaeuser Manual
        
        XYStageMinStepSize = 360; %[] %taken from Maerzhaeuser Manual
        XYStageMaxStepSize = 1638400; %[] %taken from Maerzhaeuser Manual
        
        TransmissionLampMinVoltage = 0;
        TransmissionLampMaxVoltage = 12;
        
        AutoFocusSearchRangeMinLimit = 1; %[µm]
        AutoFocusSearchRangeMaxLimit = 1000; %[µm]
    end %properties
    
    methods
        %% constructor
        function this = classMicroManagerWrapper
            import java.awt.Robot;
            this.JavaRobot = Robot;
            this.JavaRobot.delay(0)
            this.JavaRobot.setAutoDelay(0)
            this.JavaRobot.setAutoWaitForIdle(1)
        end %fun
        function import_java(this)
            micManPath = 'C:\Program Files\Micro-Manager-1.4';
            if not(exist(micManPath,'dir') == 7)
                micManPath = uigetdir;
            end %if
            classMicroManagerWrapper.MMsetup_javaclasspath(micManPath)
        end %fun
        function load_micro_manager_gui(this)
            import org.micromanager.*;
            %             import mmcorej.*;
            pause(1)
            
            this.GuiAPI = MMStudioMainFrame(0);
            this.GuiAPI.show;
        end %fun
        function setup_profile(this,profile)
            get_coreAPI(this)
            get_AcqAPI(this)
            
            get_core(this)
            get_olympus_hub(this)
            get_objective_stage(this)
            get_xy_stage(this)
            get_camera(this)
            get_transmission_lamp(this)
            get_transmission_lamp_shutter(this)
            get_objective_revolver(this)
            get_light_path(this)
            get_filter_revolver(this)
            get_auto_focus(this)
            
            set_auto_focus_search_range(this,500)
            set_transmission_lamp_auto_shutter(this,0)
            
            switch profile
                case '100x'
                    this.XYStageCtr = [60895 41333]; %(x,y) [µm
                    this.XYStageMaxRadius = 2000; %[µm]
                    
                    set_auto_focus_objective(this,100)
            end %switch
        end %fun
        
        %% getter
        function get_coreAPI(this)
            if isempty(this.GuiAPI)
                import mmcorej.*;
                this.CoreAPI = CMMCore;
            else
                this.CoreAPI = this.GuiAPI.getCore;
            end %if
        end %fun
        function get_AcqAPI(this)
            if isempty(this.GuiAPI)
                import mmcorej.*;
            else
                this.AcqAPI = this.GuiAPI.getAcquisitionEngine;
            end %if
        end %fun
        
        %%
        function deviceList = list_all_devices(this)
            deviceList = toArray(this.CoreAPI.getLoadedDevices());
        end %fun
        function propertyList = get_properties(this,device)
            propertyList = toArray(this.CoreAPI.getDevicePropertyNames(device));
        end %fun
        
        %%
        function get_core(this)
            this.Core = java.lang.String('Core');
        end %fun
        function get_olympus_hub(this)
            this.OlympusHub = java.lang.String('OlympusHub');
        end %fun
        function get_objective_stage(this)
            this.ObjectiveStage = java.lang.String('ManualFocus');
        end %fun
        function get_camera(this)
            this.Camera = this.CoreAPI.getCameraDevice();
        end %fun
        function get_xy_stage(this)
            this.XYStage = this.CoreAPI.getXYStageDevice();
        end %fun
        function get_transmission_lamp(this)
            this.TransmissionLamp = java.lang.String('TransmittedLamp');
        end %fun
        function get_transmission_lamp_shutter(this)
            this.TransmissionLampShutter = java.lang.String('Shutter1');
        end %fun
        function get_objective_revolver(this)
            this.ObjectiveRevolver = java.lang.String('Objective');
        end %fun
        function get_light_path(this)
            this.LightPath = java.lang.String('LightPath');
        end %fun
        function get_filter_revolver(this)
            this.FilterRevolver = java.lang.String('FilterCube');
        end %fun
        function get_auto_focus(this)
            this.AutoFocus = java.lang.String('AutoFocusZDC');
        end %fun
        
        function get_TIRF(this)
            this.TIRF = classTirfAdjustmentWrapper;
            panelIdentified = initialize(this.TIRF);
            if panelIdentified
            else
                %error
                this.TIRF = [];
            end %if
        end %fun
        
        
        %%
        function state = get_tranmission_lamp_power(this)
            % 1 ==> lamp is on
            state = this.CoreAPI.getState(this.TransmissionLamp);
        end %fun
        function state = get_tranmission_lamp_shutter_state(this)
            % 1 ==> shutter open
            state = this.CoreAPI.getProperty(this.TransmissionLampShutter,'State');
        end %fun
        function voltage = get_tranmission_lamp_voltage(this)
            voltage = this.CoreAPI.getProperty(this.TransmissionLamp,'Voltage');
            %convert to MATLAB double
            voltage = double(java.lang.Double(voltage));
        end %fun
        function state = get_tranmission_lamp_auto_shutter_state(this)
            % 1 ==> auto shutter ON
            state = this.CoreAPI.getProperty(this.Core,'AutoShutter');
        end %fun
        
        function pos = get_objective_revolver_position(this)
            pos = this.CoreAPI.getState(this.ObjectiveRevolver);
        end %fun
        function state = get_light_path_state(this)
            % 0 ==> Ocular
            % 1 ==> camera
            state = this.CoreAPI.getState(this.LightPath);
        end %fun
        function pos = get_filter_revolver_position(this)
            pos = this.CoreAPI.getState(this.FilterRevolver);
        end %fun
        
        function binning = get_pixel_binning(this)
            binning = this.CoreAPI.getProperty(this.Camera,'Binning');
        end %fun
        function exposureTimeMs = get_exposure_time(this)
            exposureTimeMs = this.CoreAPI.getExposure;
            %             exposureTimeMs = this.CoreAPI.getProperty(this.Camera,'Exposure');
        end %fun
        function zPosition = get_objective_stage_z_position(this)
            zPosition = this.CoreAPI.getPosition(this.ObjectiveStage);
        end %fun
        function zPosition = get_piezo_z_position(this)
            zPosition = this.CoreAPI.getPosition(this.Piezo);
        end %fun
        
        function xyPosition = get_xy_pos_micron(this)
            xyPosition = [this.CoreAPI.getXPosition(this.XYStage)...
                this.CoreAPI.getYPosition(this.XYStage)];
        end
        function xyAcceleration = get_xy_acceleration(this)
            xyAcceleration = [this.CoreAPI.getProperty(this.XYStage,'Acceleration X [m/s^2]') ...
                this.CoreAPI.getProperty(this.XYStage,'Acceleration Y [m/s^2]')];
        end %fun
        function xySpeed = get_xy_speed(this)
            xySpeed = [this.CoreAPI.getProperty(this.XYStage,'SpeedX [mm/s]') ...
                this.CoreAPI.getProperty(this.XYStage,'SpeedY [mm/s]')];
        end %fun
        function xyStepSize = get_xy_step_size(this)
            xyStepSize = [this.CoreAPI.getProperty(this.XYStage,'StepSizeX [um]') ...
                this.CoreAPI.getProperty(this.XYStage,'StepSizeY [um]')];
        end %fun
        
        function state = get_auto_focus_state(this)
            state = this.CoreAPI.getProperty(this.AutoFocus,'ContinuousMode');
            
            %convert to MATLAB
            state = char(state);
            switch state
                case 'On'
                    state = 1;
                case 'Off'
                    state = 0;
            end %switch
        end %fun
        function objective = get_auto_focus_objective(this)
            objective = this.CoreAPI.getProperty(this.AutoFocus,'ObjectiveTypeSetting');
            %convert to MATLAB
            objective = char(objective);
            
            switch objective
                case 'UApoN100XOTIRF'
                    objective = 100;
                otherwise
                    objective = nan;
            end %switch
        end %fun
        function range = get_auto_focus_search_range(this)
            range = this.CoreAPI.getProperty(this.AutoFocus,'SearchRange');
            %convert to MATLAB
            range = str2double(char(range));
        end %fun
        
        %% setter
        function set_pixel_binning(this,mode)
            if gui_running(this)
                if gui_live_mode(this)
                    toggle_gui_live_mode(this,0)
                end %if
            end %if
            
            switch mode
                case 1
                    this.CoreAPI.setProperty(this.Camera,'Binning','1x1');
                case 2
                    this.CoreAPI.setProperty(this.Camera,'Binning','2x2');
                case 3
                    this.CoreAPI.setProperty(this.Camera,'Binning','4x4');
                otherwise
                    %error
            end %switch
            
            if gui_running(this)
                if gui_live_mode(this)
                    toggle_gui_live_mode(this,0)
                end %if
            end %if
        end %fun
        function set_exposure_time(this,exposureTimeMs)
            if gui_running(this)
                if gui_live_mode(this)
                    toggle_gui_live_mode(this,0)
                end %if
            end %if
            
            this.CoreAPI.setExposure(exposureTimeMs)
            %             this.CoreAPI.setProperty(this.Camera,'Exposure',exposureTimeMs)
            
            if gui_running(this)
                if gui_live_mode(this)
                    toggle_gui_live_mode(this,0)
                end %if
            end %if
        end %fun
        function set_olympus_hub_control(this,mode)
            %mode = 0 -> only computer
            %mode = 1 -> computer + manual
            switch mode
                case 0
                    this.CoreAPI.setProperty(this.OlympusHub,'Control','Computer');
                case 1
                    this.CoreAPI.setProperty(this.OlympusHub,'Control','Manual + Computer');
                otherwise
                    %error
                    return
            end %switch
        end %fun
        function set_objective_stage_z_position_micron(this,zPosMicron)
            zPosMicron = min(this.StageMaxLimit,...
                max(this.StageMinLimit,zPosMicron));
            
            this.CoreAPI.setPosition(this.ObjectiveStage,zPosMicron)
            this.CoreAPI.waitForDevice(this.ObjectiveStage)
        end %fun
        function set_piezo_z_position_micron(this,zPosMicron)
            zPosMicron = min(this.PiezoMaxLimit,max(this.PiezoMinLimit,zPosMicron));
            this.CoreAPI.setPosition(this.Piezo,zPosMicron)
            this.CoreAPI.waitForDevice(this.Piezo)
        end %fun
        function set_objective_revolver_position(this,pos)
            if gui_running(this)
                if gui_live_mode(this)
                    %switch off lasers
                    return
                end %if
            end %if
            
            % 0 ==> 20x
            % 2 ==> 60x
            % 3 ==> 100x
            % 4 ==> 150x
            if not(any([0 2 3 4] == pos))
                fprintf('\nExpected Input: \n0 ==> 20x \n2 ==> 60x\n3 ==> 100x \n4 ==> 150x\n')
                return
            end %if
            
            if pos == get_objective_revolver_position(this)
                %no change in current position
                return
            end %if
            
            %check that objective is in the lowest position before changing
            set_objective_stage_z_position_micron(this,this.StageMinLimit)
            this.CoreAPI.setState(this.ObjectiveRevolver,pos)
            this.CoreAPI.waitForDevice(this.ObjectiveRevolver);
            
            switch pos
                case 0
                    fprintf('\n Objective: 20x\n')
                case 2
                    fprintf('\n Objective: 60x\n')
                case 3
                    fprintf('\n Objective: 100x\n')
                case 4
                    fprintf('\n Objective: 150x\n')
            end %switch
        end %fun
        
        function set_tranmission_lamp_power(this,state)
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Tranmission Lamp OFF \n1 ==> Tranmission Lamp ON\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Tranmission Lamp: OFF\n')
            elseif (state == 1)
                fprintf('\n Tranmission Lamp: ON\n')
            end %if
            
            if state == get_tranmission_lamp_power(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> lamp is on
            this.CoreAPI.setState(this.TransmissionLamp,state)
            this.CoreAPI.waitForDevice(this.TransmissionLamp);
        end %fun
        function set_tranmission_lamp_shutter_state(this,state)
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Transmission Lamp Shutter CLOSED \n1 ==> Transmission Lamp Shutter OPEN\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Tranmission Lamp Shutter: CLOSED\n')
            elseif (state == 1)
                fprintf('\n Tranmission Lamp Shutter: OPEN\n')
            end %if
            
            if state == get_tranmission_lamp_shutter_state(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> shutter open
            this.CoreAPI.setProperty(this.TransmissionLampShutter,'State',state)
        end %fun
        function set_tranmission_lamp_voltage(this,voltage)
            if not(isscalar & isnumeric)
                fprintf('\nExpected Input: \n%0.1f <= Brightness [V] <= %0.1f\n',...
                    this.TransmissionLampMinVoltage,this.TransmissionLampMaxVoltage)
                return
            end %if
            
            voltage = min(this.TransmissionLampMaxVoltage,...
                max(this.TransmissionLampMinVoltage,voltage));
            
            fprintf('\n Transmission Lamp Brightness: %.1f V\n',voltage)
            
            if voltage == get_tranmission_lamp_voltage(this)
                %no change in current state
                return
            end %if
            
            %convert to JAVA string
            voltage = java.lang.String(num2str(voltage,'%.1f'));
            this.CoreAPI.setProperty(this.TransmissionLamp,'Voltage',voltage)
            this.CoreAPI.waitForDevice(this.TransmissionLamp);
        end %fun
        function set_transmission_lamp_auto_shutter(this,state)
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Auto Shutter OFF \n1 ==> Auto Shutter ON\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Auto Shutter: OFF\n')
            elseif (state == 1)
                fprintf('\n Auto Shutter: ON\n')
            end %if
            
            if state == get_tranmission_lamp_auto_shutter_state(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> auto shutter ON
            this.CoreAPI.setProperty(this.Core,'AutoShutter',state)
        end %fun
        
        function set_light_path_state(this,state)
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Ocular \n1 ==> Camera\n')
                return
            end %if
            
            if state == get_light_path_state(this)
                %no change in current state
                return
            end %if
            
            % 0 ==> Ocular
            % 1 ==> camera
            this.CoreAPI.setState(this.LightPath,state)
            this.CoreAPI.waitForDevice(this.LightPath);
            
            if (state == 0)
                fprintf('\n Light Path: Ocular\n')
            elseif (state == 2)
                fprintf('\n Light Path: Camera\n')
            end %if
        end %fun
        
        function set_filter_revolver_position(this,pos)
            if gui_running(this)
                if gui_live_mode(this)
                    if get_tranmission_lamp_power(this) && ...
                            get_tranmission_lamp_shutter_state(this)
                        %switch off lamp
                        set_tranmission_lamp_shutter_state(this,0)
                    end %if
                    %switch off lasers
                    return
                end %if
            end %if
            
            % 0 ==> 405/488/561/642
            % 5 ==> DIC
            if not(any([0 5] == pos))
                %error
                return
            end %if
            
            if pos == get_filter_revolver_position(this)
                %no change in current position
                return
            end %if
            
            this.CoreAPI.setState(this.FilterRevolver,pos)
            this.CoreAPI.waitForDevice(this.FilterRevolver);
        end %fun
        
        function set_xy_pos_micron(this,xyPosMicron)
            if not(numel(xyPosMicron) == 2)
                %error
                return
            end %if
            
            dstvect = xyPosMicron - this.XYStageCtr;
            dst =  sqrt(dstvect(1)^2 + dstvect(2)^2);
            
            if(dst >= this.XYStageMaxRadius)
                thta = atan2(dstvect(2),dstvect(1));
                xyPosMicron = [this.XYStageMaxRadius*cos(thta) + this.XYStageCtr(1),...
                    this.XYStageMaxRadius*sin(thta) + this.XYStageCtr(2)];
            elseif(dst < this.XYStageMaxRadius)
                xyPosMicron = xyPosMicron;
            else
                xyPosMicron = get_xy_pos_micron(this);
                fprintf('something funky happened')
            end
            
            
            this.CoreAPI.setXYPosition(this.XYStage,xyPosMicron(1),xyPosMicron(2));
            this.CoreAPI.waitForDevice(this.XYStage);
        end %fun
        function set_xy_rel_pos_micron(this,xyRelPos)
            if not(numel(xyRelPos) == 2)
                %error
                return
            end %if
            
            xyPosMicron = get_xy_pos_micron(this) + xyRelPos;
            xyPosMicron = [min(this.XYStageMaxLimit(1),max(this.XYStageMinLimit(1),xyPosMicron(1))),...
                min(this.XYStageMaxLimit(1),max(this.XYStageMinLimit(1),xyPosMicron(1)))];
            this.CoreAPI.setXYPosition(this.XYStage,xyPosMicron(1),xyPosMicron(2));
            this.CoreAPI.waitForDevice(this.XYStage);
        end %fun
        function set_xy_speed(this,xySpeed)
            %[xSpeed ySpeed] in mm/s
            xySpeed = [min(this.XYStageMaxSpeed,max(this.XYStageMinSpeed,xySpeed(1))) ...
                min(this.XYStageMaxSpeed,max(this.XYStageMinSpeed,xySpeed(2)))];
            
            this.CoreAPI.getProperty(this.XYStage,'SpeedX [mm/s]',xySpeed(1))
            this.CoreAPI.getProperty(this.XYStage,'SpeedX [mm/s]',xySpeed(2))
        end %fun
        function set_xy_acceleration(this,xyAcceleration)
            %[xSpeed ySpeed] in mm/s
            xyAcceleration = [min(this.XYStageMaxAcceleration,max(this.XYStageMinAcceleration,xyAcceleration(1))) ...
                min(this.XYStageMaxAcceleration,max(this.XYStageMinAcceleration,xyAcceleration(2)))];
            
            this.CoreAPI.getProperty(this.XYStage,'Acceleration X [m/s^2]',xyAcceleration(1))
            this.CoreAPI.getProperty(this.XYStage,'Acceleration Y [m/s^2]',xyAcceleration(2))
        end %fun
        
        function set_auto_focus_state(this,state)
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Auto Focus OFF \n1 ==> Auto Focus ON\n')
                return
            end %if
            
            if state == get_auto_focus_state(this)
                %no change in current state
                return
            end %if
            
            if (state == 0)
                fprintf('\n Auto Focus: OFF\n')
            elseif (state == 1)
                fprintf('\n Auto Focus: ON\n')
            end %if
            
            switch state
                case 0
                    state = java.lang.String('Off');
                case 1
                    state = java.lang.String('On');
            end %switch
            
            this.CoreAPI.setProperty(this.AutoFocus,'ContinuousMode',state);
            this.CoreAPI.waitForDevice(this.AutoFocus);
        end %fun
        function set_auto_focus_objective(this,objective)
            if not(isscalar & isnumeric)
                fprintf('\nExpected Input: \n100 ==> 100x Objective\n')
                return
            end %if
            
            if objective == get_auto_focus_objective(this)
                %no change in current state
                return
            end %if
            
            switch objective
                case 100
                    objective = java.lang.String('UApoN100XOTIRF');
                    fprintf('\n Auto Focus Objective: UApoN100XOTIRF\n')
                otherwise
                    fprintf('\nAuto Focus Objective: Unexpected Input\n')
                    return
            end %switch
            
            this.CoreAPI.setProperty(this.AutoFocus,'ObjectiveTypeSetting',objective);
            this.CoreAPI.waitForDevice(this.AutoFocus)
        end %fun
        function set_auto_focus_search_range(this,range)
            if not(isscalar & isnumeric)
                fprintf('\nExpected Input: \n%0.1f <= Range [µm] <= %0.1f\n',...
                    this.AutoFocusSearchRangeMinLimit,this.AutoFocusSearchRangeMaxLimit)
                return
            end %if
            
            %check limits
            range = min(this.AutoFocusSearchRangeMaxLimit,...
                max(this.AutoFocusSearchRangeMinLimit,range));
            
            fprintf('\n Auto Focus Search Range: %.1f µm\n',range)
            
            if range == get_auto_focus_search_range(this)
                %no change in current state
                return
            end %if
            
            %convert to JAVA
            range = java.lang.String(num2str(voltage,'%.1f'));
            
            this.CoreAPI.setProperty(this.AutoFocus,'SearchRange',range);
            this.CoreAPI.waitForDevice(this.AutoFocus)
        end %fun
        
        %% checker
        function flag = gui_running(this)
            if isempty(this.GuiAPI)
                flag = 0;
            else
                flag = 1;
            end %if
        end %fun
        function flag = gui_live_mode(this)
            flag = this.GuiAPI.isLiveModeOn();
        end %fun
        
        %% acquisition
        function img = get_actual_image(this)
            this.CoreAPI.snapImage();
            img = this.CoreAPI.getImage();
            imgWidth = this.CoreAPI.getImageWidth();
            imgHeight = this.CoreAPI.getImageHeight();
            img = reshape(img,imgWidth,imgHeight);
            img = double(transpose(img));
        end %fun
        function continous_acquisition(this)
            imgHeight = this.CoreAPI.getImageHeight();
            imgWidth = this.CoreAPI.getImageWidth();
            
            bufferSize = min(1000,300*imgHeight*imgWidth*this.CoreAPI.getBytesPerPixel()*1e-6);
            this.CoreAPI.setCircularBufferMemoryFootprint(bufferSize)
            
            this.CoreAPI.startSequenceAcquisition(300, 0, false);
            pause(0.1)
            while this.CoreAPI.getRemainingImageCount() > 0
                img = reshape(this.CoreAPI.popNextImage(),imgHeight,imgWidth);
                imwrite(uint16(img),'E:\Users\BP\Richter\test6.tif',...
                    'compression','none','writemode','append', 'bitdepth', 16)
            end
            %             this.CoreAPI.stopSequenceAcquisition();
        end %
        
        function show_acquisition(this)
            img = get_actual_image(this);
            imagesc(img)
            colorbar
            axis image
        end %fun
        
        function toggle_gui_live_mode(this,state)
            if nargin == 1 %toggle
                switch gui_live_mode(this)
                    case 0 %-> turn on
                        this.GuiAPI.enableLiveMode(true)
                    case 1 %-> turn off
                        this.GuiAPI.enableLiveMode(false)
                end %switch
            else
                switch state
                    case 0 %-> turn off
                        this.GuiAPI.enableLiveMode(false)
                    case 1 %-> turn on
                        this.GuiAPI.enableLiveMode(true)
                    otherwise
                        %error
                        return
                end %switch
            end %if
        end %fun
        
        %% protocols
        function full_hardware_test(this)
            %test transmission lamp
            currentState = get_tranmission_lamp_power(this);
            set_tranmission_lamp_power(this,1)
            set_tranmission_lamp_shutter_state(this,0)
            set_tranmission_lamp_voltage(this,6)
            set_tranmission_lamp_shutter_state(this,1)
            pause(1)
            set_tranmission_lamp_shutter_state(this,0)
            pause(1)
            set_tranmission_lamp_shutter_state(this,1)
            pause(1)
            set_tranmission_lamp_shutter_state(this,0)
            set_tranmission_lamp_power(this,currentState)
            
            %test objective stage
            set_objective_stage_z_position_micron(this,1)
            set_objective_stage_z_position_micron(this,3000)
            set_objective_stage_z_position_micron(this,1)
            
            %test objective revolver
            currentPos = get_objective_revolver_position(this);
            for pos = [0 2 3 4];
                if not(pos == currentPos)
                    set_objective_revolver_position(this,pos)
                end %if
            end %for
            set_objective_revolver_position(this,currentPos)
            
            %test filter revolver
            currentPos = get_filter_revolver_position(this);
            for pos = [0 5];
                if not(pos == currentPos)
                    set_filter_revolver_position(this,pos)
                end %if
            end %for
            set_filter_revolver_position(this,currentPos)
            
            %test light path
            currentState = get_light_path_state(this);
            if (currentState == 0)
                set_light_path_state(this,1)
            elseif (currentState == 1)
                set_light_path_state(this,0)
            end %if
            set_light_path_state(this,currentState)
        end %fun       
        function optimize_exposure(this,mode)
            actExpTime = get_exposure_time(this);
            img = get_actual_image(this);
            
            switch mode
                case {'max','Max'}
                    pxMax = max(max(medfilt2(img,[2 2]))); %to ignore hot pixels (sCMOS)
                    if pxMax == this.PxSatThresh %-> reduce exposure time
                        %get reduction factor for pixel saturation
                        pxSatExpRedFac = min(0.9,this.PxSatExpRedFac); %at least <90% of actual exposure
                        set_exposure_time(this,actExpTime*pxSatExpRedFac)
                    else %-> increase exposure time
                        facSaturation = this.PxSatThresh/pxMax;
                        facExpTimeInc = 0.5*facSaturation;
                        set_exposure_time(this,min(2000,actExpTime*facExpTimeInc))
                        fprintf('Exposure Time set to: %.3fms\n',get_exposure_time(this))
                    end %if
            end %switch
        end %fun        
        function R = set_stage_path(this,dx,dy,r)
            x0 = 60895-r;
            xend = 60895+r;
            
            y0 = 41333-r;
            yend = 41333+r;
            
            [X,Y] = meshgrid(x0:dx:xend,y0:dy:yend);
            Y(:,2:2:end) = flipud(Y(:,2:2:end));
            
            dr = sqrt((X-60895).^2+(Y-41333).^2);
            X(dr>r) = nan;
            Y(dr>r) = nan;
            R = [X(:) Y(:)];
            R(isnan(R(:,1)),:) = [];
        end       
        function scan_coverslip(this, stage_path)
            set_tranmission_lamp_power(this,1)
            set_tranmission_lamp_shutter_state(this,1)
            set_light_path_state(this,1)
            
            set_pixel_binning(this,2)
            set_exposure_time(this,100)
            
            set_xy_pos_micron(this,[60895 41333])
            
            filename = strcat(datestr(now, 'yymmdd_HHMMSS'),'.tif');
            
            metadata = create_minimal_OME_XML_metadata(...
                [638,638,size(stage_path,1) 1 1], ...
                'uint16','dimensionOrder','XYTCZ');
            objImgWriter = bfsave_initialize(filename,metadata,'BigTiff', true);
            
            for i = 1:size(stage_path,1)
                set_xy_pos_micron(this,stage_path(i,:))
                pause(0.5)
                img = get_actual_image(this);
                imagesc(img);axis image;colormap gray;drawnow
                bfsave_append_plane(objImgWriter,uint16(img(195:832,193:830)),i)
            end
            objImgWriter.close();
            set_xy_pos_micron(this,[60895 41333])
        end
        %% fluorescence channel evalation
        function [thetaD, centroyd] = seek_pattern_orientation(this, img)
            
            % make sure image is in double format
            img = im2double(img);
            
            % scale image values to 0 to 1
            img = img-min(min(img));
            img = img/max(max(img));
            
            dims = size(img);
            
            % pixels are grouped into 3 groups to account for high
            % intensity values, lighter areas where the cell is located,
            % and the dark areas
            threshInt = multithresh(img,2);
            img_bw = im2bw(img, max(threshInt));
            
            % median filter the images for noise removal
            img_bw = medfilt2(img_bw, [3 3]);
            
            % structure elements used in dilation and erosion
            se90 = strel('line', 3, 90);
            se0 = strel('line', 3, 0);
            seD = strel('diamond', 1);
            
            % dilate, fill, and erode image for a solid shape            
            img_bw_D = imdilate(img_bw, [se90, se0]);
            img_bw_F = imfill(img_bw_D, 'holes');
            bw_F = imerode(img_bw_F, seD);
            bw_F = imerode(bw_F, seD);
            
            % regionprops obtained in order to fit ellipse to largest
            % structure and use orientation of the ellipse for approximation
            % of orientation of the pattern
            
            cc = bwconncomp(bw_F);
            labeled = labelmatrix(cc);
            
            s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
                    'MinorAxisLength', 'Eccentricity', 'Centroid');
                                   
            thetaD = s(cell2mat({s.MajorAxisLength}) == ...
                           max(cell2mat({s.MajorAxisLength}))).Orientation;
            centroyd = s(cell2mat({s.MajorAxisLength}) == ...
                           max(cell2mat({s.MajorAxisLength}))).Centroid;
                       
        end       
        function pattern_temp = floures_pattern_gen(this, str_with, sp_with, img_dims,numstrps, thetaD)
           % generates pattern for convolution with image - may not be
           % necessary in updated algorithm depending on timing issues
            
            pattern_temp = [];

            space_temp = zeros( img_dims(1), sp_widt );
            strip_temp = ones( img_dims(1), str_widt );

            for i=1:numstrps
                pattern_temp = [pattern_temp, space_temp, strip_temp];
            end
    
            pattern_temp = [pattern_temp, space_temp];
            pattern_temp = imrotate(pattern_temp, thetaD);
                 
        end       
        function newLine = create_line(this, img, thetaD, centroyd, shft)
           % this function accepts an angle, thetaD (as determined by the 
           % seek_pattern function), a point that the line goes through, 
           % centroyd, and the space between the center of adjacent 
           % stripes, centdist, and returns the valid stripe locations 
           % along these lines. If the center line is desired, shft should 
           % be 0. Otherwise, the shft variable can be used to generate a 
           % line that is shifted along the line perpindicular to the 
           % center line
            
           % slope of line determined by the angle thetaD
            slop = -tand(thetaD);
    
            b = centroyd(2)-slop.*centroyd(1);

            x=1:.002:size(img,2);
            y = slop*x+b;
            
            rnded = [round(x); round(y)]';
            datapts = unique(rnded, 'rows');
            
            if (shft ~= 0)
                thetaD_p = -(90-thetaD);
                theta_shft = 90-thetaD_p;
                shftX = sind(theta_shft)*shft;
                shftY = cosd(theta_shft)*shft;
                
                if(sign(thetaD_p) == -1)
                    shftY = -shftY;                    
                end
                
                inds1 = datapts(:,1) + shftX;
                inds2 = datapts(:,2) + shftY; 
            else
                inds1 = datapts(:,1);
                inds2 = datapts(:,2);            
            end
            
            inds1(inds1<1) = 0;
            inds2(inds2<1) = 0;

            inds1((inds1>size(img,2)),:) = 0;
            inds2((inds2>size(img,1)),:) = 0;

            rowNums = [find(inds1==0); find(inds2==0)]';
            rowNums = sort(unique(rowNums));
            
            datapts = [inds1, inds2];
            datapts(rowNums,:) = [];
            
            newLine = datapts;            
            
        end
        function [thresh, intVals_cell] = global_thresh_calc(this, img_sm, linez)
            % this function gathers the intensity values for the lines
            % determined by newLine. img_sm should be the smoothed image,
            % linez should be a cell matrix with each element containing
            % the x and y coordinates for a line. intVals_cell is a cell
            % matrix containing the intensity values for each line as a
            % cell in the matrix
            
            intVals = [];
            intVals_cell = cell(1,numel(linez));
            for i = 1:numel(lineZ)
                temp = zeros(1,size(lineZ{i},1));
                pts = round(lineZ{i});
                for j = 1:length(temp)
                    tempVals(j) = img_sm(pts(j,1), pts(j,2));
                end
                intVals = [intVals; tempVals]; 
            end
            thresh = graythresh(intVals);   
        end
        function [abvThresh, belThresh] = classify_pts(this, img_sm, thresh, intVals_cell, linez)
            % this function separates pixel values along the lines of
            % interest into those above the threshold intensity and those
            % below, returning two cell arrays, each element of which will
            % be the indices for the respective pixels for each line
            
            abvThresh = cell(1,numel(intVals_cell));
            belThresh = cell(1,numel(intVals_cell));
            
            for i = 1:numel(intVals_cell)
                intVals = intVals_cell{i};
                temp_pts = linez{i};
                
%                 abvThresh_inds = find(intVals > thresh);
%                 belThresh_inds = find(intVals >= thresh);
                
                abvThresh{i} = temp_pts((intVals > thresh), :);
                belThresh{i} = temp_pts((intVals >= thresh), :);              
            end
        end
            
    end %methods
    
    methods (Static)
        function MMsetup_javaclasspath(path2MM)
            fileList = getAllFiles(path2MM);
            fileListJarBool = regexp(fileList,'.jar$','end');
            fileListJarBool = cellfun(@isempty,fileListJarBool);
            fileListJar = fileList(~fileListJarBool);
            javaclasspath(fileListJar) %CPR
            %             fid = fopen(fullfileListJarfile(prefdir,'MMjavaclasspath.txt'),'w');
            %             cellfun(@(x) fprintf(fid,'%s\r\n',x), fileListJar);
            %             fclose(fid);
            %% nested directory listing ala gnovice from stackoverflow
            % inputs and outputs are self-explanatory
            function fileList = getAllFiles(dirName)
                dirData = dir(dirName);      % Get the data for the current directory
                dirIndex = [dirData.isdir];  % Find the index for directories
                fileList = {dirData(~dirIndex).name}';  % Get a list of the files
                if ~isempty(fileList)
                    fileList = cellfun(@(x) fullfile(dirName,x),fileList,'UniformOutput',false);
                end
                subDirs = {dirData(dirIndex).name};  % Get a list of the subdirectories
                validIndex = ~ismember(subDirs,{'.','..'});  % Find index of subdirectories
                %   that are not '.' or '..'
                for iDir = find(validIndex)                  % Loop over valid subdirectories
                    nextDir = fullfile(dirName,subDirs{iDir});    % Get the subdirectory path
                    fileList = vertcat(fileList, getAllFiles(nextDir));  % Recursively call getAllFiles
                end
            end %fun
        end %fun
    end %methods
end %classdef