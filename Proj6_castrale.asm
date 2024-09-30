TITLE Designing low-level I/O procedures     (Proj6_castrale.asm)

; Author: Alexa Castro
; Last Modified: 06/05/2022
; OSU email address: castrale@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 06/05/2022
; Description: Program asks user to input 10 signed integers, validates that the user input is a valid
;			   number, and that the user input is small enough to fit inside a 32 bit register. If not,
;			   raises an error and tells the user to input a new number. User input is entered as a string
;			   using mGetString macro and converted to a numeric value using ReadVal procedure. The sum and
;			   average of the numbers are then calculated and printed to the console along with a list of the
;			   entered numbers. Values are printed to console using mDisplayString macro and WriteVal procedure 
;			   which converts the numeric values back to ASCII characters. Program then says goodbye.

INCLUDE Irvine32.inc

; -------------------------------------------------------------------------------
; Name: mGetString
; Prints a prompt, then gets the user's input into a memory location.
; Preconditions: prompt and memLocation must be passed by reference.
; Postconditions: None
; Receives: prompt = reference to prompt message, memLocation = reference to where
;			to store user's input, MAX_LENGTH as a global variable
; Returns: User input in memLocation
; -------------------------------------------------------------------------------
mGetString MACRO prompt, memLocation
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, memLocation
	MOV		ECX, MAX_LENGTH
	CALL	ReadString
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

; -------------------------------------------------------------------------------
; Name: mDisplayString
; Prints the string stored in a specified memory location.
; Preconditions: stringAddress must be passed by reference.
; Postconditions: None
; Receives: stringAddress = reference to string to be printed
; Returns: None
; -------------------------------------------------------------------------------
mDisplayString MACRO stringAddress
	PUSH	EDX
	MOV		EDX, stringAddress
	CALL	WriteString
	POP		EDX
ENDM

; -------------------------------------------------------------------------------
; Name: mResetString
; Restores a string to an empty string
; Preconditions: stringToReset must be passed by reference.
; Postconditions: None
; Receives: stringToReset = reference to string that has to be zeroed out
; Returns: stringToReset = empty string
; -------------------------------------------------------------------------------
mResetString MACRO stringToReset
	LOCAL zeroString
.data
	zeroString	BYTE	12 DUP (0)
.code
	PUSH	ESI
	PUSH	EDI
	PUSH	ECX
	MOV		ESI, OFFSET zeroString
	MOV		EDI, stringtoReset
	MOV		ECX, LENGTHOF zeroString
	REP		MOVSB
	POP		ECX
	POP		EDI
	POP		ESI
ENDM

ARRAYSIZE = 10
MAX_LENGTH = 21

.data
intro			BYTE	"Designing low-level I/O procedures		by Alexa Castro",13,10,13,10,0
rules1			BYTE	"Please provide 10 signed decimal integers.",13,10,0
rules2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished "
				BYTE	"inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
prompt			BYTE	"Please enter a signed number: ",0
errorMsg		BYTE	"There's an error with your entry. Please enter a new number.",13,10,0
resultsMsg		BYTE	"You entered the following numbers:",13,10,0
sumMsg			BYTE	"The sum of these numbers is: ",0
averageMsg		BYTE	"The truncated average is: ",0
goodbye			BYTE	13,10,"Goodbye and thanks for playing!",13,10,0
commaSpace		BYTE	", ",0
negativeSign	BYTE	"-",0
userNum			SDWORD	0
userString		BYTE	MAX_LENGTH DUP(?)
numArray		SDWORD	ARRAYSIZE DUP(?)
sum				SDWORD	0
average			SDWORD	0

.code
main PROC
; -------------------------------------------------------------------------------
; Uses mDisplayString macro to print the program name, programmer name, and 
; program description to console.
; -------------------------------------------------------------------------------
	mDisplayString	OFFSET intro
	mDisplayString	OFFSET rules1
	mDisplayString	OFFSET rules2
	CALL	CrLf

; -------------------------------------------------------------------------------
; Fills an array with 10 validated SDWORD numeric values. Obtains a validated
; numeric value by calling ReadVal procedure. After returning from ReadVal, puts 
; validated number into array and loops to obtain next validated number.
; Pushes required parameters for ReadVal to the stack before calling procedure.
; -------------------------------------------------------------------------------
	MOV		ECX, ARRAYSIZE				; loop to fill array based on ARRAYSIZE
	MOV		EDI, OFFSET numArray		; address of array in EDI
