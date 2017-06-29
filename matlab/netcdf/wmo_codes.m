function [wmo, id, pltfm, sc, nw] = wmo_codes(mooring,mooring_no)
% [wmo_platform_code, os_id, os_platform_code, os_site_code] = wmo_codes(mooring,mooring_no)
%
% Function to return:
%   wmo_platform_code - WMO platform code
%   os_id - OceanSITES id number
%   os_platform_code - OceanSITES platform code
%   os_site_code - OceanSITES site code
%   os_network - OceanSITES network
% for specified mooring and optional mooring number (character)
% If mooring_no is ommitted, or empty, it is ignored
% Recognised moorings are:
% cis, estoc, e2m3a, pap, station-m, tenatso, dyfamed, antares
% nog, sog
% First 3 characters only required - upper of lower case
% Data taken from Sites summary file on http://www.oceansites.org/about.html

% Check we have at least a 3 character mooring code input
if nargin==0 || ~ischar(mooring) || length(mooring)<3
  error('wmo_codes needs a mooring code of at least 3 characters');
elseif nargin<2 || isempty(mooring_no)
  m_no = '';
else
  m_no = ['-' mooring_no];
end

switch lower(mooring(1:3))
  case 'dyf'
    %id = '215983'; wmo='68418'; sc='DYFAMED'; nw = 'MOOSE'; % Used by Maureen
    id = '215983'; wmo='61001'; sc='DYFAMED'; nw = 'MOOSE'; % From OceanSITES
  case 'w1m'
%     id = '494299'; wmo='61279'; sc='W1M3A'; nw = 'EUROSITES'; % Used by Maureen
    id = '494299'; wmo='61010'; sc='W1M3A'; nw = 'EUROSITES'; % From OceanSITES
  case 'pap'
    id = '498816'; wmo='62442'; sc='PAP'; nw = 'FIXO3';
  case 'pyl'
     id = '499590'; wmo='6101008'; sc='PYLOS'; nw = 'EUROSITES';
  case 'e1m'
    id = '505405'; wmo='61277'; sc='E1M3A'; nw = 'EUROSITES'; % maybe ref MFSTEP as well
  case 'cis'
    id = '508376'; wmo='44478'; sc='CIS'; nw = 'NACLIM';
  case 'est'
    id = '508380'; wmo='13471'; sc='ESTOC'; nw = 'EUROSITES';
  case 'sta'
    id = '508449'; wmo='68412'; sc='STATION-M'; nw = 'EUROSITES';
  case {'cvo','ten'}
    id = '508452'; wmo='18475'; sc='TENATSO'; nw = 'GEOMAR, SOPRAN, SFB754'; % CVOO mooring
%     id = '508451'; wmo='18475'; sc='TENATSO'; nw = 'SOLAS,SOPRAN'; % this is CVOO time series
  case 'ant'
    id = '508461'; wmo='68420'; sc='ANTARES'; nw = 'EUROSITES';
  case 'e2m'
%     id = '508463'; wmo='68416'; sc='E2M3A'; nw = 'EUROSITES'; % Used by Maureen
    id = '508463'; wmo='61278'; sc='E2M3A'; nw = 'EUROSITES'; % From OceanSITES
  case 'nog'
    id = '508529'; wmo=''; sc='NOG'; nw = 'EUROSITES';
  case 'sog'
    id = '508530'; wmo=''; sc='SOG'; nw = 'EUROSITES';
  otherwise
    id = ''; wmo=''; sc=''; nw = '';
end
pltfm=[sc m_no];

