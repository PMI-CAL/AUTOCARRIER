; AUTO-CARRIER PROGRAM FOR CUTTING CARRIERS
;*******************************************************************************************

;ENTER PART SIZE HERE
;*******************************************************************************************
;VARIABLES BELOW ARE USED TO CUT RECTANGULAR POCKETS. V53 MUST = 0 TO CUT RECTANGLES
; PART SIZE - X
V70 = 4.56
;PART SIZE - Y
V71 = 4.56

;VARIABLE BELOW USED TO CUT CIRCULAR POCKETS. IF V53 DOES NOT EQUAL ZERO, 
;THEN CIRCULAR POCKET DESIGN WILL BE USED INSTEAD OF RECTANGULAR POCKETS.
;SET V53 = DESIRED CIRULAR POCKET DIAMETER
V53 = 0

;VARIABLE BELOW USED TO OVERRIDE AUTOMATIC YIELD CALCULATIONS AND SPECIFY
;A LOWER YIELD IN THE OUTER ROW OF PARTS.
;SET V76 = DESIRED NUMBER OF POCKETS. ZERO WILL ALLOW AUTO YIELD CALULATIONS
V46 = 0
                                                                                         
;CARRIER SIZE
;*******************************************************************************************
;CHOOSE A SIZE: ENTER DESIRED SIZE FOR V30 VARIABLE
; 20B					= 20
; 16B					= 16
; 14OD POLISH			= 14
; SPEEDFAM				= 12
; PLEXI SPDFAM			= 12.001
; POLISH				= 10.25
; POLISH(BIG)			= 10.675
; 9B                    = 9   
V30= 16                      

;MISC
;*******************************************************************************************
V31 = .5     ;TAP DELAY
V34 =  50    ;NUMBER OF TAPS    
V35 = .150   ;LEAD-IN CUT LENGTH 
V37 = .300   ;.300   ;SPACING BETWEEN POCKET CORNERS    
V38 = .500   ;.500   ;SPACING BETWEEN ROWS 

V3=300            ;RAPID SPEED
;***TOOL 5 MACHINING***
V5=	15          ;T5 MACHINE SPEED
V2= 15	;SERIALIZATION SPEED
V50=0      ;MACHINE TOOL 5 LEAD
V51=400      ;MACHINE TOOL 5 PULSE WIDTH
V52=1600     ;MACHINE TOOL 5 INTERVAL

; OFFSETS 
;*******************************************************************************************
; X OFFSET
V21= -8.713

; Y OFFSET      
V22= 8.481

;LOAD UNLOAD OFFSETS

V40=17.5+V21                                                                                                                                                  
V41=17.5-V22                                                                                                                                                  

;******No modifications to the program below this line.******

G90
ROT X,Y,0
AC PL=100
PSOT,0,3,0
;PSOT,0,9,0 
PSOT,0,12,0 
PSOT,0,15,0
;SKIPHOME REMOVES THE INITIAL HOME ROUTINE  
GOTO :SKIPHOME
ME DI"PLEASE WAIT FOR SYSTEM TO HOME ITSELF"
HOME X Y
FV3 
WAIT ON
G4 500
SCF X1 Y1
G92 X0 Y0
ME DI"HOME DONE"
:SKIPHOME
ME DI"MOVING TO SET OFFSET"
G1 XV21 YV22 FV3
WAIT ALL
ME DI"SETTING OFFSET"
G92 X Y
WA ALL
:START
ME DI"MOVING TO LOAD/UNLOAD"
G1 X -V40 YV41 FV3
PSOT,0,11,1
CLRSCR
M0
PSOT,0,11,0
G1 X0 Y0 FV3
G4 1500
WAIT ALL 
AC PL=100 
RA 100 
PSOT,0,4,0 
PSOT,0,9,1 
PSOT,0,12,0 
PSOT,0,15,0 
PSOP,4,V10 
PSOD,0,V11*50000 
PSOF,3,X,Y  
G4 1500 
V57 = 0 ;POCKET COUNT
V66 = 0 ;INITIAL ROATION
V36 = 0 ;NUMBER OF ROWS CUT
IF V53 = 0 THEN
	SU:PRECALC
ELSE
	SU:PRECALCDISK
ENDIF	
;USE SEPARATE CODE FOR 20B CARRIERS (SEMI-AUTO)
IF V30 = 20 THEN
	IF V53 = 0 THEN
		GOTO :CUT20B
	ELSE
		GOTO :CUT20BDISK
	ENDIF	
