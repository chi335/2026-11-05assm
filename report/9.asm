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
; CountNearMatches PROTO 선언 (프로토타입)
; -------------------------------------------------------------------------
CountNearMatches PROTO stdcall, 
    ptrArray1: PTR SDWORD, 
    ptrArray2: PTR SDWORD, 
    count: DWORD, 
    diff: DWORD

.data
; 첫 번째 테스트 배열 쌍 (허용 오차 diff = 3)
pair1_A SDWORD 10, 20, 30, 40, 50
pair1_B SDWORD 12, 28, 30, 47, 60
; 오차 분석: |10-12|=2(O), |20-28|=8(X), |30-30|=0(O), |40-47|=7(X), |50-60|=10(X) -> 결과: 2개

; 두 번째 테스트 배열 쌍 (허용 오차 diff = 5)
pair2_A SDWORD -10, -5, 0,  5
pair2_B SDWORD -12, -2, 4, 10
; 오차 분석: |-10 - (-12)|=2(O), |-5 - (-2)|=3(O), |0-4|=4(O), |5-10|=5(O) -> 결과: 4개

; 콘솔 출력 서식 문자열 (\r\n 개행 포함)
fmt1 BYTE "Pair 1 (diff=3) Near Matches: %d (Expected: 2)", 0Dh, 0Ah, 0
fmt2 BYTE "Pair 2 (diff=5) Near Matches: %d (Expected: 4)", 0Dh, 0Ah, 0

buffer       BYTE 128 DUP(0)
bytesWritten DWORD ?
hStdOut      DWORD ?

.code
main PROC
    ; 콘솔 표준 출력 핸들 구하기
    INVOKE GetStdHandle, -11
    mov hStdOut, eax

    ; ---------------------------------------------------------------------
    ; 테스트 1 실행 (pair1, diff = 3)
    ; ---------------------------------------------------------------------
    INVOKE CountNearMatches, ADDR pair1_A, ADDR pair1_B, LENGTHOF pair1_A, 3
    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    ; ---------------------------------------------------------------------
    ; 테스트 2 실행 (pair2, diff = 5)
    ; ---------------------------------------------------------------------
    INVOKE CountNearMatches, ADDR pair2_A, ADDR pair2_B, LENGTHOF pair2_A, 5
    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, eax
    INVOKE WriteConsoleA, hStdOut, ADDR buffer, eax, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

; =========================================================================
; CountNearMatches PROC
; - 입력: ptrArray1, ptrArray2, count (배열 크기), diff (최대 허용 오차)
; - 반환: EAX = |x_i - y_i| <= diff 조건에 만족하는 요소의 개수
; - EAX 제외 보존: USES ebx ecx edx esi edi 구문 사용
; =========================================================================
CountNearMatches PROC stdcall USES ebx ecx edx esi edi,
    ptrArray1: PTR SDWORD,
    ptrArray2: PTR SDWORD,
    count: DWORD,
    diff: DWORD

    mov ecx, count          ; 루프 카운터
    cmp ecx, 0
    jle L_EMPTY             ; 크기가 0 이하이면 종료

    mov esi, ptrArray1      ; ESI = 첫 번째 배열 주소
    mov edi, ptrArray2      ; EDI = 두 번째 배열 주소
    mov edx, 0              ; EDX = 조건 만족 요소 카운터 (0 초기화)

L_LOOP:
    mov eax, [esi]          ; EAX = x_i
    sub eax, [edi]          ; EAX = x_i - y_i

    ; 절대값(|x_i - y_i|) 계산
    jge L_ABS_DONE          ; 차이가 0 이상이면 그대로 유지
    neg eax                 ; 음수이면 양수로 부호 반전 (-EAX)

L_ABS_DONE:
    ; |x_i - y_i| 와 diff 비교
    cmp eax, diff
    ja L_NEXT               ; 절대 차이가 diff보다 크면(Unsigned >) 제외

    inc edx                 ; 조건 만족시 카운터 + 1

L_NEXT:
    add esi, 4              ; 4바이트 이동
    add edi, 4              ; 4바이트 이동
    loop L_LOOP             ; 루프 반복

    mov eax, edx            ; 최종 카운트를 EAX에 저장하여 반환
    ret

L_EMPTY:
    mov eax, 0
    ret
CountNearMatches ENDP

END main