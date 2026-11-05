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
ShowParams PROTO stdcall, count: DWORD
MySample   PROTO stdcall, first: DWORD, second: DWORD, third: DWORD

.data
msgHeader BYTE "Stack parameters:--------------------------", 0Dh, 0Ah, 0
fmtParam  BYTE "Address %08X = %08X", 0Dh, 0Ah, 0

buffer       BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut      DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; 문제 예시: 3개의 인자(1234h, 5000h, 6543h)를 전달하며 MySample 호출
    INVOKE MySample, 1234h, 5000h, 6543h

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; MySample PROC
; - 3개의 매개변수를 받는 샘플 프로시저
; - 내부에서 ShowParams를 호출하여 자신의 스택 매개변수를 출력시킴
; =========================================================================
MySample PROC stdcall,
    first: DWORD,
    second: DWORD,
    third: DWORD

    ; 매개변수 개수(3)를 전달하여 ShowParams 호출
    INVOKE ShowParams, 3
    ret
MySample ENDP

; =========================================================================
; ShowParams PROC
; - 입력: count (출력할 호출자 매개변수의 개수)
; - 기능: 호출한 프로시저(MySample)의 스택 프레임(EBP)을 추적하여
;        낮은 주소부터 높은 주소 순서로 매개변수 주소와 값을 16진수로 출력
; =========================================================================
ShowParams PROC stdcall USES eax ecx edx esi,
    count: DWORD

    ; 헤더 타이틀 출력
    INVOKE WriteConsoleA, hStdOut, ADDR msgHeader, 45, ADDR bytesWritten, 0

    mov ecx, count
    cmp ecx, 0
    jle L_DONE

    ; ---------------------------------------------------------------------
    ; [ebp]는 호출자(MySample)의 이전 EBP 주소를 가지고 있음
    ; [ebp + 8] 위치가 MySample의 첫 번째 매개변수(가장 낮은 주소)임
    ; ---------------------------------------------------------------------
    mov esi, [ebp]         ; ESI = MySample의 EBP Base Pointer
    add esi, 8             ; ESI = 첫 번째 매개변수의 주소 (EBP + 8)

L_LOOP:
    push ecx               ; wsprintfA 호출 중 ECX 레지스터 보존

    mov eax, [esi]         ; EAX = 현재 스택 주소에 저장된 매개변수 값
    
    ; "Address [주소] = [값]" 서식 문자열 생성 (%08X = 8자리 16진수)
    INVOKE wsprintfA, ADDR buffer, ADDR fmtParam, esi, eax
    
    ; 생성된 문자열 콘솔에 출력 (wsprintfA 반환값 EAX = 문자열 길이)
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    pop ecx
    add esi, 4             ; 다음 매개변수 주소로 이동 (주소 증가: 낮은 주소 -> 높은 주소)
    loop L_LOOP

L_DONE:
    ret
ShowParams ENDP

END main