function [ref_tab_2, ref_tab_3] = oceansites_ref_tables
% Returns oceansites reference tables 2 and 3 as cell arrays
%QC markers
ref_tab_2={
'unknown'; % 1
'good_data'; % 2
'probably_good_data'; % 3
'potentially_correctable_bad_data'; % 4
'bad_data'; % 5
'-'; % 6
'-'; % 7
'nominal_value'; % 8
'interpolated_value'; % 9
'missing_value'}; % 10

%QC procedure level
ref_tab_3={
'Raw instrument data'; % 1
'Instrument data that has been converted to geophysical values'; % 2
'Post-recovery calibrations have been applied'; % 3
'Data has been scaled using contextual information'; % 4
'Known bad data has been replaced with null values'; % 5
'Known bad data has been replaced with values based on surrounding data'; % 6
'Ranges applied, bad data flagged'; % 7
'Data interpolated'; % 8
'Data manually reviewed'; % 9
'Data verified against model or other contextual information'; % 10
'Other QC process applied' % 11
};
