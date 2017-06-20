%type(mfilename)

%help(mfilename)

% ---------------------------- DEFINE THE FILE --------------------------- %

ncquiet                                              % No NetCDF warnings.

nc = netcdf('ncexample.nc', 'clobber');              % Create NetCDF file.

nc.description = 'NetCDF Example';                   % Global attributes.
nc.author = 'Dr. Charles R. Denham';
nc.date = 'June 9, 1997';

nc('latitude') = 10;                                 % Define dimensions.
nc('longitude') = 10;


nc{'latitude'} = 'latitude';                         % Define variables.
nc{'longitude'} = 'longitude';
nc{'depth'} = {'latitude', 'longitude'};
nc{'cccc'}=ncchar('longitude');

nc{'latitude'}.units = 'degrees';                    % Attributes.
nc{'longitude'}.units = 'degrees';
nc{'depth'}.units = 'meters';

% ---------------------------- STORE THE DATA ---------------------------- %

latitude = [0 10 20 30 40 50 60 70 80 90];           % Matlab data.
longitude = [0 20 40 60 80 100 120 140 160 180];
depth = rand(length(latitude), length(longitude));
%cc=[1 2 3 4 5 6 7 8 9 10];
cc='abcdefghij';
nc{'latitude'}(:) = latitude;                        % Put all the data.
nc{'longitude'}(:) = longitude;
nc{'depth'}(:) = depth;
nc{'cccc'}(:) ='abcdefghij';

nc = close(nc);                                      % Close the file.

% ---------------------------- RECALL THE DATA --------------------------- %

nc = netcdf('ncexample.nc', 'nowrite');              % Open NetCDF file.
description = nc.description(:)                      % Global attribute.
variables = var(nc);                                 % Get variable data.
for i = 1:length(variables)
   disp([name(variables{i}) ' =']), disp(' ')
   disp(variables{i}(:))
end
nc = close(nc);                                      % Close the file.

% --------------------------------- DONE --------------------------------- %
