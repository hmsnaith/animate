% pap_201704_rt_microcat_sbo_v1_3
% Script to generate OceanSITES netCDF file for sbo (microcat) data
%    for deplyment 201704 of PAP from data held in MySQL table

%% Setup the MetaData for this deployment
deploy = '201704';
[site, dat, dep, gr] =  setup_mooring_pap(deploy); % Sets all the MetData for this deplyment

%% Setup microcat Metadata
% SetUp parameters (global attributes mainly)
disp 'entering microcat_v1_3_params_fixo3'
QC_indicator=1; %ref table 2 code (subscript will be this +1) for variable with no <PARM>_QC
microcat_v1_3_params_fixo3;
qcProcLevel=ref_tab_3(2);

os_namer='CTDO'
cdout_os='/noc/itg/pubread/animate/oceansites/microcat/';
cdout=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/sbo/'];
cdout1=['/noc/itg/pubread/animate/animate_data/' mooringlc '/' deploy '/sbo/'];
in_dir=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/sbo/processed/'];
in_file1='';
in_file2='';

nvar=2;
sample_period=30;   % for roc qc (minutes)
decSamplePeriod=sample_period/(60*24);   % to detect missing timesteps

rt_sample_period_text='every 30 minutes';   % time between transmissions
% note data only sent 
%
%Wvar 0, sensor has pressure, non zero is number of sensor to use to calculate pressure
% stype 1=MC, 2=MC + pressure, 3=TDlogger  7=MC with pump  8=MC with pump and pressure 10 = SBE-37IMP-IDO 11 = SBE-37IMP-ODO 

serial_no(1)=13397;	v(1)=1;  	Wvar(1)=0; 		stype(1)=10; 	qc_var(1)=0;		skip(1)=0;
serial_no(2)=10535;	v(2)=30;  	Wvar(2)=0; 		stype(2)=11; 	qc_var(2)=0;		skip(2)=0;

ox_Sensor_Vendor='Seabird';
ox_Sensor_part_no='SBE-37IMP-IDO';
%ox_Sensor_Depth=;   % same as mc depth and serial no
%ox_sensor_serial_number=;

spmooring=[' ' mooring];
StartDate='2017-04-01 12:30:00';
EndDate='2025-01-01 00:00:00';
x_lab='Date (2015)';
enddate_num=now;
startdate_num=datenum(StartDate);
lon=-16.31896;
lat=49.02946;

moor_lat_min=48;
moor_lat_max=50;
moor_lon_min=-16;
moor_lon_max=-17;
M_legend=['S/N  13397','S/N 10535'];
%P_legend=[['S/N' , serial_no(1)],['S/N ', serial_no(2)]];
P_legend=M_legend;
clear moor_nr;
moor_nr=ones(1,nvar);

mooring_number=1;
mooring_no='1';

%% Setup variables
sbodat(1:sbo_nv) = struct('n',[],'Date_Time',[],'temp',[],'cond',[],'press',[],...
                     'S',[],'St',[],'ox',[],'ox_mol',[],'ox_mol_comp',[]);
flds = {'Date_Time', 'sbo_temp', 'sbo_cond', 'sbo_press','sbo_ox',...
        'sbo_temp_qc', 'sbo_cond_qc','sbo_press_qc', 'sbo_ox_qc'};
param = struct('temp','Temperature \circC','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen on Seabird microcat','ox_mol','Oxygen on Seabird microcat',...
               'ox_mol_comp','Salinity compensated Oxygen on Seabird microcat');
units = struct('temp','Temperature \circC','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen (ml/l)','ox_mol','Oxygen (\mumol/l)',...
               'ox_mol_comp','Sal. comp. O_2 (\mumol)' );