ENDIF
;OTHERWISE, USE MAIN CODE (AUTO)
SU:1. 
:LOOPDONE
;SERIALIZE WITH POCKET SIZE (ONLY IF ROOM EXISTS)
IF V75-V71 > 1.55 THEN 
	IF V53 = 0 THEN
		SU:SERIALIZE	
	ENDIF
ENDIF
;IF PLEXI SPEEDFAM CARRIER, THEN CUT 12" DIA AS WELL
IF V30 = 12.001 THEN
	SU:CUT12DIA
ENDIF
;IF POLISH CARRIER, THEN CUT 10.25" DIA AS WELL
IF V30 = 10.25 THEN
	SU:CUTPOLDIA
ENDIF
;IF BIG POLISH CARRIER, THEN CUT 10.675" DIA AS WELL
IF V30 = 10.675 THEN
	SU:CUTBIGPOLDIA
ENDIF

;IF POLISH CARRIER, THEN CUT 14" DIA AS WELL
IF V30 = 14 THEN
	SU:CUTPOLDIA14
ENDIF

ROT X, Y, 0
;DONE WITH PROGRAM
ME DI"%V57 POCKETS CUT"
G4 10000

;***End Code***
PSOT,0,3,0 
PSOT,0,9,0 
PSOT,0,12,0 
PSOT,0,15,0 
PSOF,0 
GOTO :START 

:1.
;MAIN AUTO CARRIER CODE
G90
G1X0Y0
G91
ROT X, Y, 0
:MAINLOOP
	IF V53 = 0 THEN
		SU:CALC
	ELSE	
		SU:CALCDISK
	ENDIF	
	LOOP V77
		IF V53 = 0 THEN
			SU:2 ;MAIN SUBROUTINE OF MOVEMENTS AND ROTATIONS
		ELSE
			SU:CUTDISK
		ENDIF
	NEXT
	V36=V36+1 ;COUNTS COMPLETED ROW
	ROT X, Y, 0
	IF V53 = 0 THEN
		SU:CHECKIFDONE
	ELSE
		SU:CHECKIFDONEDISK
	ENDIF	
	ME DI "CALC DONE = CHECK IS OK"
	V66=0
GOTO :MAINLOOP
RETURN

:PRECALC
V72 = (V70-(.1059*2)) ;POCKETWALLX
V73= (V71-(.1059*2)) ;POCKETWALLY
V74 = V70 / 2 ;HALF SIDE
;CALCULATE TOP CENTER LOCATIONS TO V94
IF V30=20 THEN
	V94= SQR((9.75-(V71*V36+V38*V36))^2-(V74*V74))
		IF V94>9.05 THEN
		V94 = 9.05
	ENDIF
ENDIF
IF V30=16 THEN

	V94= SQR((7.575-(V71*V36+V38*V36))^2-(V74*V74))
	IF V94>7.08 THEN
		V94 = 7.08
	ENDIF

            	;V94= SQR((7.575-(V71*V36+V38*V36))^2-(V74*V74))
	;IF V94>7.08 THEN
		;V94 = 7.08
	;ENDIF
ENDIF
IF V30=12 THEN
	V94= SQR((5.54-(V71*V36+V38*V36))^2-(V74*V74))
ENDIF
IF V30=12.001 THEN
	V94= SQR((5.54-(V71*V36+V38*V36))^2-(V74*V74))
ENDIF	
IF V30=10.25 THEN
	V94= SQR((4.83-(V71*V36+V38*V36))^2-(V74*V74))
ENDIF	
IF V30=10.675 THEN
	V94= SQR((5.04-(V71*V36+V68*V36))^2-(V74*V74))
ENDIF
IF V30=9 THEN
	V94= SQR(((3.9-(V71*V36+V38*V36))^2)-(V74*V74))
ENDIF
IF V30=14 THEN
	V94= SQR((6.54-(V71*V36+V38*V36))^2-(V74*V74))
ENDIF
RETURN

:PRECALCDISK
IF V30=20 THEN
	V94 = 9.25
ENDIF
IF V30=16 THEN
	V94 = 7.5
ENDIF
IF V30=12 THEN
	V94 = 5.6
ENDIF	
IF V30=12.001 THEN
	V94 = 5.6
ENDIF
IF V30=10.25 THEN
	V94 = 4.8
ENDIF	
IF V30=10.675 THEN
	V94 = 5.1
ENDIF
IF V30=9 THEN
	V94 = 3.95
ENDIF
IF V30=14 THEN
	V94 = 6.54
ENDIF
RETURN

