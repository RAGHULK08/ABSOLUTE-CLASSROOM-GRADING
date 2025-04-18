include "emu8086.inc"
JMP START

DATA SEGMENT
    N               DW      ?                                        
    MARKS           DB      1000 DUP (?)
    ID              DB      1000 DUP (?)
    GRADE           DB      1000 DUP (?)

    MSG1            DB 'Enter the number of students (DOES NOT EXCEED 1000): ', 0
    INVALID_N_MSG   DB 0Dh,0Ah, 'Invalid number of students! Number must be between 1 and 1000.', 0
    MSG2            DB 0Dh,0Ah, 'Enter the IDs of students: ', 0
    MSG3            DB 0Dh,0Ah, 'Enter the marks of students (0-100): ', 0
    INVALID_MARK_MSG DB 0Dh,0Ah, 'Invalid mark entered! Please enter mark (0-100): ', 0

    HR              DB 0Dh,0Ah, '*******************Sorted Marks***********************', 0
    MSG4            DB 0Dh,0Ah, 'ID:', 09H, 'MARKS:', 09H, 'GRADE:', 09H, 'STATUS:', 0

    PASS_MSG        DB 'PASS', 0
    FAIL_MSG        DB 'FAIL', 0

    PASS_COUNT      DW 0
    FAIL_COUNT      DW 0
    GRADE_S_COUNT   DW 0
    GRADE_A_COUNT   DW 0
    GRADE_B_COUNT   DW 0
    GRADE_C_COUNT   DW 0
    GRADE_D_COUNT   DW 0
    GRADE_E_COUNT   DW 0
    GRADE_F_COUNT   DW 0

    PASS_COUNT_MSG      DB 0Dh,0Ah, "PASS COUNT: ", 0
    FAIL_COUNT_MSG      DB 0Dh,0Ah, "FAIL COUNT: ", 0
    GRADE_S_COUNT_MSG   DB 0Dh,0Ah, "GRADE S COUNT: ", 0
    GRADE_A_COUNT_MSG   DB 0Dh,0Ah, "GRADE A COUNT: ", 0
    GRADE_B_COUNT_MSG   DB 0Dh,0Ah, "GRADE B COUNT: ", 0
    GRADE_C_COUNT_MSG   DB 0Dh,0Ah, "GRADE C COUNT: ", 0
    GRADE_D_COUNT_MSG   DB 0Dh,0Ah, "GRADE D COUNT: ", 0
    GRADE_E_COUNT_MSG   DB 0Dh,0Ah, "GRADE E COUNT: ", 0
    GRADE_F_COUNT_MSG   DB 0Dh,0Ah, "GRADE F COUNT: ", 0

    AVG_MSG         DB 0Dh,0Ah,0Dh,0Ah, "AVERAGE MARKS: ", 0
    HIGH_MARK_MSG   DB 0Dh,0Ah,0Dh,0Ah, "HIGHEST MARK: ", 0
    LOW_MARK_MSG    DB 0Dh,0Ah,0Dh,0Ah, "LOWEST MARK: ", 0
    MEDIAN_MSG      DB 0Dh,0Ah,0Dh,0Ah, "MEDIAN Mark: ", 0
    ID_MSG          DB " (ID: ", 0
    END_MSG         DB ")", 0

    ; Variables to store computed results.
    HIGH_MARK       DW 0
    LOW_MARK        DW 0
    HIGH_ID         DB 0
    LOW_ID          DB 0
    MEDIAN          DW 0
DATA ENDS

CODE SEGMENT
ASSUME DS:DATA, CS:CODE
START:
    MOV AX, DATA
    MOV DS, AX

    DEFINE_SCAN_NUM
    DEFINE_PRINT_STRING
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS

    ;---------------------------------------
    ; Get number of students with validation.
