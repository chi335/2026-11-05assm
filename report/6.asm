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
; PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
Swap PROTO stdcall, 
    pValX: PTR SDWORD, 
    pValY: PTR SDWORD

SwapPairs PROTO stdcall, 
    ptrArray: PTR SDWORD, 
    count: DWORD

PrintArray PROTO stdcall, 
    ptrArray: PTR SDWORD, 
    count: DWORD, 
    msgTitle: PTR BYTE

.data
; 정수 배열 (무작위 값 8개)
myArray SDWORD 14, 3, 22, 5, 89, 12, 7, 42

; 콘솔 출력 메시지
msgBefore BYTE "Before Swap: ", 0
msgAfter  BYTE "After Swap : ", 0
fmtNum    BYTE "%d ", 0
fmtNewline BYTE 0Dh, 0Ah, 0

buffer       BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut      DWORD ?

.code
main PROC
    ; 콘솔 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; 1. 교환 전 배열 출력
    INVOKE PrintArray, ADDR myArray, LENGTHOF myArray, ADDR msgBefore

    ; 2. 인접한 쌍 교환 루프 실행
    INVOKE SwapPairs, ADDR myArray, LENGTHOF myArray

    ; 3. 교환 후 배열 출력
    INVOKE PrintArray, ADDR myArray, LENGTHOF myArray, ADDR msgAfter

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; Swap PROC (교재 8.4.6절 방식)
; - 두 개의 SDWORD 포인터를 입력받아 두 포인터가 가리키는 메모리 값을 교환
; =========================================================================
Swap PROC stdcall USES eax ebx esi edi,
    pValX: PTR SDWORD,
    pValY: PTR SDWORD

    mov esi, pValX         ; ESI = 첫 번째 요소의 주소
    mov edi, pValY         ; EDI = 두 번째 요소의 주소

    mov eax, [esi]         ; EAX = *pValX
    mov ebx, [edi]         ; EBX = *pValY

    mov [esi], ebx         ; *pValX = EBX
    mov [edi], eax         ; *pValY = EAX

    ret
Swap ENDP

; =========================================================================
; SwapPairs PROC
; - 배열 내의 연속된 쌍(0-1, 2-3, 4-5...)을 Swap 함수를 호출하여 교환
; =========================================================================
SwapPairs PROC stdcall USES ecx esi edi,
    ptrArray: PTR SDWORD,
    count: DWORD

    mov ecx, count
    shr ecx, 1             ; count / 2 (교환할 쌍의 개수 구하기)
    jz L_DONE              ; 요소가 2개 미만이면 종료

    mov esi, ptrArray       ; ESI = 배열의 시작 주소

L_LOOP:
    lea edi, [esi + 4]     ; EDI = 바로 다음 요소의 주소 (esi + 4바이트)

    ; Swap(&array[i], &array[i+1]) 호출
    INVOKE Swap, esi, edi

    add esi, 8             ; 2개 요소(8바이트)를 지나쳐 다음 쌍으로 이동
    loop L_LOOP            ; ECX 감쇠 및 루프 반복

L_DONE:
    ret
SwapPairs ENDP

; =========================================================================
; PrintArray PROC (배열 요소들을 콘솔에 출력하는 보조 프로시저)
; =========================================================================
PrintArray PROC stdcall USES eax ecx esi,
    ptrArray: PTR SDWORD,
    count: DWORD,
    msgTitle: PTR BYTE

    ; 제목 메시지 출력
    INVOKE WriteConsoleA, hStdOut, msgTitle, 13, ADDR bytesWritten, 0

    mov ecx, count
    mov esi, ptrArray

L_PRINT_LOOP:
    push ecx               ; loop 및 wsprintfA 호환을 위한 ECX 보존
    
    mov eax, [esi]
    INVOKE wsprintfA, ADDR buffer, ADDR fmtNum, eax
    
    ; 반환된 문자열 길이 계산 (EAX에 저장됨)
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0
    
    pop ecx
    add esi, 4
    loop L_PRINT_LOOP

    ; 개행 출력
    INVOKE WriteConsoleA, hStdOut, ADDR fmtNewline, 2, ADDR bytesWritten, 0
    ret
PrintArray ENDP

END main