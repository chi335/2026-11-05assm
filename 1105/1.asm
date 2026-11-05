.386
.model flat, stdcall
option casemap :none

; 윈도우 커널 API 선언 (프로그램 종료용)
includelib kernel32.lib
ExitProcess PROTO :DWORD

.code
main PROC
    push 5              ; 5! 계산을 위해 5를 스택에 푸시
    call Factorial      ; 팩토리얼 계산 (결과가 EAX 레지스터에 저장됨)
    
    push 0              ; 종료 코드 0
    call ExitProcess    ; 프로그램 정상 종료
main ENDP

;--------------------------------------------------
Factorial PROC
; 재귀 방식으로 팩토리얼을 계산합니다.
; 받음: [ebp+8] = n (계산할 숫자)
; 반환: EAX = n의 팩토리얼 결과
;--------------------------------------------------
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]    ; n 값을 EAX에 가져옴
    cmp eax, 1          ; n <= 1 인가?
    jle L1              ; 맞다면 기저 조건(Base Case)으로 이동
    
    dec eax             ; n - 1
    push eax            ; Factorial(n-1)의 인자로 푸시
    call Factorial      ; 재귀 호출
    
    ; --- 각 재귀 호출이 리턴된 후 실행되는 영역 ---
    mov ebx, [ebp+8]    ; 원래의 n 값을 EBX에 가져옴
    imul ebx            ; EAX = EAX * EBX (부호 있는 곱셈)
    jmp L2

L1:
    mov eax, 1          ; 0! 또는 1!일 때 1을 반환

L2:
    pop ebp
    ret 4               ; 파라미터(4바이트)만큼 스택 정리 후 리턴
Factorial ENDP

END main