:2
;TESTING MESSAGES
V57 = V57+1
;ME DI " CUTTING POCKET %V57 ROW %V36"
G4 500
;GOTO :SKIPCUT ;USED TO DEBUG PROGRAM
;REST OF POCKET CUT ROUTINE
ROT X, Y, V66 ;ROTATE
G1 X0 Y(V75-V35) ;MOVE UP
PSOT,0,15,1 ;AIR
G4 500
;TAPS
LOOP V34
SU:N31
NEXT
;CUT POCKET
FV5
PSOT,0,3,1
G1 Y V35
G1 X (V72/2)
G2 X .1059 Y-.1059 I .0559 J-.059
G1 Y-V73
G2 X-.1059 Y-.1059 I-.0559 J-.059
G1 X-V72
G2 X-.1059 Y .1059 I-.0559 J .059
G1 Y V73
G2 X .1059 Y .1059 I .0559 J .059
G1 X (V72/2)
;TURN OFF AND MOVE BACK TO CENTER
PSOT,0,3,0
G4 500
FV3
G1 X0 Y-V75
:SKIPCUT
;SET NEXT ROATION VALUE
V66=V66+V76
RETURN

:CUTDISK
;TESTING MESSAGES
V57 = V57+1
ROT X, Y, V66 ;ROTATE
G1 X0 Y(V75-V35) ;MOVE UP
PSOT,0,15,1 ;AIR
G4 500
;TAPS
LOOP V34
SU:N31
NEXT
;CUT POCKET
FV5
PSOT,0,3,1
G1 Y V35
G2 X0 Y0 I0 J-(V53/2)
;TURN OFF AND MOVE BACK TO CENTER
PSOT,0,3,0
G4 500
FV3
G1 X0 Y-V75
:SKIPCUT
;SET NEXT ROATION VALUE
V66=V66+V76
RETURN

:N31    ;Tap Routine
PSOT,0,3,1 
G4 V31
PSOT,0,3,0 
G4 V31
RETURN 

:CALC
IF V36 = 0 THEN
	V75 = V94
ELSE
	V75= SQR(((V94-(V71*V36+V38*V36))^2)-(V74*V74))
ENDIF
ME DI "TOP CENTER @ %V75"
V77 = V75-V71
;ME DI"BOTTOM CENTER @ %V77"
V78 = SQR((V74+(V37/2))^2+(V75-V71)^2)  
;ME DI"HYPOTENUSE @ %V78"
IF V46 = 0 THEN
	V79 = 2*(90-DEG(ACOS((V74+(V37/2))/V78)))
ELSE
	V79 = 359 / V46
ENDIF
;ME DI"ANGLE PER CUTOUT = %V79"
;ME DI"ROUNDED..."
V76=V79 ;ZERO ANGLE 
V77=0 ;COUNTING VARIABLE
IF V75-V71-(V38/2) < 0 THEN
	ME DI"ONLY SPACE TO CUT ONE POCKET"
	V77=1
	V57=0
ELSE
	WHILE V76 < 360
		V76=V76+V79
		V77=V77+1
	ENDWHILE
ENDIF
ME DI"NUMBER OF CUTOUTS = %V77"
V76=360/V77
ME DI"ANGLE PER CUTOUT %V76"
RETURN

:CALCDISK
IF V36 = 0 THEN
	V75 = V94
ELSE
	V75= V94-((V53*V36)+(V38*V36))
ENDIF
ME DI "TOP CENTER @ %V75"
;FIND CIRCUMEFERENCE OF ROW
V32= 2 * 3.14159 * (V75-(V53/2))
;FIND NUMBER OF POCKETS THAT CAN BE PLACED IN RING
IF V46 = 0 THEN
	V77= CVI(V32 / (V53+V37))
ELSE
	V77 = V46
ENDIF
ME DI"NUMBER OF CUTOUTS = %V77"
;CALCULATE ANGLE FOR ROTATION
V76=360/V77
ME DI"ANGLE PER CUTOUT %V76"
RETURN

:CUT20B
;NEED TO CUT 20B POCKETS IN TWO STEPS

;NOTIFY OPERATOR OF ALTERNATIVE METHOD OF CUTTING 20B CARRIERS
CLRSCR
ME DI "20B CARRIERS HAVE TO BE CUT HALF AT A TIME"
ME DI " "
ME DI "LOAD 20B CARRIER W/ SAME CENTERPOINT AS NORMAL"
ME DI "CARRIER PROGRAM. 1ST HALF OF CARRIER WILL BE CUT"
ME DI "+ ALIGNMENT MARK WILL ALSO BE ADDED TO INDICATE"
ME DI "WHERE TO ROTATE CARRIER TO CUT REMAINING CELLS"

