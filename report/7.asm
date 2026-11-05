.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 선언 (외부 라이브러리 필요 없음)
; -------------------------------------------------------------------------
ExitProcess   PROTO stdcall :DWORD
GetStdHandle  PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
wsprintfA     PROTO C :PTR BYTE, :PTR BYTE, :VARARG

includelib kernel32.lib
includelib user32.lib

; -------------------------------------------------------------------------
; GCD PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
GCD PROTO stdcall, 
    x: DWORD, 
    y: DWORD

.data
; 콘솔 출력 서식 문자열 (\r\n 개행 포함)
fmt1 BYTE "GCD(5, 20)    = %d (Expected: 5)", 0Dh, 0Ah, 0
fmt2 BYTE "GCD(24, 18)   = %d (Expected: 6)", 0Dh, 0Ah, 0
fmt3 BYTE "GCD(11, 7)    = %d (Expected: 1)", 0Dh, 0Ah, 0
fmt4 BYTE "GCD(432, 226) = %d (Expected: 2)", 0Dh, 0Ah, 0
fmt5 BYTE "GCD(26, 13)   = %d (Expected: 13)", 0Dh, 0Ah, 0

buffer       BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut      DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1: (5, 20)
    ; ---------------------------------------------------------------------
    INVOKE GCD, 5, 20
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2: (24, 18)
    ; ---------------------------------------------------------------------
    INVOKE GCD, 24, 18
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 3: (11, 7)
    ; ---------------------------------------------------------------------
    INVOKE GCD, 11, 7
    INVOKE wsprintfA, ADDR buffer, ADDR fmt3, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 4: (432, 226)
    ; ---------------------------------------------------------------------
    INVOKE GCD, 432, 226
    INVOKE wsprintfA, ADDR buffer, ADDR fmt4, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 5: (26, 13)
    ; ---------------------------------------------------------------------
    INVOKE GCD, 26, 13
    INVOKE wsprintfA, ADDR buffer, ADDR fmt5, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; GCD PROC (재귀적 유클리드 호제법)
; - 수학 공식: GCD(x, y) = y == 0 ? x : GCD(y, x % y)
; - 입력: x (DWORD), y (DWORD)
; - 반환: EAX = 두 수의 최대공약수
; =========================================================================
GCD PROC stdcall USES ebx edx,
    x: DWORD,
    y: DWORD

    mov ebx, y
    cmp ebx, 0
    je L_BASE               ; y == 0 인 경우 (기초 조건: x 반환)

    ; ---------------------------------------------------------------------
    ; 재귀 단계: GCD(y, x % y)
    ; ---------------------------------------------------------------------
    mov eax, x
    mov edx, 0              ; 나눗셈 전 EDX 0으로 초기화
    div ebx                 ; EAX = x / y (몫), EDX = x % y (나머지)

    ; 자기 자신 재귀 호출: INVOKE GCD, y, (x % y)
    INVOKE GCD, ebx, edx
    ret                     ; 재귀 결과를 반환하며 종료

L_BASE:
    mov eax, x              ; 기초 조건 충족 시 x를 EAX에 저장하여 반환
    ret
GCD ENDP

END main