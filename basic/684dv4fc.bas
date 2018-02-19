100 REM  #######################################################################
110 REM 
120 REM     Distance variation of LF resultant field strength of 1 $ 2 hop
130 REM     sky-waves and ground-wave as well as its phase delay relative
140 REM     to ground-wave
150 REM 
160 REM                           by N. Wakai
170 REM 
180 REM                                               (684DV4FC.BAS)  Oct. 2005
190 REM  #######################################################################
200 REM 
210 REM   This program is applicable for calculating the distance variation of
220 REM   resultant field strength of 1 & 2 hop sky-wave and the ground-wave
230 REM   at frequencies between 40 and 500 kHz over ground ranges from 100 to
240 REM   4000 km as well as phase delay of resultant relative to ground-wave.
250 REM                                        (parabolic D/E layer model)
260 REM 
270 REM CLS
280 REM #INCLUDE "windows.bi"
290 DEFDBL A-C,E,G-H,O-Z
300 PAI=3.14159265#
310 VEL=2.99792458#*10^5
320 RTD=180/PAI :DTR=PAI/180
330 RE=6360*4/3
340 DIM F(8),D(16),FG(10),DG(19),GW(10,19),FF(8,16),PS(13),AF(8,13),FCS(15),CSX(11),RCX(11,15),DPHAS(5000),FSR(5000),DIST(5000)
350 REM 
360 REM CLS 3
370 PRINT
380 INPUT "input radiation power in kW";P
390 INPUT "input operating frequency in kHz";FREQ
400 LAMD=VEL/FREQ/1000
410 INPUT "input latitude of transmitter in degree and its decimals with - for southern latitude";LATT
420 INPUT "input longitude of transmitter in degree and its decimals with -for western longitude";LONT
430 INPUT "input minimum(>100), maximum(<4000) and step(>1) distances of propagation in km as 100,1000,5";DMIN,DMAX,DSTP
440 INPUT "input azimuthal angle to receiver from transmitter in degrees measured clockwise from north ";AZIM
450 REM 
460 INPUT "input ground condition at transmitter, 1 for sea water or                                                              2 for land or                                                                   3 for dry ground";GCT
470 INPUT "input averaged ground condition at receiver, 1 for sea water or                                                              2 for land or                                                                   3 for dry ground";GCR
480 REM 
490 INPUT "input solar activity epoch, 1 for minimum sunspot number or                                                 2 for medium sunspot number or                                                  3 for maximum sunspot number";YR
500 INPUT "input month, 1 for January, or 2 for February or to 12 for December";MON
510 IF MON=1 THEN SOL=-21 ELSE IF MON=2 THEN SOL=-13 ELSE IF MON=3 THEN SOL=-2 ELSE IF MON=4 THEN SOL=10 ELSE IF MON=5 THEN SOL=19 ELSE IF MON=6 THEN SOL=23
520 IF MON=7 THEN SOL=22 ELSE IF MON=8 THEN SOL=14 ELSE IF MON=9 THEN SOL=3 ELSE IF MON=10 THEN SOL=-8 ELSE IF MON=11 THEN SOL=-18 ELSE IF MON=12 THEN SOL=-23
530 INPUT "input local time at transmitter";LT
540 INPUT "input local standard time meridian longitude in degree, + for east,                                                                     - for west";LSTM
550 LATT=LATT*DTR: LONT=LONT*DTR: AZIM=AZIM*DTR
560 REM 
570 OPEN "lfdata.dat" AS #1 :CLOSE #1 :KILL "lfdata.dat"
580 OPEN "lfdata.dat" FOR OUTPUT AS #1
590 J=1
600 FOR I=DMIN TO DMAX STEP DSTP
610 DIST(J)=I :CA=DIST(J)/6367
620 REM 
630 REM   reflection point coordinate and height
640 PCOS=COS(CA/2)*SIN(LATT)+SIN(CA/2)*COS(LATT)*COS(AZIM)
650 PSIN=SQR(1-PCOS^2)
660 IF PSIN/PCOS<0 THEN LATP=-PAI/2-ATN(PSIN/PCOS) ELSE LATP=PAI/2-ATN(PSIN/PCOS)
670 QCOS=(COS(CA/2)-SIN(LATP)*SIN(LATT))/COS(LATP)/COS(LATT)
680 IF QCOS>1 THEN QCOS=1
690 QSIN=SQR(1-QCOS^2)
700 IF LONT>0 AND LONT<PAI THEN LONP=LONT+ATN(QSIN/QCOS) ELSE LONP=LONT-ATN(QSIN/QCOS)
710 LATP=LATP*RTD :LONP=LONP*RTD
720 GOSUB 2470 REM *REFH
730 REM 
740 FOR K=1 TO 2
750 HOP=K
760 REM   ray path length, elevation and incidence angles and delay
770 PL=2*SQR(RE*RE+(RE+HR)^2-2*RE*(RE+HR)*COS(DIST(J)/2/RE/HOP))
780 PSI=ATN(1/TAN(DIST(J)/2/RE/HOP)-RE/(RE+HR)/SIN(DIST(J)/2/RE/HOP))
790 INC=PAI/2-DIST(J)/2/RE/HOP-PSI
800 FC=FREQ*COS(INC) :IF FC<5 THEN FC=5
810 DTIM=HOP*(PL-DIST(J)/HOP)/VEL*10^6
820 DPH=(HOP*(PL-DIST(J)/HOP)/LAMD-INT(HOP*(PL-DIST(J)/HOP)/LAMD))*360
830 IF HOP=1 THEN DPH1=DPH ELSE DPH2=DPH
840 REM 
850 REM   focusing factor
860 RESTORE 3860
870 FOR M=1 TO 8:READ F(M):NEXT M
880 FOR N=1 TO 16 :READ D(N):NEXT N
890 RESTORE 3880
900 FOR M=1 TO 8
910 FOR N=1 TO 16
920 READ FF(M,N)
930 NEXT N
940 NEXT M
950 GOSUB 2890 REM *INTFF
960 REM 
970 REM   transmitting antenna factor
980 PSI=PSI*RTD
990 RESTORE 3970
1000 FOR M=1 TO 13
1010 READ PS(M)
1020 NEXT M
1030 IF GCT=1 THEN GOTO 1040 ELSE IF GCT=2 THEN GOTO 1050 ELSE GOTO 1060
1040 RESTORE 3980 :GOTO 1070
1050 RESTORE 4070 :GOTO 1070
1060 RESTORE 4160 :GOTO 1070
1070 FOR M=1 TO 8
1080 FOR N=1 TO 13
1090 READ AF(M,N)
1100 NEXT N
1110 NEXT M
1120 GOSUB 3210 REM *INTAF
1130 FT=ANT
1140 REM 
1150 REM   receiving antenna factor
1160 IF GCR=1 THEN GOTO 1170 ELSE IF GCR=2 THEN GOTO 1180 ELSE GOTO 1190
1170 RESTORE 3980 :GOTO 1200
1180 RESTORE 4070 :GOTO 1200
1190 RESTORE 4160 :GOTO 1200
1200 FOR M=1 TO 8
1210 FOR N=1 TO 13
1220 READ AF(M,N)
1230 NEXT N
1240 NEXT M
1250 GOSUB 3210 REM *INTAF
1260 FR=ANT
1270 REM 
1280 REM  ionospheric reflection coefficient
1290 RESTORE 4240
1300 FOR M=1 TO 11
1310 READ CSX(M)
1320 NEXT M
1330 RESTORE 4250
1340 FOR N=1 TO 15
1350 READ FCS(N)
1360 NEXT N
1370 IF YR=1 THEN GOTO 1380 ELSE IF YR=2 THEN GOTO 1390 ELSE IF YR=3 THEN GOTO 1400
1380 RESTORE 4270 :GOTO 1410
1390 RESTORE 4390 :GOTO 1410
1400 RESTORE 4510 :GOTO 1410
1410 FOR M=1 TO 11
1420 FOR N=1 TO 15
1430 READ RCX(M,N)
1440 NEXT N
1450 NEXT M
1460 GOSUB 3530 REM *INTRC
1470 REM 
1480 REM   reflection coefficient of ground
1490 PSI=PSI*DTR
1500 IF HOP=1 THEN GOTO 1660
1510 IF GCR=1 THEN EPS=80 ELSE IF GCR=2 THEN EPS=15 ELSE IF GCR=3 THEN EPS=15
1520 IF GCR=1 THEN SIGMA=5 ELSE IF GCR=2 THEN SIGMA=.002 ELSE IF GCR=3 THEN SIGMA=.0005
1530 X=18000*SIGMA/FREQ*1000 :ROH=SQR((EPS-COS(PSI)^2)^2+X*X)
1540 A=-ATN(X/(EPS-COS(PSI)^2)) :B=X/SQR(EPS^2+X^2)
1550 RG=SQR(ROH^2+(EPS^2+X*X)^2*SIN(PSI)^4-2*ROH*(EPS^2+X^2)*SIN(PSI)^2*COS(A+2*ATN(B/SQR(1-B*B))))/(ROH+(EPS^2+X*X)*SIN(PSI)^2+2*SQR(ROH)*SQR(EPS^2+X*X)*SIN(PSI)*COS(A/2+ATN(B/SQR(1-B*B))))
1560 IF (EPS^2+X*X)*SIN(PSI)^2-ROH=0 AND SIN(PSI)*SIN(ATN(X/EPS)+A/2)=0 THEN PHAS=0 ELSE GOTO 1580
1570 GOTO 1650
1580 IF (EPS^2+X*X)*SIN(PSI)^2-ROH=0 AND SIN(PSI)*SIN(ATN(X/EPS)+A/2)>0 THEN PHAS=PAI/2 ELSE GOTO 1600
1590 GOTO 1650
1600 IF (EPS^2+X*X)*SIN(PSI)^2-ROH=0 AND SIN(PSI)*SIN(ATN(X/EPS)+A/2)<0 THEN PHAS=-PAI/2 ELSE GOTO 1620
1610 GOTO 1650
1620 IF ROH-(EPS^2+X*X)*SIN(PSI)^2>0 THEN PHAS=-ATN(2*SQR(ROH)*SQR(EPS^2+X*X)*SIN(PSI)*SIN(ATN(X/EPS)+A/2)/(ROH-(EPS^2+X*X)*SIN(PSI)^2))+PAI ELSE GOTO 1640
1630 GOTO 1650
1640 IF ROH-(EPS^2+X*X)*SIN(PSI)^2<0 THEN PHAS=-ATN(2*SQR(ROH)*SQR(EPS^2+X*X)*SIN(PSI)*SIN(ATN(X/EPS)+A/2)/(ROH-(EPS^2+X*X)*SIN(PSI)^2))
1650 REM 
1660 REM   skywave field strength
1670 VU=300*SQR(P)
1680 ET=VU/PL*COS(PSI)*RC*FOC*FT
1690 IF HOP=2 THEN GOTO 1730
1700 EL1=2*VU/PL*COS(PSI)*RC*FOC*FT*FR
1710 FS1=20*LOG(EL1*1000)/LOG(10)
1720 GOTO 1750
1730 EL2=2*VU/PL/2*COS(PSI)*RC*RC*RG*FOC*FT*FR
1740 FS2=20*LOG(EL2*1000)/LOG(10)
1750 NEXT K
1760 REM 
1770 REM   ground-wave and resultant field strength
1780 GOSUB 4640 REM *GWAVE
1790 G=10^(GWS/20)*.001
1800 REM 
1810 DPH1=DPH1*DTR :DPH2=DPH2*DTR
1820 RLG=SQR(EL1^2+G^2+2*EL1*G*COS(DPH1))
1830 SINSK=EL1*SIN(DPH1)/RLG
1840 IF ABS(SINSK)>1 THEN SINSK=.99999
1850 COSSK=SQR(1-SINSK^2) :SK=ATN(SINSK/COSSK)
1860 IF SK<0 THEN SK=SK+2*PAI
1870 RL=SQR(RLG^2+EL2^2+2*RLG*EL2*COS(DPH2+PHAS-SK))
1880 SD12G=EL2*SIN(DPH2+PHAS-SK)/RL
1890 IF ABS(SD12G)>1 THEN SD12G=.99999
1900 CD12G=SQR(1-SD12G^2) :D12G=ATN(SD12G/CD12G)
1910 IF D12G<0 THEN D12G=D12G+2*PAI
1920 RLDB=20*LOG(RL*1000)/LOG(10)
1930 FSR(J)=20*LOG(RL*1000)/LOG(10)
1940 DPHAS=D12G+SK
1950 IF DPHAS>2*PAI THEN DPHAS=DPHAS-INT(DPHAS/2/PAI)*2*PAI
1960 DPHAS(J)=DPHAS*RTD/10
1970 PRINT #1, USING "  ####.##   ###.###   ####.###   ###.##  ";DIST(J);FSR(J);GWS;DPHAS(J)
1980 J=J+1
1990 NEXT I
2000 CLOSE #1
2010 INPUT "input 1 for table output, or                                                          2 for graphic output";OPT
2020 OPEN "lfdata.dat" FOR INPUT AS #1
2030 IF OPT=1 THEN GOTO 2320
2040 CONSOLE 0,24 : WIDTH "scrn:",80
2050 COLOR 0,15
2060 CLS
2070 WINDOW (0,0)-(4000,100): VIEW(25,15)-(629,330)
2080 FOR M=0 TO 4000 STEP 200
2090 XC=M
2100 LINE(XC,0)-(XC,100),PSET,0
2110 NEXT M
2120 FOR N=0 TO 100 STEP 10
2130 YC=N
2140 LINE(0,YC)-(4000,YC),PSET,0
2150 NEXT N
2160 LOCATE 1,0:PRINT "dB"
2170 LOCATE 0,1:PRINT "100"
2180 LOCATE 1,9:PRINT "50"
2190 LOCATE 4,12:PRINT "360"
2200 LOCATE 1,18:PRINT "0"
2210 LOCATE 3,19:PRINT "0                                    2Mm                                  4Mm
2220 C=5
2230 IF EOF(1) THEN GOTO 2360 REM *FIN REM *LFV :
2240 INPUT #1, DIST,FSR,GWS,DPHAS
2250 X=DIST :Y1=100-FSR
2260 circle(X,Y1),0.2,C
2270 Y2=100-GWS
2280 circle(X,Y2),0.2,0
2290 Y3=100-DPHAS
2300 circle(X,Y3),0.2,3
2310 GOTO 2230 REM *LFV
2320 IF EOF(1) THEN GOTO 2360 REM *FIN REM *LFVT :
2330 INPUT #1,DIST,FSR,GWS,DPHAS
2340 PRINT USING "  ####.##   ###.###   ####.###   ###.## ";DIST;FSR;GWS;DPHAS
2350 GOTO 2320 REM *LFVT
2360 CLOSE #1 REM *FIN :
2370 WINHARDC
2380 PRINT
2390 PRINT "Do you continue calculation? (Y/N)";
2400 Q$=INKEY$ :IF Q$="" THEN GOTO 2400
2410 IF Q$="N" OR Q$="n" THEN GOTO 2430
2420 IF Q$="Y" OR Q$="y" THEN GOTO 360
2430 STOP
2440 END
2450 REM 
2460 REM   reflection height subroutine
2470 REM *REFH
2480 IF YR=1 THEN SSN=13 ELSE IF YR=2 THEN SSN=50 ELSE IF YR=3 THEN SSN=100
2490 PHI=SSN+46-23*EXP(-.05*SSN)
2500 FMIN=(.004*(1+.021*PHI)^2)^.25*1000
2510 AP=1+.0094*(PHI-66)
2520 IF ABS(LATP-SOL)<80 THEN NF=LATP-SOL ELSE IF ABS(LATP-SOL)>=80 THEN NF=80
2530 IF ABS(LATP)<32 THEN MF=-1.93+1.92*COS(LATP*DTR) ELSE IF ABS(LATP)>=32 THEN MF=.11-.49*COS(LATP*DTR)
2540 BP=COS(NF*DTR)^MF
2550 IF ABS(LATP)<32 THEN XP=23 ELSE IF ABS(LATP)>=32 THEN XP=92
2560 IF ABS(LATP)<32 THEN YP=116 ELSE IF ABS(LATP)>=32 THEN YP=35
2570 CP=XP+YP*COS(LATP*DTR)
2580 IF ABS(LATP)<=12 THEN PF=1.31 ELSE IF ABS(LATP)>12 THEN PF=1.2
2590 IF LATP>0 AND SOL>0 THEN KMIN=ABS(LATP)-ABS(SOL) ELSE IF LATP<0 AND SOL<0 THEN KMIN=ABS(LATP)-ABS(SOL)
2600 KMIN=ABS(KMIN)
2610 IF LATP>0 AND SOL<0 THEN KMIN=ABS(LATP)+ABS(SOL) ELSE IF LATP<0 AND SOL>0 THEN KMIN=ABS(LATP)+ABS(SOL)
2620 IF KMIN>90 THEN KMIN=89
2630 DPM=COS(KMIN*DTR)^PF
2640 FK0=(AP*CP)^.25*1000
2650 FMAX=(AP*BP*CP*DPM)^.25*1000
2660 IF FMAX<350 THEN FMAX=350
2670 LTP=LT-(LONT*RTD-LONP)/15
2680 COSK=SIN(LATP*DTR)*SIN(SOL*DTR)+COS(LATP*DTR)*COS(SOL*DTR)*COS(PAI-15*DTR*LTP+LSTM*DTR-LONP*DTR)
2690 SINK=SQR(1-COSK^2)
2700 KAI=ATN(SINK/COSK) :IF COSK<0 THEN KAI=PAI+KAI
2710 KAI=KAI*RTD
2720 IF KAI<=73 THEN DP=COS(KAI*DTR)^PF ELSE IF KAI>73 THEN GOTO 2740
2730 GOTO 2780
2740 IF KAI>73 AND KAI<90 THEN DKAI=6.27*10^-13*(KAI-50)^8 ELSE IF KAI>=90 THEN GOTO 2770
2750 DP=COS(KAI*DTR-DKAI*DTR)^PF
2760 GOTO 2780
2770 DP=.072^PF*EXP(25.2-.28*KAI)
2780 FOE=(AP*BP*CP*DP)^.25*1000
2790 IF FOE<FMIN THEN FOE=FMIN ELSE IF FOE>=FMIN THEN FOE=FOE
2800 YMM=30-20*(FK0-FMAX)/(FK0-FMIN)
2810 YM=YMM-(YMM-10)*(FMAX-FOE)/(FMAX-FMIN)
2820 IF FOE>FREQ THEN GOTO 2830 ELSE GOTO 2850
2830 HR=100-YM*SQR(1-(FREQ-10)/FOE)
2840 GOTO 2860
2850 HR=100
2860 RETURN
2870 REM 
2880 REM   focusing factor subroutine
2890 REM *INTFF
2900 FOR N=1 TO 16
2910 IF DIST(J)/HOP=D(N) THEN GOTO 3080
2920 NEXT N
2930 FOR N=1 TO 15
2940 IF D(N)<DIST(J)/HOP AND DIST(J)/HOP<D(N+1) THEN GOTO 2960
2950 NEXT N
2960 FOR M=1 TO 8
2970 IF FREQ=F(M) THEN GOTO 3020
2980 NEXT M
2990 FOR M=1 TO 7
3000 IF F(M)<FREQ AND FREQ<F(M+1) THEN GOTO 3040
3010 NEXT M
3020 FOC=FF(M,N)+(FF(M,N+1)-FF(M,N))*(DIST(J)/HOP-D(N))/(D(N+1)-D(N))
3030 GOTO 3180
3040 FFM1=FF(M,N)+(FF(M,N+1)-FF(M,N))*(DIST(J)/HOP-D(N))/(D(N+1)-D(N))
3050 FFM2=FF(M+1,N)+(FF(M+1,N+1)-FF(M+1,N))*(DIST(J)/HOP-D(N))/(D(N+1)-D(N))
3060 FOC=FFM1+(FFM2-FFM1)*(FREQ-F(M))/(F(M+1)-F(M))
3070 GOTO 3180
3080 REM FREQINT
3090 FOR M=1 TO 8
3100 IF FREQ=F(M) THEN GOTO 3150
3110 NEXT M
3120 FOR M=1 TO 7
3130 IF F(M)<FREQ AND FREQ<F(M+1) THEN GOTO 3170
3140 NEXT M
3150 FOC=FF(M,N)
3160 GOTO 3180
3170 FOC=FF(M,N)+(FF(M+1,N)-FF(M,N))*(FREQ-F(M))/(F(M+1)-F(M))
3180 RETURN
3190 REM 
3200 REM   antenna factor subroutine
3210 REM *INTAF
3220 FOR N=1 TO 13
3230 IF PSI=PS(N) THEN GOTO 3400
3240 NEXT N
3250 FOR N=1 TO 12
3260 IF PS(N)>PSI AND PSI>PS(N+1) THEN GOTO 3280
3270 NEXT N
3280 FOR M=1 TO 8
3290 IF FREQ=F(M) THEN GOTO 3340
3300 NEXT M
3310 FOR M=1 TO 7
3320 IF F(M)<FREQ AND FREQ<F(M+1) THEN GOTO 3360
3330 NEXT M
3340 ANT=AF(M,N)+(AF(M,N+1)-AF(M,N))*(PSI-PS(N))/(PS(N+1)-PS(N))
3350 GOTO 3500
3360 AFM1=AF(M,N)+(AF(M,N+1)-AF(M,N))*(PSI-PS(N))/(PS(N+1)-PS(N))
3370 AFM2=AF(M+1,N)+(AF(M+1,N+1)-AF(M+1,N))*(PSI-PS(N))/(PS(N+1)-PS(N))
3380 ANT=AFM1+(AFM2-AFM1)*(FREQ-F(M))/(F(M+1)-F(M))
3390 GOTO 3500
3400 REM freqint
3410 FOR M=1 TO 8
3420 IF FREQ=F(M) THEN GOTO 3470
3430 NEXT M
3440 FOR M=1 TO 7
3450 IF F(M)<FREQ AND FREQ<F(M+1) THEN GOTO 3490
3460 NEXT M
3470 ANT=AF(M,N)
3480 GOTO 3500
3490 ANT=AF(M,N)+(AF(M+1,N)-AF(M,N))*(FREQ-F(M))/(F(M+1)-F(M))
3500 RETURN
3510 REM 
3520 REM   ionospheric reflection coefficient subroutine
3530 *INTRC
3540 FOR N=1 TO 15
3550 IF FC=FCS(N) THEN GOTO 3720
3560 NEXT N
3570 FOR N=1 TO 14
3580 IF FCS(N)<FC AND FC<FCS(N+1) THEN GOTO 3600
3590 NEXT N
3600 FOR M=1 TO 11
3610 IF COSK=CSX(M) THEN GOTO 3660
3620 NEXT M
3630 FOR M=1 TO 10
3640 IF CSX(M)<COSK AND COSK=<CSX(M+1) THEN GOTO 3680
3650 NEXT M
3660 RC=RCX(M,N)+(RCX(M,N+1)-RCX(M,N))*(FC-FCS(N))/(FCS(N+1)-FCS(N))
3670 GOTO 3830
3680 RCM1=RCX(M,N)+(RCX(M,N+1)-RCX(M,N))*(FC-FCS(N))/(FCS(N+1)-FCS(N))
3690 RCM2=RCX(M+1,N)+(RCX(M+1,N+1)-RCX(M+1,N))*(FC-FCS(N))/(FCS(N+1)-FCS(N))
3700 RC=RCM1+(RCM2-RCM1)*(COSK-CSX(M))/(CSX(M+1)-CSX(M))
3710 GOTO 3830
3720 FOR M=1 TO 11
3730 IF COSK=CSX(M) THEN GOTO 3780
3740 NEXT M
3750 FOR M=1 TO 10
3760 IF CSX(M)<COSK AND COSK=<CSX(M+1) THEN GOTO 3800
3770 NEXT M
3780 RC=RCX(M,N)
3790 GOTO 3830
3800 RC=RCX(M,N)+(RCX(M+1,N)-RCX(M,N))*(COSK-CSX(M))/(CSX(M+1)-CSX(M))
3810 GOTO 3830
3820 RC=RCX(M,N)
3830 RC=10^RC
3840 RETURN
3850 REM 
3860 DATA 20,50,100,150,200,300,400,500
3870 DATA 50,200,400,800,1000,1200,1400,1500,1600,1700,1800,1900,2000,2500,3000,4000
3880 DATA 1,1.02,1.06,1.2,1.29,1.40,1.53,1.58,1.61,1.64,1.66,1.68,1.70,1.89,1.89,1.89
3890 DATA 1,1.02,1.06,1.2,1.30,1.46,1.62,1.70,1.78,1.84,1.89,1.94,1.99,2.22,2.22,2.22
3900 DATA 1,1.02,1.06,1.2,1.31,1.48,1.69,1.80,1.92,2.03,2.11,2.17,2.22,2.47,2.47,2.47
3910 DATA 1,1.02,1.06,1.2,1.32,1.50,1.73,1.85,1.99,2.12,2.22,2.30,2.37,2.64,2.64,2.64
3920 DATA 1,1.02,1.06,1.2,1.32,1.51,1.74,1.88,2.03,2.19,2.31,2.40,2.49,2.79,2.79,2.79
3930 DATA 1,1.02,1.06,1.2,1.32,1.52,1.76,1.90,2.07,2.25,2.40,2.50,2.60,2.89,2.89,2.89
3940 DATA 1,1.02,1.06,1.2,1.32,1.52,1.76,1.90,2.07,2.25,2.40,2.50,2.60,2.89,2.89,2.89
3950 DATA 1,1.02,1.06,1.2,1.32,1.52,1.76,1.90,2.07,2.25,2.40,2.50,2.60,2.89,2.89,2.89
3960 REM 
3970 DATA 80,15,10,7.5,5,3.75,2.5,1.25,0,-1.25,-2.5,-5,-7.5
3980 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.70,0.60,0.50,0.33,0.22
3990 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.70,0.575,0.447,0.263,0.14
4000 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.68,0.55,0.4,0.19,0.085
4010 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.66,0.525,0.36,0.15,0.05
4020 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.65,0.5,0.324,0.12,0.043
4030 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.636,0.48,0.29,0.088,0.025
4040 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.626,0.46,0.26,0.07,0.02
4050 DATA 1,1,1,0.98,0.95,0.91,0.87,0.8,0.617,0.44,0.24,0.06,0.016
4060 REM 
4070 DATA 0.95,0.95,0.92,0.90,0.83,0.8,0.75,0.68,0.6,0.525,0.44,0.3,0.2
4080 DATA 0.92,0.92,0.87,0.8,0.74,0.7,0.63,0.575,0.48,0.4,0.33,0.2,0.12
4090 DATA 0.81,0.81,0.79,0.75,0.68,0.616,0.52,0.457,0.35,0.26,0.18,0.076,0.027
4100 DATA 0.78,0.78,0.75,0.71,0.63,0.55,0.46,0.38,0.26,0.17,0.1,0.03,0.005
4110 DATA 0.76,0.76,0.71,0.67,0.58,0.5,0.41,0.324,0.21,0.13,0.063,0.013,0.0021
4120 DATA 0.7,0.7,0.65,0.64,0.55,0.47,0.37,0.26,0.16,0.08,0.034,0.0035,0.0004
4130 DATA 0.65,0.65,0.62,0.61,0.52,0.44,0.34,0.24,0.14,0.06,0.02,0.0016,0.0001
4140 DATA 0.6,0.6,0.6,0.58,0.5,0.417,0.33,0.23,0.13,0.05,0.013,0.0008,0.00004
4150 REM 
4160 DATA 0.9,0.89,0.83,0.79,0.72,0.68,0.63,0.57,0.51,0.45,0.38,0.26,0.17
4170 DATA 0.8,0.79,0.73,0.67,0.6,0.54,0.47,0.4,0.33,0.25,0.18,0.09,0.041
4180 DATA 0.7,0.69,0.65,0.6,0.51,0.45,0.38,0.3,0.22,0.13,0.073,0.02,0.0045
4190 DATA 0.61,0.6,0.57,0.53,0.45,0.39,0.33,0.24,0.16,0.084,0.04,0.007,0.001
4200 DATA 0.53,0.52,0.5,0.46,0.40,0.35,0.28,0.20,0.12,0.06,0.025,0.0035,0.00041
4210 DATA 0.46,0.45,0.44,0.41,0.36,0.31,0.25,0.17,0.09,0.038,0.013,0.0013,0.00014010 DATA 0.4,0.39,0.38,0.37,0.33,0.28,0.22,0.15,0.07,0.026,0.008,0.00068,0.00005
4220 DATA 0.34,0.34,0.34,0.33,0.3,0.26,0.20,0.13,0.06,0.02,0.006,0.00043,0.00003
4230 REM 
4240 DATA -1,-0.5,-0.35,-0.21,0,0.2,0.375,0.55,0.707,0.85,1
4250 DATA 5,8,10,15,20,30,40,50,75,100,150,200,300,400,500
4260 REM  ssn min
4270 DATA -0.33,-0.34,-0.35,-0.36,-0.4,-0.47,-0.52,-0.56,-0.64,-0.7,-0.76,-0.76,-0.72,-0.66,-0.6
4280 DATA -0.33,-0.34,-0.35,-0.36,-0.4,-0.47,-0.52,-0.56,-0.64,-0.7,-0.76,-0.76,-0.72,-0.66,-0.6
4290 DATA -0.33,-0.34,-0.35,-0.39,-0.44,-0.53,-0.61,-0.67,-0.79,-0.85,-0.91,-0.91,-0.87,-0.81,-0.76
4300 DATA -0.33,-0.34,-0.36,-0.41,-0.48,-0.6,-0.72,-0.81,-0.95,-1.02,-1.07,-1.07,-1.03,-0.97,-0.92
4310 DATA -0.36,-0.37,-0.39,-0.48,-0.59,-0.76,-0.97,-1.07,-1.24,-1.36,-1.4,-1.42,-1.37,-1.35,-1.34
4320 DATA -0.39,-0.41,-0.44,-0.56,-0.72,-0.95,-1.18,-1.32,-1.53,-1.66,-1.74,-1.78,-1.82,-1.81,-1.8
4330 DATA -0.43,-0.45,-0.49,-0.63,-0.82,-1.1,-1.34,-1.51,-1.76,-1.92,-2.06,-2.14,-2.24,-2.3,-2.34
4340 DATA -0.47,-0.5,-0.54,-0.74,-0.92,-1.24,-1.48,-1.66,-1.95,-2.15,-2.34,-2.46,-2.57,-2.72,-2.83
4350 DATA -0.52,-0.54,-0.59,-0.83,-1.05,-1.4,-1.64,-1.8,-2.1,-2.3,-2.58,-2.75,-2.92,-3.03,-3.1
4360 DATA -0.6,-0.66,-0.74,-1.03,-1.4,-1.81,-2.02,-2.2,-2.54,-2.82,-3.1,-3.26,-3.24,-3.21,-3.18
4370 DATA -0.76,-0.8,-0.9,-1.46,-2,-2.9,-3.45,-3.7,-3.93,-3.99,-3.97,-3.87,-3.66,-3.41,-3.2
4380 REM  ssn med
4390 DATA -0.3,-0.31,-0.32,-0.33,-0.37,-0.43,-0.47,-0.51,-0.58,-0.64,-0.71,-0.73,-0.76,-0.76,-0.75
4400 DATA -0.3,-0.31,-0.32,-0.33,-0.37,-0.43,-0.47,-0.51,-0.58,-0.64,-0.71,-0.73,-0.76,-0.76,-0.75
4410 DATA -0.3,-0.31,-0.32,-0.36,-0.41,-0.49,-0.56,-0.61,-0.71,-0.76,-0.84,-0.87,-0.89,-0.88,-0.88
4420 DATA -0.3,-0.31,-0.33,-0.38,-0.44,-0.55,-0.65,-0.73,-0.85,-0.92,-1,-1.04,-1.07,-1.06,-1.06
4430 DATA -0.33,-0.34,-0.36,-0.44,-0.52,-0.64,-0.81,-0.91,-1.1,-1.22,-1.33,-1.39,-1.45,-1.51,-1.58
4440 DATA -0.36,-0.38,-0.40,-0.5,-0.62,-0.79,-0.98,-1.15,-1.36,-1.5,-1.66,-1.76,-1.92,-2.03,-2.14
4450 DATA -0.40,-0.42,-0.44,-0.57,-0.7,-0.93,-1.13,-1.29,-1.57,-1.76,-1.98,-2.12,-2.34,-2.49,-2.64
4460 DATA -0.44,-0.47,-0.5,-0.67,-0.83,-1.1,-1.33,-1.5,-1.83,-2.06,-2.32,-2.49,-2.69,-2.85,-2.98
4470 DATA -0.49,-0.51,-0.56,-0.77,-0.99,-1.32,-1.57,-1.75,-2.1,-2.35,-2.66,-2.84,-3.01,-3.13,-3.2
4480 DATA -0.57,-0.62,-0.7,-0.97,-1.33,-1.81,-2.07,-2.3,-2.68,-2.94,-3.19,-3.31,-3.34,-3.35,-3.33
4490 DATA -0.72,-0.77,-0.86,-1.31,-1.9,-2.74,-3.23,-3.5,-3.85,-3.95,-3.98,-3.92,-3.76,-3.58,-3.42
4500 REM  ssn max
4510 DATA -0.27,-0.27,-0.28,-0.3,-0.34,-0.38,-0.42,-0.46,-0.52,-0.57,-0.65,-0.7,-0.8,-0.85,-0.89
4520 DATA -0.27,-0.27,-0.28,-0.3,-0.34,-0.38,-0.42,-0.46,-0.52,-0.57,-0.65,-0.7,-0.8,-0.85,-0.89
4530 DATA -0.27,-0.27,-0.28,-0.32,-0.37,-0.44,-0.5,-0.55,-0.62,-0.67,-0.76,-0.82,-0.91,-0.95,-1.01
4540 DATA -0.27,-0.27,-0.29,-0.34,-0.4,-0.5,-0.58,-0.64,-0.74,-0.82,-0.93,-1,-1.1,-1.16,-1.2
4550 DATA -0.29,-0.30,-0.32,-0.39,-0.44,-0.52,-0.64,-0.74,-0.96,-1.08,-1.25,-1.36,-1.53,-1.67,-1.81
4560 DATA -0.32,-0.33,-0.36,-0.44,-0.5,-0.62,-0.78,-0.9,-1.18,-1.34,-1.57,-1.73,-2.02,-2.26,-2.48
4570 DATA -0.35,-0.36,-0.40,-0.5,-0.57,-0.76,-0.92,-1.06,-1.38,-1.6,-1.9,-2.1,-2.44,-2.68,-2.89
4580 DATA -0.39,-0.41,-0.45,-0.6,-0.73,-0.95,-1.17,-1.34,-1.69,-1.96,-2.29,-2.52,-2.8,-2.97,-3.13
4590 DATA -0.45,-0.48,-0.52,-0.7,-0.92,-1.24,-1.5,-1.7,-2.09,-2.4,-2.73,-2.92,-3.1,-3.22,-3.3
4600 DATA -0.54,-0.58,-0.65,-0.9,-1.25,-1.8,-2.11,-2.4,-2.81,-3.06,-3.28,-3.36,-3.43,-3.48,-3.48
4610 DATA -0.67,-0.74,-0.82,-1.15,-1.8,-2.58,-3,-3.3,-3.75,-3.9,-3.98,-3.97,-3.85,-3.74,-3.64
4620 REM 
4630 REM  Ground Wave field strength based on Rec. P.368
4640 REM *GWAVE
4650 RESTORE 5260
4660 FOR M=1 TO 10 :READ FG(M) :NEXT M
4670 FOR N=1 TO 19 :READ DG(N) :NEXT N
4680 IF GCT=1 THEN GOTO 4690 ELSE IF GCT=2 THEN GOTO 4760 ELSE GOTO 4830
4690 RESTORE 5290
4700 FOR M=1 TO 10
4710 FOR N=1 TO 19
4720 READ GW(M,N)
4730 NEXT N
4740 NEXT M
4750 GOTO *INTGW
4760 RESTORE 5400
4770 FOR M=1 TO 10
4780 FOR N=1 TO 19
4790 READ GW(M,N)
4800 NEXT N
4810 NEXT M
4820 GOTO *INTGW
4830 RESTORE 5510
4840 FOR M=1 TO 10
4850 FOR N=1 TO 19
4860 READ GW(M,N)
4870 NEXT N
4880 NEXT M
4890 GOTO *INTGW
4900 GWS=GWS+10*LOG(P)/LOG(10)
4910 RETURN
4920 REM 
4930 *INTGW
4940 FOR N=1 TO 19
4950 IF DIST(J)=DG(N) THEN GOTO 5130
4960 NEXT N
4970 FOR N=1 TO 18
4980 IF DG(N)<DIST(J) AND DIST(J)<DG(N+1) THEN GOTO 5000
4990 NEXT N
5000 FOR M=1 TO 10
5010 IF FREQ=FG(M) THEN GOTO 5060
5020 NEXT M
5030 FOR M=1 TO 9
5040 IF FG(M)<FREQ AND FREQ<FG(M+1) THEN GOTO 5080
5050 NEXT M
5060 GWS=GW(M,N)+(GW(M,N+1)-GW(M,N))*(DIST(J)-DG(N))/(DG(N+1)-DG(N))
5070 GOTO 5230
5080 REM distance interpolation
5090 GWM1=GW(M,N)+(GW(M,N+1)-GW(M,N))*(DIST(J)-DG(N))/(DG(N+1)-DG(N))
5100 GWM2=GW(M+1,N)+(GW(M+1,N+1)-GW(M+1,N))*(DIST(J)-DG(N))/(DG(N+1)-DG(N))
5110 GWS=GWM1+(GWM2-GWM1)*(FREQ-FG(M))/(FG(M+1)-FG(M))
5120 GOTO 5230
5130 REM frequency interpolation
5140 FOR M=1 TO 10
5150 IF FREQ=FG(M) THEN GOTO 5200
5160 NEXT M
5170 FOR M=1 TO 9
5180 IF FG(M)<FREQ AND FREQ<FG(M+1) THEN GOTO 5220
5190 NEXT M
5200 GWS=GW(M,N)
5210 GOTO 5230
5220 GWS=GW(M,N)+(GW(M+1,N)-GW(M,N))*(FREQ-FG(M))/(FG(M+1)-FG(M))
5230 GOTO 4900
5240 REM 
5250 REM ground wave field strength data
5260 DATA 20,40,50,75,100,150,200,300,400,500
5270 DATA 50,100,150,200,300,400,500,600,700,800,900,1000,1200,1400,1600,1800,2000,3000,4000
5280 REM 
5290 DATA 75,69,65.2,62.7,58.7,55.9,53,51,49,47.5,46,44,41,37.5,34,31,27.5,13,-1
5300 DATA 75,68.8,65,62.5,58.4,55.5,52.5,50.1,48.2,45.8,43.9,42,38,34,30.2,26.3,22.5,5,-11.5
5310 DATA 75,68.7,64.9,62.2,58.1,55,51.7,49.1,47.1,44.8,42.9,41,36.5,32.5,28.5,24.5,20.4,1.5,-16
5320 DATA 75,68.6,64.7,62,57.8,54.4,50.9,48.1,46.0,43.8,41.9,39,35,30.5,26.2,22,17.5,-3,-23
5330 DATA 75,68.5,64.6,61.8,57.5,53.8,50.1,47.1,44.7,42.5,40.4,37.5,33,28.5,24,19,14.5,-8,-29
5340 DATA 75,68.4,64.4,61.6,57.2,53.2,49.3,46.1,43.5,41.3,38.9,36,31,26,20.5,15.4,10,-14.5,-36
5350 DATA 75,68.3,64.3,61.4,56.9,52.6,48.6,45.1,42.3,39.8,37.2,34,28.5,23,17.5,12,6,-20,-42.5
5360 DATA 75,68.2,64.1,61.2,56.6,52,47.9,44.1,41.1,38.3,35.4,32,26.2,20,13.7,7.5,1,-27.5,-52
5370 DATA 75,68.1,63.9,61,56.3,51.5,47.2,43.1,39.9,36.8,33.6,30,23,16.5,9.6,3,-4,-35,-62
5380 DATA 75,68,63.8,60.8,56,51,46.5,42.1,38.7,35.3,31.9,27.5,20.3,13.3,6.5,-0.5,-7.5,-42,-70
5390 REM 
5400 DATA 75,69,65.1,62.5,59,55.5,53,50.5,49,47,45.2,43.5,40.5,37,34,31,28,14,0
5410 DATA 74.8,68.6,64.9,62.2,58,55,52,49.5,47.4,45.5,43.2,41.3,37.5,33.5,30,26.5,22.5,5,-12
5420 DATA 74.7,68.4,64.7,62,57.4,54,51.2,48.5,46,44,42,40,36,31.6,28,24,20,1,-17
5430 DATA 74.6,68.2,64.4,61.5,56.7,53,49.7,47,44,41.6,39.5,37,32,27.2,22.5,17.7,13,-9,-30
5440 DATA 74.5,68,63.8,60.5,55,51,48,45,42,38.8,36,33,27.5,22,17,11.5,6,-20,-42
5450 DATA 74,67.2,62.6,59,52,47.3,43,39,35,31.5,27.5,24,17,10,3,-4,-11,-43,-67
5460 DATA 73.3,65.5,60.4,56,48,42.5,37.5,32.5,27.5,23,18.6,14,5,-3.5,-12.5,-21,-30,-65,-90
5470 DATA 71.5,61.7,54.4,49,40,32.5,26,19,13,7.5,1.5,-4,-15.5,-27.5,-37.5,-47,-55,-90,-120
5480 DATA 68,57.2,48.8,42.5,32.5,24.2,17,10,2.5,-4.3,-11,-17.5,-30,-42.5,-53,-62,-71,-110,-145
5490 DATA 65,52.5,43.3,37,27,17.7,10,2,-5.5,-13,-20,-28,-41,-53,-65,-75,-85,-125,-165
5500 REM 
5510 DATA 74.5,68.5,64.7,62,57.5,54.5,51.5,49,47,45,43,41.2,37.7,34.3,31,27.7,24.5,9,-5.5
5520 DATA 74,67.5,63.1,60,55,51,47,43.5,40.5,37,34.5,31.7,26.5,21.2,16.5,12,7,-17,-39
5530 DATA 73.5,66,60.8,57.5,52.5,47.5,43.5,40,36.5,33.2,30,26.5,20,14,8,2.2,-3.5,-30,-57
5540 DATA 72.5,63,57.3,53,46,40,34.5,30,25,20.5,16.5,12,4.5,-3.5,-11,-18,-25,-57,-87
5550 DATA 71,59.5,52.3,47.5,40,32.5,26,21,16,11,6.3,1.5,-8,-16.5,-25.5,-34,-42.5,-79.5,-115
5560 DATA 66,53.5,44,38,29.5,22,15.5,9.5,4,-2,-7.5,-13,-24,-35,-46,-55,-65,-108,-152
5570 DATA 61,47.3,38.5,32.5,23,14.5,8,1,-6,-12,-18.5,-25,-38,-50,-62.5,-73,-83.5,-134,-185
5580 DATA 52.5,39,31,25,15,6.5,-1.5,-9.5,-17,-24,-32.5,-40,-54.5,-69,-80,-92,-102,-158,-214
5590 DATA 47,34,26.2,20,9,-1,-9,-18.5,-27.5,-36,-44,-53,-68.5,-82,-95,-106,-118,-177,-236
5600 DATA 43,30,20.9,14.2,3,-8,-18,-28,-37,-45,-54,-63,-80,-95,-109,-122,-135,-200,-264
 