GET_N:
    LEA SI, MSG1
    CALL PRINT_STRING
    CALL SCAN_NUM
    MOV N, CX
    MOV AX, N
    CMP AX, 0
    JE INVALID_N
    CMP AX, 1000
    JA INVALID_N

    ;---------------------------------------
    ; Input student IDs.
    LEA SI, MSG2
    CALL PRINT_STRING
    MOV DI, 0
LOOP1:
    CALL SCAN_NUM
    MOV [ID + DI], CL
    INC DI
    PRINT 0DH
    PRINT 0AH
    MOV AX, N
    CMP DI, AX
    JNE LOOP1

    ;---------------------------------------
    ; Input student marks with range check.
    LEA SI, MSG3
    CALL PRINT_STRING
    MOV DI, 0
LOOP2:
    CALL SCAN_NUM
    ; Validate mark is between 0 and 100.
    MOV AL, CL
    CMP AL, 0
    JB INVALID_MARK     ; (Underflow is unlikely, but here for completeness)
    CMP AL, 100
    JA INVALID_MARK
    MOV [MARKS + DI], AL
    INC DI
    PRINT 0DH
    PRINT 0AH
    MOV AX, N
    CMP DI, AX
    JNE LOOP2
    JMP CONTINUE_INPUT

; If N is invalid, show error and restart.
INVALID_N:
    LEA SI, INVALID_N_MSG
    CALL PRINT_STRING
    MOV AH, 0
    INT 16h
    JMP START

; If a mark is invalid, show error and re-read for same student.
INVALID_MARK:
    LEA SI, INVALID_MARK_MSG
    CALL PRINT_STRING
    JMP LOOP2

CONTINUE_INPUT:
    ;---------------------------------------
    ; Bubble sort (descending order) of marks and corresponding IDs.
    MOV CX, N
    DEC CX                ; Outer loop count = N - 1
SORT_OUTER:
    PUSH CX
    MOV DI, 0
    MOV BX, N
    DEC BX                ; Inner loop count = N - 1
SORT_INNER:
    MOV AL, [MARKS + DI]
    MOV DL, [MARKS + DI + 1]
    CMP AL, DL
    JAE NO_SWAP         ; if AL >= DL then no swap needed
    ; Swap marks.
    XCHG AL, [MARKS + DI + 1]
    MOV [MARKS + DI], AL
    ; Swap corresponding IDs.
    MOV AL, [ID + DI]
    MOV DL, [ID + DI + 1]
    XCHG AL, [ID + DI + 1]
    MOV [ID + DI], AL
NO_SWAP:
    INC DI
    DEC BX
    CMP BX, 0
    JG SORT_INNER
    POP CX
    DEC CX
    CMP CX, 0
    JG SORT_OUTER

    ;---------------------------------------
    ; Grade assignment and pass/fail counting.
    MOV DI, 0
GRADE_LOOP:
    MOV AL, [MARKS + DI]
    CMP AL, 90
    JAE GRADE_S
    CMP AL, 80
    JAE GRADE_A
    CMP AL, 70
    JAE GRADE_B
    CMP AL, 60
    JAE GRADE_C
    CMP AL, 55
    JAE GRADE_D
    CMP AL, 50
    JAE GRADE_E
    MOV BYTE PTR [GRADE + DI], 'F'
    INC WORD PTR [GRADE_F_COUNT]
    JMP CHECK_PASS_FAIL

GRADE_S:
    MOV BYTE PTR [GRADE + DI], 'S'
    INC WORD PTR [GRADE_S_COUNT]
    JMP CHECK_PASS_FAIL
GRADE_A:
    MOV BYTE PTR [GRADE + DI], 'A'
    INC WORD PTR [GRADE_A_COUNT]
    JMP CHECK_PASS_FAIL
GRADE_B:
    MOV BYTE PTR [GRADE + DI], 'B'
    INC WORD PTR [GRADE_B_COUNT]
    JMP CHECK_PASS_FAIL
GRADE_C:
    MOV BYTE PTR [GRADE + DI], 'C'
    INC WORD PTR [GRADE_C_COUNT]
    JMP CHECK_PASS_FAIL
