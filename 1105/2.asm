.386
.model flat, stdcall
option casemap :none

; 윈도우 커널 API 선언 (프로그램 종료용)
includelib kernel32.lib
ExitProcess PROTO :DWORD

; Swap 함수 프로토타입 선언
Swap PROTO :PTR DWORD, :PTR DWORD

.data
Array DWORD 10000h, 20000h

.code
main PROC
    ; 교환 전 배열 상태 (메모리 창에서 확인 가능)
    
    ; Swap 함수 호출 (ADDR 대신 OFFSET 사용)
    invoke Swap, OFFSET Array, OFFSET [Array + 4]

    ; 교환 후 배열 상태 (Array[0]과 Array[1]의 값이 바뀜)

    push 0              ; 종료 코드 0
    call ExitProcess    ; 프로그램 정상 종료
main ENDP

;--------------------------------------------------
Swap PROC USES esi edi eax ebx, pValX:PTR DWORD, pValY:PTR DWORD
; 포인터를 이용해 두 32비트 정수 값을 서로 교환합니다.
;--------------------------------------------------
    mov esi, pValX          ; 첫 번째 값의 주소 복사
    mov edi, pValY          ; 두 번째 값의 주소 복사
    
    mov eax, [esi]          ; 첫 번째 값을 EAX에 저장
    mov ebx, [edi]          ; 두 번째 값을 EBX에 저장
    
    mov [esi], ebx          ; 첫 번째 주소에 EBX 값(원래 두 번째 값) 저장
    mov [edi], eax          ; 두 번째 주소에 EAX 값(원래 첫 번째 값) 저장
    
    ret
Swap ENDP

END main