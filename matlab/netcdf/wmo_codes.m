first_char=mooringlc(1);
if (first_char == 'c')	wmo_platform_code='44478'; platform_code=['CIS-' mooring_no];   site_code='CIS'; end	
if ((first_char == 'e')&(mooringlc(2)=='s'))
			wmo_platform_code='13471'; platform_code=['ESTOC-' mooring_no]; site_code='ESTOC'; end	
if ((first_char == 'e')&(mooringlc(2)=='2'))
			wmo_platform_code='68416'; platform_code=['E2M3A-' mooring_no]; site_code='E2M3A'; end	
if (first_char == 'p')	wmo_platform_code='62442'; platform_code=['PAP-' mooring_no];   site_code='PAP'; end	
if (first_char == 's')	wmo_platform_code='68412'; platform_code=['STATION-M-' mooring_no];   site_code='STATION-M'; end	
if ((mooringlc(1) == 'c')&(mooringlc(2) == 'v'))
			wmo_platform_code='18475'; platform_code=['TENATSO-' mooring_no];   site_code='TENATSO'; end	
%  see list on partner area of website
if (first_char == 'd')	wmo_platform_code='68418'; platform_code=['DYFAMED-' mooring_no]; site_code='DYFAMED'; end	
if (first_char == 'a')	wmo_platform_code='68420'; platform_code=['ANTARES-' mooring_no]; site_code='ANTARES'; end	
if (first_char == 'n')  wmo_platform_code=''; platform_code=['NOG-' mooring_no]; site_code='NOG'; end
if (first_char == 's')  wmo_platform_code=''; platform_code=['SOG-' mooring_no]; site_code='SOG'; end
%E1-M3A         61277   pre-existing from MFSTEP
%E2-M3A		61278	pre-existing
%W1-M3A		61279	pre-existing
%DYFAMED        61001        	used by me 68418   
%E2-M3A         61278		used by me 68416
%PYLUS 		6101008