;PAUSE TO ALLOW OPERATOR TO READ INSTRUCTIONS
M0

;CUT FIRST HALF OF ROW
;PAUSE BETWEEN EACH HALF TO ALLOW OPERATOR TO ROTATE CARRIER
V91=0
G90
G1X0Y0
ROT X, Y, 0
SU:CUTALIGN
G91
V57 = 0
V36 = 0
:LOOP20B
	V66 = -35
	;MAIN 20B CALCULATIONS
	SU:CALC20B

	;CUT 1ST HALF OF POCKETS IN CURRENT ROW
	ME DI "CUTTING FIRST HALF OF ROW"
	V93 = CVI(V77/2)+V92 
	LOOP V93
		SU:CUT20BPOCKET
	NEXT

	;NOTIFY OPERATOR THAT WE NEED TO ROTATE CARRIER
	CLRSCR
	ME DI "CARRIER NEEDS TO BE ROTATED 180�"
	ME DI "USE ALIGNMENT MARKS TO ORIENT"

	;MOVE SO OPERATOR CAN ROTATE CARRIER
	PSOT,0,15,0 
	ROT X, Y, 0
	G4 500
	FV3
	G1 X-9 Y9

	;PAUSE FOR ROTATION
	M0

	FV3
	G1 X9 Y-9
	PSOT,0,15,1
	G4 500
	
	;DETERMINE WHERE 2ND HALF SHOULD START AND RESET
	IF V92 = 0 THEN
		V66 = -35
	ELSE
		V66 = -35 + (V76/2)
	ENDIF

	;CUT SECOND HALF OF POCKETS IN CURRENT ROW
	ME DI "CUTTING SECOND HALF OF ROW"
	V93 = CVI(V77/2)
	LOOP V93
		SU:CUT20BPOCKET
	NEXT

	V36=V36+1 ;COUNTS COMPLETED ROW

	SU:CHECKIFDONE
	ME DI "CALC DONE = CHECK IS OK"
	V66 = 0
GOTO :MAINLOOP
RETURN

:CUT20BDISK
;NEED TO CUT 20B POCKETS IN TWO STEPS

;NOTIFY OPERATOR OF ALTERNATIVE METHOD OF CUTTING 20B CARRIERS
CLRSCR
ME DI "20B CARRIERS HAVE TO BE CUT HALF AT A TIME"
ME DI " "
ME DI "LOAD 20B CARRIER W/ SAME CENTERPOINT AS NORMAL"
ME DI "CARRIER PROGRAM. 1ST HALF OF CARRIER WILL BE CUT"
ME DI "+ ALIGNMENT MARK WILL ALSO BE ADDED TO INDICATE"
ME DI "WHERE TO ROTATE CARRIER TO CUT REMAINING CELLS"

;PAUSE TO ALLOW OPERATOR TO READ INSTRUCTIONS
M0

;CUT FIRST HALF OF ROW
;PAUSE BETWEEN EACH HALF TO ALLOW OPERATOR TO ROTATE CARRIER
V91=0
G90
G1X0Y0
ROT X, Y, 0
SU:CUTALIGN
G91
V57 = 0
V36 = 0
:LOOP20BDISK
	V66 = -35
	;MAIN 20B CALCULATIONS
	SU:CALC20BDISK

	;CUT 1ST HALF OF POCKETS IN CURRENT ROW
	ME DI "CUTTING FIRST HALF OF ROW"
	V93 = CVI(V77/2)+V92 
	LOOP V93
		SU:CUT20BDISKPOCKET
	NEXT

	;NOTIFY OPERATOR THAT WE NEED TO ROTATE CARRIER
	CLRSCR
	ME DI "CARRIER NEEDS TO BE ROTATED 180�"
	ME DI "USE ALIGNMENT MARKS TO ORIENT"

	;MOVE SO OPERATOR CAN ROTATE CARRIER
	PSOT,0,15,0 
	ROT X, Y, 0
	G4 500
	FV3
	G1 X-9 Y9

	;PAUSE FOR ROTATION
	M0

	FV3
	G1 X9 Y-9
	PSOT,0,15,1
	G4 500
	
	;DETERMINE WHERE 2ND HALF SHOULD START AND RESET
	IF V92 = 0 THEN
		V66 = -35
	ELSE
		V66 = -35 + (V76/2)
	ENDIF

	;CUT SECOND HALF OF POCKETS IN CURRENT ROW
	ME DI "CUTTING SECOND HALF OF ROW"
	V93 = CVI(V77/2)
	LOOP V93
		SU:CUT20BDISKPOCKET
	NEXT

	V36=V36+1 ;COUNTS COMPLETED ROW

	SU:CHECKIFDONEDISK
	ME DI "CALC DONE = CHECK IS OK"
	V66 = 0
