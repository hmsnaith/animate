function monthly_average(deploy, s_yr, e_yr, D, Var, VName)
% Generate monthly averages for PAP

fd = fopen(['/noc/users/animate/animate_data/pap/' deploy '/monthly/' VName '_monthly_average.csv'],'w+');
for loop_year=s_yr:e_yr;
	for loop_mon=1:12;
		kwkw = find((D(:,1)==loop_year)&(D(:,2)==loop_mon));		
		mon_ave = nanmean(Var(kwkw));
		mon_std = nanstd(Var(kwkw));
    mon_n = sum(~isnan(Var(kwkw)));
		fprintf(fd, '%u,%u,%f,%f,%u\n', loop_year, loop_mon, mon_ave, mon_std, mon_n);
	end
end
fclose(fd);
