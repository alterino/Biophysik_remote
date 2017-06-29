function metaOME = add_setup_specific_OME_XML_Metadata(metaOME,objMetaSrc,varargin)
ip = inputParser;
ip.KeepUnmatched = true;
addParamValue(ip,'verbose', false, @(x)islogical(x))
parse(ip,varargin{:});

binning = get_pixel_binning(objMetaSrc);
NA = get_numerical_aperture(objMetaSrc);
magnification = get_total_magnification(objMetaSrc);
pxSize = get_pixel_size_X(objMetaSrc)/1000; %[nm] -> [µm]
exposureTime = get_exposure_time(objMetaSrc);
lagTime = get_timelag(objMetaSrc); 
laserWvlnth = get_laser_name(objMetaSrc);
laserPower = get_laser_output(objMetaSrc);

imageIndex = 0;
instrumentIndex = 0;
channelIndex = 0;
% emissionFilterRefIndex = 0;
objectiveIndex = 0;
detectorIndex = 0;
lightSourceIndex = 0;
setInstrumentID(metaOME,'Instrument:0',instrumentIndex)
setObjectiveID(metaOME,'Objective:0',instrumentIndex,objectiveIndex)
setObjectiveSettingsID(metaOME,'ObjectiveSettings:0',imageIndex)
setDetectorID(metaOME,'Detector:0',instrumentIndex,detectorIndex)
setLaserID(metaOME,'Laser:0',instrumentIndex,lightSourceIndex)
setDetectorSettingsID(metaOME,'Detector:0',imageIndex,channelIndex)

%%
% setMicroscopeModel(metaOME,...
%     get_microscope_body(objMetaSrc),instrumentIndex)
% setLightPathExcitationFilterRef
% setLightPathEmissionFilterRef(metaOME,...
%     get_mirror_cube(objMetaSrc),imageIndex,channelIndex,emissionFilterRefIndex)

%% OBJECTIVE
% setObjectiveModel(metaOME,...
%     get_obejective(objMetaSrc),instrumentIndex,objectiveIndex)


% setObjectiveWorkingDistance(metaOME,...
%     java.lang.Double(get_objective_working_distance(objMetaSrc)),instrumentIndex,objectiveIndex)

if not(isempty(NA))
    setObjectiveLensNA(metaOME,...
        java.lang.Double(NA),instrumentIndex,objectiveIndex)
end %if
%
% ImmersionEnumHandler = ome.xml.model.enums.handlers.ImmersionEnumHandler();
% immersion = ImmersionEnumHandler.getEnumeration(get_objective_immersion_medium(objMetaSrc));
% setObjectiveImmersion(metaOME,...
%     immersion,instrumentIndex,objectiveIndex)
%
% setObjectiveSettingsRefractiveIndex(metaOME,...
%     java.lang.Double(get_objective_immersion_refractive_index(objMetaSrc)),imageIndex)

if not(isempty(magnification))
    setObjectiveCalibratedMagnification(metaOME,...
        java.lang.Double(magnification),instrumentIndex,objectiveIndex)
end %if

if not(isempty(pxSize))
    pxSize = ome.units.quantity.Length(java.lang.Double(pxSize), ome.units.UNITS.MICROM);
    setPixelsPhysicalSizeX(metaOME,pxSize,imageIndex)
    setPixelsPhysicalSizeY(metaOME,pxSize,imageIndex)
end %if

%% CAMERA
% setDetectorModel(metaOME,...
%     get_camera(objMetaSrc),instrumentIndex,detectorIndex)
if not(isempty(binning))
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
    
    setDetectorSettingsBinning(metaOME,...
        binning,imageIndex,channelIndex)
end %if

if not(isempty(exposureTime))
    exposureTime = ome.units.quantity.Time(java.lang.Double(exposureTime), ome.units.UNITS.MS);
    setPlaneExposureTime(metaOME,exposureTime,imageIndex,0)
end %if
if not(isempty(lagTime))
    lagTime = ome.units.quantity.Time(java.lang.Double(lagTime), ome.units.UNITS.MS);
    setPixelsTimeIncrement(metaOME,lagTime,imageIndex)
end %if

% setDetectorOffset(offset,instrumentIndex,detectorIndex)

%% LASER
% setLaserManufacturer
% setLaserModel
% setLaserType
if not(isempty(laserWvlnth))
    laserWvlnth = ome.units.quantity.Length(java.lang.Double(laserWvlnth), ome.units.UNITS.NM);
    setLaserWavelength(metaOME,laserWvlnth,instrumentIndex,lightSourceIndex)
end %if
if not(isempty(laserPower))
    laserPower = ome.units.quantity.Power(java.lang.Double(laserPower), ome.units.UNITS.MW);
    setLaserPower(metaOME,laserPower,instrumentIndex,lightSourceIndex)
end %if
end