.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 및 라이브러리 선언 (외부 파일 필요 없음)
; -------------------------------------------------------------------------
ExitProcess  PROTO stdcall :DWORD
GetStdHandle PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
wsprintfA    PROTO C :PTR BYTE, :PTR BYTE, :VARARG

includelib kernel32.lib
includelib user32.lib

; -------------------------------------------------------------------------
; FindThrees PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
FindThrees PROTO stdcall, 
    ptrArray: PTR SDWORD, 
    count: DWORD

.data
; 다양한 경우를 검증하기 위한 5개의 테스트 배열
array1 SDWORD 1, 2, 3, 3, 3, 4, 5       ; 3이 3번 연속 등장 -> 결과: 1
array2 SDWORD 3, 3, 2, 3, 3, 1          ; 3이 2번씩 떨어져 있음 -> 결과: 0
array3 SDWORD 3, 3, 3                   ; 딱 3개 모두 3 -> 결과: 1
array4 SDWORD 10, -5, 20, 30            ; 3이 없음 -> 결과: 0
array5 SDWORD 3, 3                      ; 길이 3 미만 -> 결과: 0

; 콘솔 출력 서식 문자열 (\r\n 개행 포함)
fmt1 BYTE "Array 1 Result: %d (Expected: 1)", 0Dh, 0Ah, 0
fmt2 BYTE "Array 2 Result: %d (Expected: 0)", 0Dh, 0Ah, 0
fmt3 BYTE "Array 3 Result: %d (Expected: 1)", 0Dh, 0Ah, 0
fmt4 BYTE "Array 4 Result: %d (Expected: 0)", 0Dh, 0Ah, 0
fmt5 BYTE "Array 5 Result: %d (Expected: 0)", 0Dh, 0Ah, 0

buffer BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut DWORD ?

.code
main PROC
    ; 콘솔 출력 핸들 가져오기 (-11 = STD_OUTPUT_HANDLE)
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1 실행 (결과: 1)
    ; ---------------------------------------------------------------------
    INVOKE FindThrees, ADDR array1, LENGTHOF array1
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2 실행 (결과: 0)
    ; ---------------------------------------------------------------------
    INVOKE FindThrees, ADDR array2, LENGTHOF array2
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 3 실행 (결과: 1)
    ; ---------------------------------------------------------------------
    INVOKE FindThrees, ADDR array3, LENGTHOF array3
    INVOKE wsprintfA, ADDR buffer, ADDR fmt3, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 4 실행 (결과: 0)
    ; ---------------------------------------------------------------------
    INVOKE FindThrees, ADDR array4, LENGTHOF array4
    INVOKE wsprintfA, ADDR buffer, ADDR fmt4, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 5 실행 (결과: 0)
    ; ---------------------------------------------------------------------
    INVOKE FindThrees, ADDR array5, LENGTHOF array5
    INVOKE wsprintfA, ADDR buffer, ADDR fmt5, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; FindThrees PROC
; - 기능: 연속된 숫자 3이 3개 이상 존재하는지 확인
; - 입력: ptrArray (배열 포인터), count (배열 요소 개수)
; - 반환: EAX = 1 (발견 시), EAX = 0 (미발견 시)
; - EAX 제외 보존: USES ebx ecx edx esi 구문 사용
; =========================================================================
FindThrees PROC stdcall USES ebx ecx edx esi,
    ptrArray: PTR SDWORD,
    count: DWORD

    mov ecx, count
    cmp ecx, 3
    jl L_NOT_FOUND          ; 크기가 3 미만이면 3번 연속 불가능

    mov esi, ptrArray       ; ESI에 배열 시작 주소 로드
    mov edx, 0              ; EDX: 연속으로 나온 3의 개수 카운터

L_LOOP:
    mov eax, [esi]          ; 현재 배열 요소 읽기
    cmp eax, 3
    je L_IS_THREE           ; 현재 요소가 3인 경우

    ; 현재 요소가 3이 아니면 카운터를 0으로 리셋
    mov edx, 0
    jmp L_NEXT

L_IS_THREE:
    inc edx                 ; 연속 3 카운터 + 1
    cmp edx, 3
    je L_FOUND              ; 연속 3번 3이 나왔으면 성공

L_NEXT:
    add esi, 4              ; 다음 요소로 이동 (4바이트)
    loop L_LOOP             ; 루프 반복

L_NOT_FOUND:
    mov eax, 0              ; 미발견 시 0 반환
    ret

L_FOUND:
    mov eax, 1              ; 발견 시 1 반환
    ret
FindThrees ENDP

END main