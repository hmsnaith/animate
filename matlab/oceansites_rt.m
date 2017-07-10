function [ffn] = oceansites_rt(mooring,deploy,ds)
%oceansites_rt Create an OceanSITES Near Real Time data file
%
%   [fn] = oceansites_rt(mooring,deployment,data_stream)
%
% Create an OceanSITES Near Real Time format file for specified
%     mooring, deployment and data stream
% fn (output) : full path of created OceanSITES netCDF file
% mooring (input) : mooring name (eg 'pap')
% deployment (input) : specific deployment (eg '4', '201704')
% data_stream (input) : data stream to include (eg 'microcat', 'cyclops')

if nargsin<3
  error('Required input is mooring, deployment and datastream');
end

%% Setup the metadata for this mooring / deployment
[meta, ~] = setup_mooring_pap(mooring,deploy);
      
%% Setup the generic NRT metadata
meta.mode = 'R'; % OceanSITES code for Near Real Time mode
meta.ncVerNo = 3; % Still using netCDF v3 at the moment
meta.os_format_version = '1.3';
meta.os_conventions = 'CF-1.6';
meta.os_data_type = 'OceanSITES time-series';
meta.os_data_source = 'Mooring observation';
meta.history_in = 'Near real-time processed quality controlled at DAC';
meta.comment_in = 'no comment';
meta.author = 'Helen Snaith';
meta.publisher_name = 'Helen Snaith';
meta.publisher_email = 'h.snaith@bodc.ac.uk';
meta.contacts_email = 'bodcnocs@bodc.ac.uk';
meta.contributor_name = 'Helen Snaith';
meta.contributor_role = 'Editor';
meta.contributor_email = 'bodcnocs@bodc.ac.uk';
meta.keywords_vocabulary = 'SeaDataNet Parameter Discovery Vocabulary';
meta.qc_manual='MERSEA: In-situ real-time data quality control. Mersea-WP03-IFR-UMAN-001-02A, November 2005';

%% Setup variable specific metadata
switch ds
  case {'mc','microcat','CTD'}
  [var, meta] = def_pap_microcat(db_tab,meta);
end
%% Read in data
switch ds
  case {'mc','microcat','CTD'}
    [dat,meta] = read_animate_microcat(db_tab,var);
end
%% Set netCDF parameters
[g, d, v] = oceansites_create_params(meta);

%% Set directories and filenames
cdout_os = '/noc/itg/pubread/animate/oceansites/microcat/'; % OceanSITES netCDF dir for ftp pickup
cdout_as = ['/noc/itg/pubread/animate/animate_data/' lower(mooring) '/' deploy '/microcat/']; % animate microcat data - ftp copy
cdout_mc = ['/noc/users/animate/animate_data/' lower(mooring) '/' deploy '/microcat/']; % animate microcat data - local copy
in_dir = ['/noc/users/animate/animate_data/' lower(mooring) '/' deploy '/microcat/processed/']; % animate microcat data - local copy
ffn = [cdout_os meta.id '.nc'];

%% Create netCDF file
make_oceansites_netcdf(ffn,g,d,v,dat)

%% Write data into file

end

