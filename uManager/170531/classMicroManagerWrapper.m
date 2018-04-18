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
        Laser
        CleanupFilter
        LocationClassifier
        
        ScreenShot
        
        JavaRobot
        MicManPath = 'C:\Program Files\Micro-Manager-1.4';
        Profile = 'Roboscope.cfg';
    end %properties
    properties(Access=private)
        PhysPxSize = 6.5; %[µm] sCMOS Hamamatsu ORCA Flash
        
        StageMinLimit = 5; %[µm]
        StageMaxLimit = 5000; %[µm]
        PiezoMinLimit = 0;
        PiezoMaxLimit = 99; %[µm]
        PxSatThresh = 2^16;
        PxSatExpRedFac = 0.5;
        
        XYStageCtr; %(x,y) [µm]
        XYStageMaxRadius = 1250; %[µm]
        
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
        
        AutoFocusOffsetMinLimit = 0;
        AutoFocusOffsetMaxLimit = 2000;
    end %properties
    properties(Access=private,Transient)
        FatalError = false; %checked before each critical step and set in case of mis-behaviour
    end %properties
    
    methods
        %% constructor
        function this = classMicroManagerWrapper
            import_java(this)
            
            import java.awt.Robot;
            this.JavaRobot = Robot;
            this.JavaRobot.delay(0)
            this.JavaRobot.setAutoDelay(0)
            this.JavaRobot.setAutoWaitForIdle(1)
            
            this.ScreenShot = ScreenHandler;
        end %fun
        function import_java(this)
            if not(exist(this.MicManPath,'dir') == 7)
                this.MicManPath = uigetdir;
            end %if
            classMicroManagerWrapper.MMsetup_javaclasspath(this.MicManPath)
        end %fun
        
        function initialize_micro_manager(this,mode)
            fprintf('\nPLEASE WAIT...\n')
            
            if nargin == 1
                mode = '';
            end %if
            
            switch mode
                case 'GUI'
                    import org.micromanager.*;
                    pause(1)
                    
                    this.GuiAPI = MMStudioMainFrame(0);
                    this.GuiAPI.show;
                otherwise
                    get_coreAPI(this)
                    profile = fullfile(this.MicManPath,this.Profile);
                    this.CoreAPI.loadSystemConfiguration(profile);
                    pause(1)
                    fprintf('\n Hardware Profile loaded: %s\n',profile)
                    
                    get_all_hardware(this)
                    
                    %some general settings to start with
                    set_light_path_state(this,1) %set to camera (in case)
                    set_pixel_binning(this,2)
                    set_exposure_time(this,30) %[ms]
                    set_auto_focus_search_range(this,500)
%                     set_piezo_z_position_micron(this,10)
                    
                    this.XYStageCtr = get_xy_pos_micron(this);
                    set_xy_speed(this,[1 1])
                    set_xy_acceleration(this,[0.2 0.2])
                    
                    fprintf('\nREADY...\n')
            end %switch
        end %fun
        
        %% getter
        function get_coreAPI(this)
            if isempty(this.GuiAPI)
                import mmcorej.*;
                pause(1)
                
                this.CoreAPI = CMMCore;
            else
                this.CoreAPI = this.GuiAPI.getCore;
            end %if
        end %fun
        function get_AcqAPI(this)
            if isempty(this.GuiAPI)
                this.AcqAPI = [];
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
        
        %% hardware pointer
        function get_all_hardware(this)
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
            %             try
            get_piezo(this)
            %             catch msg
            %                 fprintf('\n%s\n',msg)
            %             fprintf('\nPiezo Stage not detected.\n')
            %             end %try
        end %fun
        
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
        function get_piezo(this)
            this.Piezo = java.lang.String('NanoScanZ');
        end %fun
        
        %% cellsense interfaces
        function get_cellsense_interface(this)
            %interfaces to cellsense (temp. hack)
            get_TIRF(this)
            get_laser(this)
            get_cleanup_filter(this)
        end %fun
        function get_TIRF(this)
            this.TIRF = classTirfAdjustmentWrapper(this);
            
            %make sure internal state matches
            %             set_fiber_state(this.TIRF,405,...
            %                 get_fiber_state(this.TIRF,405));
            %             set_fiber_position(this.TIRF,405,...
            %                 get_fiber_position(this.TIRF,405))
            %             pause(0.05)
            %
            %             set_fiber_state(this.TIRF,488,...
            %                 get_fiber_state(this.TIRF,488));
            %             set_fiber_position(this.TIRF,488,...
            %                 get_fiber_position(this.TIRF,488))
            %             pause(0.05)
            %
            %             set_fiber_state(this.TIRF,561,...
            %                 get_fiber_state(this.TIRF,561));
            %             set_fiber_position(this.TIRF,561,...
            %                 get_fiber_position(this.TIRF,561))
            %             pause(0.05)
            %
            %             set_fiber_state(this.TIRF,640,...
            %                 get_fiber_state(this.TIRF,640));
            %             set_fiber_position(this.TIRF,640,...
            %                 get_fiber_position(this.TIRF,640))
            %             pause(0.05)
        end %fun
        function get_laser(this)
            this.Laser = classLaserControlWrapper(this);
            
            %make sure internal state matches
%             set_laser_power(this.Laser,405,...
%                 get_laser_power(this.Laser,405))
%             pause(0.05)
%             
%             set_laser_power(this.Laser,488,...
%                 get_laser_power(this.Laser,488))
%             pause(0.05)
%             
%             set_laser_power(this.Laser,561,...
%                 get_laser_power(this.Laser,561))
%             pause(0.05)
%             
%             set_laser_power(this.Laser,640,...
%                 get_laser_power(this.Laser,640))
%             pause(0.05)
        end %fun
        function get_cleanup_filter(this)
            this.CleanupFilter = classCleanupFilterWrapper(this);
            
            %make sure internal state matches