GOTO :MAINLOOP
RETURN

:CUT12DIA
ME DI "CUTTING PLEXI CARRIER OD"
FV3
G90 
G1X 0 Y 6
PSOT,0,15,1 ;AIR
FV5
PSOT,0,3,1
G91
G2 X 0 Y 0 I 0 J -6
G90
G1
PSOT,0,3,1
RETURN

:CUTPOLDIA
ME DI "CUTTING POLISH CARRIER OD"
FV3
G90 
G1X 0 Y 5.125
PSOT,0,15,1 ;AIR
FV5
PSOT,0,3,1
G91
G2 X 0 Y 0 I 0 J -5.125
G90
G1
PSOT,0,3,1
RETURN

:CUTPOLDIA14
ME DI "CUTTING POLISH CARRIER OD"
FV3
G90 
G1X 0 Y 7.0
PSOT,0,15,1 ;AIR
FV5
PSOT,0,3,1
G91
G2 X 0 Y 0 I 0 J -7.0
G90
G1
PSOT,0,3,1
RETURN

:CUTBIGPOLDIA
ME DI "CUTTING POLISH CARRIER OD"
FV3
G90 
G1X 0 Y 5.3375
PSOT,0,15,1 ;AIR
FV5
PSOT,0,3,1
G91
G2 X 0 Y 0 I 0 J -5.3375
G90
G1
PSOT,0,3,1
RETURN

:CUTALIGN
CLRSCR
ME DI "CUTTING ALIGNMENT MARKS ON CARRIER"
ME DI "SO CARRIER CAN BE EASILY ROTATED 180�"
ME DI ""
FV3
G1 X5.3459 Y7.6348
PSOT,0,15,1 ;AIR
G4 500
;TAPS
LOOP V34
	SU:N31
NEXT
FV5
PSOT,0,3,1
G1 X5.3254 Y7.6491
G1 X5.4688 Y7.8539
G1 X5.5098 Y7.8252
G1 X5.3664 Y7.6204
G1 X5.3459 Y7.6348
PSOT,0,3,0
G4 500
FV3
G1 X-5.3459 Y-7.6348
;TAPS
LOOP V34
	SU:N31
NEXT
FV5
PSOT,0,3,1
G1 X-5.3254 Y-7.6491
G1 X-5.4688 Y-7.8539
G1 X-5.5098 Y-7.8252
G1 X-5.3664 Y-7.6404
G1 X-5.3459 Y-7.6348
PSOT,0,3,0
G4 500
FV3
G1 X0 Y0
RETURN

:CUT20BPOCKET
V57 = V57+1
;ME DI " CUTTING POCKET %V57 ROW %V36"
;G4 1000
;GOTO :SKIPCUT2 ;USED TO DEBUG PROGRAM

;REST OF POCKET CUT ROUTINE
ROT X, Y, V66 ;ROTATE
G1 X0 Y(V75-V35) ;MOVE UP
PSOT,0,15,1 ;AIR
G4 500
;TAPS
LOOP V34
	SU:N31
NEXT
;CUT POCKET
FV5
PSOT,0,3,1
G1 Y V35
G1 X (V72/2)
G2 X .1059 Y-.1059 I .0559 J-.059
G1 Y-V73
G2 X-.1059 Y-.1059 I-.0559 J-.059
G1 X-V72
G2 X-.1059 Y .1059 I-.0559 J .059
G1 Y V73
G2 X .1059 Y .1059 I .0559 J .059
G1 X (V72/2)
;TURN OFF AND MOVE BACK TO CENTER
PSOT,0,3,0
G4 500
FV3
G1 X0 Y-V75
:SKIPCUT2
;SET NEXT ROATION VALUE
V66=V66+V76
RETURN

:CUT20BDISKPOCKET
V57 = V57+1
;REST OF POCKET CUT ROUTINE
ROT X, Y, V66 ;ROTATE
G1 X0 Y(V75-V35) ;MOVE UP
PSOT,0,15,1 ;AIR
G4 500
;TAPS
LOOP V34
	SU:N31
NEXT
;CUT POCKET
FV5
PSOT,0,3,1
G1 Y V35
G2 X0 Y0 I0 J-(V53/2)
;TURN OFF AND MOVE BACK TO CENTER
PSOT,0,3,0
G4 500
FV3
G1 X0 Y-V75
:SKIPCUT2
;SET NEXT ROATION VALUE
V66=V66+V76
RETURN

