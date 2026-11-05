# 📘 Chapter 8. Advanced Procedures (고급 프로시저)

> 본 문서는 Assembly Programming의 고급 프로시저 개념(스택 프레임, 매개변수 전달, 고급 디렉티브, 다중 모듈 프로그램 작성 등)을 정리한 문서입니다.

---

## 💡 목차 (Table of Contents)
1. [스택 프레임 (Stack Frames)](#1-스택-프레임-stack-frames)
2. [고급 프로시저 지시어 (INVOKE, ADDR, PROC, PROTO)](#2-고급-프로시저-지시어-invoke-addr-proc-proto)
3. [재귀 (Recursion)](#3-재귀-recursion)
4. [다중 모듈 프로그램 작성 (Multimodule Programs)](#4-다중-모듈-프로그램-작성-multimodule-programs)
5. [호출 규약 및 추가 개념 (Calling Conventions & Advanced Parameters)](#5-호출-규약-및-추가-개념-calling-conventions--advanced-parameters)

---

## 1. 스택 프레임 (Stack Frames)

**스택 프레임(Stack Frame / Activation Record)**은 프로시저 호출 시 매개변수, 복귀 주소(Return Address), 지역 변수, 저장된 레지스터 등을 관리하기 위해 스택에 할당되는 메모리 영역입니다.

### 1.1 레지스터 매개변수 전달의 단점
- 매개변수를 레지스터로 전달하면 호출 전 레지스터 값을 백업(`PUSH`)하고 종료 후 복원(`POP`)해야 합니다.
- 매개변수가 많아질수록 코드의 복잡도가 높아지고, 레지스터 절약을 위해 스택을 활용한 전달 방식이 필요하게 됩니다.

### 1.2 스택 프레임 생성 과정
1. **Push Arguments**: 매개변수를 스택에 역순(오른쪽에서 왼쪽)으로 PUSH
2. **Call Subroutine**: 프로시저 호출 (복귀 주소가 스택에 PUSH됨)
3. **Push EBP**: 이전 `EBP` 값을 스택에 저장
4. **Set EBP to ESP**: `mov ebp, esp` (EBP를 현재 스택의 기준점으로 설정)
5. **Allocate Local Variables**: `sub esp, N` (지역 변수 메모리 할당)
6. **Save Registers**: 사용될 레지스터 PUSH

### 1.3 스택 프레임 구조 (32-bit 기준)

| 주소 / 위치 | 내용 | 비고 |
| :--- | :--- | :--- |
| `[ebp + 12]` | Parameter 2 | 두 번째 매개변수 |
| `[ebp + 8]` | Parameter 1 | 첫 번째 매개변수 |
| `[ebp + 4]` | **Return Address** | 복귀 주소 (`CALL` 명령으로 저장됨) |
| **`[ebp + 0]`** | **Saved EBP** | **현재 Base Pointer (`EBP`)** |
| `[ebp - 4]` | Local Variable 1 | 지역 변수 1 |
| `[ebp - 8]` | Local Variable 2 | 지역 변수 2 |
| `[ebp - N]` | Saved Registers | 보존할 레지스터 (`ESP` 지점) |

### 1.4 핵심 명령어 (`ENTER`, `LEAVE`, `LEA`)
- `ENTER numbytes, nestinglevel` : Prologue 코드를 대체 (`push ebp` + `mov ebp, esp` + `sub esp, numbytes`)
- `LEAVE` : Epilogue 코드를 대체 (`mov esp, ebp` + `pop ebp`)
- `LEA reg, mem` : 변수의 유효 주소(Effective Address)를 레지스터로 로드 (`OFFSET`과 달리 실행 시간에 간접 주소를 계산할 때 필수적)

---

## 2. 고급 프로시저 지시어 (INVOKE, ADDR, PROC, PROTO)

MASM은 C 언어 스타일로 함수를 호출하고 매개변수를 쉽게 처리할 수 있도록 고수준 지시어를 제공합니다.

### 2.1 `PROC` 지시어
프로시저 선언 시 파라미터 리스트와 속성(`USES` 등)을 함께 정의할 수 있습니다.
```assembly
AddTwo PROC,
    val1: DWORD,
    val2: DWORD
    
    mov eax, val1
    add eax, val2
    ret
AddTwo ENDP
```

### 2.2 `PROTO` 지시어
프로시저의 호출 시그니처(프로토타입)를 사전에 선언합니다.
```assembly
AddTwo PROTO, val1:DWORD, val2:DWORD
```

### 2.3 `INVOKE` & `ADDR`
- `INVOKE`: 매개변수를 스택에 자동으로 `PUSH`하고 프로시저를 `CALL`하는 지시어입니다.
- `ADDR`: 실행 시점에 매개변수의 주소를 스택에 전달할 때 사용됩니다.

```assembly
; PROC 호출 예시
INVOKE AddTwo, 10, 20
INVOKE Swap, ADDR Array, ADDR [Array+4]
```

---

## 3. 재귀 (Recursion)

자기 자신을 다시 호출하는 프로시저로, 각 호출 시마다 새로운 스택 프레임이 생성됩니다.

### 3.1 팩토리얼(Factorial) 예시
```assembly
Factorial PROC
    push ebp
    mov  ebp, esp
    mov  eax, [ebp+8]    ; n 가져오기
    cmp  eax, 0          ; n > 0 검사
    ja   L1
    mov  eax, 1          ; Base case: 0! = 1
    jmp  L2

L1:
    dec  eax
    push eax             ; n - 1 전달
    call Factorial
    
    ; Return EAX에는 (n-1)! 결과가 있음
    imul eax, [ebp+8]    ; n * (n-1)!

L2:
    pop  ebp
    ret  4               ; 매개변수 정리 (STDCALL)
Factorial ENDP
```

---

## 4. 다중 모듈 프로그램 작성 (Multimodule Programs)

대규모 프로그램 개발 시 소스 코드를 나누어 독립적으로 컴파일(Assembling)하고 하나로 링크(Linking)할 수 있습니다.

### 4.1 모듈 간 캡슐화 및 내보내기
- **`PRIVATE`**: 프로시저를 해당 모듈 내에서만 접근 가능하도록 제한 (캡슐화 및 이름 충돌 방지)
  ```assembly
  mySub PROC PRIVATE
  ```
- **`PUBLIC` / `EXTERN` (전통적인 방식)**:
  - `PUBLIC varName`: 외부 모듈에서 참조 가능하도록 내보냄
  - `EXTERN varName:type`: 외부 모듈의 변수/프로시저 참조
- **`EXTERNDEF` (권장 방식)**:
  - Header/Include 파일(`.inc`)에 사용하여 `PUBLIC`과 `EXTERN` 역할을 동시에 수행합니다.

### 4.2 Include 파일을 이용한 방식 예시 (`vars.inc`)
```assembly
; vars.inc
EXTERNDEF count: DWORD, SYM1: ABS

; sub1.asm
INCLUDE vars.inc
.data
count DWORD 0

; main.asm
INCLUDE vars.inc
.code
main PROC
    mov count, 2000h
    ...
main ENDP
```

---

## 5. 호출 규약 및 추가 개념 (Calling Conventions & Advanced Parameters)

### 5.1 32-Bit C vs STDCALL 비교

| 특징 | C Calling Convention (`C`) | STDCALL Convention (`STDCALL`) |
| :--- | :--- | :--- |
| **파라미터 전달 순서** | 오른쪽에서 왼쪽 (Right-to-Left) | 오른쪽에서 왼쪽 (Right-to-Left) |
| **스택 정리 주체** | **호출자 (Caller)** (`add esp, 8`) | **피호출자 (Callee)** (`ret 8`) |
| **주요 사용처** | C/C++ 기본 함수, 가변 인자 함수 | Windows API (`ExitProcess` 등) |

### 5.2 `WriteStackFrame` (디버깅 팁)
Irvine32 라이브러리에서 제공하는 함수로, 현재 프로시저의 스택 프레임 상태(매개변수, 복귀 주소, 지역변수, 레지스터 상태)를 화면에 출력할 때 유용하게 쓰입니다.
```assembly
INVOKE WriteStackFrame, PARAMS, LOCALS, SAVED_REGS
```
