.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 함수 선언 (Irvine32의 Sleep, Gotoxy, SetTextColor 대체)
; -------------------------------------------------------------------------
GetStdHandle            PROTO stdcall :DWORD
SetConsoleCursorPosition PROTO stdcall :DWORD, :DWORD
SetConsoleTextAttribute PROTO stdcall :DWORD, :DWORD
WriteConsoleA           PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
Sleep                   PROTO stdcall :DWORD       ; 500ms 지연 처리를 위한 API
ExitProcess             PROTO stdcall :DWORD

includelib kernel32.lib

; 흰색 배경 고정 상수 (15 SHL 4 = 0F0h)
COLOR_WHITE EQU 0F0h

.code
; =========================================================================
; 1. SetCursorPosition (Gotoxy 역할)
; =========================================================================
SetCursorPosition PROC stdcall USES eax,
    hOut: DWORD,
    xPos: DWORD,
    yPos: DWORD

    mov eax, yPos
    shl eax, 16                 ; 상위 16비트에 Y 배치
    mov ax, word ptr xPos       ; 하위 16비트에 X 배치
    
    INVOKE SetConsoleCursorPosition, hOut, eax
    ret
SetCursorPosition ENDP

; =========================================================================
; 2. DrawSquare (단일 칸 그리기)
; =========================================================================
DrawSquare PROC stdcall USES eax,
    hOut: DWORD,
    xPos: DWORD,
    yPos: DWORD,
    colorAttr: DWORD

    LOCAL spaces: WORD
    LOCAL bytesWritten: DWORD

    mov spaces, 2020h           ; ASCII 공백 2개 ('  ')

    INVOKE SetCursorPosition, hOut, xPos, yPos
    INVOKE SetConsoleTextAttribute, hOut, colorAttr
    INVOKE WriteConsoleA, hOut, ADDR spaces, 2, ADDR bytesWritten, 0
    ret
DrawSquare ENDP

; =========================================================================
; 3. DrawRow (1개 행 그리기)
; =========================================================================
DrawRow PROC stdcall USES eax ecx edx,
    hOut: DWORD,
    rowIdx: DWORD,
    startIsWhite: DWORD,       ; 1 = 흰색으로 시작, 0 = 변경색으로 시작
    coloredAttr: DWORD         ; 동적으로 전달받는 변경 배경색

    LOCAL col: DWORD
    LOCAL isCurrentWhite: DWORD
    LOCAL currentColor: DWORD
    LOCAL xPos: DWORD

    mov eax, startIsWhite
    mov isCurrentWhite, eax
    mov col, 0

L_COL_LOOP:
    cmp col, 8
    jge L_ROW_DONE

    ; X 좌표 = col * 2
    mov eax, col
    shl eax, 1
    mov xPos, eax

    ; 현재 칸의 색상 결정 (흰색 vs 변하는 색)
    cmp isCurrentWhite, 1
    jne L_USE_COLORED
    mov currentColor, COLOR_WHITE
    jmp L_DRAW_IT

L_USE_COLORED:
    mov eax, coloredAttr
    mov currentColor, eax

L_DRAW_IT:
    INVOKE DrawSquare, hOut, xPos, rowIdx, currentColor

    ; 다음 칸은 색상 반전 (White <-> Colored)
    xor isCurrentWhite, 1

    inc col
    jmp L_COL_LOOP

L_ROW_DONE:
    ret
DrawRow ENDP

; =========================================================================
; 4. DrawBoard (체스판 1회 그리기)
; =========================================================================
DrawBoard PROC stdcall USES eax ecx,
    hOut: DWORD,
    coloredAttr: DWORD

    LOCAL row: DWORD
    LOCAL startIsWhite: DWORD

    mov row, 0

L_BOARD_LOOP:
    cmp row, 8
    jge L_BOARD_DONE

    ; 짝수 행은 흰색 시작(1), 홀수 행은 변경색 시작(0)
    mov eax, row
    test eax, 1
    jnz L_ODD_ROW

    mov startIsWhite, 1
    jmp L_DRAW

L_ODD_ROW:
    mov startIsWhite, 0

L_DRAW:
    INVOKE DrawRow, hOut, row, startIsWhite, coloredAttr
    inc row
    jmp L_BOARD_LOOP

L_BOARD_DONE:
    ret
DrawBoard ENDP

; =========================================================================
; Main 프로시저 (16가지 색상 순환 루프 및 500ms 지연)
; =========================================================================
main PROC
    LOCAL hStdOut: DWORD
    LOCAL colorIdx: DWORD
    LOCAL coloredAttr: DWORD

    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    mov colorIdx, 0

L_MAIN_LOOP:
    cmp colorIdx, 16            ; 16가지 색상(0 ~ 15) 처리 후 종료
    jge L_MAIN_DONE

    ; 4비트 색상 인덱스(0~15)를 배경색 비트(bit 4-7) 위치로 시프트 (colorIdx * 16)
    mov eax, colorIdx
    shl eax, 4
    mov coloredAttr, eax

    ; 현재 색상으로 체스판 다시 그리기
    INVOKE DrawBoard, hStdOut, coloredAttr

    ; 500밀리초(0.5초) 대기
    INVOKE Sleep, 500

    inc colorIdx
    jmp L_MAIN_LOOP

L_MAIN_DONE:
    ; 콘솔 색상 복구 및 커서 이동
    INVOKE SetConsoleTextAttribute, hStdOut, 7
    INVOKE SetCursorPosition, hStdOut, 0, 9

    INVOKE ExitProcess, 0
main ENDP

END main