%             set_cleanup_filter_set(this.CleanupFilter,...
%                 get_cleanup_filter_set(this.CleanupFilter))
%             pause(0.05)
        end %fun
        
        %% hardware configuration
        function binning = get_pixel_binning(this)
            switch char(this.CoreAPI.getProperty(this.Camera,'Binning'))
                case '1x1'
                    binning = 1;
                case '2x2'
                    binning = 2;
                case '4x4'
                    binning = 4;
            end %switch
        end %fun
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
        function pxSize = get_img_px_size(this)
            switch get_objective_revolver_position(this)
                case 0
                    magnification = 20;
                case 2
                    magnification = 60;
                case 3
                    magnification = 100;
                case 4
                    magnification = 150;
            end %switch
            
            binningFac = get_pixel_binning(this);
            
            pxSize = this.PhysPxSize/magnification*binningFac; %[µm]
        end %fun
        
        function ROI = get_camera_ROI(this)
            javaROI = this.CoreAPI.getROI;
            
            i0 = getY(javaROI);
            j0 = getX(javaROI);
            imgHeigth = getHeight(javaROI);
            imgWidth = getWidth(javaROI);
            
            ROI = [i0 j0 imgWidth imgHeigth];
        end %fun
        function set_camera_ROI(this,ROI)
            this.CoreAPI.setROI(ROI(1),ROI(2),ROI(3),ROI(4))
        end %fun
        
        function exposureTimeMs = get_exposure_time(this)
            exposureTimeMs = this.CoreAPI.getExposure;
            %             exposureTimeMs = this.CoreAPI.getProperty(this.Camera,'Exposure');
        end %fun
        function set_exposure_time(this,exposureTimeMs) %[ms]
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
        
        function set_olympus_hub_control(this,mode) %(0 -> only computer & 1 -> computer + manual)
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
        
        function zPosition = get_objective_stage_z_position(this)
            zPosition = this.CoreAPI.getPosition(this.ObjectiveStage);
        end %fun
        function set_objective_stage_z_position_micron(this,zPosMicron)
            zPosMicron = min(this.StageMaxLimit,...
                max(this.StageMinLimit,zPosMicron));
            
            this.CoreAPI.setPosition(this.ObjectiveStage,zPosMicron)
            this.CoreAPI.waitForDevice(this.ObjectiveStage)
        end %fun
        
        %------- PIEZO
        function zPosition = get_piezo_z_position(this)
            if isempty(this.Piezo)
                zPosition = [];
            else
                zPosition = this.CoreAPI.getPosition(this.Piezo);
            end %if
        end %fun
        function set_piezo_z_position_micron(this,zPosMicron)
            %             if get_auto_focus_state(this) == 1
            %                 %the auto focus will block any input, so we switch it off
            %                 set_auto_focus_state(this,0)
            %             end %fun
            
            zPosMicron = min(this.PiezoMaxLimit,max(this.PiezoMinLimit,zPosMicron));
            this.CoreAPI.setPosition(this.Piezo,zPosMicron)
            this.CoreAPI.waitForDevice(this.Piezo)
        end %fun
        
        %------- OBJECTIVE
        function pos = get_objective_revolver_position(this)
            pos = this.CoreAPI.getState(this.ObjectiveRevolver);
        end %fun
        function set_objective_revolver_position(this,pos) %(0 ==> 20x & 2 ==> 60x & 3 ==> 100x & 4 ==> 150x)
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
            
            if pos == get_objective_revolver_position(this)
                %no change in current position
                return
            end %if
            
            %check that objective is in the lowest position before changing
            set_objective_stage_z_position_micron(this,this.StageMinLimit)
            
            if get_objective_stage_z_position(this) == this.StageMinLimit
                this.CoreAPI.setState(this.ObjectiveRevolver,pos)
                this.CoreAPI.waitForDevice(this.ObjectiveRevolver);
                
                switch pos
                    case 2
                        set_auto_focus_objective(this,60)
                    case [3,4]
                        set_auto_focus_objective(this,100)
                end %switch
            else
                fprintf('\nError: Objective could not be moved into safe position at %.2f\n',this.StageMinLimit)
            end %if
        end %fun
        
        %------- TRANSMISSION LAMP
        function state = get_transmission_lamp_power(this)
            % 1 ==> lamp is on
            state = this.CoreAPI.getState(this.TransmissionLamp);
        end %fun
        function state = get_transmission_lamp_shutter_state(this)
            % 1 ==> shutter open
            state = this.CoreAPI.getProperty(this.TransmissionLampShutter,'State');
        end %fun
        function voltage = get_transmission_lamp_voltage(this)
            voltage = this.CoreAPI.getProperty(this.TransmissionLamp,'Voltage');
            %convert to MATLAB double
            voltage = double(java.lang.Double(voltage));
        end %fun
        function state = get_transmission_lamp_auto_shutter_state(this)
            % 1 ==> auto shutter ON
            state = this.CoreAPI.getProperty(this.Core,'AutoShutter');
        end %fun
        
        function set_transmission_lamp_power(this,state) % 1 ==> lamp is on
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Transmission Lamp OFF \n1 ==> Transmission Lamp ON\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Transmission Lamp: OFF\n')
            elseif (state == 1)
                fprintf('\n Transmission Lamp: ON\n')
            end %if
            
            if state == get_transmission_lamp_power(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> lamp is on
            this.CoreAPI.setState(this.TransmissionLamp,state)
            this.CoreAPI.waitForDevice(this.TransmissionLamp);
        end %fun
        function set_transmission_lamp_shutter_state(this,state) % 1 ==> shutter open
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Transmission Lamp Shutter CLOSED \n1 ==> Transmission Lamp Shutter OPEN\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Transmission Lamp Shutter: CLOSED\n')
            elseif (state == 1)
                fprintf('\n Transmission Lamp Shutter: OPEN\n')
            end %if
            
            if state == get_transmission_lamp_shutter_state(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> shutter open
            this.CoreAPI.setProperty(this.TransmissionLampShutter,'State',state)
        end %fun
        function set_transmission_lamp_voltage(this,voltage) %[V]
            if not(isscalar(voltage) & isnumeric(voltage))
                fprintf('\nExpected Input: \n%0.1f <= Brightness [V] <= %0.1f\n',...
                    this.TransmissionLampMinVoltage,this.TransmissionLampMaxVoltage)
                return
            end %if
            
            voltage = min(this.TransmissionLampMaxVoltage,...
                max(this.TransmissionLampMinVoltage,voltage));
            
            fprintf('\n Transmission Lamp Brightness: %.1f V\n',voltage)
            
            if voltage == get_transmission_lamp_voltage(this)
                %no change in current state
                return
            end %if
            
            %convert to JAVA string
            voltage = java.lang.String(num2str(voltage,'%.1f'));
            this.CoreAPI.setProperty(this.TransmissionLamp,'Voltage',voltage)
            this.CoreAPI.waitForDevice(this.TransmissionLamp);
        end %fun
        function set_transmission_lamp_auto_shutter(this,state) % 1 ==> auto shutter ON
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
            
            if state == get_transmission_lamp_auto_shutter_state(this)
                %no change in current state
                return
            end %if
            
            % 1 ==> auto shutter ON
            this.CoreAPI.setProperty(this.Core,'AutoShutter',state)
        end %fun
        
        %------- LIGHT PATH
        function state = get_light_path_state(this)
            % 0 ==> Ocular
            % 1 ==> camera
            state = this.CoreAPI.getState(this.LightPath);
        end %fun
        function set_light_path_state(this,state) %(0 ==> Ocular & 1 ==> camera)
            %parse input
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Ocular \n1 ==> Camera\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Light Path: Ocular\n')
            elseif (state == 2)
                fprintf('\n Light Path: Camera\n')
            end %if
            
            if state == get_light_path_state(this)
                %no change in current state
                return
            end %if
            
            % 0 ==> Ocular
            % 1 ==> camera
            this.CoreAPI.setState(this.LightPath,state)
            this.CoreAPI.waitForDevice(this.LightPath);
        end %fun
        
        %------- DICHROID
        function pos = get_filter_revolver_position(this)
            pos = this.CoreAPI.getState(this.FilterRevolver);
        end %fun
        function set_filter_revolver_position(this,pos) %(0 ==> 405/488/561/642 & 5 ==> DIC)
            if gui_running(this)
                if gui_live_mode(this)
                    if get_transmission_lamp_power(this) && ...
                            get_transmission_lamp_shutter_state(this)
                        %switch off lamp
                        set_transmission_lamp_shutter_state(this,0)
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
            
            if (pos == 0)
                fprintf('\n Filter Cube: 405/488/561/642\n')
            elseif (pos == 5)
                fprintf('\n Filter Cube: DIC\n')
            end %if
            
            if pos == get_filter_revolver_position(this)
                %no change in current position
                return
            end %if
            
            this.CoreAPI.setState(this.FilterRevolver,pos)
            this.CoreAPI.waitForDevice(this.FilterRevolver);
        end %fun
        
        %------- X-Y-STAGE
        function xyStageCtr = get_central_xy_pos(this)
            xyStageCtr = this.XYStageCtr;
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
        
        function set_central_xy_pos(this)
            this.XYStageCtr = get_xy_pos_micron(this);
        end %fun
        function set_xy_pos_micron(this,xyPosMicron) %[µm] (x,y)
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
            set_xy_pos_micron(this,xyPosMicron)
        end %fun
        function set_xy_speed(this,xySpeed) %[mm/s]
            %[xSpeed ySpeed] in mm/s
            xySpeed = [min(this.XYStageMaxSpeed,max(this.XYStageMinSpeed,xySpeed(1))) ...
                min(this.XYStageMaxSpeed,max(this.XYStageMinSpeed,xySpeed(2)))];
            
            this.CoreAPI.setProperty(this.XYStage,'SpeedX [mm/s]',xySpeed(1))
            this.CoreAPI.setProperty(this.XYStage,'SpeedY [mm/s]',xySpeed(2))
            
            fprintf('\nXY-Stage Speed: \nx = %.3f [mm/s]\ny = %.3f [mm/s]\n',...
                xySpeed(1),xySpeed(2))
        end %fun
        function set_xy_acceleration(this,xyAcceleration) %[m/s^2]
            %[xSpeed ySpeed] in m/s^2
            xyAcceleration = [min(this.XYStageMaxAcceleration,max(this.XYStageMinAcceleration,xyAcceleration(1))) ...
                min(this.XYStageMaxAcceleration,max(this.XYStageMinAcceleration,xyAcceleration(2)))];
            
            this.CoreAPI.setProperty(this.XYStage,'Acceleration X [m/s^2]',xyAcceleration(1))
            this.CoreAPI.setProperty(this.XYStage,'Acceleration Y [m/s^2]',xyAcceleration(2))
            
            fprintf('\nXY-Stage Acceleration: \nx = %.3f [m/s^2]\ny = %.3f [m/s^2]\n',...
                xyAcceleration(1),xyAcceleration(2))
        end %fun
        
        %------- AUTO-FOCUS
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
        function offset = get_auto_focus_offset(this)
            offset = this.CoreAPI.getProperty(this.AutoFocus,'Offset');
            %convert to MATLAB
            offset = str2double(char(offset));
        end %fun
        
        function set_auto_focus_state(this,state)
            if islogical(state)
                state = double(state);
            elseif (state == 0) || (state == 1)
            else
                fprintf('\nExpected Input: \n0 ==> Auto Focus OFF \n1 ==> Auto Focus ON\n')
                return
            end %if
            
            if (state == 0)
                fprintf('\n Auto Focus: OFF\n')
            elseif (state == 1)
                fprintf('\n Auto Focus: ON\n')
            end %if
            
            if state == get_auto_focus_state(this)
                %no change in current state
                return
            end %if
            
            switch state
                case 0
                    this.CoreAPI.setProperty(this.AutoFocus,...
                        'ContinuousMode',java.lang.String('Off'));
                case 1
                    this.CoreAPI.setProperty(this.AutoFocus,...
                        'ContinuousMode',java.lang.String('On'));
            end %switch
            this.CoreAPI.waitForDevice(this.AutoFocus);
            %wait some seconds so the autofocus can stabilize
            pause(1)
            
            if state == 1 && get_auto_focus_state(this) == 0
                fprintf('\n Auto Focus could not be determined.\n')
            end %if
        end %fun
        function set_auto_focus_objective(this,objective)
            if not(isscalar(objective) & isnumeric(objective))
                fprintf('\nExpected Input: \n100 ==> 100x Objective\n')
                return
            end %if
            
            switch objective
                case 60
                    objective = java.lang.String('ApoN60XOTIRF');
                    fprintf('\n Auto Focus Objective: ApoN60XOTIRF\n')
                case 100
                    objective = java.lang.String('UApoN100XOTIRF');
                    fprintf('\n Auto Focus Objective: UApoN100XOTIRF\n')
                otherwise
                    fprintf('\nAuto Focus Objective: Unexpected Input\n')
                    return
            end %switch
            
            if objective == get_auto_focus_objective(this)
                %no change in current state
                return
            end %if
            
            this.CoreAPI.setProperty(this.AutoFocus,'ObjectiveTypeSetting',objective);
            this.CoreAPI.waitForDevice(this.AutoFocus)
        end %fun
        function set_auto_focus_search_range(this,range)
            if not(isscalar(range) & isnumeric(range))
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
            range = java.lang.String(num2str(range,'%.1f'));
            
            this.CoreAPI.setProperty(this.AutoFocus,'SearchRange',range);
            this.CoreAPI.waitForDevice(this.AutoFocus)
        end %fun
        function set_auto_focus_offset(this,offset)
            if not(isscalar(offset) & isnumeric(offset))
                fprintf('\nExpected Input: \n%0.1f <= Range [AU] <= %0.1f\n',...
                    this.AutoFocusOffsetMinLimit,this.AutoFocusOffsetMaxLimit)
                return
            end %if
            
            %check limits
            offset = min(this.AutoFocusOffsetMaxLimit,...
                max(this.AutoFocusOffsetMinLimit,offset));
            
            fprintf('\n Auto Focus Offset: %.1f AU\n',offset)
            
            if offset == get_auto_focus_offset(this)
                %no change in current state
                return
            end %if
            
            %convert to JAVA
            offset = java.lang.String(num2str(offset,'%.1f'));
            
            this.CoreAPI.setProperty(this.AutoFocus,'Offset',offset);
            this.CoreAPI.waitForDevice(this.AutoFocus)
        end %fun
        
        function meta = get_acq_meta(this)
            meta = struct(...
                'Time',datevec(now),...
                'ExposureTime',get_exposure_time(this),...
                'CameraROI',get_camera_ROI(this),...
                'PixelBinning',get_pixel_binning(this),...
                'PixelSize',get_img_px_size(this),...
                'PositionXY',get_xy_pos_micron(this),...
                'StageZ',get_objective_stage_z_position(this),...
                'StateZDC',get_auto_focus_state(this),...
                'OffsetZDC',get_auto_focus_offset(this));
%             meta = struct(...
%                 'Time',datevec(now),...
%                 'ExposureTime',get_exposure_time(this),...
%                 'CameraROI',get_camera_ROI(this),...
%                 'PixelBinning',get_pixel_binning(this),...
%                 'PixelSize',get_img_px_size(this),...
%                 'PositionXY',get_xy_pos_micron(this),...
%                 'StageZ',get_objective_stage_z_position(this),...
%                 'StateZDC',get_auto_focus_state(this),...
%                 'OffsetZDC',get_auto_focus_offset(this),...
%                 'PiezoZ',get_piezo_z_position(this),...
%                 'StateTIRF',get_fiber_state(this.TIRF),...
%                 'PosTIRF',get_fiber_position(this.TIRF),...
%                 'StateLaser',get_laser_state(this.Laser),...
%                 'PowerLaser',get_laser_power(this.Laser));
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
        
        %%
        function [img,meta] = snap_img(this)
            this.CoreAPI.snapImage();
            img = double(this.CoreAPI.getImage());
            idxUnderflow = img < 0;
            if any(idxUnderflow(:))
                img(idxUnderflow) = img(idxUnderflow) + 2^16;
                disp('Camera over-saturated')
            end %if
            imgWidth = this.CoreAPI.getImageWidth();
            imgHeight = this.CoreAPI.getImageHeight();
            img = reshape(img,imgWidth,imgHeight);
            img = transpose(img);
            
            if nargout == 2 %generates meta information if requested by caller
                meta = get_acq_meta(this);
            end %if
        end %fun
        
        %------ Rectangular scanning
        function [x,y,bad] = set_rectangular_path(this,numX,numY)
            %calculate stepsize to produce no overlap
            pxSize = get_img_px_size(this); %[µm]
            imgWidth = this.CoreAPI.getImageWidth()*pxSize;
            imgHeight = this.CoreAPI.getImageHeight()*pxSize;
            
            totalHeight = numY*imgHeight;
            totalWidth = numX*imgWidth;
            
            [X,Y] = meshgrid(...
                (-totalWidth/2+imgWidth/2:imgWidth:totalWidth/2-imgWidth/2)+this.XYStageCtr(1),...
                (-totalHeight/2+imgHeight/2:imgHeight:totalHeight/2-imgHeight/2)+this.XYStageCtr(2));
            Y(:,2:2:end) = flipud(Y(:,2:2:end));
            x = X(:);
            y = Y(:);
            
            %check that the stage does not leave the safety region
            dr = sqrt((X-this.XYStageCtr(1)).^2+(Y-this.XYStageCtr(2)).^2);
            bad = (dr > this.XYStageMaxRadius);
            x(bad) = [];
            y(bad) = [];
        end %fun
        
        function [img,x,y,img_] = acq_rectangular_path_DIC(this,numX,numY)
            [x,y,bad] = set_rectangular_path(this,numX,numY); %[µm] generates the path coordinates using non-overlapping steps
            img_ = acq_path_DIC(this,x,y); %acqures images along the path
            
            if any(bad(:)) %in case of non-rectangular path
                img = cell(numel(bad),1);
                img(not(bad(:))) = img_;
                img(bad(:)) = {zeros(this.CoreAPI.getImageHeight(),...
                    this.CoreAPI.getImageWidth())};
            else
                img = img_;
            end %if
            
            imgCol = cell(1,numX);
            for j = 1:numX
                if rem(j,2) %odd
                    imgCol{1,j} = vertcat(img{(1:numY)+(j-1)*numX});
                else
                    imgCol{1,j} = vertcat(img{(numY:-1:1)+(j-1)*numX});
                end %if
            end %for
            img = horzcat(imgCol{:});
        end %fun
        function [img,meta] = acq_path_DIC(this,x,y)
%             set_laser_state(this.Laser,405,0); %switch off laser
%             pause(0.05)
%             set_laser_state(this.Laser,488,0); %switch off laser
%             pause(0.05)
%             set_laser_state(this.Laser,561,0); %switch off laser
%             pause(0.05)
%             set_laser_state(this.Laser,640,0); %switch off laser
%             pause(0.05)
            
            set_filter_revolver_position(this,5) %put analysator (2nd polarizer)
            %             set_transmission_lamp_shutter_state(this,1) %open bright-field lamp shutter (in case)
            
            %%
            hImg = [];
            numFrame = numel(x);
            img = cell(numFrame,1);
            for idxPos = 1:numFrame
                set_xy_pos_micron(this,[x(idxPos) y(idxPos)]) %move stage
                pause(0.1) %delay for the auto-focus to adapt
                
                [img{idxPos,1},meta(idxPos,1)] = snap_img_DIC(this); %acquire image
                
                [hImg,~,hFig] = classMicroManagerWrapper.live_acquisition(img{idxPos,1},hImg);
                sprintf('Acquisition: %d/%d',idxPos,numFrame)
            end %for
            close(hFig)
            %%
            %             set_transmission_lamp_shutter_state(this,0) %close bright-field lamp shutter (in case)
        end %fun
        function [img,meta] = snap_img_DIC(this)
            set_cleanup_filter_set(this.CleanupFilter,5) %remove any cleanup filter
            set_transmission_lamp_shutter_state(this,1)
            
            [img,meta] = snap_img(this);
            
            set_transmission_lamp_shutter_state(this,0)
        end %fun
        
        function [img,x,y,img_] = acq_rectangular_path_fluorescense(this,numX,numY,laser)
            [x,y,bad] = set_rectangular_path(this,numX,numY); %[µm] generates the path coordinates using non-overlapping steps
            img_ = acq_path_fluorescense(this,x,y,laser); %acqures images along the path
            
            if any(bad(:)) %in case of non-rectangular path
                img = cell(numel(bad),1);
                img(not(bad(:))) = img_;
                img(bad(:)) = {zeros(this.CoreAPI.getImageHeight(),...
                    this.CoreAPI.getImageWidth())};
            else
                img = img_;
            end %if
            
            imgCol = cell(1,numX);
            for j = 1:numX
                if rem(j,2) %odd
                    imgCol{1,j} = vertcat(img{(1:numY)+(j-1)*numX});
                else
                    imgCol{1,j} = vertcat(img{(numY:-1:1)+(j-1)*numX});
                end %if
            end %for
            img = horzcat(imgCol{:});
        end %fun
        function [img,meta] = acq_path_fluorescense(this,x,y,laser)
            set_transmission_lamp_shutter_state(this,0) %close bright-field lamp shutter (in case)
            set_filter_revolver_position(this,0) %put 405/488/561/640 dichroic (Schweizer Käse)
            
            %%
            hImg = [];
            numFrame = numel(x);
            img = cell(numFrame,1);
            for idxPos = 1:numFrame
                set_xy_pos_micron(this,[x(idxPos) y(idxPos)]) %move stage
                pause(0.5) %delay for the auto-focus to adapt
                
                [img{idxPos,1},meta(idxPos,1)] = snap_img_fluorescence(this,laser); %acquire image
                
                [hImg,~,hFig] = classMicroManagerWrapper.live_acquisition(img{idxPos,1},hImg);
                sprintf('Acquisition: %d/%d',idxPos,numFrame)
            end %for
            close(hFig)
        end %fun
        function [img,meta] = snap_img_fluorescence(this,laser)
            set_cleanup_filter_set(this.CleanupFilter,laser) %put respective cleanup filter
            set_laser_state(this.Laser,laser,1); %switch on laser
            
            [img,meta] = snap_img(this);
            
            set_laser_state(this.Laser,laser,0); %switch on laser
            %             set_cleanup_filter_set(this.CleanupFilter,5) %remove any cleanup filter
        end %fun
        
        function imgStack = acq_mov_fluorescence(this,laser,numFrame,deadTime)
            if nargin == 3
                deadTime = 0; %[ms] continuous acquisition
            end %if
            
            %allocate memory
            imgHeight = this.CoreAPI.getImageHeight();
            imgWidth = this.CoreAPI.getImageWidth();
            
            bufferSize = (numFrame+10)*imgHeight*imgWidth*this.CoreAPI.getBytesPerPixel()*1e-6; %[megabytes]
            this.CoreAPI.setCircularBufferMemoryFootprint(bufferSize)
            
            %%
            set_filter_revolver_position(this,0) %put 405/488/561/640 dichroic (Schweizer Käse)
            set_cleanup_filter_set(this.CleanupFilter,laser) %put respective cleanup filter
            set_laser_state(this.Laser,laser,1); %switch on laser
            
            this.CoreAPI.startSequenceAcquisition(numFrame, deadTime, false);
            pause((numFrame+10)*get_exposure_time(this)/1000)
            
            set_laser_state(this.Laser,laser,0); %switch on laser
            %             set_cleanup_filter_set(this.CleanupFilter,5) %remove any cleanup filter
            
            %%
            imgCnt = numFrame;
            while imgCnt > 0
                %in case acquisition is much faster then stream to hard drive
                %                 if this.CoreAPI.isBufferOverflowed()
                %                     sprintf('Buffer Overflow! Increase Buffer Size.')
                %                     break
                %                 end %if
                imgStack(:,:,imgCnt) = reshape(this.CoreAPI.popNextImage(),imgHeight,imgWidth);
                imgCnt = this.CoreAPI.getRemainingImageCount();
            end %while
            imgStack = imgStack(:,:,numFrame:-1:1);
        end %fun
        
        
        function img = stitch_img(this,img_,bad)
            if any(bad(:)) %in case of non-rectangular path
                img = cell(numel(bad),1);
                img(not(bad(:))) = img_;
                img(bad(:)) = {zeros(this.CoreAPI.getImageHeight(),...
                    this.CoreAPI.getImageWidth())};
            else
                img = img_;
            end %if
            
            [numY,numX] = size(bad);
            imgCol = cell(1,numX);
            for j = 1:numX
                if rem(j,2) %odd
                    imgCol{1,j} = vertcat(img{(1:numY)+(j-1)*numX});
                else
                    imgCol{1,j} = vertcat(img{(numY:-1:1)+(j-1)*numX});
                end %if
            end %for
            img = horzcat(imgCol{:});
        end %fun
        
        
        function prep_acq(this,mode)
            switch mode
                case 'DIC'
                    set_filter_revolver_position(this,5) %put DIC
                    set_cleanup_filter_set(this.CleanupFilter,5) %remove any cleanup filter
                    
                    set_tranmission_lamp_shutter_state(this,1) %open bright-field lamp shutter (in case)
                case {405,488,561,640}
                    laser = mode;
                    set_filter_revolver_position(this,0) %put 405/488/561/640 dichroic (Schweizer Käse)
                    set_cleanup_filter_set(this.CleanupFilter,laser) %put respective cleanup filter
                    
                    set_tranmission_lamp_shutter_state(this,0) %close bright-field lamp shutter (in case)
                otherwise
                    %error
                    disp('Acquisition Mode: "%s" not known.',mode)
                    return
            end %switch
        end %fun
        %%
        
        %% protocols
        function full_hardware_test(this)
            %test transmission lamp
            currentState = get_transmission_lamp_power(this);
            set_transmission_lamp_power(this,1)
            set_transmission_lamp_shutter_state(this,0)
            set_transmission_lamp_voltage(this,6)
            set_transmission_lamp_shutter_state(this,1)
            pause(1)
            set_transmission_lamp_shutter_state(this,0)
            pause(1)
            set_transmission_lamp_shutter_state(this,1)
            pause(1)
            set_transmission_lamp_shutter_state(this,0)
            set_transmission_lamp_power(this,currentState)
            
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
        
        function scan_and_lock_into_auto_focus(this)
            zmin = 4000; %[µm]
            dz = 150; %[µm]
            zmax = this.StageMaxLimit - 0.9*get_auto_focus_search_range(this); %[µm]
            
            z = zmin;
            
            %initialize search at lowest safe position
            set_objective_stage_z_position_micron(this,z)
            while (get_auto_focus_state(this) == false) && ...
                    get_objective_stage_z_position(this) < zmax
                %move objective towards coverslip z µm
                z = min(zmax,z+dz);
                set_objective_stage_z_position_micron(this,z);
                
                %perform search for autofocus
                set_auto_focus_state(this,1)
                %wait some seconds so the autofocus can stabilize
                pause(2)
            end %while
            
            if (get_auto_focus_state(this) == false)
                fprintf('\nAuto-Focus not detectable!\n')
            else
                fprintf('\nAuto-Focus established at %.2f µm\n',...
                    get_objective_stage_z_position(this))
            end %if
        end %fun
        function [img,meta] = adjust_auto_focus_offset_lens(this,laser)
            z0 = 0;
            dz = 50;
            zmax = 1000;
            offset = z0:dz:zmax;
            
            hImg = [];
            for i = 1:numel(offset)
                set_auto_focus_offset(this,offset(i))
                [img(:,:,i),meta(i,1)] = snap_img_fluorescence(this,laser);
                
                [hImg,~,hFig] = classMicroManagerWrapper.live_acquisition(img{idxPos,1},hImg);
                %                 img = snap_img(objMicMan);
                % imagesc(img(512:1024,512:1024))
                %             colorbar
                %             axis image
                %             colormap gray
                %                 imgCorr = ...
                %                     img_norm_circ_auto_corr(double(img(512:1024,512:1024)));
                %                 [RCF,r] = img_radial_avg_corr(imgCorr(1:rMax,1:rMax));
                %% approximate start parameters
                %     [guessOffset,idxMin] = min(RCF);
                %     RCF_ = RCF;
                %     r_ = r;
                %     r_([1 idxMin]) = []; RCF_([1 idxMin]) = [];
                %     RCF_ = log((RCF_-guessOffset)/(max(RCF_)-guessOffset));
                %     m = OLS_fit_linear(-r_.^2,RCF_,0);
                %     guessStd = 1/sqrt(2*m);
                %     guessVolume = (RCF(2)-guessOffset)*sqrt(2*pi)*guessStd;
                %     thetaGuess = [guessVolume,guessStd,guessOffset];
                %%
                %             [thetaEst(i,:)] = ...
                %             OLS_fit_1dim_gaussian(r(2:end),RCF(2:end),thetaGuess,...
                %             'lb',[0 0 0],'ub',[100*guessVolume rMax 1],...
                %             'TolFun',10^-15);
                %%
                %         plot(r(2:end),RCF(2:end),'color',cmap(i,:));
                %                 plot(offset(i),var(RCF(2:end)),'x','color',cmap(i,:));
                %                 set_auto_focus_offset(objMicMan,offset(i))
            end %for
            close(hFig)
            %             set_laser_state(objMicMan.Laser,561,0);
        end %fun
        
        function imgStack = piezo_relative_z_scan(this, rZ, dz)
            z0 = get_piezo_z_position(this);
            
            if z0 - rZ < this.PiezoMinLimit || z0 + rZ > this.PiezoMaxLimit
                fprintf('\nError: Cannot scan whole z-range.\nAdjust absolute piezo z-position\n')
                imgStack = [];
                return
            end %if
            
            z = (z0-rZ):dz:(z0+rZ);
            imgStack = piezo_absolute_z_scan (this,z);
        end %fun
        function imgStack = piezo_absolute_z_scan(this, z)
            %deactivate auto-focus in case
            if (get_auto_focus_state(this) == true)
                set_auto_focus_state(this,0)
            end %if
            
            for i = 1:numel(z)
                set_piezo_z_position_micron(this,z(i))
                imgStack(:,:,i) = snap_img(this);
            end
        end %fun
        
        %%
        function [img,meta] = scan_TIRF_angle(this,fiber,range)
            for i = 1:numel(range)
                set_fiber_position(this.TIRF,fiber,range(i))
                pause(0.2)
                [img(:,:,i),meta(i,1)] = snap_img_fluorescence(this,fiber);
            end
        end %fun
        
        function R = set_stage_path(this,dx,dy,r)
            x0 = this.XYStageCtr(1)-r;
            xend = this.XYStageCtr(1)+r;
            
            y0 = this.XYStageCtr(2)-r;
            yend = this.XYStageCtr(2)+r;
            
            [X,Y] = meshgrid(x0:dx:xend,y0:dy:yend);
            Y(:,2:2:end) = flipud(Y(:,2:2:end));
            
            dr = sqrt((X-this.XYStageCtr(1)).^2+(Y-this.XYStageCtr(2)).^2);
            X(dr>r) = nan;
            Y(dr>r) = nan;
            R = [X(:) Y(:)];
            R(isnan(R(:,1)),:) = [];
        end
        
        function [defocusPsfEst,defocusPsfEstSE] = calibrate_z_PSF(this,z0,dz,z1)
            set_filter_revolver_position(this, 0);
            set_laser_state(this.Laser, 561, 1);
            
            z = z0:dz:z1;
            img = scan_z_PSF_determ(this, z);
            
            set_laser_state(this.Laser, 561, 0);
            
            for i = 1:numel(z)
                [~,thetaEst(i,:)] = PSF_radius_via_auto_corr(double(img(:,:,i)));
            end %for
            
            [defocusPsfEst,defocusPsfEstSE,~,~,~,~,modelFun] = ...
                global_OLS_fit_astig_calib(z',thetaEst(:,2),[min(thetaEst(:,2)) 1 0 0 0],...
                'lb',[0 0 0 0 0],'ub',[max(thetaEst(:,2)) range(z) 10 100 100]);
            
            figure; hold on;
            plot(z,thetaEst(:,2),'k.');
            plot(z,modelFun(defocusPsfEst,z),'r');
        end %fun
        
        function img = scan_z_PSF_determ(this, z)
            for i = 1:numel(z)
                set_piezo_z_position_micron(this,z(i))
                img(:,:,i) = snap_img(this);
            end
        end
        
        function scan_z_DIC_FL(this,z)
            filename1 = strcat(datestr(now, 'yymmdd_HHMMSS'),'_DIC.tif');
            filename2 = strcat(datestr(now, 'yymmdd_HHMMSS'),'_Fluor.tif');
            
            metadata = create_minimal_OME_XML_metadata(...
                [302,294,numel(z) 1 1], ...
                'uint16','dimensionOrder','XYTCZ');
            objImgWriter1 = bfsave_initialize(filename1,metadata);
            objImgWriter2 = bfsave_initialize(filename2,metadata);
            
            for i = 1:numel(z)
                set_piezo_z_position_micron(this,z(i))
                
                set_exposure_time(this,100)
                set_laser_state(this.Laser, 561, 1);
                img_FL = snap_img(this);
                set_laser_state(this.Laser, 561, 0);
                
                set_exposure_time(this,20)
                set_transmission_lamp_shutter_state(this, 1);
                img_DIC = snap_img(this);
                set_transmission_lamp_shutter_state(this, 0);
                
                bfsave_append_plane(objImgWriter1,uint16(img_DIC),i)
                bfsave_append_plane(objImgWriter2,uint16(img_FL),i)
            end %for
            objImgWriter1.close();
            objImgWriter2.close();
        end %fun
        function optimize_exposure(this,mode)
            actExpTime = get_exposure_time(this);
            img = snap_img(this);
            
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
        
        %% visualization
        function show_acquisition(this)
            img = snap_img(this);
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
        
        % live view + manual adjustments
        function live_view(this)
            ROI = get_camera_ROI(this);
            
            hFig = figure; hold on;
            hImg = imagesc(zeros(ROI(4),ROI(3)));
            axis image ij
            colormap gray
            
            while ishandle(hFig)
                img = snap_img(this);
                set(hImg,'cdata',img)
                caxis(quantile(img(:),[0.01 0.999]))
                drawnow
            end %for
        end %fun
        
        %
        function live_auto_focus_offset_adjustment(this)
            ROI = get_camera_ROI(this);
            
            hFig = figure; hold on;
            hImg = imagesc(zeros(ROI(4),ROI(3)));
            axis image ij
            colormap gray
            
            hSlider = uicontrol(...
                'parent'  , hFig,...
                'units'   , 'normalized',...
                'style'   , 'slider',...
                'position', [0 0 1 0.05],...
                'min'     , this.AutoFocusOffsetMinLimit,...
                'max'     , this.AutoFocusOffsetMaxLimit,...
                'value'   , get_auto_focus_offset(this),...
                'callback', @(src,evnt)sliderCallback(this,src));
            handle.listener(hSlider,'ActionEvent',@(src,evnt)sliderCallback(this,src));
            
            while ishandle(hFig)
                img = snap_img(this);
                set(hImg,'cdata',img)
                caxis(quantile(img(:),[0.01 0.999]))
                drawnow
            end %for
        end %fun
        function sliderCallback(this,src)
            offset = get(src,'Value');
            set_auto_focus_offset(this,offset)
        end
        
        function listCoordXY = select_cells_from_overview(this,imgScan,ROI)
            [imgWidth,imgHeight,~] = size(imgScan);
            
            hFig = figure;
            hAx = axes('Parent',hFig);
            image('XData',[1 imgWidth],'YData',[1 imgHeight],'CData',imgScan);
            axis image
            colormap(gray)
            
            %%
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
                        listCoordXY(cnt,:) = [jGuess iGuess]; %[px]
                        
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
            
            %% convert to stage coordinates
            pxSize = get_img_px_size(this); %[µm]
            xyStageCtr = get_central_xy_pos(this);
            listCoordXY = [(listCoordXY(:,1)-imgWidth/2-0.5)*pxSize+xyStageCtr(1), ...
                (listCoordXY(:,2)-imgHeight/2-0.5)*pxSize+xyStageCtr(2)];
        end %fun
    end %methods
    %% image classification methods
    methods
        function scled_img = scale_input(this, inp_img)
            inp_img = im2double(inp_img);
            scled_img = inp_img - min(min(inp_img));
            scled_img = scled_img./max(max(scled_img));
        end
        function imgs_parsed = parse_images(this, inp_img)
            % for now this function is specific to an image composed of 4
            % frames arranged 2x2
            img_cnt = 4;
            
            dims = size(inp_img);
            seg_step = img_cnt/2;
            stepX = round(dims(2)/seg_step);
            stepY = round(dims(1)/seg_step);
            imgs_parsed = cell(1,img_cnt);
            
            imgs_parsed{1} = inp_img(1:stepY, 1:stepX);
            imgs_parsed{2} = inp_img(1:stepY, stepX+1:end);
            imgs_parsed{3} = inp_img(stepY+1:end, 1:stepX);
            imgs_parsed{4} = inp_img(stepY+1:end, stepX+1:end);
            
            % this is used to adjust for one particular dataset
            %            imgs_parsed{1} = inp_img(1:260, 1:260);
            %            imgs_parsed{2} = inp_img(1:260, 260:end);
            %            imgs_parsed{3} = inp_img(261:end, 1:260);
            %            imgs_parsed{4} = inp_img(261:end, 261:end);
            
        end
        function img_2D = img_stack_to_img_2D( img_stack, dims )
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here
            % dims should be a 2D vector in the form of [rows cols] where rows
            % represents the number of images from the stack per row and cols defined
            % similarly. rows*cols should equal the number of images in the stack
            
            numRows = dims(1);
            numCols = dims(2);
            data_type = class( img_stack );
            
            if( length( dims ) ~= 2 )
                error('dims should be a vector of length 2')
            end
            if( dims(1)*dims(2) ~= size( img_stack, 3) )
                error('img dimensions and desired stack dimensions inconsistent.' )
            end
            if( ~isnumeric( img_stack ) && ~islogical( img_stack ) )
                error('img is limited to numeric array due to programmer laziness.')
            end
            img_stack_dims = size( img_stack );
            img_stack_dims = img_stack_dims(1:2);
            
            img2D_dims = [numRows*img_stack_dims(1) numCols*img_stack_dims(2)];
            
            img_2D = zeros( img2D_dims(1), img2D_dims(2), data_type );
            
            tempIDX = 0;
            for i=1:numRows
                for j=1:numCols
                    tempIDX = tempIDX + 1;
                    img_2D( img_stack_dims(1)*(i-1)+1:img_stack_dims(1)*i,...
                        img_stack_dims(2)*(j-1)+1:img_stack_dims(2)*j ) =...
                        img_stack( :,:, tempIDX );
                end
            end
        end
        function [img_stack, orig_idx] = img_2D_to_img_stack( img, dims )
            %img_2D_to_img_stack -
            %   dims should be the size of each individual image that will be planes
            %   in the resulting stack in rows x cols format, orig_idx gives a matrix
            %   with one 2D vector for each image in the resulting image stack. This
            %   vector corresponds to the top left point of the image in the original
            %   2D matrix in [row col] format
            
            img2D_dims = size( img );
            data_type = class( img );
            
            if( length( dims ) ~= 2 )
                error('dims should be a vector of length 2')
            end
            
            if( mod( img2D_dims(1), dims(1)) ~= 0 || mod( img2D_dims(2), dims(2)) )
                error('img dimensions and desired stack dimensions inconsistent.' )
            end
            
            if( ~isnumeric( img ) && ~islogical( img )  )
                error('img is limited to numeric or logical array due to programmer laziness.')
            end
            
            numCols = img2D_dims(1)/dims(1);
            numRows = img2D_dims(2)/dims(2);
            
            orig_idx = zeros( numCols*numRows, 2 );
            
            img_stack = zeros(dims(1), dims(2), numCols*numRows, data_type);
            
            tempIDX = 0;
            for i=1:numRows
                for j=1:numCols
                    tempIDX = tempIDX + 1;
                    img_stack( :,:, tempIDX ) =...
                        img( dims(1)*(i-1)+1:dims(1)*i, dims(2)*(j-1)+1:dims(2)*j );
                    orig_idx( tempIDX, : ) = [dims(1) dims(2)];
                end
            end
        end
        % fluorescence channel evaluation
        function [thetaD, pattern, img_corr] = ...
                est_pattern_orientation( img, bw_img )
            cc = bwconncomp(bw_img);
            
            % s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
            %     'MinorAxisLength', 'Eccentricity', 'Centroid');
            s = regionprops(cc, 'MajorAxisLength');
            k = find(cell2mat({s.MajorAxisLength})==max(cell2mat({s.MajorAxisLength})));
            
            thetaD = s(k).Orientation;
            
            pattern = floures_pattern_gen(25, 30, size(bw_img), 1);
            pattern = imrotate(pattern, -(90-thetaD));
            
            img_corr = conv2( double(img), double(pattern), 'same');
        end
        function pattern_temp =...
                floures_pattern_gen(this, str_with, sp_with, img_dims,numstrps, thetaD)
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
        function [x, resnorm, residual, exitflag] = fit_gaussian_flour( img, bw_img )
            dim = size(img, 1);
            x0 = [1,0,50,0,50];
            lb = [0,-dim/2,0,-dim/2,0];
            ub = [realmax('double'),dim/2,(dim/2)^2,dim/2,(dim/2)^2];
            
            [X,Y] = meshgrid(-dim/2+.5:dim/2-.5);
            
            X = X(:); Y = Y(:); temp_bw = bw_img(:); Z = im2double(img(:));
            
            X(temp_bw==0) = [];
            Y(temp_bw==0) = [];
            Z(temp_bw==0) = [];
            xdata(:,1) = X;
            xdata(:,2) = Y;
            
            [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction,x0,xdata,Z,lb,ub);
        end
        function stripe_bw = ...
                generate_stripe_bw( stripe_centers, thetaD, img_dims, stripe_width  )
            %GENERATE_STRIPE_BW Generated black and white image composed of the
            % a stripe pattern specified by stripe_width and stripe_centers, rotated by
            % thetaD
            %   thetaD should be an angle in degrees, stripe_centers should be x
            %   coordinates (the y coordinate is assumed to be the center of the
            %   image), and stripe_width should be a value in pixels
            
            % adapting for worst-case scenario once rotated - so that the stripe still
            % extends along the entire image
            dim = round( sqrt( img_dims(1)^2 + img_dims(2)^2 ) );
            col_diff = dim - img_dims(2);
            row_diff = dim - img_dims(1);
            % stripe_centers = stripe_centers + col_diff/2;
            
            stripe_template = ones( dim, stripe_width );
            stripe_template = imrotate( stripe_template, -(90-thetaD) );
            stripe_dims = size( stripe_template );
            h_diff = stripe_dims(1) - img_dims(1);
            stripe_template = stripe_template( 1+h_diff/2:end-h_diff/2,:);
            stripe_dims = size( stripe_template );
            stripe_bw = zeros( img_dims );
            center = floor(stripe_dims(2)/2);
            
            for i = 1:length( stripe_centers )
                shift = center-stripe_centers(i);
                stripe_locs = (1:stripe_dims(2))-shift;
                if( min(stripe_locs) < 1 )
                    new_start = find( stripe_locs == 1 );
                    stripe_locs = stripe_locs(new_start:end);
                    stripe_crop = stripe_template(:,new_start:end);
                else
                    stripe_crop = stripe_template;
                end
                if( max(stripe_locs) > size(stripe_bw, 2) )
                    new_end = find( stripe_locs == size(stripe_bw,2) );
                    stripe_locs = stripe_locs(1:new_end);
                    stripe_crop = stripe_crop(:,1:new_end);
                end
                if( length(stripe_locs) ~= size(stripe_crop,2) )
                    error('stripe dimension mismatch')
                end
                stripe_bw(:, stripe_locs) = or( stripe_bw(:,stripe_locs), stripe_crop );
            end
            % stripe_bw = imrotate( stripe_bw, -(90-thetaD) );
            diff = size( stripe_bw ) - img_dims;
            % stripe_bw = imcrop( stripe_bw,...
            %     [1+col_diff/2, 1+row_diff/2, img_dims(2), img_dims(1)] );
            stripe_bw = imcrop( stripe_bw,...
                [1+diff(2)/2, 1+diff(1)/2, img_dims(2), img_dims(1)] );
            
        end
        function loc_max = clean_loc_vec( data, indices, min_dist, phiD  )
            dy_dx = diff(data)./diff(indices);
            zero_cross = diff( sign(dy_dx), 1, 2);
            loc_max = find(zero_cross<0);
            max_vals = data(loc_max);
            dists = diff(loc_max)*sin(phiD);
            cnt = 1;

            while( any( dists < min_dist ) )
                [~,sorted_idx] = sort(max_vals);
                sorted_idx = fliplr(sorted_idx);
                max_idx = sorted_idx(cnt);

                while( max_idx > 1 && dists(max_idx-1)<min_dist )
                    loc_max(max_idx-1) = [];
                    max_idx = max_idx-1;
                    dists = diff(loc_max)*sin(phiD);
                    max_vals = data(loc_max);
                end
                while( max_idx < length(loc_max) && dists(max_idx)<min_dist)
                    loc_max(max_idx+1) = [];
                    dists = diff(loc_max)*sin(phiD);
                    max_vals = data(loc_max);
                end
                cnt = cnt+1;
            end
        end
        % old flourescence functions - can be cleaned and maybe removed
        function newLinez = create_linez(this, img, thetaD, centroyd)
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
            
            inds1 = datapts(:,1);
            inds2 = datapts(:,2);
            
            inds1(inds1<1) = 0;
            inds2(inds2<1) = 0;
            
            inds1((inds1>size(img,2)),:) = 0;
            inds2((inds2>size(img,1)),:) = 0;
            
            rowNums = [find(inds1==0); find(inds2==0)]';
            rowNums = sort(unique(rowNums));
            
            datapts = [inds1, inds2];
            datapts(rowNums,:) = [];
            
            newLinez = datapts;
            
        end
        function [thresh, intVals_cell, intVals] =...
                global_thresh_calc(this, img_sm, linez)
            % this function gathers the intensity values for the lines
            % determined by newLine. img_sm should be the smoothed image,
            % linez should be a cell matrix with each element containing
            % the x and y coordinates for a line. intVals_cell is a cell
            % matrix containing the intensity values for each line as a
            % cell in the matrix
            
            intVals = [];
            intVals_cell = cell(1,numel(linez));
            for i = 1:numel(linez)
                pts = round(linez{i});
                tempVals = zeros(1,size(pts,1));
                
                for j = 1:length(tempVals)
                    tempVals(j) = img_sm(pts(j,2), pts(j,1));
                end
                intVals_cell{i} = tempVals;
                intVals = [intVals, tempVals];
            end
            thresh = multithresh(intVals(intVals~=0));
        end
        function [abvThresh, belThresh] =...
                classify_pts(this, thresh, intVals_cell, linez)
            % this function separates pixel values along the lines of
            % interest into those above the threshold intensity and those
            % below, returning two cell arrays, each element of which will
            % be the indices for the respective pixels for each line
            
            
            abvThresh = cell(1,numel(intVals_cell));
            belThresh = cell(1,numel(intVals_cell));
            abvLength = zeros(1,numel(intVals_cell));
            
            for i = 1:numel(intVals_cell)
                intVals = intVals_cell{i};
                temp_pts = linez{i};
                
                abvThresh_inds = find(intVals > thresh);
                belThresh_inds = find(intVals <= thresh);
                abvThresh{i} = temp_pts(abvThresh_inds, :);
                belThresh{i} = temp_pts(belThresh_inds, :);
                if(~isempty(abvThresh_inds))
                    temp = abvThresh{i};
                    strtPt = temp(1,:);
                    endPt = temp(end,:);
                    abvLength(i) = round(sqrt( (strtPt(1) - endPt(1))^2 + ...
                        (strtPt(2) - endPt(2)^2)));
                end
                
            end
            
            if (max(abvLength) < 20)
                this.LocationClassifier = -1;
            end
            
        end
        function img_trans = reorient_params(this, img, linez1, magnif)
            % this function takes the interpreted pattern limits and
            % centers them in the image composition. img is the image,
            % linez1 is the set of lines determined to contain a pattern,
            % and magnif is the current magnification which determines the
            % distance of the adjustment based on the size of the pixel; it
            % is currently not complete
            
            minX = inf; maxX = 0; minY = inf; maxY = 0;
            dims = size(img);
            
            for i = 1:numel(linez1)
                temp = linez1{i};
                
                if(min(temp(:,1) < minX))
                    minX = min(temp(:,1));
                end
                if(min(temp(:,2) < minY))
                    minY = min(temp(:,2));
                end
                if(max(temp(:,1) > maxX))
                    maxX = max(temp(:,1));
                end
                if(max(temp(:,2) > maxY))
                    maxY = max(temp(:,2));
                end
            end
            
            cntrPt = [round( (maxX - minX)/2 ), round( (maxY - minY)/2)];
            img_cent = [round( dims(1)/2 ), round( dims(2)/2 )];
            
            img_transY = img_cent(2) - cntrPt(2);
            img_transX = img_cent(1) - cntrPt(1);
            
            img_trans = [img_transX, img_transY];
            
            
        end
        function [img_roted, linez_roted] =...
                rotate_all(this, img, linez, theta)
            
            dims1 = size(img);
            img_roted = imrotate(img, theta);
            linez_roted_temp = cell(1,numel(linez));
            dims2 = size(img_roted);
            
            dims_dif = dims2 - dims1;
            
            img_cent = round([dims1(2)/2, dims1(1)/2]);
            img_cent2 = img_cent + dims_dif./2;
            
            dims1 = size(img);
            dims2 = size(img_roted);
            
            for i = 1:numel(linez)
                temp_line = linez{i};
                line_cent = [(max(temp_line(:,1)) - min(temp_line(:,1)))/2,...
                    (max(temp_line(:,2)) - min(temp_line(:,2)))/2];
                line_cent = round(line_cent);
                
                temp_cntrd = [temp_line(:,1) - img_cent(1),...
                    temp_line(:,2) - img_cent(2)];
                
                R = [cosd(theta), -sind(theta);...
                    sind(theta), cosd(theta)];
                line_rtd_cntrd = temp_cntrd*R;
                line_rtd = [line_rtd_cntrd(:,1) + img_cent2(1),...
                    line_rtd_cntrd(:,2) + img_cent2(2)];
                %                line_rtd(:,1) = line_rtd(:,1) + dims2(2) - dims1(2);
                line_rtd(:,1) = round(mean(line_rtd(:,1)));
                line_rtd = unique(round(line_rtd), 'rows');
                linez_roted_temp{i} = line_rtd;
                
                if(i > 1 && ~isempty(linez_roted_temp{i-1}) &&...
                        ~isempty(line_rtd))
                    curr_line = line_rtd;
                    last_line = linez_roted_temp{i-1};
                    diffX = abs(curr_line(1,1) - last_line(1,1));
                end
                
                if(i > 1 && ~isempty(linez_roted_temp{i - 1}) &&...
                        exist('diffX') && diffX < 20)
                    sprintf('here and i = %d/n',i);
                    
                    xUpd = (curr_line(1,1) + last_line(1,1)) / 2;
                    tempLine = linez_roted_temp{i};
                    tempLine(:,1) = xUpd;
                    linez_roted_temp{i} = tempLine;
                    linez_roted_temp{i-1} =  [];
                end
                
                linecnt = 0;
                
                for i = 1:numel(linez_roted_temp)
                    if(~isempty(linez_roted_temp{i}))
                        linecnt = linecnt + 1;
                        linez_roted{linecnt} = linez_roted_temp{i};
                    end
                end
            end
            
            
        end
        function [count, decis] = classify_image_FL(this, img, abvThresh)
            % this function is a temporary one with a half-assed classifier
            % which will be used in some preliminary testing
            
            count = length(abvThresh);
            
            if(count > 1000)
                decis = 1;
            else
                decis = 0;
            end
            
            
        end
        function [imgs_cr, recs] =...
                extract_AOIs(this, img, roted_linez, recWidth)
            
            %             recWidth = 91;
            imgs_cr = cell(1,numel(roted_linez));
            recs = cell(1,numel(roted_linez));
            
            for i = 1:numel(roted_linez)
                tempLine = roted_linez{i};
                minX = min(tempLine(:,1)) - floor(recWidth/2);
                minY = min(tempLine(:,2));
                maxY = max(tempLine(:,2));
                recHeight = maxY - minY;
                recSpecs = [minX, minY, recWidth, recHeight];
                
                [imgs_cr{i}, recs{i}] = imcrop(img, recSpecs);
                temp = imgs_cr{i};
                dims = size(temp);
                
                [y, x] = find(imgs_cr{i} == 0);
                if(~isempty(y))
                    
                    if (min(y) > size(imgs_cr{i},1)/2)
                        temp = temp(1:min(y), 1:dims(2));
                    else
                        temp = temp(max(y):dims(1), 1:dims(2));
                    end
                    imgs_cr{i} = temp;
                    
                end
                
                
                
            end
            
        end
        function [imgs_var, var_nrm, imgs_mn, mn_nrm, coeff_var] = ...
                acquire_local_stats(this, imgs_cr, nhood, n)
            % function returns the local std and mean for each image.
            % Currently values are normalized for easy visualisation
            
            h = fspecial('average', n);
            imgs_var = cell(1,numel(imgs_cr));
            imgs_mn = cell(1,numel(imgs_cr));
            var_nrm = cell(1,numel(imgs_cr));
            mn_nrm = cell(1,numel(imgs_cr));
            coeff_var = cell(1,numel(imgs_cr));
            
            for i = 1:numel(imgs_var)
                temp_std = stdfilt(imgs_cr{i}, nhood);
                temp_mn = imfilter(imgs_cr{i}, h, 'replicate');
                imgs_var{i} = temp_std.^2;
                imgs_mn{i} = temp_mn;
                var_nrm{i} = temp_std - min(min(temp_std));
                var_nrm{i} = var_nrm{i}/max(max(var_nrm{i}));
                mn_nrm{i} = temp_mn - min(min(temp_mn));
                mn_nrm{i} = mn_nrm{i}/max(max(mn_nrm{i}));
                coeff_var{i} = temp_std./temp_mn;
            end
        end
        function [threshX, rightIndx, leftIndx, img_bw] =...
                acq_stripe_border_CV(this, coeff_var, img, strBnds)
            % coeff_var is the images coefficient of variation matrix
            % defined as std/mean. strBnds is a 2 element vector
            % containing the lower bound and upper bound for the stripe
            % width. If the stripe is below or above these bounds nothing
            % will be returned
            
            strWidths = zeros(1,numel(coeff_var));
            rightIndx = zeros(1,numel(coeff_var));
            leftIndx = zeros(1,numel(coeff_var));
            
            for i = 1:numel(coeff_var)
                var_thresh = 1.2*graythresh(coeff_var{i});
                img_bw = im2bw(coeff_var{i}, var_thresh);
                
                title('thresholded coefficient of variation')
                
                cc = bwconncomp(img_bw);
                labeled = labelmatrix(cc);
                s = regionprops(cc, 'area');
                lowOnes = find([s.Area] < 30);
                inds2low = [];
                for j = 1:length(lowOnes)
                    temp = find(labeled == lowOnes(j));
                    if(size(temp,2)>1)
                        temp = temp';
                    end
                    inds2low = [inds2low; temp];
                end
                img_bw(inds2low) = 0;
                figure, imshow(img_bw)
                
                [y, x] = find(img_bw == 1);
                threshX = mean(x);
                ymin = min(y);
                ymax = max(y);
                
                rowNumsAbv = find(x > threshX);
                rowNumsBel = find(x < threshX);
                
                rightIndx(i) = round(median(x(rowNumsAbv)));
                leftIndx(i) = round(median(x(rowNumsBel)));
                
                strWidths(i) = rightIndx(i) - leftIndx(i);
                
                figure, imshow(img{i}), title('image with border plotted')
                
                if(strWidths(i) < min(strBnds) ||...
                        strWidths(i) > max(strBnds))
                    break;
                    
                end
                yvec = ymin:ymax;
                xVecL = repmat(leftIndx(i), 1, length(yvec));
                xVecR = repmat(rightIndx(i), 1, length(yvec));
                hold on, plot(xVecL, yvec, 'g.', xVecR, yvec, 'g.')
                
            end
            
            if(max(strWidths) < min(strBnds) ||...
                    min(strWidths) > max(strBnds))
                this.LocationClassifier = -1;
            end
        end
        % DIC channel evaluation
        function gmm = ...
                generate_gmm_entropy(img_stack, block_dims, wind, num_clusts)
            
            img_ent = zeros( size( img_stack ) );
            
            for i = 1:size(img_stack,3)
                im = img_stack(:,:,i);
                img_ent(:,:,i) = entropyfilt(im, ones(wind,wind));
            end
            
            img_ent = img_stack_to_img_2D( img_ent, block_dims );
            
            se = strel('disk',9);
            ent_smooth = imclose(img_ent, se);
            
            skip_size = 30;
            ent_vector = ent_smooth(:);
            options = statset( 'MaxIter', 200 );
            gmm = fitgmdist(ent_vector(1:skip_size:end), num_clusts, 'replicates',3, 'Options', options);
        end
        function labeled_img = ...
                cluster_img_entropy(img, stack_dims, gmm, wind, sizeThresh)
            % if stack_dims is [] that means that the image should be assumed to be a
            % single 2D image rather than an array of 2D images composing a larger
            % image
            
            if( isempty( stack_dims) )
                img_ent = entropyfilt( img, ones(wind,wind) );
                se = strel('disk',9);
                ent_smooth = imclose(img_ent, se);
            else
                img_stack = img_2D_to_img_stack( img, stack_dims );
                img_ent = entropyfilt( img_stack, ones(wind,wind) );
                img_ent = img_stack_to_img_2D(img_ent, [15 15]);
                se = strel('disk',9);
                ent_smooth = imclose(img_ent, se);
            end
            num_clusts = length(gmm.mu);
            idx = reshape(cluster(gmm, ent_smooth(:)), size(ent_smooth));
            % Order the clustering so that the indices are from min to max cluster mean
            [~,sorted_idx] = sort(gmm.mu);
            temp = zeros(num_clusts,1);
            for j = 1:num_clusts
                temp(j) = find( sorted_idx == j );
            end
            sorted_idx = temp; clear temp
            
            new_idx = sorted_idx(idx);
            bwInterior = (new_idx > 1);
            cc = bwconncomp(bwInterior);
            bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);
            new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
            labeled_img = new_idx;
            
        end
        function [cc, keep_idx] = remove_oversized_regions( cc, dims )
        %REMOVE_OVERSIZED_REGIONS takes a connected components structure as
        % returned from bwconncomp(BW) function and removes any component that does
        % not fit in the bounding box defined by dims
        %   cc - a connected components structure from bwconncomp(BW)
        %   dims - dimensions of the specified bounding box in [
            cc_props = regionprops(cc, 'BoundingBox');

            keep_idx = [];
            for i = 1:length( cc_props )
                bnd_box = cc_props(i).BoundingBox;
                if( bnd_box(3)<dims(1) && bnd_box(4)<dims(2) )
                    keep_idx = [keep_idx; i];
                end
            end

            cc = cc(keep_idx);
            cc.PixelIdxList = cc.PixelIdxList(keep_idx);
            cc.NumObjects = length(keep_idx);
        end
        function class_vec = classify_ROIs( stat_vec, thresh )
        %CLASSIFY_ROIS takes a vector stat_vec and a threshold thres and classifies
        % entries in stat_vec according to the specify threshold with 'true'
        % corresponding to the higher-valued class
        % thresh - a scalar threshold
            if( numel(thresh) ~= 1 )
                error('threshold must be scalar value')
            end
            if( ~isnumeric(thresh) )
                error('threshold must be numeric value')
            end

            class_vec = (stat_vec > thresh);
        end

        % old DIC functions - can be cleaned and maybe removed
        function [imgOut, imgOutScld] =...
                lowpassFFT(this, img, uprbound, deltax, deltay)
            % this function computes the lowpass filtered image of the image
            % img with the cutoff frequency determined by uprbound.
            %             F = fft2(double(img));
            
            M = size(img,2);
            N = size(img,1);
            
            %             deltax = 1;
            %             deltay = 1; % for now these, representing the sampling rate in
            % x and y, will be set to 1 pixel, rather than
            % their metric values
            
            % grid goes from 0 to .5 and then from -.5 back to 0 in steps
            % size 1/M, provided that deltax is set to 1 pixel. Otherwise
            % values are scaled by 1/sample rate
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) -1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) -1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
            k0 = sqrt(uprbound^2*(deltax^-2+deltay^-2)); % filter set to
            % filter out frequency values above this magnitude
            
            bnd = double(KX.*KX+KY.*KY < k0^2);
            
            H = fspecial('gaussian', 100, 20);
            T1 = imfilter(bnd, H, 'replicate');
            
            imgOut = abs(ifft2(T1.*fft2(img)));
            
            imgOutScld = imgOut-min(min(imgOut));
            imgOutScld = imgOutScld/max(max(imgOutScld));
            
        end
        function [imgOut, imgOutScld] =...
                highpassFFT(this, img, lowrbound, deltax, deltay)
            % this function computes the highpass filtered image of the image
            % img with the cutoff frequency determined by lowrbound.
            %             F = fft2(double(img));
            
            M = size(img,2);
            N = size(img,1);
            
            %             deltax = 1;
            %             deltay = 1; % for now these, representing the sampling rate in
            % x and y, will be set to 1 pixel, rather than
            % their metric values
            
            % grid goes from 0 to .5 and then from -.5 back to 0 in steps
            % size 1/M, provided that deltax is set to 1 pixel. Otherwise
            % values are scaled by 1/sample rate
            kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) - 1/2;
            kx = kx1*(2*pi/deltax);
            ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) - 1/2;
            ky = ky1*(2*pi/deltay);
            
            [KX, KY] = meshgrid(kx, ky);
            
            k0 = sqrt(lowrbound^2*(deltax^-2+deltay^-2)); % filter set to
            % filter out frequency values above this magnitude
            
            bnd = double(KX.*KX+KY.*KY > k0^2);
            
            H = fspecial('gaussian', 100, 20);
            T1 = imfilter(bnd, H, 'replicate');
            
            imgOut = abs(ifft2(T1.*fft2(img)));
            
            imgOutScld = imgOut-min(min(imgOut));
            imgOutScld = imgOutScld/max(max(imgOutScld));
            
        end
        function [imgOut, imgOutScld] =...
                bandpassFFT(this, img, lowrbound, uprbound, deltax, deltay)
            % this function uses the functions lowpassFFT and highpassFFT in
            % order to produce a bandpass filter by subtracting the lowpass
            % and highpass images from the original image
            
            hpIMG = highpassFFT(this, img, lowrbound, deltax, deltay);
            lpIMG = lowpassFFT(this, img, uprbound, deltax, deltay);
            
            imgOut = img - lpIMG - hpIMG;
            imgOutScld = imgOut - min(min(imgOut));
            imgOutScld = imgOutScld./max(max(imgOutScld));
        end
        function img_sm = smooth_img_DIC_20x(this, img, wind)
            % function currently used to smooth image with no flexibility.
            % Eventually this function should be updated to allow the user
            % to adjust parameters
            
            Have = fspecial('average', 3);
            img_sm = imfilter(img, Have, 'replicate');
            
        end
        function img_sm = smooth_img_DIC_60x(this, img, sigm, wind)
            % this function simply smooths the image with a Gaussian filter
            % with the standard deviation sigma and the window size wind
            
            Hgauss = fspecial('gaussian', wind, sigm);
            img_sm = imfilter(img, Hgauss, 'replicate');
            
            
        end
        function img_bw = segment_image_DIC(this, img_sm)
            % this function also provides little flexibility, but for now
            % it laeufts
            
            [~, thresh] = edge(img_sm, 'sobel');
            scld = .4;
            
            bwC_F = edge(img_sm, 'sobel', thresh*scld);
            
            se90 = strel('line', 3, 90);
            se0 = strel('line', 3, 0);
            seD = strel('disk', 5);
            
            bwC_F = imdilate(bwC_F, [se90 se0]);
            bwC_F = imfill(bwC_F, 'holes');
            
            seD = strel('diamond', 1);
            
            bwC_F = imerode(bwC_F, seD);
            bwC_F = imerode(bwC_F, seD);
            
            cc = bwconncomp(bwC_F);
            labeled = labelmatrix(cc);
            pixArea = zeros(max(max(labeled)),1);
            
            for j=1:max(max(labeled))
                pixArea(j) = length(find(labeled==j));
            end
            
            thresh = 1000;
            
            % obtains label for objects below area threshold
            tolow = find(pixArea<thresh);
            inds_2low = [];
            for j=1:length(tolow)
                inds_2low = [inds_2low; find(labeled==tolow(j))];
            end
            
            % eliminates noise objects as defined above
            bwC_F(inds_2low) = 0;
            
            img_bw = bwC_F;
            
        end
        function draw_boundaries(this,img,img_bw)
            edge_bw = bwperim(img_bw);
            edgemp = uint16(img);
            edgemp(edge_bw) = 65535;
            figure, imshow(edgemp);
            
        end
        function [indsD, indsA, indsM, numLive] =...
                classify_cells_DIC(this, img_bw)
            % again, this function is half-assed, and should be updated and
            % refined as the algorithm is refined
            
            cc = bwconncomp(img_bw);
            s = regionprops(cc, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');
            
            classMat = zeros(1,length(s)) + 999;
            centroyds = cat(1, s.Centroid);
            
            for j=1:numel(s)
                
                if s(j).Area/s(j).ConvexArea > 0.8
                    classMat(j) = 0;
                elseif s(j).Area < 2000
                    classMat(j) = 0;
                elseif s(j).Area > 50000
                    classMat(j) = 2;
                else
                    classMat(j) = 1;
                end
            end
            
            indsD = [centroyds(classMat == 0,1), centroyds(classMat == 0,2)];
            indsA = [centroyds(classMat == 1,1), centroyds(classMat == 1,2)];
            indsM = [centroyds(classMat == 2,1), centroyds(classMat == 2,2)];
            numLive = size(indsA,1);
        end
        function plot_classifier(this, indsD, indsA, indsM)
            
            hold on, plot(indsD(:,1), indsD(:,2), 'r*', indsA(:,1),...
                indsA(:,2), 'g*', indsM(:,1), indsM(:,2), 'b*')
            
            
        end
        % final classification here - just a spaceholder now, needs work
        function decis = classify_image_DIC(this, numLive, magnif)
            % another half-ass placer function for testing
            decis = 0;
            switch magnif
                case 20
                    if (numLive > 5)
                        decis = 1;
                    end
                case 60
                    if (numLive > 0)
                        decis = 1;
                    end
                case 100
                    if (numLive > 0)
                        decis = 1;
                    end
                otherwise
                    decis = 0;
            end
        end
    end % methods
    
    %%
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
        function coordinates = set_figure_position(ratio, factor, position)
            %written by
            %C.P.Richter
            %Division of Biophysics / Group J.Piehler
            %University of Osnabrueck
            
            scrSize = get(0, 'ScreenSize');
            scrRatio = scrSize(3)/scrSize(4);
            
            if  ratio == scrRatio
                figWidth = factor*scrSize(3);
                figHeight = factor*scrSize(4);
            else %height limited
                figWidth = factor*scrSize(3)*ratio/scrRatio;
                figHeight = factor*scrSize(4);
                if figWidth > scrSize(3) %width limited
                    figWidth = factor*scrSize(3);
                    figHeight = factor*scrSize(4)/ratio*scrRatio;
                end %if
            end %if
            
            switch position
                case 'north-west'
                    coordinates = [1 scrSize(4)-figHeight figWidth figHeight];
                case 'north-east'
                    coordinates = [scrSize(3)-figWidth scrSize(4)-figHeight figWidth figHeight];
                case 'south-east'
                    coordinates = [scrSize(3)-figWidth 1 figWidth figHeight];
                case 'south-west'
                    coordinates = [1 1 figWidth figHeight];
                case 'center'
                    coordinates = [0.5*(scrSize(3)-figWidth) 0.5*(scrSize(4)-figHeight) figWidth figHeight];
            end %switch
        end %fun
        function [hImg,hAx,hFig] = init_acq_vis(img)
            [imgHeight,imgWidth] = size(img);
            figPos = classMicroManagerWrapper.set_figure_position(imgWidth/imgHeight, 0.5, 'south-east');
            
            hFig = figure(...
                'Units','pixels',...
                'Position',figPos,...
                'Color',[0 0 0]);
            hAx = axes(...
                'Parent', hFig,...
                'Units','normalized',...
                'Position', [0 0 1 1],...
                'XTickLabel','',...
                'YTickLabel','',...
                'NextPlot','add',...
                'Box','on');
            hImg = imagesc(img,'Parent',hAx);
            axis(hAx,'image','ij')
            colormap gray
        end %fun
        function [hImg,hAx,hFig] = live_acquisition(img,hImg)
            if isempty(hImg)
                [hImg,hAx,hFig] = classMicroManagerWrapper.init_acq_vis(img);
            else
                hAx = [];
                hFig = [];
                set(hImg,'cdata',img);
                ampLim = quantile(img(:),[0.01 0.99]);
                caxis(ampLim);
                title(ampLim)
            end %if
        end %fun
        
        function p = DIC_pooled_bias_est(imgStack)
            for idxFrame = 1:numel(imgStack)
                p(:,idxFrame) = DIC_estimate_bias(imgStack{idxFrame});
            end %for
            p = median(p,2);
        end %fun
    end %methods
end %classdef