GRADE_D:
    MOV BYTE PTR [GRADE + DI], 'D'
    INC WORD PTR [GRADE_D_COUNT]
    JMP CHECK_PASS_FAIL
GRADE_E:
    MOV BYTE PTR [GRADE + DI], 'E'
    INC WORD PTR [GRADE_E_COUNT]
    ; Fall through to pass/fail check.

CHECK_PASS_FAIL:
    CMP BYTE PTR [GRADE + DI], 'F'
    JE FAIL_STUDENT
    INC WORD PTR [PASS_COUNT]
    JMP NEXT_STUDENT
FAIL_STUDENT:
    INC WORD PTR [FAIL_COUNT]
NEXT_STUDENT:
    INC DI
    MOV AX, N
    CMP DI, AX
    JL GRADE_LOOP

    ;---------------------------------------
    ; Determine highest and lowest marks and corresponding student IDs.
    MOV DI, 0
    MOV AL, [MARKS]      ; Set first student's mark as both current high and low.
    MOV AH, 0
    MOV HIGH_MARK, AX
    MOV LOW_MARK, AX
    MOV AL, [ID]         ; Set first student's ID.
    MOV HIGH_ID, AL
    MOV LOW_ID, AL
    MOV DI, 1
HIGH_LOW_LOOP:
    MOV AL, [MARKS + DI]
    MOV AH, 0
    CMP AX, HIGH_MARK
    JA UPDATE_HIGH
    CMP AX, LOW_MARK
    JB UPDATE_LOW
CONTINUE_HIGH_LOW:
    INC DI
    MOV AX, N
    CMP DI, AX
    JL HIGH_LOW_LOOP
    ;---------------------------------------------------------
    ; Clear screen before sorted output.
    CALL CLEAR_SCREEN

    ;---------------------------------------
    ; Print sorted records header.
    LEA SI, HR
    CALL PRINT_STRING
    LEA SI, MSG4
    CALL PRINT_STRING
    PRINT 0DH
    PRINT 0AH

    ;---------------------------------------
    ; Print each student record.
    MOV DI, 0
LOOP3:
    ; --- Print Student ID ---
    MOV AL, [ID + DI]
    MOV AH, 0
    CALL PRINT_NUM_UNS
    PRINT 09H

    ; --- Print Marks ---
    MOV AL, [MARKS + DI]
    MOV AH, 0
    CALL PRINT_NUM_UNS
    PRINT 09H

    ; --- Print Grade ---
    MOV DL, [GRADE + DI]
    MOV AH, 02H
    INT 21h
    PRINT 09H

    ; --- Print Pass/Fail status ---
    CMP BYTE PTR [GRADE + DI], 'F'
    JE PRINT_FAIL
    LEA SI, PASS_MSG
    CALL PRINT_STRING
    JMP PRINT_NEXT
PRINT_FAIL:
    LEA SI, FAIL_MSG
    CALL PRINT_STRING
PRINT_NEXT:
    PRINT 0DH
    PRINT 0AH
    INC DI
    MOV AX, N
    CMP DI, AX
    JL LOOP3

    ;---------------------------------------
    ; Print Pass/Fail and Grade counts.
    PRINT 0DH
    PRINT 0AH
    LEA SI, PASS_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, PASS_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, FAIL_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, FAIL_COUNT
    CALL PRINT_NUM

    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_S_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_S_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_A_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_A_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_B_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_B_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_C_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_C_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_D_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_D_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_E_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_E_COUNT
    CALL PRINT_NUM
    PRINT 0DH
    PRINT 0AH
    LEA SI, GRADE_F_COUNT_MSG
    CALL PRINT_STRING
    MOV AX, GRADE_F_COUNT
    CALL PRINT_NUM

    ;---------------------------------------
    ; Compute and Display the Average of the Class.
    MOV DI, 0
    XOR BX, BX       ; BX holds the sum of marks.
