; Nico Rinck, Jonas Vogt, Sebastian Bernauer
; V1

RS EQU	P2.0
RW EQU	P2.1
E EQU	P2.2
D7 EQU	P1.7
D6 EQU	P1.6
D5 EQU	P1.5
D4 EQU	P1.4
D3 EQU	P1.3
D2 EQU	P1.2
D1 EQU	P1.2
D0 EQU	P1.0

INCREMENT EQU P3.0
DECREMENT EQU P3.1
NEXT_DIGIT EQU P3.2
ENTER EQU P3.7

aktuelleEingabe EQU 30h
currentNumber EQU 31h
currentDigitPosition EQU 32h
number EQU 33h
basis EQU 34h

	; Start of program
	mov aktuelleEingabe, #0
	mov currentNumber, #0
	mov currentDigitPosition, #0
	
	;Init LCD-Display
	mov A, #38h
	acall COMNWRT
	mov A, #0Eh
	acall COMNWRT
	mov A, #01h
	acall COMNWRT
	mov A, #06h
	acall COMNWRT
	mov A, #80h
	acall COMNWRT
	mov A, #'Z'
	acall DATAWRT
	mov A, #'a'
	acall DATAWRT
	mov A, #'h'
	acall DATAWRT
	mov A, #'l'
	acall DATAWRT
	mov A, #':'
	acall DATAWRT
	mov A, #0C0h
	acall COMNWRT
	mov A, #'B'
	acall DATAWRT
	mov A, #'a'
	acall DATAWRT
	mov A, #'s'
	acall DATAWRT
	mov A, #'i'
	acall DATAWRT
	mov A, #'s'
	acall DATAWRT
	mov A, #':'
	acall DATAWRT

	; Write initial zeros
	mov A, #0C7h
	acall COMNWRT
	mov A, #'0'
	acall DATAWRT
	mov A, #87h
	acall COMNWRT
	mov A, #'0'
	acall DATAWRT
	
	NUMBER_LOOP:
		DIGIT_LOOP:
			jb INCREMENT, NOT_INCREMENT
				; Increment pressed
				INC aktuelleEingabe
				; Überlauf?
				mov A, aktuelleEingabe
				cjne A, #10, FORWARD_INCREMENT
					mov aktuelleEingabe, #0
				FORWARD_INCREMENT:
				; Ausgabe der Ziffer
				mov A, aktuelleEingabe
				acall REPLACE_ACTUAL_CHARACTER
				;Warten bis Taster wieder losgelassen
				RELEASE_INCREMENT:
				jnb INCREMENT, RELEASE_INCREMENT
				
			NOT_INCREMENT:
			jb DECREMENT, NOT_DECREMENT
				; Decrement pressed
				DEC aktuelleEingabe
				; Überlauf?
				mov A, aktuelleEingabe
				cjne A, #255, FORWARD_DECREMENT
					mov aktuelleEingabe, #9
				FORWARD_DECREMENT:
				; Ausgabe der Ziffer
				mov A, aktuelleEingabe
				acall REPLACE_ACTUAL_CHARACTER
				;Warten bis Taster wieder losgelassen
				RELEASE_DECREMENT:
				jnb DECREMENT, RELEASE_DECREMENT
				
			NOT_DECREMENT:
			jnb ENTER, NUMBER_FINISHED
			jb NEXT_DIGIT, DIGIT_LOOP
		RELEASE_NEXT_DIGIT:
		jnb NEXT_DIGIT, RELEASE_NEXT_DIGIT
	
		; Next digit pressed
		acall ADD_CURRENT_EINGABE_TO_CURRENT_NUMBER

		mov aktuelleEingabe, #0
		inc currentDigitPosition
		mov A, #'0'
		acall DATAWRT
	sjmp NUMBER_LOOP

	NUMBER_FINISHED:
	; Release Enter
	jnb ENTER, NUMBER_FINISHED
	
	acall ADD_CURRENT_EINGABE_TO_CURRENT_NUMBER
	mov number, currentNumber

	mov currentNumber, #0
	mov currentDigitPosition, #0
	mov aktuelleEingabe, #0

	mov A, #0C8h
	acall COMNWRT

	BASIS_LOOP:
		DIGIT_LOOP_2:
			jb INCREMENT, NOT_INCREMENT_2
				; Increment pressed
				INC aktuelleEingabe
				; Überlauf?
				mov A, aktuelleEingabe
				cjne A, #10, FORWARD_INCREMENT_2
					mov aktuelleEingabe, #0
				FORWARD_INCREMENT_2:
				; Ausgabe der Ziffer
				mov A, aktuelleEingabe
				acall REPLACE_ACTUAL_CHARACTER_2
				;Warten bis Taster wieder losgelassen
				RELEASE_INCREMENT_2:
				jnb INCREMENT, RELEASE_INCREMENT_2
				
			NOT_INCREMENT_2:
			jb DECREMENT, NOT_DECREMENT_2
				; Decrement pressed
				DEC aktuelleEingabe
				; Überlauf?
				mov A, aktuelleEingabe
				cjne A, #255, FORWARD_DECREMENT_2
					mov aktuelleEingabe, #9
				FORWARD_DECREMENT_2:
				; Ausgabe der Ziffer
				mov A, aktuelleEingabe
				acall REPLACE_ACTUAL_CHARACTER_2
				;Warten bis Taster wieder losgelassen
				RELEASE_DECREMENT_2:
				jnb DECREMENT, RELEASE_DECREMENT_2
				
			NOT_DECREMENT_2:
			jnb ENTER, BASIS_FINISHED
			jb NEXT_DIGIT, DIGIT_LOOP_2
		RELEASE_NEXT_DIGIT_2:
		jnb NEXT_DIGIT, RELEASE_NEXT_DIGIT_2
	
		; Next digit pressed
		acall ADD_CURRENT_EINGABE_TO_CURRENT_NUMBER
		
		mov aktuelleEingabe, #0
		inc currentDigitPosition
		mov A, #'0'
		acall DATAWRT
	sjmp BASIS_LOOP

	BASIS_FINISHED:
	acall ADD_CURRENT_EINGABE_TO_CURRENT_NUMBER
	mov basis, currentNumber
	; Berechung
	BERECHNUNG:
		; TODOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
	sjmp BERECHNUNG
		

INFINITE_LOOP:
	sjmp INFINITE_LOOP

COMNWRT:
	acall WAIT_FOR_READY
	mov P1, A
	clr RS
	clr RW
	setb E
	clr E
	ret

DATAWRT:
	call WAIT_FOR_READY
	mov P1, A
	setb RS
	clr RW
	setb E
	clr E
	ret

WAIT_FOR_READY:
	setb D7
	clr RS
	setb RW
	BACK:
	setb E
	clr E
	jb D7, BACK
	RET

REPLACE_ACTUAL_CHARACTER:	; Character to write is in A, 0 puts out a 0, no ASCII-Number is needed
	push A
	mov A, #87h
	ADD A, currentDigitPosition
	acall COMNWRT
	pop A
	add A, #30h  ; Offset for ASCII-Character
	acall DATAWRT
	ret

REPLACE_ACTUAL_CHARACTER_2:	; Character to write is in A, 0 puts out a 0, no ASCII-Number is needed
	push A
	mov A, #0C7h
	ADD A, currentDigitPosition
	acall COMNWRT
	pop A
	add A, #30h  ; Offset for ASCII-Character
	acall DATAWRT
	ret

ADD_CURRENT_EINGABE_TO_CURRENT_NUMBER:
	mov A, currentNumber
	mov B, #10
	mul AB
	add A, aktuelleEingabe
	mov currentNumber, A
	ret