_readLoop:
	PUSH	OFFSET prompt
	PUSH	OFFSET errorMsg
	PUSH	OFFSET userNum
	PUSH	OFFSET userString
	CALL	ReadVal
	MOV		EAX, userNum				; move validated SDWORD numeric value to EAX
	MOV		[EDI], EAX
	ADD		EDI, 4
	LOOP	_readLoop
	CALL	CrLf

; -------------------------------------------------------------------------------
; Calculates the sum and truncated average of the 10 SDWORD numeric values in the
; array. Saves the values in sum and average variables.
; -------------------------------------------------------------------------------
	MOV		ESI, OFFSET numArray		; address of array in ESI
	MOV		ECX, ARRAYSIZE				; ARRAYSIZE in ECX for loop counter
	MOV		EAX, 0
_sumLoop:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_sumLoop
	MOV		sum, EAX

	CDQ
	MOV		EBX, ARRAYSIZE
	IDIV	EBX
	MOV		average, EAX

; -------------------------------------------------------------------------------
; Uses mDisplayString macro to print message to console. Then, passes one number
; from the array at a time to WriteVal procedure to be converted to a string and
; printed to console. Loops through entire array. Pushes required parameters for
; WriteVal to the stack before calling procedure.
; -------------------------------------------------------------------------------	
	mDisplayString	OFFSET resultsMsg
	mResetString	OFFSET userString		; reset string to empty string
	MOV		EBX, 0							; initialize EBX to 0 as counter for adding commas 
	MOV		ECX, ARRAYSIZE					; loop to print array numbers based on ARRAYSIZE
	MOV		ESI, OFFSET numArray			; address of array in ESI
_writeLoop:
	PUSH	[ESI]						; push current value of array
	PUSH	OFFSET userString
	PUSH	OFFSET negativeSign
	CALL	WriteVal
	INC		EBX
	ADD		ESI, 4
	CMP		EBX, 10						; if EBX = 10, do not add comma after printed number
	JNE		_addComma					; else add comma
	LOOP	_writeLoop
	CALL	CrLf
	JMP		_printSumAndAvg

_addComma:
	mDisplayString	OFFSET commaSpace
	LOOP	_writeLoop

; -------------------------------------------------------------------------------
; Uses mDisplayString macro to print sum and average messages to console. Pushes
; sum and average values, as well as other parameters needed for the procedure,
; to the stack and calls WriteVal procedure.
; -------------------------------------------------------------------------------
_printSumAndAvg:
	mDisplayString	OFFSET sumMsg
	PUSH	sum
	PUSH	OFFSET userString
	PUSH	OFFSET negativeSign
	CALL	WriteVal
	CALL	CrLf

	mDisplayString	OFFSET averageMsg
	PUSH	average
	PUSH	OFFSET userString
	PUSH	OFFSET negativeSign
	CALL	WriteVal
	CALL	CrLf

; -------------------------------------------------------------------------------
; Uses mDisplayString macro to print program goodbye message to console.
; -------------------------------------------------------------------------------
	mDisplayString	OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; -------------------------------------------------------------------------------
; Name: ReadVal
; Obtains user input in the form of a string of digits then converts the string 
; of ASCII digits to its numeric SDWORD value. Also validates that the user input
; is a valid number and can fit within a 32 bit register. Once validated, stores
; the value in a memory variable.
; Preconditions: None
; Postconditions: None
; Receives: [EBP+8] = reference to user string, [EBP+12] = reference to address
;			where converted SDWORD value will be stored, [EBP+16] = reference to
;			error message, [EBP+20] = reference to prompt
; Returns: [EBP+12] = validated numeric SDWORD value
; -------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX ECX EDX ESI EDI
	LOCAL	signVal:DWORD, currentTotal:SDWORD
	MOV		EAX, 0
	MOV		currentTotal, 0			; local variable to store converted SDWORD numeric value

; -------------------------------------------------------------------------------
; Gets user input in the form of a string of digits and converts the string to its 
; numeric value. Validates that the user's input is a valid number and can fit
; inside a 32 bit register. If user's input is invalid, will display an error message 
; and prompt the user to enter a new number. If valid, stores the converted numeric 
; value in a memory variable at [EBP+12].
; -------------------------------------------------------------------------------
_getString:
	mGetString	[EBP+20], [EBP+8]
	MOV		ESI, [EBP+8]			; user string input in ESI
	MOV		ECX, 0					; counter in ECX
	MOV		signVal, 0				; local variable for sign of value initalized to 0
	CLD

