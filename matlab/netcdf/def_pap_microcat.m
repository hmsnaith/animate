function [v, meta] = def_pap_microcat(meta)
%def_microcats Define variables in a pap microcats OceanSITES netCDF file
%   Generate structure array, v, of variable description for OceanSITES
%   netCDF CTD (microcats) file for PAP site

% depstr used to set comments and long names
meta.dep_str = num2str(meta.sbo(~isnan(meta.sbo(:,1)),1)','%dm ');

%% Set up variable types and standard attributes
vname = 'TEMP'; v.(vname) = setup_var(vname,'NC_FLOAT',meta.dep_str,[2.0 100.],1);
vname = 'TEMP_QC'; v.(vname) = setup_var(vname,'NC_SHORT',meta.dep_str,[0 9]);

vname = 'CNDC'; v.(vname) = setup_var(vname,'NC_FLOAT',meta.dep_str,[0 9],1);
vname = 'CNDC_QC'; v.(vname) = setup_var(vname,'NC_SHORT',meta.dep_str,[0 9]);

vname = 'PRES'; v.(vname) = setup_var(vname,'NC_FLOAT',meta.dep_str,[0. 12000.],1);
vname = 'PRES_QC'; v.(vname) = setup_var(vname,'NC_SHORT',meta.dep_str,[0 9]);

vname = 'PSAL'; v.(vname) = setup_var(vname,'NC_FLOAT',meta.dep_str,[29. 40.],1);
vname = 'PSAL_QC'; v.(vname) = setup_var(vname,'NC_SHORT',meta.dep_str,[0 9]);

%%Additional attributes that need to be set up
meta.time_coverage_resolution = 'PT30M';
meta.mc_Sensor_Sampling_Frequency = 'Every 30 minutes';
meta.mc_Sensor_Reporting_Time = 'No comment';
meta.mc_Sensor_Vendor='Seabird';
meta.mc_Sensor_Sampling_Period='instantaneous';

meta.properties = 'Pressure, Temperature, Conductivity and Salinity';
meta.keywords = 'WC_Temp, WC_Sal, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/, http://vocab.nerc.ac.uk/collection/P02/current/DOXY/'; %-> def_pap_microcats

end

%% Functions
