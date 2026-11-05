.386
.model flat, stdcall
.stack 4096

; -------------------------------------------------------------------------
; Windows API 선언 (외부 파일 필요 없음)
; -------------------------------------------------------------------------
ExitProcess   PROTO stdcall :DWORD
GetStdHandle  PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
wsprintfA     PROTO C :PTR BYTE, :PTR BYTE, :VARARG

includelib kernel32.lib
includelib user32.lib

; -------------------------------------------------------------------------
; CountMatches PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
CountMatches PROTO stdcall, 
    ptrArray1: PTR SDWORD, 
    ptrArray2: PTR SDWORD, 
    count: DWORD

.data
; 첫 번째 테스트 배열 쌍 (길이 5, 일치하는 요소: 10, 30, 50 -> 3개)
pair1_A SDWORD 10, 20, 30, 40, 50
pair1_B SDWORD 10, 25, 30, 44, 50

; 두 번째 테스트 배열 쌍 (길이 4, 일치하는 요소 없음 -> 0개)
pair2_A SDWORD -5,   0, 15, -100
pair2_B SDWORD  1,   2,  3,    4

; 콘솔 출력 서식 문자열 (\r\n 개행 포함)
fmt1 BYTE "Pair 1 Matching Count: %d (Expected: 3)", 0Dh, 0Ah, 0
fmt2 BYTE "Pair 2 Matching Count: %d (Expected: 0)", 0Dh, 0Ah, 0

buffer       BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut      DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1 실행 (첫 번째 배열 쌍)
    ; ---------------------------------------------------------------------
    INVOKE CountMatches, ADDR pair1_A, ADDR pair1_B, LENGTHOF pair1_A
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2 실행 (두 번째 배열 쌍)
    ; ---------------------------------------------------------------------
    INVOKE CountMatches, ADDR pair2_A, ADDR pair2_B, LENGTHOF pair2_A
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; CountMatches PROC
; - 입력: ptrArray1 (첫 번째 배열 포인터), ptrArray2 (두 번째 배열 포인터), count (배열 길이)
; - 반환: EAX = 두 배열에서 동일한 위치의 값이 일치하는 요소의 총 개수
; - EAX 제외 보존: USES ebx ecx edx esi edi 구문 사용
; =========================================================================
CountMatches PROC stdcall USES ebx ecx edx esi edi,
    ptrArray1: PTR SDWORD,
    ptrArray2: PTR SDWORD,
    count: DWORD

    mov ecx, count          ; 반복 횟수 설정
    cmp ecx, 0
    jle L_EMPTY             ; 배열 크기가 0 이하이면 예외 처리

    mov esi, ptrArray1      ; ESI = 첫 번째 배열의 주소
    mov edi, ptrArray2      ; EDI = 두 번째 배열의 주소
    mov edx, 0              ; EDX = 일치하는 요소 개수 카운터 (0으로 초기화)

L_LOOP:
    mov eax, [esi]          ; EAX = 첫 번째 배열의 현재 요소 (x_i)
    mov ebx, [edi]          ; EBX = 두 번째 배열의 현재 요소 (y_i)
    
    cmp eax, ebx            ; x_i 와 y_i 비교
    jne L_NEXT              ; 다르면 다음 요소로 이동

    inc edx                 ; 같으면 일치 카운터 + 1

L_NEXT:
    add esi, 4              ; 첫 번째 배열 다음 원소 주소 (4바이트)
    add edi, 4              ; 두 번째 배열 다음 원소 주소 (4바이트)
    loop L_LOOP             ; 루프 반복

    mov eax, edx            ; 최종 일치 개수를 EAX에 저장하여 반환
    ret

L_EMPTY:
    mov eax, 0
    ret
CountMatches ENDP

END main