:CALC20B
;ME DI "HALF SIDE @ %V74"
IF V30=20 THEN
	V75= SQR((V94-(V71*V36+V38*V36))^2-(V74*V74))
	IF V75>9 THEN
		V75 = 9
	ENDIF
ENDIF
ME DI "TOP CENTER @ %V75"
V77 = V75-V71
;ME DI"BOTTOM CENTER @ %V77"
V78 = SQR((V74+(V37/2))^2+(V75-V71)^2)  
;ME DI"HYPOTENUSE @ %V78"
IF V46 = 0 THEN
	V79 = 2*(90-DEG(ACOS((V74+(V37/2))/V78)))
ELSE
	V79 = 359 / V46
ENDIF
;ME DI"ANGLE PER CUTOUT = %V79"
;ME DI"ROUNDED..."
V76=V79 ;ZERO ANGLE 
V77=0 ;COUNTING VARIABLE
IF V75-V71-.5 < 0 THEN
	ME DI"NOT ENOUGH SPACE TO AUTO-CUT MORE ROWS"
	V77=0
	V57=-1
ELSE
	WHILE V76 < 360
		V76=V76+V79
		V77=V77+1
	ENDWHILE
ENDIF
ME DI"NUMBER OF CUTOUTS = %V77"
V76=360/V77
ME DI"ANGLE PER CUTOUT %V76"
;DETERMINE IF ROW POCKETS ARE EVEN OR ODD
V92 = CVI(V77/2)
IF V92*2 = V77 THEN
	ME DI "# OF POCKETS IS EVEN"
	V92=0
ELSE
	ME DI "# OF POCKETS IS ODD"
	V92=1
ENDIF
RETURN

:CALC20BDISK
;ME DI "HALF SIDE @ %V74"
IF V30=20 THEN
	V75= 9
ENDIF
ME DI "TOP CENTER @ %V75"
;FIND CIRCUMEFERENCE OF ROW
V32= 2 * 3.14159 * (V75-(V53/2))
;FIND NUMBER OF POCKETS THAT CAN BE PLACED IN RING
IF V46 = 0 THEN
	V77= CVI(V32 / (V53+V37))
ELSE
	V77 = V46
ENDIF
ME DI"NUMBER OF CUTOUTS = %V77"
;CALCULATE ANGLE FOR ROTATION
V76=360/V77
ME DI"ANGLE PER CUTOUT %V76"
;DETERMINE IF ROW POCKETS ARE EVEN OR ODD
V92 = CVI(V77/2)
IF V92*2 = V77 THEN
	ME DI "# OF POCKETS IS EVEN"
	V92=0
ELSE
	ME DI "# OF POCKETS IS ODD"
	V92=1
ENDIF
RETURN

:CHECKIFDONE
IF V75-(V71*2)-.5 < 0 THEN
	IF V30 = 9 THEN
		ME DI "ALL ROWS ARE DONE CUTTING 9B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-2.0 < 0 THEN
	IF V30 = 16 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 16B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-2.0 < 0 THEN
	IF V30 = 20 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 20B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-1.5 < 0 THEN
	IF V30 = 12 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 12"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-1.5 < 0 THEN
	IF V30 = 14 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 12"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-1.5 < 0 THEN
	IF V30 = 12.001 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 12"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V71*2)-2.0 < 0 THEN
	IF V30 = 10.25 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 10.5"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
	IF V30 = 10.675 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 10.675"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
RETURN

:CHECKIFDONEDISK
IF V75-(V53*2)-.5 < 0 THEN
	IF V30 = 9 THEN
		ME DI "ALL ROWS ARE DONE CUTTING 9B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V53*2)-2.0 < 0 THEN
	IF V30 = 16 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 16B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V53*2)-2.0 < 0 THEN
	IF V30 = 20 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 20B"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V53*2)-1.5 < 0 THEN
	IF V30 = 12 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 12"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V53*2)-1.5 < 0 THEN
	IF V30 = 14 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 12"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
IF V75-(V53*2)-2.0 < 0 THEN
	IF V30 = 10.25 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 10.25"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
	IF V30 = 10.675 THEN 
		ME DI "ALL ROWS ARE DONE CUTTING 10.675"
		ME DI "STARTING CARRIER SERIALIZATION"
		ME DI ""	
		GOTO :LOOPDONE
	ENDIF
ENDIF
RETURN

:SERIALIZE
;USE THIS ROUTINE TO PARSE SUB SIZE AND SERIALIZE ONTO CARRIAER WHEN DONE

