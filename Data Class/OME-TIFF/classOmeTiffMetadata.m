classdef classOmeTiffMetadata < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    %modified 21.10.2015
    
    properties
        objOmeMeta
    end %properties
    
    methods
        %constructor
        function this = classOmeTiffMetadata(objImgReader)
            if nargin == 0
                bfCheckJavaPath();
                bfCheckJavaMemory();
                
                OMEXMLService = javaObject('loci.formats.services.OMEXMLServiceImpl');
                this.objOmeMeta = OMEXMLService.createOMEXMLMetadata();
                this.objOmeMeta.createRoot();
                imageIndex = 0;
                instrumentIndex = 0;
                objectiveIndex = 0;
                this.objOmeMeta.setImageID('Image:0', imageIndex);
                this.objOmeMeta.setPixelsID('Pixels:0', imageIndex);
                this.objOmeMeta.setPixelsBinDataBigEndian(java.lang.Boolean.TRUE, imageIndex, 0);
                setInstrumentID(this.objOmeMeta,'Instrument:0',instrumentIndex)
                setObjectiveID(this.objOmeMeta,'Objective:0',instrumentIndex,objectiveIndex)
                
                setROIID(this.objOmeMeta,'ROI:0',0)
                setPolygonID('Polygon:0', 0, 0) 
                
                set_pixel_type(this,'uint16')
                set_dim_order(this,'XYTCZ')
            else
                this.objOmeMeta = getMetadataStore(objImgReader);
            end %if
        end %fun
        
        function set_general_meta(this,srcMeta)
            set_temperature(this,srcMeta)
            set_NA(this,srcMeta)
            set_magnification(this,srcMeta)
            set_phys_pixel_size(this,srcMeta)
            set_exposure_time(this,srcMeta)
            set_lag_time(this,srcMeta)
        end %fun
        function set_channel_meta(this,srcMeta,idxChannel)
            %             toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
            %                 javaObject('java.lang.Integer', x));
            %
            %             imageIndex = 0;
            %             this.objOmeMeta.setChannelID(['Channel:0:' num2str(idxChannel-1)], imageIndex, idxChannel-1);
            %             this.objOmeMeta.setChannelSamplesPerPixel(toInt(1), imageIndex, idxChannel-1);
            
            imagetIndex = 0;
            setDetectorSettingsID(this.objOmeMeta,'Objective:0',imagetIndex,idxChannel-1)
            
            set_channel_name(this,srcMeta,idxChannel)
            set_channel_fluor(this,srcMeta,idxChannel)
            set_channel_ex_wvlnth(this,srcMeta,idxChannel)
            set_channel_em_wvlnth(this,srcMeta,idxChannel)
            set_channel_color(this,idxChannel)
            set_pixel_binning(this,srcMeta,idxChannel)
        end %fun
        
        %% getter
        function metaData = get_meta_data(this)
            metaData = this.objOmeMeta;
        end %fun
        function dimOrder = get_dim_order(this)
            dimOrder = char(getPixelsDimensionOrder(this.objOmeMeta, 0));
        end %fun
        
        function temperature = get_temperature(this)
            imageIndex = 0;
            out = getImagingEnvironmentTemperature(this.objOmeMeta,imageIndex);
            temperature = double(value(out));
        end %fun
        
        function NA = get_NA(this)
            instrumentIndex = 0;
            objectiveIndex = 0;
            out = getObjectiveLensNA(this.objOmeMeta,instrumentIndex,objectiveIndex);
            NA = double(out);
        end %fun
        function magnification = get_magnification(this)
            instrumentIndex = 0;
            objectiveIndex = 0;
            out = getObjectiveNominalMagnification(this.objOmeMeta,instrumentIndex,objectiveIndex);
            magnification = double(out);
        end %fun
        function binning = get_pixel_binning(this)
            imageIndex = 0;
            channelIndex = 0;
            binning = getDetectorSettingsBinning(this.objOmeMeta,imageIndex,channelIndex);
            
            switch char(getValue(binning))
                case '1x1'
                    binning = 1;
                case '2x2'
                    binning = 2;
                case '3x3'
                    binning = 3;
                case '4x4'
                    binning = 4;
            end %switch
        end %fun
        
        function physPxSize = get_phys_pixel_size(this)
            imageIndex = 0;
            
            out = getPixelsPhysicalSizeX(this.objOmeMeta,imageIndex);
            physPxSize = double(value(out));
            physPxSize = physPxSize*(double(getScaleFactor(unit(out)))/1e-6); %[µm]
        end %fun
        function pxSize = get_pixel_size(this)
            physPxSize = get_phys_pixel_size(this); %[µm]
            magnification = get_magnification(this);
            binning = get_pixel_binning(this);
            
            pxSize = physPxSize/magnification*binning*1000; %[nm]
        end %fun
        
        function exposureTime = get_exposure_time(this)
            imageIndex = 0;
            planeIndex = 0;
            out = getPlaneExposureTime(this.objOmeMeta,imageIndex,planeIndex);
            exposureTime = double(value(out));
            exposureTime = exposureTime*(double(getScaleFactor(unit(out)))/1e-3); %[ms]
        end %fun
        function lagTime = get_lag_time(this)
            imageIndex = 0;
            out = getPixelsTimeIncrement(this.objOmeMeta,imageIndex);
            lagTime = double(value(out));
            lagTime = lagTime*(double(getScaleFactor(unit(out)))/1e-3); %[ms]
        end %fun
        
        function channelName = get_channel_name(this,idxChannel)
            imageIndex = 0;
            channelName = char(getChannelName(this.objOmeMeta,imageIndex,idxChannel-1));
        end %fun
        function fluor = get_channel_fluor(this,idxChannel)
            imageIndex = 0;
            out = getChannelFluor(this.objOmeMeta,imageIndex,idxChannel-1);
            fluor = char(out);
        end %fun
        function exWvlnth = get_channel_ex_wvlnth(this,idxChannel)
            imageIndex = 0;
            out = getChannelExcitationWavelength(this.objOmeMeta,imageIndex,idxChannel-1);
            exWvlnth = double(value(out));
            exWvlnth = exWvlnth*(double(getScaleFactor(unit(out)))/1e-9); %[nm]
        end %fun
        function emWvlnth = get_channel_em_wvlnth(this,idxChannel)
            imageIndex = 0;
            out = getChannelEmissionWavelength(this.objOmeMeta,imageIndex,idxChannel-1);
            emWvlnth = double(value(out));
            emWvlnth = emWvlnth*(double(getScaleFactor(unit(out)))/1e-9); %[nm]
        end %fun
        
        function laserWvlnth = get_laser_wvlnth(this,idxChannel)
            %             instrumentIndex = 0;
            %             lightSourceIndex = 0;
            %             out = getLaserWavelength(this.objOmeMeta,instrumentIndex,lightSourceIndex);
            out = getChannelExcitationWavelength(this.objOmeMeta,imageIndex,idxChannel);
            laserWvlnth = double(value(out));
            laserWvlnth = laserWvlnth*(double(getScaleFactor(unit(out)))/1e-9); %[nm]
        end %fun
        function laserPower = get_laser_power(this)
            instrumentIndex = 0;
            lightSourceIndex = 0;
            out = getLaserPower(this.objOmeMeta,instrumentIndex,lightSourceIndex);
            laserPower = double(value(out));
            laserPower = laserPower*(double(getScaleFactor(unit(out)))/1e-3); %[mW] @the objective
        end %fun
        
        function [roiVertX,roiVertY] = get_ROI(this)
            listVert = char(getPolygonPoints(this.objOmeMeta, 0, 0));
            vert = textscan(listVert,'%f%f','delimiter',',');
            roiVertX = vert{1};
            roiVertY = vert{2};
        end %fun
        
        %% setter
        function set_pixel_type(this,type)
            pixelTypeEnumHandler = javaObject('ome.xml.model.enums.handlers.PixelTypeEnumHandler');
            pixelsType = pixelTypeEnumHandler.getEnumeration(type);
            this.objOmeMeta.setPixelsType(pixelsType, 0);
        end %fun
        
        function set_dim_order(this,dimOrder)
            dimensionOrderEnumHandler = javaObject('ome.xml.model.enums.handlers.DimensionOrderEnumHandler');
            dimOrder = dimensionOrderEnumHandler.getEnumeration(java.lang.String(dimOrder));
            this.objOmeMeta.setPixelsDimensionOrder(dimOrder, 0);
        end %fun
        function set_dim_size(this,X,Y,Z,C,T)
            toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
                javaObject('java.lang.Integer', x));
            
            this.objOmeMeta.setPixelsSizeX(toInt(X), 0);
            this.objOmeMeta.setPixelsSizeY(toInt(Y), 0);
            this.objOmeMeta.setPixelsSizeZ(toInt(Z), 0);
            this.objOmeMeta.setPixelsSizeC(toInt(C), 0);
            this.objOmeMeta.setPixelsSizeT(toInt(T), 0);
            
            % Set channels ID and samples per pixel
            for i = 1: C
                this.objOmeMeta.setChannelID(['Channel:0:' num2str(i-1)], 0, i-1);
                this.objOmeMeta.setChannelSamplesPerPixel(toInt(1), 0, i-1);
            end
        end %fun
        
        
        function set_temperature(this,srcMeta)
            temperature = get_temperature(srcMeta);
            
            imageIndex = 0;
            temperature = ome.units.quantity.Temperature(...
                java.lang.Double(temperature), ome.units.UNITS.DEGREEC);
            this.objOmeMeta.setImagingEnvironmentTemperature(temperature,imageIndex)
        end %fun
        
        function set_NA(this,srcMeta)
            NA = get_numerical_aperture(srcMeta);
            if isempty(NA)
                return
            end %if
            
            instrumentIndex = 0;
            objectiveIndex = 0;
            setObjectiveLensNA(this.objOmeMeta,...
                java.lang.Double(NA),instrumentIndex,objectiveIndex)
        end %fun
        
        function set_magnification(this,srcMeta)
            magnification = get_magnification(srcMeta);
            if isempty(magnification)
                return
            end %if
            
            instrumentIndex = 0;
            objectiveIndex = 0;
            setObjectiveNominalMagnification(this.objOmeMeta,...
                java.lang.Double(magnification),instrumentIndex,objectiveIndex)
        end %fun
        function set_pixel_binning(this,srcMeta,idxChannel)
            binning = get_pixel_binning(srcMeta);
            if isempty(binning)
                return
            end %if
            
            BinningEnumHandler = ome.xml.model.enums.handlers.BinningEnumHandler();
            switch binning
                case 1
                    binning = BinningEnumHandler.getEnumeration('1x1');
                case 2
                    binning = BinningEnumHandler.getEnumeration('2x2');
                case 3
                    binning = BinningEnumHandler.getEnumeration('3x3');
                case 4
                    binning = BinningEnumHandler.getEnumeration('4x4');
            end %switch
            
            imageIndex = 0;
            setDetectorSettingsBinning(this.objOmeMeta,...
                binning,imageIndex,idxChannel-1)
        end %fun
        function set_phys_pixel_size(this,srcMeta)
            pxSize = get_phys_pixel_size(srcMeta);
            if isempty(pxSize)
                return
            end %if
            
            imageIndex = 0;
            pxSize = ome.units.quantity.Length(...
                java.lang.Double(pxSize), ome.units.UNITS.MICROM);
            setPixelsPhysicalSizeX(this.objOmeMeta,pxSize,imageIndex)
            setPixelsPhysicalSizeY(this.objOmeMeta,pxSize,imageIndex)
        end %fun
        
        function set_channel_name(this,srcMeta,idxChannel)
            channelName = get_channel_name(srcMeta,idxChannel);
            if isempty(channelName)
                return
            end %if
            
            imageIndex = 0;
            this.objOmeMeta.setChannelName(java.lang.String(channelName),imageIndex,idxChannel-1)
        end %fun
        function set_channel_color(this,idxChannel)
            toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
                javaObject('java.lang.Integer', x));
            
            switch idxChannel
                case 1
                    channelColor = [255 0 0 255];
                case 2
                    channelColor = [0 255 0 255];
                case 3
                    channelColor = [0 0 255 255];
            end %switch
            channelColor = int32(channelColor);
            
            imageIndex = 0;
            this.objOmeMeta.setChannelColor(ome.xml.model.primitives.Color(channelColor(1),channelColor(2),channelColor(3),channelColor(4)),imageIndex,idxChannel-1)
        end %fun
        function set_channel_fluor(this,srcMeta,idxChannel)
            channelFluor = get_channel_fluor(srcMeta,idxChannel);
            if isempty(channelFluor)
                return
            end %if
            
            imageIndex = 0;
            this.objOmeMeta.setChannelFluor(java.lang.String(channelFluor),imageIndex,idxChannel-1)
        end %fun
        function set_channel_ex_wvlnth(this,srcMeta,idxChannel)
            exWvlnth = get_channel_ex_wvlnth(srcMeta,idxChannel);
            if isempty(exWvlnth)
                return
            end %if
            
            imageIndex = 0;
            exWvlnth = ome.units.quantity.Length(...
                java.lang.Double(exWvlnth), ome.units.UNITS.NM);
            this.objOmeMeta.setChannelExcitationWavelength(exWvlnth,imageIndex,idxChannel-1)
        end %fun
        function set_channel_em_wvlnth(this,srcMeta,idxChannel)
            emWvlnth = get_channel_em_wvlnth(srcMeta,idxChannel);
            if isempty(emWvlnth)
                return
            end %if
            
            imageIndex = 0;
            emWvlnth = ome.units.quantity.Length(...
                java.lang.Double(emWvlnth), ome.units.UNITS.NM);
            this.objOmeMeta.setChannelEmissionWavelength(emWvlnth,imageIndex,idxChannel-1)
        end %fun
        function set_channel_acq_mode(srcMeta,idxChannel)
            acqMode = get_channel_acq_mode(srcMeta,idxChannel);
            if isempty(acqMode)
                return
            end %if
            
            imageIndex = 0;
            this.objOmeMeta.setChannelEmissionWavelength(java.lang.String(acqMode),imageIndex,idxChannel-1)
        end %fun
        
        function set_exposure_time(this,srcMeta)
            exposureTime = get_exposure_time(srcMeta);
            if isempty(exposureTime)
                return
            end %if
            
            imageIndex = 0;
            planeIndex = 0;
            exposureTime = ome.units.quantity.Time(...
                java.lang.Double(exposureTime), ome.units.UNITS.MS);
            setPlaneExposureTime(this.objOmeMeta,exposureTime,imageIndex,planeIndex)
        end %fun
        function set_lag_time(this,srcMeta)
            lagTime = get_lag_time(srcMeta);
            if isempty(lagTime)
                return
            end %if
            
            imageIndex = 0;
            lagTime = ome.units.quantity.Time(...
                java.lang.Double(lagTime), ome.units.UNITS.MS);
            setPixelsTimeIncrement(this.objOmeMeta,lagTime,imageIndex)
        end %fun
        function set_laser_wvlnth(this,srcMeta,idxChannel)
            laserWvlnth = get_laser_wvlnth(srcMeta,idxChannel);
            
            %             instrumentIndex = 0;
            %             lightSourceIndex = 0;
            laserWvlnth = ome.units.quantity.Length(...
                java.lang.Double(laserWvlnth), ome.units.UNITS.NM);
            %             setLaserWavelength(this.objOmeMeta,laserWvlnth,instrumentIndex,lightSourceIndex)
            imageIndex = 0;
            setChannelExcitationWavelength(this.objOmeMeta,laserWvlnth,imageIndex,idxChannel)
        end %fun
        function set_laser_power(this,srcMeta)
            laserPower = get_laser_power(srcMeta,idxChannel);
            
            %             instrumentIndex = 0;
            %             lightSourceIndex = 0;
            laserPower = ome.units.quantity.Power(...
                java.lang.Double(laserPower), ome.units.UNITS.MW);
            %             setLaserPower(this.objOmeMeta,laserPower,instrumentIndex,lightSourceIndex)
            imageIndex = 0;
            setChannelLightSourceSettingsAttenuation(this.objOmeMeta,laserPower,imageIndex,idxChannel)
        end %fun
        
        function set_ROI(this,roiVertX,roiVertY)
            listVert = [];
            for idxVert = 1:numel(roiVertX)
                listVert = [listVert,sprintf('%.3f,%.3f ',...
                    roiVertX(idxVert),roiVertY(idxVert))];
            end
            listVert = listVert(1:end-1);
            
            setPolygonPoints(this.objOmeMeta,java.lang.String(listVert), 0, 0)
        end %fun
        
        function set_PSF_radius(this,idxChannel,radPSF)            
            imageIndex = 0;
            try
                annotationIndex = getDoubleAnnotationCount(this.objOmeMeta);
            catch
                annotationIndex = 0;
            end %if
            annotationRefIndex = 0;
            setDoubleAnnotationID(this.objOmeMeta,sprintf('PSF:%d',annotationIndex),annotationIndex)
%             setDoubleAnnotationDescription(this.objOmeMeta,'PSF Radius [px]',tagAnnotationIndex)
            setDoubleAnnotationValue(this.objOmeMeta,java.lang.Double(radPSF),annotationIndex) 
%             setDoubleAnnotationAnnotationRef(this.objOmeMeta,'PSF:0',tagAnnotationIndex,annotationRefIndex) 
            setChannelAnnotationRef(this.objOmeMeta,sprintf('PSF:%d',annotationIndex),imageIndex,idxChannel-1,annotationRefIndex)
        end %if
        function radPSF = get_PSF_radius(this,idxChannel)
            imageIndex = 0;
            annotationRefIndex = 0;
            out = char(getChannelAnnotationRef(this.objOmeMeta,imageIndex,idxChannel-1,annotationRefIndex));
            out = textscan(out,'%s%d','delimiter',':');
            annotationIndex = out{2};
            radPSF = double(getDoubleAnnotationValue(this.objOmeMeta,annotationIndex));
        end %fun
    end %methods
end %class