have_data = 0;
last_date = datenum('01-01-1900');
%% Read in, apply QC and Calculate Derived Values
% For each SBO dataset
for m=1:sbo_nv;
  % Read data from MySQL database table
  db_tab=[db_table '_sbo_' num2str(m)];
  s_str = ' order by Date_Time ASC';
  [DATA, sbodat(m).n] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
  
  if (sbodat(m).n > 0)
    have_data = have_data + 1;
    % transfer data into data structure
    sbodat(m).Date_Time = DATA.Date_Time;
    last_date = max(last_date,sbodat(m).Date_Time(end));
    for fld={'temp','cond','press','ox'}
      % Copy basic measurements into data structure
      fldnm = ['sbo_' char(fld)];
      sbodat(m).(char(fld)) = DATA.(fldnm);
      % If qc flags are set - apply to relevant data
      tmp = DATA.([fldnm '_qc']);
      % If all values are null, we ignore them, otherwise
      if ~isempty(tmp)
        % Convert QC cell array to matrix
        qc = tmp;
        if length(qc)<sbodat(m).n % if the QC array is 'short', not all values set
          % Assume all values bad
          qc = ones(1,sbodat(m).n);
          for i=1:sbodat(m).n
            % Loop over all QC values, NULL or 0 are considered good
            if isempty(tmp(i)) || tmp(i)==0, qc(i) = 0; end
          end
        end
        % Any flagged bad values - set to NaN
        sbodat(m).(char(fld))(qc>0) = NaN;
      end
    end
    
    % Apply pressure correction
    sbodat(m).press=sbodat(m).press-sbo_press_corr(m);
    
    % Reject all Oxygen values >=10
    qc = sbodat(m).ox > 9.9;
    sbodat(m).ox(qc)=NaN;
        
    % Calculate Salinty
    sbodat(m).S = salinity(sbodat(m).press, sbodat(m).temp, sbodat(m).cond);
    
    qc = find((sbodat(m).S < 34.5) | (sbodat(m).S > 35.7));
    if (~isempty(qc))
      disp(' potential out of range SBO salinity');
      fprintf('    %s\n',datestr(sbodat(m).numdate(qc)));
    end
    
    % Calculate SigmaT
    sbodat(m).St = sigmat(sbodat(m).temp,sbodat(m).S);
    
    % Calculate Oxygen (/mol)
    sbodat(m).ox_mol = sbodat(m).ox * 44.658;
    
    % Calculate T compensated Oxygen sat for all valid Oxygen values
    sbo_t_rat_1 = 298.15-sbodat(m).temp;
    sbo_t_rat_2 = 273.15+sbodat(m).temp;
    sbo_temp_K_ratio = sbo_t_rat_1./sbo_t_rat_2;
    sbo_temp_scaled = log(sbo_temp_K_ratio);
    
    s_coeff =(b0+(b1.*sbo_temp_scaled)+(b2.*sbo_temp_scaled.^2)+(b3.*sbo_temp_scaled.^3));
    
    sbodat(m).ox_mol_comp = sbodat(m).ox_mol.*(exp((sbodat(m).S.*s_coeff)+(c0*sbodat(m).S.^2)));
    sbodat(m).ox_mol_comp(isnan(sbodat(m).ox)) = NaN;
    
  end % end of 'if sbodat(m).n>0'
  % end of data input

end % End SBO dataset loop

%% Setup netCDF vars

date(1:19)=getfield(DATA1,{1,1},'Date_Time');

DateTimeTemp=last_date;   %last time
rowsCorr=round((DateTimeTemp-startdate_num)/decSamplePeriod)+1;

DateTime=zeros(rowsCorr,nvar);
T=zeros(rowsCorr,nvar);
P=zeros(rowsCorr,nvar);
C=zeros(rowsCorr,nvar);
S=zeros(rowsCorr,nvar);
St=zeros(rowsCorr,nvar);
Ox=zeros(rowsCorr,nvar);
TQ=ones(rowsCorr,nvar);
PQ=ones(rowsCorr,nvar);
CQ=ones(rowsCorr,nvar);
SQ=ones(rowsCorr,nvar);
StQ=ones(rowsCorr,nvar);
OxQ=ones(rowsCorr,nvar);


%  The 2 sensors are on the same time regime, and so can be added to an array. MRP 20140722
% however timestamps are missing from both data streams so that needs to be fixed MRP 20150806
%%%%%%%%%%%%%% read msql
for j=1:nvar;

s1=['SELECT * FROM PAP' deploy '_sbo_' int2str(j)];
s2=[' where  Date_Time > "' StartDate '"  order by Date_Time ASC'];
sqlstr=strcat(s1,s2);
mysql('open','mysql','animate','an1mate9','animate');
DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);
   
i=0;   %line counter to allow for additional data lines    
for  im = 1:rows;
    i=i+1;
    date(1:19)=getfield(DATA,{im,1},'Date_Time');
    ddd(1)=date(6);
    ddd(2)=date(7);
    ddd(3)=date(8);
    ddd(4)=date(9);
    ddd(5)=date(10);    
    ddd(6)=date(5);
    ddd(7)=date(1);
    ddd(8)=date(2);
    ddd(9)=date(3);
    ddd(10)=date(4);
    ddd(11:19)=date(11:19);
    DateTimeTemp=datenum(ddd(1:19));

    if (im>1)
      timeDiff=DateTimeTemp-DateTime(i-1,j);
      loop=round(timeDiff/decSamplePeriod);
      if loop > 1
        for iz=2:loop
            DateTime(i,j)=DateTime(i-1,j)+((iz-1)*decSamplePeriod);
            T(i,j)=NaN;
            P(i,j)=NaN;
            C(i,j)=NaN;
            S(i,j)=NaN;
            St(i,j)=NaN;
            Ox(i,j)=NaN;
            TQ(i,j)=9;
            CQ(i,j)=9;
            PQ(i,j)=9;
            SQ(i,j)=9;
            StQ(i,j)=9;
            OxQ(i,j)=9;
            i=i+1;
        end
      end
    else
        DateTime(1,j)=DateTimeTemp;   
    end
    DateTime(i,j)=DateTimeTemp;   

