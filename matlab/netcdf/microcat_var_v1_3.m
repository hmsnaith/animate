varid=netcdf.defVar(scope,varname,'NC_FLOAT',[dimidD,dimidT]);
%netcdf.putAtt(scope,varid,'name',varname);
netcdf.putAtt(scope,varid,'long_name',long_name);
netcdf.putAtt(scope,varid,'standard_name',standard_name);
netcdf.putAtt(scope,varid,'valid_min',valid_min);
netcdf.putAtt(scope,varid,'valid_max',valid_max);
netcdf.putAtt(scope,varid,'comment',var_comment);
netcdf.putAtt(scope,varid,'units',units);
netcdf.putAtt(scope,varid,'coordinates',coordinates);
netcdf.putAtt(scope,varid,'sensor_depth',mc_Sensor_Depth);
netcdf.putAtt(scope,varid,'sensor_mount',mc_sensor_mount);
netcdf.putAtt(scope,varid,'sensor_orientation',mc_sensor_orientation);

if ncVerNo < 4
	netcdf.putAtt(scope,varid,'_FillValue',single(fillValue));   % changed to single 20140514
else 
	netcdf.defVarFill(scope,varid,false,single(fillValue));  %doesn't work for netcdf3
end
netcdf.endDef(scope);
netcdf.putVar(scope,varid,var');
netcdf.reDef(scope);

if exist('sensor_manual_ref') 
	    sensor_comment=[var_comment sensor_manual_ref];	
else
	    sensor_comment=var_comment;
end
 
netcdf.putAtt(scope,varid,'DM_indicator',mode);
netcdf.putAtt(scope,varid,'sensor_name',[var_Sensor_Vendor ':' var_Sensor_part_no]);
netcdf.putAtt(scope,varid,'sensor_serial_number',var_sensor_serial_number);
if (var_uncertainty<999) 
	netcdf.putAtt(scope,varid,'uncertainty',var_uncertainty);
end;
if (var_accuracy<999)
	netcdf.putAtt(scope,varid,'accuracy',var_accuracy);
end;
if (var_precision<999)
	netcdf.putAtt(scope,varid,'precision',var_precision);
end
if (var_resolution<999)
	netcdf.putAtt(scope,varid,'resolution',var_resolution);
end;
if (ischar(var_cell_methods))	netcdf.putAtt(scope,varid,'cell_methods',var_cell_methods);	end;
if exist([varStr 'Q'])
    ancilVar=var_qcName;
    netcdf.putAtt(scope,varid,'ancillary_variables',ancilVar);
    
    varidQC=netcdf.defVar(scope,var_qcName,'NC_BYTE',[dimidD,dimidT]);
    netcdf.putAtt(scope,varidQC,'name',var_qcName);
    netcdf.putAtt(scope,varidQC,'long_name',['quality flag for ' var_comment]);
    netcdf.putAtt(scope,varidQC,'flag_values',qc_flag_values);
    netcdf.putAtt(scope,varidQC,'flag_meanings',qc_flag_meanings);
    netcdf.putAtt(scope,varidQC,'coordinates',coordinates);
    netcdf.putAtt(scope,varid,'processing_level',qcProcLevel{:});
    netcdf.endDef(scope);
    netcdf.putVar(scope,varidQC,var_qc); 
    netcdf.reDef(scope);   
else
    netcdf.putAtt(scope,varid,'QC_indicator',ref_tab_2{QC_indicator+1});
    netcdf.putAtt(scope,varid,'processing_level',qcProcLevel{:});
end
if ((varStr ~= 'P') & exist('P'))
	ancilVar=[ancilVar ' ' 'PRES'];
	netcdf.putAtt(scope,varid,'ancillary_variables',ancilVar);
else
	ancilVar='';
end
     