_iterate:
	LODSB
	CMP		AL, 0
	JE		_null

_continue:
	CMP		AL, 48
	JL		_checkIfSign
	CMP		AL, 57
	JG		_invalid
	INC		ECX
	SUB		AL, 48
	CMP		signVal, 0
	JE		_convertPositive		; if signVal = 0, value is positive
	JNE		_convertNegative		; if signVal = 1, value is negative

_checkIfSign:
	CMP		AL, 45
	JE		_setSign
	CMP		AL, 43
	JNE		_invalid
	INC		ECX
	CMP		ECX, 1					
	JA		_invalid			; if ECX > 1, + sign was entered after the first char and value is invalid
	LODSB
	CMP		AL, 0
	JE		_invalid			; if next value is null terminator, only + char was entered and value is invalid
	JMP		_continue

_setSign:
	MOV		signVal, 1
	INC		ECX
	CMP		ECX, 1
	JA		_invalid			; if ECX > 1, - sign was entered after the first char and value is invalid
	LODSB
	CMP		AL, 0
	JE		_invalid			; if next value is null terminator, only - char was entered and value is invalid
	JMP		_continue

_invalid:
	mDisplayString	[EBP+16]
	MOV		EAX, 0
	MOV		EBX, 0
	MOV		currentTotal, 0
	JMP		_getString

_null:
	CMP		ECX, 0
	JE		_invalid			; if ECX = 0, empty string was entered and is invalid
	JMP		_end

_convertPositive:
	MOV		EBX, EAX				; move numeric value of string character to EBX
	MOV		EAX, currentTotal
	MOV		EDX, 10
	IMUL	EDX
	JO		_invalid
	MOV		currentTotal, EAX
	MOV		EAX, 0
	ADD		currentTotal, EBX		; add numeric value to currentTotal
	JO		_invalid
	JMP		_iterate

_convertNegative:
	MOV		EBX, EAX				; move numeric value of string character to EBX
	MOV		EAX, currentTotal
	MOV		EDX, 10
	IMUL	EDX
	JO		_invalid
	MOV		currentTotal, EAX
	MOV		EAX, 0
	SUB		currentTotal, EBX		; subtract numeric value from currentTotal
	JO		_invalid
	JMP		_iterate

_end:
	MOV		EAX, currentTotal
	MOV		EDI, [EBP+12]
	MOV		[EDI], EAX			; converted SDWORD numeric value gets moved into [EBP+12]
	RET		16
ReadVal ENDP

; -------------------------------------------------------------------------------
; Name: WriteVal
; Converts a numeric SDWORD value to a string of ASCII digits then prints the
; string to the console.
; Preconditions: Numeric value passed must be a SDWORD
; Postconditions: None
; Receives: [EBP+8] = reference to negative sign string, [EBP+12] = reference to
;			empty string to store ASCII digits, [EBP+16] = numeric SDWORD value 
; Returns: None
; -------------------------------------------------------------------------------
WriteVal PROC USES EAX EBX ECX EDX EDI
	LOCAL	count:DWORD
	MOV		count, 0		; initalize local count variable to 0
	CLD

; -------------------------------------------------------------------------------
; Checks whether the passed numeric value is positive or negative, then converts
; the value to a string of ASCII characters, and prints the string.
; -------------------------------------------------------------------------------
_checkSign:
	MOV		EDI, [EBP+12]
	MOV		EAX, [EBP+16]
	CMP		EAX, 0
	JGE		_convertNum			; if EAX >= 0, number is positive and can move to converting normally
	NEG		EAX					; else EAX < 0, number is negative and has to be negated
	mDisplayString	[EBP+8]		; print '-' character for negated negative number

_convertNum:
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX
	ADD		EDX, 48
	INC		count
	PUSH	EDX					; push remainder in EDX which equals ASCII character of number
	CMP		EAX, 0				; if EAX = 0, number is completely converted to ASCII
	JNE		_convertNum			

	MOV		ECX, count			; loop for moving ASCII characters to EDI
_printString:
	POP		EAX					; pop converted ASCII characters off stack into EAX 
	STOSB
	LOOP	_printString
	mDisplayString	[EBP+12]
	mResetString	[EBP+12]	; reset string to empty string for next conversion 

	RET		12
WriteVal ENDP

END main