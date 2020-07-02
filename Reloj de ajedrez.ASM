LIST p=16F84A
#include "P16F84a.inc"

__CONFIG        _CP_OFF & _PWRTE_ON & _WDT_OFF & _XT_OSC

CONT1	EQU 0CH
CONT2	EQU 0DH
CONT3	EQU 0EH
TIEMPO	EQU 0FH
CONFIG_	EQU 10H
DISP1	EQU 11H
DISP2	EQU 12H
DISP3	EQU 13H
DISP4	EQU 14H
DISP5	EQU 15H
DISP6	EQU 16H
DISP7	EQU 17H
DISP8	EQU 18H
TIMER1	EQU 19H
TIMER2	EQU 1AH
FISH1	EQU	1BH
FISH2	EQU	1CH
W_TEMP  EQU 1DH
STATUS_TEMP EQU 1EH


;	EL REGISTRO CONGIF_ ES USADO PARA DETECTAR EL STATUS DEL PROGRAMA
;**************************************************************
;** BIT 0: ACTIVE TIMER (0=PARA EL TIMER1, 1=PARA EL TIMER2) ** 
;**************************************************************
;*************************************************  USADO PARA DESACTIVAR EL AUMENTO
;** BIT 1: FISHER STATUS (0=INACTIVO, 1=ACTIVO) **  EN EL PRIMER CAMBIO DEL JUGADOR 1
;*************************************************
;*************************************************  USADO PARA DESACTIVAR EL AUMENTO
;** BIT 2: FISHER STATUS (0=INACTIVO, 1=ACTIVO) **  EN EL PRIMER CAMBIO DEL JUGADOR 2
;*************************************************

#DEFINE BANK0 BCF STATUS,RP0
#DEFINE BANK1 BSF STATUS,RP0

	ORG 00H
	GOTO INICIO

;*****************************************************************************************************************
;******************************************* INTERRUPCION ********************************************************
;*****************************************************************************************************************

	ORG 04H
	MOVWF W_TEMP		; Copy W to a Temporary Register
						; regardless of current bank
	SWAPF STATUS,W 		; Swap STATUS nibbles and place
						; into W register
	MOVWF STATUS_TEMP 	; Save STATUS to a Temporary register
						; in Bank0
	BCF INTCON,2
	INCF TIEMPO
	MOVLW D'61'
	SUBWF TIEMPO,W		;CHEQUEAR SI TMR0 SE HA DESBORDADO 61 VECES
	BTFSC STATUS,2
	  GOTO RESET_TMR0

FIN_INT
	SWAPF STATUS_TEMP,W ; Swap original STATUS register value
						; into W (restores original bank)
	MOVWF STATUS 		; Restore STATUS register from
						; W register
	SWAPF W_TEMP,F 		; Swap W_Temp nibbles and return
						; value to W_Temp
	SWAPF W_TEMP,W 		; Swap W_Temp to W to restore original
						; W value without affecting STATUS
	RETFIE

RESET_TMR0				;RUTINA PARA EL RESET DE TMR0 Y PREESCALER A 1 SEGUNDO EXACTAMENTE
	MOVLW D'113'
	MOVWF CONT3

	DECFSZ CONT3
	  GOTO $-1
	NOP
	NOP
	NOP
	CLRF TMR0
	BTFSC CONFIG_,0
	  GOTO TIME2
		
TIME1					;DECREMENTO PARA TIMER 1
	BCF STATUS,0		;DISP4
	DECF DISP4
	MOVLW D'9'
	SUBWF DISP4,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'9'
	MOVWF DISP4

	BCF STATUS,0		;DISP3
	DECF DISP3
	MOVLW D'5'
	SUBWF DISP3,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'5'
	MOVWF DISP3

	BCF STATUS,0		;DISP2
	DECF DISP2
	MOVLW D'9'
	SUBWF DISP2,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'9'
	MOVWF DISP2

	BCF STATUS,0		;DISP1
	DECF DISP1
	MOVLW D'9'
	SUBWF DISP1,W
	BTFSS STATUS,0
	  GOTO FIN_INT

	CLRF DISP1
	CLRF DISP2
	CLRF DISP3
	CLRF DISP4
	GOTO FINAL