AVG_LOOP:
    MOV AL, [MARKS + DI]
    MOV AH, 0
    ADD BX, AX
    INC DI
    MOV AX, N
    CMP DI, AX
    JL AVG_LOOP

    CMP WORD PTR [N], 0
    JE SKIP_AVG

    MOV AX, BX
    XOR DX, DX
    MOV CX, N       
    DIV CX          ; AX now holds the average.
    
    LEA SI, AVG_MSG
    CALL PRINT_STRING
    CALL PRINT_NUM

SKIP_AVG:
    ;---------------------------------------
    ; Compute and Display Median Mark.
    ; Since array is sorted in descending order:
    ; For an odd number of students, the median is at index N/2.
    ; For an even number, it is the average of the two center marks.
    MOV AX, N
    MOV BX, AX
    AND BX, 1       ; Test if N is odd.
    CMP BX, 1
    JE ODD_MEDIAN
    ; Even number of students.
    MOV AX, N
    MOV BX, 2
    XOR DX, DX
    DIV BX         ; Now AX = N/2 (upper median index)
    MOV SI, AX     ; SI = upper median index
    MOV DI, SI
    DEC DI        ; Lower median index = SI - 1.
    MOV AL, [MARKS + DI]  ; lower median mark
    MOV BL, [MARKS + SI]  ; upper median mark
    ADD AL, BL
    MOV AH, 0
    MOV BL, 2
    DIV BL        ; AL becomes the average of the two.
    LEA SI, MEDIAN_MSG
    CALL PRINT_STRING
    CALL PRINT_NUM_UNS
    JMP AFTER_MEDIAN

ODD_MEDIAN:
    MOV AX, N
    MOV BX, 2
    XOR DX, DX
    DIV BX         ; Quotient in AX is the median index.
    MOV SI, AX
    MOV AL, [MARKS + SI]
    LEA SI, MEDIAN_MSG
    CALL PRINT_STRING
    CALL PRINT_NUM_UNS

AFTER_MEDIAN:
    ;---------------------------------------
    ; Display Highest and Lowest Marks along with corresponding IDs.
    LEA SI, HIGH_MARK_MSG
    CALL PRINT_STRING
    MOV AX, HIGH_MARK
    CALL PRINT_NUM
    LEA SI, ID_MSG
    CALL PRINT_STRING
    MOV AL, HIGH_ID
    MOV AH, 0
    CALL PRINT_NUM_UNS
    LEA SI, END_MSG
    CALL PRINT_STRING

    LEA SI, LOW_MARK_MSG
    CALL PRINT_STRING
    MOV AX, LOW_MARK
    CALL PRINT_NUM
    LEA SI, ID_MSG
    CALL PRINT_STRING
    MOV AL, LOW_ID
    MOV AH, 0
    CALL PRINT_NUM_UNS
    LEA SI, END_MSG
    CALL PRINT_STRING

    ;---------------------------------------
    ; Wait for key press before exiting.
    MOV AH, 0
    INT 16h
    JMP DONE

;---------------------------------------
; Update routines for highest and lowest marks.
UPDATE_HIGH:
    MOV HIGH_MARK, AX
    MOV AL, [ID + DI]
    MOV HIGH_ID, AL
    JMP CONTINUE_HIGH_LOW
UPDATE_LOW:
    MOV LOW_MARK, AX
    MOV AL, [ID + DI]
    MOV LOW_ID, AL
    JMP CONTINUE_HIGH_LOW

;---------------------------------------
; Clear screen routine using direct video memory clear.
CLEAR_SCREEN:
    MOV AX, 0B800h
    MOV ES, AX
    XOR DI, DI
    MOV CX, 2000         ; 80 * 25 words
    MOV AX, 0720h        ; ASCII space (20h) with attribute 07h
    REP STOSW
    ; Reset cursor to top left.
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10h
    RET

DONE:
    MOV AH, 4Ch
    INT 21h
CODE ENDS
END START
