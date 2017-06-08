set_auto_focus_state(objMicMan,0)
set_objective_stage_z_position_micron(objMicMan,0)

%% reset
unloadAllDevices(objMicMan.CoreAPI)
objMicMan.CoreAPI.loadSystemConfiguration(fullfile(objMicMan.MicManPath,objMicMan.Profile))