TIME2					;DECREMENTO PARA TIMER 2
	BCF STATUS,0		;DISP8
	DECF DISP8
	MOVLW D'9'
	SUBWF DISP8,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'9'
	MOVWF DISP8

	BCF STATUS,0		;DISP7
	DECF DISP7
	MOVLW D'5'
	SUBWF DISP7,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'5'
	MOVWF DISP7

	BCF STATUS,0		;DISP6
	DECF DISP6
	MOVLW D'9'
	SUBWF DISP6,W
	BTFSS STATUS,0
	  GOTO FIN_INT
	MOVLW D'9'
	MOVWF DISP6

	BCF STATUS,0		;DISP5
	DECF DISP5
	MOVLW D'9'
	SUBWF DISP5,W
	BTFSS STATUS,0
	  GOTO FIN_INT

	CLRF DISP5
	CLRF DISP6
	CLRF DISP7
	CLRF DISP8
	GOTO FINAL
	
;*****************************************************************************************************************
;**************************************	RUTINAS DE FUNCIONAMIENTO ************************************************
;*****************************************************************************************************************
INICIO
	BANK1
	MOVLW B'10000'
	MOVWF TRISA
	CLRF TRISB
	MOVLW B'11000101'
	MOVWF OPTION_REG
	BANK0
	BSF INTCON,5

	GOTO INICIO_CONFIG_NORMAL
;*****************************************************************************************************************
;*******************************	RUTINA GAMEPLAY  (PRESENTE DURANTE EL JUEGO)	******************************
;*****************************************************************************************************************

INICIO_GAMEPLAY			
	BSF INTCON,7
	BCF CONFIG_,1
	MOVFW DISP1
	MOVWF DISP5
	MOVFW DISP2
	MOVWF DISP6
	MOVFW DISP3
	MOVWF DISP7
	MOVFW DISP4
	MOVWF DISP8

GAMEPLAY		
	BSF PORTB,7
	MOVFW DISP1
	MOVWF PORTA
	BCF PORTB,0
	CALL DELAY
	BTFSS PORTA,4
	  CALL GAMEPLAY_P1

	BSF PORTB,0
	MOVFW DISP2
	MOVWF PORTA
	BCF PORTB,1
	CALL DELAY
		
	BSF PORTB,1
	MOVFW DISP3
	MOVWF PORTA
	BCF PORTB,2
	CALL DELAY

	BSF PORTB,2
	MOVFW DISP4
	MOVWF PORTA
	BCF PORTB,3
	CALL DELAY
	BTFSS PORTA,4
	  CALL GAMEPLAY_P3

	BSF PORTB,3
	MOVFW DISP5
	MOVWF PORTA
	BCF PORTB,4
	CALL DELAY

	BSF PORTB,4
	MOVFW DISP6
	MOVWF PORTA
	BCF PORTB,5
	CALL DELAY

	BSF PORTB,5
	MOVFW DISP7
	MOVWF PORTA
	BCF PORTB,6
	CALL DELAY

	BSF PORTB,6
	MOVFW DISP8
	MOVWF PORTA
	BCF PORTB,7
	CALL DELAY
	BTFSS PORTA,4
	  CALL GAMEPLAY_P2

	GOTO GAMEPLAY

;**************************	SUBRUTINAS PARA LA CONFIGURACION DE LOS PULSADORES ***********************************

	GAMEPLAY_P1
		BTFSC CONFIG_,0
		  RETURN
	
		BCF INTCON,7	
		MOVFW TIEMPO
		MOVWF TIMER1
		MOVLW D'128'
		MOVWF TMR0
		MOVFW TIMER2
		MOVWF TIEMPO
	
		BSF INTCON,7
		BSF CONFIG_,0
		BTFSS CONFIG_,1
		  RETURN
		GOTO INC_TIMER2
		BSF CONFIG_,1
		RETURN
	
	GAMEPLAY_P2
		BTFSS CONFIG_,0
		  RETURN
		
		BCF INTCON,7
		MOVFW TIEMPO
		MOVWF TIMER2
		MOVLW D'128'
		MOVWF TMR0
		MOVFW TIMER1
		MOVWF TIEMPO

		BSF INTCON,7
		BCF CONFIG_,0
		BTFSS CONFIG_,1
		  RETURN
		GOTO INC_TIMER1
		BSF CONFIG_,1
		RETURN
	
	GAMEPLAY_P3
		BCF INTCON,7
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INICIO_PAUSE
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		
		GOTO INICIO_CONFIG_NORMAL

;*****************************************************************************************************************
;*********************************	RUTINA DE CONFIGURACION DE TIEMPO INICIAL	**********************************
;*****************************************************************************************************************

INICIO_CONFIG_NORMAL		
	CLRF DISP1
	CLRF DISP2
	CLRF DISP3
	CLRF DISP4
	CLRF DISP5
	CLRF DISP6
	CLRF DISP7
	CLRF DISP8
	CALL APAGAR

