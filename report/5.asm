.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 선언 (외부 파일/라이브러리 연결 오류 방지)
; -------------------------------------------------------------------------
ExitProcess   PROTO stdcall :DWORD
GetStdHandle  PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
wsprintfA     PROTO C :PTR BYTE, :PTR BYTE, :VARARG

includelib kernel32.lib
includelib user32.lib

; -------------------------------------------------------------------------
; DifferentInputs PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
DifferentInputs PROTO stdcall, 
    val1: SDWORD, 
    val2: SDWORD, 
    val3: SDWORD

.data
; 콘솔 출력 서식 문자열 (\r\n 개행 포함)
fmt1 BYTE "Test 1 (10, 20, 30) -> Result: %d (Expected: 1)", 0Dh, 0Ah, 0
fmt2 BYTE "Test 2 (10, 10, 30) -> Result: %d (Expected: 0)", 0Dh, 0Ah, 0
fmt3 BYTE "Test 3 (10, 20, 10) -> Result: %d (Expected: 0)", 0Dh, 0Ah, 0
fmt4 BYTE "Test 4 (10, 20, 20) -> Result: %d (Expected: 0)", 0Dh, 0Ah, 0
fmt5 BYTE "Test 5 (5,  5,  5 ) -> Result: %d (Expected: 0)", 0Dh, 0Ah, 0

buffer BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1: 모두 다른 값 (10, 20, 30) -> 결과: 1
    ; ---------------------------------------------------------------------
    INVOKE DifferentInputs, 10, 20, 30
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2: val1 == val2 (10, 10, 30) -> 결과: 0
    ; ---------------------------------------------------------------------
    INVOKE DifferentInputs, 10, 10, 30
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 3: val1 == val3 (10, 20, 10) -> 결과: 0
    ; ---------------------------------------------------------------------
    INVOKE DifferentInputs, 10, 20, 10
    INVOKE wsprintfA, ADDR buffer, ADDR fmt3, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 4: val2 == val3 (10, 20, 20) -> 결과: 0
    ; ---------------------------------------------------------------------
    INVOKE DifferentInputs, 10, 20, 20
    INVOKE wsprintfA, ADDR buffer, ADDR fmt4, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 5: 모두 같은 값 (5, 5, 5) -> 결과: 0
    ; ---------------------------------------------------------------------
    INVOKE DifferentInputs, 5, 5, 5
    INVOKE wsprintfA, ADDR buffer, ADDR fmt5, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; DifferentInputs PROC
; - 입력: val1, val2, val3 (32비트 정수 3개)
; - 반환: EAX = 1 (모두 다른 값일 때), EAX = 0 (하나라도 같을 때)
; =========================================================================
DifferentInputs PROC stdcall USES ebx,
    val1: SDWORD,
    val2: SDWORD,
    val3: SDWORD

    ; 1. val1 과 val2 비교
    mov eax, val1
    cmp eax, val2
    je L_NOT_DIFFERENT      ; 같으면 0 반환으로 이동

    ; 2. val1 과 val3 비교
    cmp eax, val3
    je L_NOT_DIFFERENT      ; 같으면 0 반환으로 이동

    ; 3. val2 와 val3 비교
    mov eax, val2
    cmp eax, val3
    je L_NOT_DIFFERENT      ; 같으면 0 반환으로 이동

    ; 세 비교를 모두 통과한 경우 (모두 다름)
    mov eax, 1
    ret

L_NOT_DIFFERENT:
    mov eax, 0
    ret
DifferentInputs ENDP

END main