function [DATA, rows] = mysql_animate(db_table, cols, start_date, end_date, s_str)
% Function to open animate MySQL database as animate_admin
% and read all data for columns (col)
% between start_date and end_date from table db_table
verb = 0; % 1=verbose, 0=silent
%% Argument checks
% If db_table for a charcter - return error
% if start_date not set, set to 1900
% if end_date not set, set to 2100
if nargin < 4, s_str = ''; end

%% Open MySQL database - note recent change to mysql needs 'use' call
%mysql('open','mysql','animate_admin','an1mate9876','animate');
mysql('open','mysql','animate_admin','an1mate9876');
mysql('use','animate');
if verb
  [a,~,~,~,~,~] = mysql(['DESCRIBE ' db_table]);
  disp(a)
end
%% Read data from table then close connection
for i = 1:length(cols)
  sql=['SELECT ' cols{i} ' FROM ' db_table ...
       ' WHERE Date_Time < "' end_date '" ' ...
       ' and Date_Time > "' start_date '"' s_str ];
  if verb, disp(sql); end
  try
    DATA.(cols{i}) = mysql(sql);
  catch
    error('Error in submitted SQL statement: %s',sql);
  end     
end

mysql close;
[rows,~]=size(DATA.Date_Time);

if verb, fprintf('Read %d rows by %d colums of data\n',rows, length(cols)); end

end