;STORE PART SIZE INTO SEPARATE VARIABLES
V80 = V70
V81 = V71

;FIRST LET'S BREAK DOWN THE PART SIZE

;XCHAR1
V82 = CVI(V80)

;XCHAR2
V83 = CVI(((V80-V82)*10)+.0001)

;XCHAR3
V84 = CVI((((V80-V82)-(V83/10))*100)+.0001)

;XCHAR4
V85 = CVI(((V80-V82-(V83/10)-(V84/100))*1000)+.0001)

;YCHAR1
V86 = CVI(V81)

;YCHAR2
V87 = CVI(((V81-V86)*10)+.0001)

;YCHAR3
V88 = CVI((((V81-V86)-(V87/10))*100)+.0001)

;YCHAR4
V89 = CVI(((V81-V86-(V87/10)-(V88/100))*1000)+.0001)

;NOW WE NEED TO SERIALIZE THE SAVED VALUES.

PSOT,0,15,1 ;AIR
G4 500
G90
G1X0Y0
G91
ROT X, Y, 0

;FIRST SERIALIZE THE DEFAULT CHARACTERS
G1 G90 X-1.0313 Y-1.1306 
PSOT,0,3,0 
FV3 
FV2 
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1 
FV2 
G1 Y-1.0891 
PSOT,0,3,0 
FV3 
G1 X-.0833 Y-.8811 
FV2 
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1 
FV2 
G1 X.0838 Y-1.1316 
PSOT,0,3,0 
FV3 
G1 X-.0833 
FV2 
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1 
FV2 
G1 X.0838 Y-.8811 
PSOT,0,3,0 
FV3 
G1 X.5843 Y-1.1306 
FV2 
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1 
FV2 
G1 Y-1.0891 
PSOT,0,3,0 
FV3 

;NEXT SERIALIZE THE INDIVIDUAL CHARACTERS

;XCHAR1
G1 G90 X-1.2535 Y-1.1316
V90 = V82
SU:CHOOSER

;XCHAR2
G1 G90 X-.9742 Y-1.1316
V90 = V83
SU:CHOOSER

;XCHAR3
G1 G90 X-.7515 Y-1.1316
V90 = V84
SU:CHOOSER

;XCHAR4
G1 G90 X-.5288 Y-1.1316
V90 = V85
SU:CHOOSER

;YCHAR1
G1 G90 X.3621 Y-1.1316
V90 = V86
SU:CHOOSER

;YCHAR2
G1 G90 X.6414 Y-1.1316
V90 = V87
SU:CHOOSER

;YCHAR3
G1 G90 X.8641 Y-1.1316
V90 = V88
SU:CHOOSER

;YCHAR4
G1 G90 X1.0868 Y-1.1316
V90 = V89
SU:CHOOSER

RETURN

:CHOOSER
;CHOOSES WHICH CHARACTER TO SERIALIZE BASED ON VALUE SAVED IN V90
IF V90 = 0 THEN
	SU:CHAR0
ENDIF
IF V90 = 1 THEN
	SU:CHAR1
ENDIF
IF V90 = 2 THEN
	SU:CHAR2
ENDIF
IF V90 = 3 THEN
	SU:CHAR3
ENDIF
IF V90 = 4 THEN
	SU:CHAR4
ENDIF
IF V90 = 5 THEN
	SU:CHAR5
ENDIF
IF V90 = 6 THEN
	SU:CHAR6
ENDIF
IF V90 = 7 THEN
	SU:CHAR7
ENDIF
IF V90 = 8 THEN
	SU:CHAR8
ENDIF
IF V90 = 9 THEN
	SU:CHAR9
ENDIF
RETURN

;CHARACTER SERIALIZATION GEOMETRY

:CHAR0

