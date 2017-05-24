function SIGMA = sigmat(T,S)

%//C
%//C      PROGRAM SIGMAT
%//C
%//C EXPECTS INPUT FILE "TS.DAT"
%//C OUTPUTS TO "TSST.DAT"
%//C
%//      FUNCTION SIGMA(T,S)
%//      REAL*8 S0,E1,E2,B1,B2
	 S0=((6.76786136E-6.* S - 4.8249614E-4).* S+0.814876577).* S- 0.0934458632 ;
	 E1=(((-1.4380306E-7.* T-0.00198248399).* T-0.545939111).* T + 4.53168426).* T  ;
	 B1=((-1.0843E-6.* T+9.8185E-5).* T-0.0047867).* T+1.  ;
	 B2=((1.667E-8.* T-8.164E-7).* T+1.803E-5).* T  ;
	 E2=( B2.* S0+ B1).* S0   ;
	 SIGMA= E1./( T+67.26) +  E2 ;
%//	RETURN
%//	END
%return $SIGMA;

