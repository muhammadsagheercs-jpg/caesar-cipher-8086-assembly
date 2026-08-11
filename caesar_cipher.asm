.MODEL SMALL
.STACK 200H
.DATA
    title_msg   DB '================================', 0Dh, 0Ah
                DB '   CAESAR CIPHER - 8086 ASM    ', 0Dh, 0Ah
                DB '================================', 0Dh, 0Ah, '$'

    menu_msg    DB '[1] Encrypt', 0Dh, 0Ah
                DB '[2] Decrypt', 0Dh, 0Ah
                DB 'Your choice : $'

    shift_msg   DB 'Shift value (1-9): $'
    input_msg   DB 'Enter text  : $'
    output_msg  DB 'Result      : $'
    err_msg     DB 'Invalid choice!', 0Dh, 0Ah, '$'
    newline_str DB 0Dh, 0Ah, '$'

    input_buf   DB 81
                DB 0
                DB 81 DUP(0)

    result_buf  DB 84 DUP('$')

    shift_val   DB 0
    choice      DB 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, title_msg
    MOV AH, 09H
    INT 21H

    LEA DX, menu_msg
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    MOV choice, AL
    CALL PRINT_NL

    LEA DX, shift_msg
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV shift_val, AL
    CALL PRINT_NL

    LEA DX, input_msg
    MOV AH, 09H
    INT 21H

    LEA DX, input_buf
    MOV AH, 0AH
    INT 21H
    CALL PRINT_NL

    MOV AL, choice
    CMP AL, '1'
    JE  DO_ENCRYPT
    CMP AL, '2'
    JE  DO_DECRYPT

    LEA DX, err_msg
    MOV AH, 09H
    INT 21H
    JMP EXIT_PROG

DO_ENCRYPT:
    CALL ENCRYPT
    JMP  SHOW_RESULT

DO_DECRYPT:
    CALL DECRYPT

SHOW_RESULT:
    LEA DX, output_msg
    MOV AH, 09H
    INT 21H

    LEA DX, result_buf
    MOV AH, 09H
    INT 21H
    CALL PRINT_NL

EXIT_PROG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP


PRINT_NL PROC
    LEA DX, newline_str
    MOV AH, 09H
    INT 21H
    RET
PRINT_NL ENDP


ENCRYPT PROC
    MOV CL, input_buf[1]
    MOV CH, 0
    JCXZ ENC_DONE

    LEA SI, input_buf[2]
    LEA DI, result_buf
    MOV BL, shift_val

ENC_LOOP:
    LODSB

    CMP AL, 'A'
    JL  ENC_CHK_LOWER
    CMP AL, 'Z'
    JG  ENC_CHK_LOWER

    ADD AL, BL
    CMP AL, 'Z'
    JLE ENC_STORE
    SUB AL, 26
    JMP ENC_STORE

ENC_CHK_LOWER:
    CMP AL, 'a'
    JL  ENC_STORE
    CMP AL, 'z'
    JG  ENC_STORE

    ADD AL, BL
    CMP AL, 'z'
    JLE ENC_STORE
    SUB AL, 26

ENC_STORE:
    STOSB
    LOOP ENC_LOOP

ENC_DONE:
    MOV BYTE PTR [DI], '$'
    RET
ENCRYPT ENDP


DECRYPT PROC
    MOV CL, input_buf[1]
    MOV CH, 0
    JCXZ DEC_DONE

    LEA SI, input_buf[2]
    LEA DI, result_buf
    MOV BL, shift_val

DEC_LOOP:
    LODSB

    CMP AL, 'A'
    JL  DEC_CHK_LOWER
    CMP AL, 'Z'
    JG  DEC_CHK_LOWER

    SUB AL, BL
    CMP AL, 'A'
    JGE DEC_STORE
    ADD AL, 26
    JMP DEC_STORE

DEC_CHK_LOWER:
    CMP AL, 'a'
    JL  DEC_STORE
    CMP AL, 'z'
    JG  DEC_STORE

    SUB AL, BL
    CMP AL, 'a'
    JGE DEC_STORE
    ADD AL, 26

DEC_STORE:
    STOSB
    LOOP DEC_LOOP

DEC_DONE:
    MOV BYTE PTR [DI], '$'
    RET
DECRYPT ENDP

END MAIN