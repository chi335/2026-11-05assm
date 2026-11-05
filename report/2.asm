.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 함수 선언 (32비트 표준)
; -------------------------------------------------------------------------
GetStdHandle            PROTO stdcall :DWORD
SetConsoleCursorPosition PROTO stdcall :DWORD, :DWORD
SetConsoleTextAttribute PROTO stdcall :DWORD, :DWORD
WriteConsoleA           PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess             PROTO stdcall :DWORD

includelib kernel32.lib

; 색상 상수 정의
COLOR_WHITE EQU 0F0h    ; 흰색 배경 (0xF0)
COLOR_GRAY  EQU 070h    ; 회색 배경 (0x70)

.code
; =========================================================================
; 1. SetCursorPosition (Gotoxy 역할: 커서 위치 이동)
; =========================================================================
SetCursorPosition PROC stdcall USES eax,
    hOut: DWORD,
    xPos: DWORD,
    yPos: DWORD

    mov eax, yPos
    shl eax, 16                 ; 상위 16비트에 Y 좌표 배치
    mov ax, word ptr xPos       ; 하위 16비트에 X 좌표 배치
    
    INVOKE SetConsoleCursorPosition, hOut, eax
    ret
SetCursorPosition ENDP

; =========================================================================
; 2. DrawSquare (단일 체스판 칸 그리기)
; =========================================================================
DrawSquare PROC stdcall USES eax,
    hOut: DWORD,
    xPos: DWORD,
    yPos: DWORD,
    colorAttr: DWORD

    LOCAL spaces: WORD
    LOCAL bytesWritten: DWORD

    mov spaces, 2020h           ; ASCII 공백 2개 ('  ')

    ; 커서 이동 및 색상 설정
    INVOKE SetCursorPosition, hOut, xPos, yPos
    INVOKE SetConsoleTextAttribute, hOut, colorAttr

    ; 콘솔에 공백 2칸 출력하여 정사각 칸 형성
    INVOKE WriteConsoleA, hOut, ADDR spaces, 2, ADDR bytesWritten, 0
    ret
DrawSquare ENDP

; =========================================================================
; 3. DrawRow (1개 행 - 8개 칸 그리기)
; =========================================================================
DrawRow PROC stdcall USES eax ecx edx,
    hOut: DWORD,
    rowIdx: DWORD,
    startColor: DWORD

    LOCAL col: DWORD
    LOCAL currentColor: DWORD
    LOCAL xPos: DWORD

    mov eax, startColor
    mov currentColor, eax
    mov col, 0

L_COL_LOOP:
    cmp col, 8
    jge L_ROW_DONE

    ; X 좌표 = col * 2 (공백 2칸 너비 고려)
    mov eax, col
    shl eax, 1
    mov xPos, eax

    ; 칸 출력
    INVOKE DrawSquare, hOut, xPos, rowIdx, currentColor

    ; 색상 교대 (White <-> Gray)
    cmp currentColor, COLOR_WHITE
    je L_SET_GRAY
    mov currentColor, COLOR_WHITE
    jmp L_NEXT_COL

L_SET_GRAY:
    mov currentColor, COLOR_GRAY

L_NEXT_COL:
    inc col
    jmp L_COL_LOOP

L_ROW_DONE:
    ret
DrawRow ENDP

; =========================================================================
; 4. DrawBoard (전체 8x8 체스판 그리기)
; =========================================================================
DrawBoard PROC stdcall USES eax ecx,
    hOut: DWORD

    LOCAL row: DWORD
    LOCAL startColor: DWORD

    mov row, 0

L_BOARD_LOOP:
    cmp row, 8
    jge L_BOARD_DONE

    ; 짝수 행/홀수 행 판별
    mov eax, row
    test eax, 1
    jnz L_ODD_ROW

    ; 짝수 행: 흰색 시작
    mov startColor, COLOR_WHITE
    jmp L_DRAW

L_ODD_ROW:
    ; 홀수 행: 회색 시작
    mov startColor, COLOR_GRAY

L_DRAW:
    INVOKE DrawRow, hOut, row, startColor
    inc row
    jmp L_BOARD_LOOP

L_BOARD_DONE:
    ret
DrawBoard ENDP

; =========================================================================
; Main 프로시저
; =========================================================================
main PROC
    LOCAL hStdOut: DWORD

    ; 표준 출력 핸들 획득
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; 체스판 출력
    INVOKE DrawBoard, hStdOut

    ; 커서 위치 및 기본 콘솔 색상(0x07)으로 원상 복구
    INVOKE SetConsoleTextAttribute, hStdOut, 7
    INVOKE SetCursorPosition, hStdOut, 0, 9

    INVOKE ExitProcess, 0
main ENDP

END main