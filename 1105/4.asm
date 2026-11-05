.386
.model flat, stdcall
option casemap :none

; 윈도우 API 선언
includelib kernel32.lib
GetStdHandle PROTO :DWORD
WriteFile PROTO :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :PTR DWORD
ExitProcess PROTO :DWORD

STD_OUTPUT_HANDLE EQU -11

.data
    ; 출력할 문자열 (13, 10은 줄바꿈 문자입니다)
    msg DB "Student ID: 20261234, Name: Hong Gildong", 13, 10
    msgLen EQU ($ - msg)        ; 문자열의 길이를 자동으로 계산
    bytesWritten DD ?           ; 실제로 쓰여진 바이트 수 저장용

.code
main PROC
    ; 1. 표준 출력(콘솔) 핸들 가져오기
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov ebx, eax                ; 핸들 값을 EBX에 저장

    ; 2. 콘솔에 문자열 출력하기 (WriteFile API 사용)
    push 0                      ; lpOverlapped (사용 안 함)
    push OFFSET bytesWritten    ; 실제 출력된 바이트 수
    push msgLen                 ; 출력할 문자열 길이
    push OFFSET msg             ; 출력할 문자열의 주소
    push ebx                    ; 출력 핸들 (STDOUT)
    call WriteFile

    ; 3. 프로그램 정상 종료
    push 0
    call ExitProcess
main ENDP

END main