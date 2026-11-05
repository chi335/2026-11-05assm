.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; 윈도우 순수 API 함수 선언 (외부 라이브러리 충돌 없음)
; -------------------------------------------------------------------------
ExitProcess PROTO stdcall :DWORD
GetStdHandle PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
wsprintfA PROTO C :PTR BYTE, :PTR BYTE, :VARARG

includelib kernel32.lib
includelib user32.lib

; -------------------------------------------------------------------------
; FindLargest PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
FindLargest PROTO stdcall, 
    ptrArray: PTR SDWORD, 
    count: DWORD

.data
; 문제 조건: 서로 다른 크기와 음수가 포함된 3개의 테스트 배열
array1 SDWORD -10, -5, -20, -1, -50              ; 크기 5 (최대값: -1)
array2 SDWORD 15, -30, 42, -100, 0, 8, -5        ; 크기 7 (최대값: 42)
array3 SDWORD -99, -150, -200                    ; 크기 3 (최대값: -99)

; 서식 문자열 (0Dh, 0Ah = 개행문자 \r\n)
fmt1 BYTE "Array 1 Largest Value: %d", 0Dh, 0Ah, 0
fmt2 BYTE "Array 2 Largest Value: %d", 0Dh, 0Ah, 0
fmt3 BYTE "Array 3 Largest Value: %d", 0Dh, 0Ah, 0

buffer BYTE 128 DUP(0)      ; 출력용 문자열 버퍼
bytesWritten DWORD ?
hStdOut DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기 (-11 = STD_OUTPUT_HANDLE)
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1 실행
    ; ---------------------------------------------------------------------
    INVOKE FindLargest, ADDR array1, LENGTHOF array1
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2 실행
    ; ---------------------------------------------------------------------
    INVOKE FindLargest, ADDR array2, LENGTHOF array2
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 3 실행
    ; ---------------------------------------------------------------------
    INVOKE FindLargest, ADDR array3, LENGTHOF array3
    INVOKE wsprintfA, ADDR buffer, ADDR fmt3, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; FindLargest PROC
; - 입력: ptrArray (배열 주소), count (배열 크기)
; - 출력: EAX (최대값)
; - EAX를 제외한 레지스터(EBX, ECX, EDX, ESI) 보존 (USES 절 사용)
; =========================================================================
FindLargest PROC stdcall USES ebx ecx edx esi,
    ptrArray: PTR SDWORD,
    count: DWORD

    mov ecx, count          ; 반복 횟수 (배열 크기)
    cmp ecx, 0
    jle L_EMPTY             ; 크기가 0 이하인 예외 처리

    mov esi, ptrArray       ; ESI에 배열 시작 주소 로드
    mov eax, [esi]          ; EAX에 첫 번째 요소를 기본 최대값으로 설정

    dec ecx                 ; 첫 요소를 읽었으므로 count - 1
    jz L_DONE               ; 요소를 모두 확인했으면 종료

L_LOOP:
    add esi, 4              ; SDWORD(4바이트) 이동
    mov edx, [esi]          ; 현재 원소 읽기
    
    cmp edx, eax            ; 부호 있는 비교 (EDX vs EAX)
    jge L_GREATER           ; EDX >= EAX 인 경우 (jge 사용)
    jmp L_NEXT

L_GREATER:
    mov eax, edx            ; 더 큰 값으로 EAX(최대값) 갱신

L_NEXT:
    loop L_LOOP             ; 루프 반복

L_DONE:
    ret

L_EMPTY:
    mov eax, 0
    ret
FindLargest ENDP

END main