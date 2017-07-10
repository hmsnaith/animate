function [v, meta] = def_pap_microcat(meta)
%def_microcats Define variables in a pap microcats OceanSITES netCDF file
%   Generate structure array, v, of variable description for OceanSITES
%   netCDF CTD (microcats) file for PAP site
meta.mc_Sensor_Sampling_Frequency = 'Every 30 minutes';
meta.mc_Sensor_Reporting_Time = 'No comment';
meta.mc_Sensor_Vendor='Seabird';
meta.mc_Sensor_Sampling_Period='instantaneous';
meta.keywords = 'WC_Temp, WC_Sal, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/, http://vocab.nerc.ac.uk/collection/P02/current/DOXY/'; %-> def_pap_microcats


dep_str = num2str(meta.sbo(~isnan(meta.sbo(:,1)),1)','%dm ');

vname = 'TEMP'; v.(vname) = setup_var(vname,'NC_FLOAT',dep_str,[2.0 100.]);
vname = 'TEMP_QC'; v.(vname) = setup_var(vname,'NC_SHORT',dep_str,[0 9]);

vname = 'CNDC'; v.(vname) = setup_var(vname,'NC_FLOAT',dep_str,[0 9]);
vname = 'CNDC_QC'; v.(vname) = setup_var(vname,'NC_SHORT',dep_str,[0 9]);

vname = 'PRES'; v.(vname) = setup_var(vname,'NC_FLOAT',dep_str,[0. 12000.]);
vname = 'PRES_QC'; v.(vname) = setup_var(vname,'NC_SHORT',dep_str,[0 9]);

vname = 'PSAL'; v.(vname) = setup_var(vname,'NC_FLOAT',dep_str,[29. 40.]);
vname = 'PSAL_QC'; v.(vname) = setup_var(vname,'NC_SHORT',dep_str,[0 9]);

end

%% Functions
