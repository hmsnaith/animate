function t68 = t90tot68(t90)
%function t68 = t90tot68(t90)
%
%-----------------------------------------------------------------------------
% Converts temperature from ITPS-90 to ITS-68
%
%     Input:
%            t90  -  Temperature  [ PTS-90]
%
%     Output:
%            t68  -  Temperature  [IPTS-68]
%
%     References:
%
%     Checkvalue:  T90toT68(100) = 100.024
%
%---------------------------------------------------------------------
%  S. Chiswell 1991

t68 = t90/0.99976 ;