CONFIG_NORMAL
	BSF PORTB,7
	MOVFW DISP1
	MOVWF PORTA
	BCF PORTB,0
	CALL DELAY
	BTFSS PORTA,4
	  CALL P1

	BSF PORTB,0
	MOVFW DISP2
	MOVWF PORTA
	BCF PORTB,1
	CALL DELAY
		
	BSF PORTB,1
	MOVFW DISP3
	MOVWF PORTA
	BCF PORTB,2
	CALL DELAY

	BSF PORTB,2
	MOVFW DISP4
	MOVWF PORTA
	BCF PORTB,3
	CALL DELAY
	BTFSS PORTA,4
	  GOTO P3

	BSF PORTB,3
	MOVFW DISP1
	MOVWF PORTA
	BCF PORTB,4
	CALL DELAY

	BSF PORTB,4
	MOVFW DISP2
	MOVWF PORTA
	BCF PORTB,5
	CALL DELAY

	BSF PORTB,5
	MOVFW DISP3
	MOVWF PORTA
	BCF PORTB,6
	CALL DELAY

	BSF PORTB,6
	MOVFW DISP4
	MOVWF PORTA
	BCF PORTB,7
	CALL DELAY
	BTFSS PORTA,4
	  CALL P2


	DECFSZ CONT2
	  GOTO CONFIG_NORMAL
	CALL APAGAR
	CALL DELAY2	

	GOTO CONFIG_NORMAL

;**************************	SUBRUTINAS PARA LA CONFIGURACION DE LOS PULSADORES ***********************************

	P1
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INC_10M
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INC_30S
		RETURN
	
	P2
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INC_1M
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INC_5M

		RETURN
	
	P3
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INICIO_CONFIG_FISHER
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INICIO_GAMEPLAY

;*****************************************************************************************************************
;**********************	RUTINA FISHER  (CONFIGURACION DE TIEMPO AÑADIDO POR JUGADA)	******************************
;*****************************************************************************************************************

INICIO_CONFIG_FISHER
	CALL APAGAR

CONFIG_FISHER
	
	BSF PORTB,7
	MOVLW B'1111'
	MOVWF PORTA
	BCF PORTB,0
	BTFSS PORTA,4
	  CALL FISH_P1
	
	BSF PORTB,0
	MOVFW FISH1
	MOVWF PORTA
	BCF PORTB,2
	CALL DELAY

	BSF PORTB,2
	MOVFW FISH2
	MOVWF PORTA
	BCF PORTB,3
	CALL DELAY
	BTFSS PORTA,4
	  GOTO FISH_P3

	BSF PORTB,3
	MOVFW FISH1
	MOVWF PORTA
	BCF PORTB,6
	CALL DELAY

	BSF PORTB,6
	MOVFW FISH2
	MOVWF PORTA
	BCF PORTB,7
	CALL DELAY
	BTFSS PORTA,4
	  CALL FISH_P2
	
	GOTO CONFIG_FISHER

;**************************	SUBRUTINAS PARA LA CONFIGURACION DE LOS PULSADORES ***********************************

	FISH_P1
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INCF_10S
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INCF_30S
		RETURN
	
	FISH_P2
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INCF_1S
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INCF_5S

		RETURN
	
	FISH_P3
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INICIO_CONFIG_NORMAL
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INICIO_GAMEPLAY	

;*****************************************************************************************************************
;******************************************	RUTINA DE PAUSE	******************************************************
;*****************************************************************************************************************

INICIO_PAUSE
	MOVFW TIEMPO
	BTFSC CONFIG_,0
	  GOTO SAVE2
	
	SAVE1
		MOVWF TIMER1
		GOTO PAUSE
	
	SAVE2
		MOVWF TIMER2
		
PAUSE
	BSF PORTB,7
	CALL DELAY2		;RETARDO PARA EL PARPADEO DE LOS DISPLAY
	MOVFW DISP1
	MOVWF PORTA
	BCF PORTB,0
	CALL DELAY
	BTFSS PORTA,4
	  GOTO PAUSE_P1

	BSF PORTB,0
	MOVFW DISP2
	MOVWF PORTA
	BCF PORTB,1
	CALL DELAY
		
	BSF PORTB,1
	MOVFW DISP3
	MOVWF PORTA
	BCF PORTB,2
	CALL DELAY

	BSF PORTB,2
	MOVFW DISP4
	MOVWF PORTA
	BCF PORTB,3
	CALL DELAY
	BTFSS PORTA,4
	  GOTO PAUSE_P3

	BSF PORTB,3
	MOVFW DISP5
	MOVWF PORTA
	BCF PORTB,4
	CALL DELAY

	BSF PORTB,4
	MOVFW DISP6
	MOVWF PORTA
	BCF PORTB,5
	CALL DELAY

	BSF PORTB,5
	MOVFW DISP7
	MOVWF PORTA
	BCF PORTB,6
	CALL DELAY

	BSF PORTB,6
	MOVFW DISP8
	MOVWF PORTA
	BCF PORTB,7
	CALL DELAY
	BTFSS PORTA,4
	  CALL PAUSE_P2
	
	GOTO PAUSE