% for microcats	
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
          x=(getfield(DATA,{im,1},['sbo_temp']));
	  T(i,j) = x;
	  x =getfield(DATA,{im,1},['sbo_temp_qc']);
	    if (isempty(x)) 
			  TQ(i,j) = 1; 
	    else 
			  TQ(i,j) = x; 
	    end;

          x=(getfield(DATA,{im,1},['sbo_cond']));
	  C(i,j) = x; 
      	  x =getfield(DATA,{im,1},['sbo_cond_qc']);
	      if (isempty(x)) 
		    	CQ(i,j) = 1; 
	      else 
			CQ(i,j) = x; 
              end;
                
    

%pressure
%%%%%%%%%%%%%%%%%%%%%    
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
	x=getfield(DATA,{im,1},['sbo_press']);
    	P(i,j) =  x; 
    x =getfield(DATA,{im,1},['sbo_press_qc']);
    if (isempty(x)) 
		PQ(i,j) = 1; 
    else 
		PQ(i,j) = x; 
    end;
 
 
         clear depth_str;
     	  depth_str=int2str(v(j));    	  
 	 x=getfield(DATA,{im,1},['sbo_ox']);
     	Ox(i,j) =  x; 
     x =getfield(DATA,{im,1},['sbo_ox_qc']);
     if (isempty(x)) 
 		OxQ(i,j) = 1; 
     else 
 		OxQ(i,j) = x; 
     end;

%111111111111111111111
 
 
 
	    if ((P(i,j) > 1800) | (P(i,j) < 1) | (PQ(i,j) > 1) )
	        P(i,j) = NaN;
	        PQ(i,j)=9;
	     end;
        if  (T(i,j) > 99) | (T(i,j) < 0.1 )
            TQ(i,j) = 9;
        end;
        if  (C(i,j) > 99) | (C(i,j) < 0.1 )
            CQ(i,j) = 9;
            C(i,j) = NaN;            
        end;
        if  (TQ(i,j) > 1)
            T(i,j) = NaN;
            C(i,j) = NaN;
        end;
        if  (OxQ(i,j) > 1)
            sbo_Ox(i,j) = NaN;
        end;

        if (isnan(T(i,j)) | (CQ(i,j) > 1)) | (PQ(i,j) > 1)	     
            S(i,j)= NaN;
            St(i,j) = NaN;
            SQ(i,j)= 9;
            StQ(i,j) = 9;
        else
            Tsal=t90tot68(T(i,j));
            S(i,j)  =salinity(P(i,j), Tsal, C(i,j) );
  	        St(i,j) =sigmat(Tsal,S(i,j));
        end;
    end;

end;

startdate=datestr(DateTime(1,1),1);
enddate=datestr(DateTime(rows,1),1);

dens=sw_dens(S,T,P);
Oxm=Ox.*44.661.*dens./1000;  % convert ml/l to micromol/kg
OxmQ=OxQ;

%%%%%%%%%%%%%% end of read
microcat_graphs;   

microcat_ox_graphs;

% change Nans to Fill values

clear kkk;
kkk=find((TQ==9)|isnan(T));
T(kkk)=99999.0;

clear kkk;
kkk=find((CQ==9)|isnan(C));
C(kkk)=99999.0;

clear kkk;
kkk=find((PQ==9)|isnan(P));
P(kkk)=99999.0;

clear kkk;
kkk=find((SQ==9)|isnan(S));
S(kkk)=99999.0;

clear kkk;
kkk=find((StQ==9)|isnan(St));
St(kkk)=99999.0;

clear kkk;
kkk=find((OxQ==9)|isnan(Ox));
Ox(kkk)=99999.0;


%QC as at data acquisition for RT %%%%%%%%%%%%%%%%%
%quality_control_indicator='unknown';
%quality_index='B';
%time_qc_indicator=ref_tab_2{2);
%pos_qc_indicator=ref_tab_2{2);

for j=1:nvar
	if (Wvar(j)>0) PQ(:,j)=8; end;
end

disp 'entering microcat_rt_1_3_native'
microcat_rt_1_3;
