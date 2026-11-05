.386
.model flat, stdcall
option casemap :none

; 윈도우 커널 API 선언 (프로그램 종료용)
includelib kernel32.lib
ExitProcess PROTO :DWORD

; Swap 함수 프로토타입 선언
Swap PROTO :PTR DWORD, :PTR DWORD

.data
Array DWORD 10000h, 20000h    ; 교환을 테스트할 32비트 배열

.code
main PROC
    ; Swap 함수 호출 (Array[0]과 Array[1]의 주소를 전달)
    invoke Swap, OFFSET Array, OFFSET [Array + 4]

    push 0              ; 종료 코드 0
    call ExitProcess    ; 프로그램 정상 종료
main ENDP

;-----------------------------------------------------
Swap PROC USES eax esi edi,
      pValX:PTR DWORD,
      pValY:PTR DWORD
; Exchange the values of two 32-bit integers
; pValX: pointer to first integer
; pValY: pointer to second integer
; Returns: nothing
; (참고: 인자가 2개이므로 MASM이 자동으로 'RET 8'을 생성하여 스택을 정리합니다)
;-----------------------------------------------------
    mov esi, pValX          ; 첫 번째 포인터 로드
    mov edi, pValY          ; 두 번째 포인터 로드
    
    mov eax, [esi]          ; 첫 번째 값을 EAX에 저장
    xchg eax, [edi]         ; EAX 값과 두 번째 주소의 값을 상호 교환
    mov [esi], eax          ; 원래 두 번째 값을 첫 번째 주소에 저장
    
    ret                     ; 자동으로 RET 8 수행됨
Swap ENDP

END main