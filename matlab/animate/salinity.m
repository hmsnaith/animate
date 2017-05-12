function SALTY = salinity(PRESS,TEMP,COND)
%// adjusted FORTRAN subroutine
%//
%//     SUBROUTINE SALIN(PRESS,TEMP,COND,SALTY)
%//     TITLE:
%//
%//C       SALIN  -- CALCULATE PRACTICAL SALINITY SCALE 1978 (PSS 78)
%//C                 SALINITY
%//C
%//C     PURPOSE:
%//C     *******
%//C
%//C       TO CALCULATE PSS 78 SALINITY FROM PRESSURE, TEMPERATURE AND
%//C       CONDUCTIVITY.
%//C
%//C     PARAMETERS:
%//C     **********
%//C
%//C       PRESS  -- PRESSURE IN DECIBARS
%//C       TEMP   -- TEMPERATURE IN CELSIUS DEGREES
%//C       COND   -- CONDUCTIVITY IN MICRO-MOHS
%//C
%//C       SALTY  -- SALINITY PSS 78
%//C
%//        REAL PRESS,TEMP,COND,SALTY
%//C
%//C     VARIABLES:
%//C     *********
%//C
%//         REAL*4 BARS,DELTAS,G,R,RISP0,RISSTD,RSTDIS,RSTRMS
%//C
%//C     CONSTANTS:
%//C     *********
%//C
%//        REAL STDCND
%//        PARAMETER (STDCND=42.914)

%//C         /* CONDUCTIVITY OF STANDARD SEA WATER -- DEFINED
%//C            PRESSURE=0.0, TEMPERATURE=15.0, SALINITY=35.0 */
%//C
%//C     CODE:
%//C     ****
%//C

%// test data
%//PRESS = 16.98; TEMP = 19.730;COND = 39.873;

% 17-jAN-2005 always convert temperature from t90 to t68 using matlab routine borrowed from Kiel

TEMP=t90tot68(TEMP);

STDCND=42.914;
G = COND;
RISSTD = G/STDCND;
%//C       /* RATIO OF IN SITU CONDUCTIVITY TO STD CONDUCTIVITY */
%//C
      BARS = PRESS.*0.10;
%//C       /* PRESSURE IN BARS */
%//C
     RISP0 = BARS.*(2.07E-4+BARS.*(-6.37E-8+3.989E-12.*BARS));
%//C       /* RATIO OF IN SITU CONDUCTIVITY TO COND AT SAME TEMP, BUT
%//C          PRESSURE=0.0 */
%//C
      R = 1.0 + TEMP.*(.03426+4.464E-4.*TEMP)+(.4215-.003107.*TEMP).*RISSTD;
      RISP0 = 1.0 + RISP0./R;
%//C
%      RSTDIS = TEMP .*(.0200564+TEMP.*(1.104259E-4+TEMP.*(-6.9698E-7
%                   +1.0031E-9.*TEMP)));
       RSTDIS = TEMP .*(.0200564+TEMP.*(1.104259E-4+TEMP.*(-6.9698E-7+1.0031E-9.*TEMP)));
                   
      RSTDIS = RSTDIS + .6766097;
      RSTDIS = RISSTD./(RISP0.*RSTDIS);
%//C       /* RATIO OF STD CONDUCTIVITY TO STD SEA WATER AT T=IN SITU */
%//C
%//     IF(RSTDIS.LT.0.) RSTDIS = 0.0
if  (RSTDIS < 0 )  
RSTDIS = 0; 
end
%      RSTRMS = SQRT(RSTDIS);
       RSTRMS = sqrt(RSTDIS);
%//C
      DELTAS = RSTRMS.*(-.0056+RSTRMS.*(-.0066+RSTRMS.*(-.0375+RSTRMS.*(.0636+RSTRMS.*(-.0144)))));
      DELTAS = DELTAS + 5.0E-4;
      DELTAS = (TEMP-15.0)./(1.0+.0162.*(TEMP-15.0)).*DELTAS;
%//C       /* RATIO AT 15 DEGREES */
%//C
      SALTY = RSTRMS.*(-.1692+RSTRMS.*(25.3851+RSTRMS.*(14.0941+RSTRMS.*(-7.0261+RSTRMS.*2.7081)))) + DELTAS + .008;
%//echo("SALTY");
%if (SALTY < 30)
%{     echo(" PRESS TEMP COND");   }
%return SALTY;