;**************************	SUBRUTINAS PARA LA CONFIGURACION DE LOS PULSADORES ***********************************
	
	PAUSE_P1
		MOVLW D'128'
		MOVWF TMR0
		MOVFW TIMER2
		MOVWF TIEMPO
	
		BSF CONFIG_,0
		GOTO INICIO_GAMEPLAY
	
	PAUSE_P2
		MOVLW D'128'
		MOVWF TMR0
		MOVFW TIMER1
		MOVWF TIEMPO
	
		BSF CONFIG_,0
		GOTO INICIO_GAMEPLAY
	
	PAUSE_P3
		CALL APAGAR
		CALL REBOTE

		CLRF CONT2
		BTFSC PORTA,4
		  GOTO INICIO_GAMEPLAY
		DECFSZ CONT2
		  GOTO $-1
		DECFSZ CONT1
		  GOTO $-6
		GOTO INICIO_CONFIG_NORMAL

;*****************************************************************************************************************
;************************************	SUBRUTINAS GENERALES	**************************************************
;*****************************************************************************************************************

		DELAY 
			DECFSZ CONT1
			  GOTO $-1
		
			RETURN
		
		DELAY2				
			NOP
			NOP
			NOP
			NOP
			DECFSZ CONT2
			  GOTO DELAY2
			DECFSZ CONT1
			  GOTO DELAY2
		
			RETURN
		 
		REBOTE
			DECFSZ CONT2
			  GOTO $-1
			DECFSZ CONT1
			  GOTO $-3
		
			RETURN
		
		APAGAR
			MOVLW B'1111'
			MOVWF PORTA
				
			RETURN

		INC_10M
			INCF DISP1
			RETURN
		
		INC_5M
			INCF DISP2
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_10M
			INCF DISP2
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_10M
			INCF DISP2
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_10M
			INCF DISP2
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_10M
			INCF DISP2
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_10M
			RETURN
	
		INC_1M
			INCF DISP2
			RETURN
	
		INC_30S
			INCF DISP3
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP3,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_1M
			INCF DISP3
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP3,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF DISP3
				CALL INC_1M
			INCF DISP3
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP3,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP3
				CALL INC_1M
			RETURN

		INCF_30S		
			INCF FISH1
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH1,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF FISH1
			INCF FISH1
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH1,W
				BTFSS STATUS,0
				  GOTO $+2
				CLRF FISH1
			INCF FISH1
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH1,W
				BTFSS STATUS,0
				  RETURN
				CLRF FISH1
			RETURN

		INCF_10S
			INCF FISH1
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH1,W
				BTFSS STATUS,0
				  RETURN
				CLRF FISH1
			RETURN

		INCF_5S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  GOTO $+3
				CLRF FISH2
				CALL INCF_10S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  GOTO $+3
				CLRF FISH2
				CALL INCF_10S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  GOTO $+3
				CLRF FISH2
				CALL INCF_10S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  GOTO $+3
				CLRF FISH2
				CALL INCF_10S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  RETURN
				CLRF FISH2
				GOTO INCF_10S

		INCF_1S
			INCF FISH2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF FISH2,W
				BTFSS STATUS,0
				  RETURN
				CLRF FISH2
				GOTO INCF_10S

		INC_TIMER1
			INCF DISP4
				BCF STATUS,0
				MOVLW D'9'
				SUBWF DISP4,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP4
			INCF DISP3
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP3,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP3
			INCF DISP2
				BCF STATUS,0
				MOVLW D'9'
				SUBWF DISP2,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP2
			INCF DISP1
				RETURN


		INC_TIMER2
			INCF DISP8
				BCF STATUS,0
				MOVLW D'9'
				SUBWF DISP8,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP8

			INCF DISP7
				BCF STATUS,0
				MOVLW D'5'
				SUBWF DISP7,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP7
			INCF DISP6
				BCF STATUS,0
				MOVLW D'9'
				SUBWF DISP6,W
				BTFSS STATUS,0
				  RETURN
				CLRF DISP6
			INCF DISP5
				RETURN
		
		FINAL
			RESET
			RETURN


END