G91
G1 X0 Y.1242
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1Y-.0621
G3X.0184Y-.0437I.0619J.0004
G3X.0437Y-.0184I.0441J.0435
G1X.0414
G3X.044Y.0182I.0001J.0621
G3X.0182Y.0439I-.044J.0439
G1X.001Y.1187
G3X-.0182Y.048I-.0763J-.0015
G3X-.045Y.0237I-.0477J-.0359
G1X-.0414
G3X-.0437Y-.0202I.0011J-.0596
G3X-.0184Y-.0459I.0501J-.0467
G1Y-.0622
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR1 
G91
G1 X0 Y.2111
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1 X.0419 Y.0424
G1 Y-.253
PSOT,0,3,0
FV3
G1 X.0424
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1 X-.0843
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR2 
G91
G1 X0 Y.1874
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G2X.0184Y.0442I.0626J-.0002
G2X.0442Y.0184I.0444J-.0442
G1X.0414
G2X.044Y-.0187I-.0005J-.0624
G2X.0187Y-.0439I-.0437J-.0445
G2X-.0192Y-.045I-.0629J.0002
G1X-.1475Y-.1424
G1 X.1667
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR3
G91
G1 X0 Y.2338
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G2X.0424Y.0187I.0429J-.0399
G1X.0399
G2X.0424Y-.0189I-.0001J-.0573
G2X.0172Y-.0442I-.0486J-.0444
G2X-.0172Y-.0442I-.0659J.0001
G2X-.0424Y-.0189I-.0425J.0384
G2X.0424Y-.019I-.0001J-.0574
G2X.0172Y-.0442I-.0486J-.0443
G2X-.0174Y-.0439I-.0645J.0002
G2X-.0422Y-.0187I-.0426J.0391
G1X-.0399
G2X-.0424Y.0182I.0003J.0593
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR4
G91
G1 X.1242 Y0
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1Y.2485
G1 X-.1242Y-.1657
G1 X.1657
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR5
G91
G1 X.1677Y.2515
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1 X-.1677
G1 Y-.0838
G1 X.105
G2X.044Y-.0187I-.0005J-.0624
G2X.0187Y-.044I-.0437J-.0445
G1Y-.0419
G2X-.0185Y-.0444I-.0634J.0003
G2X-.0442Y-.0187I-.0444J.0435
G1X-.0419
G2X-.0444Y.0184I.0003J.0634
G2X-.0187Y.0442I.0435J.0445
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR6
G91
G1 X.1485Y.2318
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G3X-.0445Y.0182I-.0442J-.0445
G1X-.0414
G3X-.0442Y-.0184I.0002J-.0626
G3X-.0184Y-.0442I.0442J-.0444
G1Y-.1248
G3X.0184Y-.0442I.0626J.0002
G3X.0442Y-.0184I.0444J.0442
G1X.0414
G3X.0442Y.0184I-.0001J.0626
G3X.0185Y.0442I-.0441J.0444
G1Y.0414
G3X-.0187Y.044I-.0624J-.0005
G3X-.044Y.0187I-.0445J-.0437
G1X-.0414
G3X-.0442Y-.0185I.0002J-.0626
G3X-.0184Y-.0442I.0442J-.0443
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR7
G91
G1 X0Y.2515
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G1X.1677
G1X-.1258Y-.2515
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR8 
G91
G1 X.1608Y.1627
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G3X.0049Y.0237I-.0571J.0241
G3X-.0185Y.0439I-.0628J-.0005
G3X-.0437Y.0187I-.0442J-.0429
G1X-.0414
G3X-.0437Y-.0187I.0005J-.0616
G3X-.0184Y-.0439I.0444J-.0444
G3X.0184Y-.0437I.062J.0004
G3X.0437Y-.0185I.0441J.0435
G1X.0414
G2X.0437Y-.0192I-.0006J-.0608
G2X.0185Y-.0449I-.0466J-.0453
G2X-.0185Y-.0427I-.0588J.0001
G2X-.0437Y-.0174I-.0437J.0462
G1X-.0409
G2X-.0439Y.0174I.0002J.0645
G2X-.0187Y.0427I.0397J.0428
G2X.0182Y.0449I.0655J-.0003
G2X.0439Y.0192I.0443J-.0414
G1X.0414
G3X.0437Y.0185I-.0004J.062
G3X.0136Y.02I-.0435J.0441
PSOT,0,3,0
FV3
G90
RETURN
 
:CHAR9
G91
G1 X.0182Y.0182
;TAPS
LOOP V34
SU:N31
NEXT
PSOT,0,3,1
FV2
G3X.0444Y-.0182I.0441J.0445
G1X.0414
G3X.0442Y.0184I-.0001J.0626
G3X.0185Y.0442I-.0441J.0444
G1Y.1248
G3X-.0187Y.0439I-.0624J-.0006
G3X-.044Y.0187I-.0445J-.0437
G1X-.0414
G3X-.0442Y-.0184I.0002J-.0626
G3X-.0184Y-.0442I.0442J-.0444
G1Y-.0414
G3X.0184Y-.0442I.0626J.0001
G3X.0442Y-.0185I.0444J.0441
G1X.0414
G3X.0442Y.0185I-.0001J.0626
G3X.0185Y.0442I-.0441J.0443
PSOT,0,3,0
FV3
G90
RETURN


