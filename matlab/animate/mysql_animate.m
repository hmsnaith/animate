function [DATA, rows, cols] = mysql_animate(db_table, start_date, end_date, s_str)
% Function to open animate MySQL database as animate_admin
% and read all data between start_date and end_date from table db_table
verb = 1; % 1=verbose, 0=silent
%% Argument checks
% If db_table for a charcter - return error
% if start_date not set, set to 1900
% if end_date not set, set to 2100
if nargin < 4, s_str = ''; end

%% Open MySQL database
mysql('open','mysql','animate_admin','an1mate9876','animate');

%% Read data from table then close connection
sql=['SELECT * FROM ' db_table ' WHERE Date_Time < "' end_date '" ' ...
    ' and Date_Time > "' start_date '"' s_str ];
if verb, disp(sql); end
DATA=mysql(sql);
mysql close;
[rows,cols]=size(DATA);

if verb, fprintf('Read %d rows by %d colums of data\n',rows, cols); end

end
