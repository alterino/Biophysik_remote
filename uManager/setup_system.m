setup_profile(objMicMan,'60x')

set_exposure_time(objMicMan,100)
set_pixel_binning(objMicMan,2)

set_tranmission_lamp_voltage(objMicMan,4)
set_tranmission_lamp_power(objMicMan,1)
set_tranmission_lamp_shutter_state(objMicMan,1)
set_light_path_state(objMicMan,1)

set_auto_focus_objective(objMicMan,100)
set_auto_focus_search_range(objMicMan,500)

set_laser_power(objLaser,561,30)