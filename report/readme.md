### 1번 문제

> **Which statements belong in a procedure’s epilogue when the procedure has stack parameters and local variables?**  
> (프로시저에 스택 매개변수와 지역 변수가 있을 때, 프로시저의 에필로그(epilogue)에 속하는 명령어(문)는 무엇인가요?)

#### 풀이 (Explanation)
어셈블리 언어(x86)에서 스택 매개변수와 지역 변수를 사용하는 프로시저가 종료될 때 스택 상태를 호출 전으로 원상 복구하는 에필로그 과정은 다음과 같습니다.
1. **지역 변수 해제:** `mov esp, ebp`를 통해 스택 포인터(`ESP`)를 `EBP` 위치로 되돌려 지역 변수 공간을 해제합니다.
2. **호출자의 EBP 복원:** `pop ebp`를 실행하여 스택에 저장해 두었던 이전 `EBP` 값을 복원합니다. *(참고: 1번과 2번 과정은 `leave` 명령어 하나로 대체 가능합니다.)*
3. **리턴 및 스택 정리:** `ret` 또는 STDCALL인 경우 `ret N` 명령어로 호출한 위치로 복귀합니다.

#### 답 (Answer)
1. **`mov esp, ebp`** (지역 변수 공간 해제)
2. **`pop ebp`** (이전 `EBP` 값 복원)
3. **`ret`** 또는 **`ret N`** (호출자로 복귀 및 스택 매개변수 정리)  
*(단축 형태: **`leave`** 및 **`ret N`**)*

---

### 2번 문제

> **When a C function returns a 32-bit integer, where is the return value stored?**  
> (C 함수가 32비트 정수를 반환할 때, 반환값은 어디에 저장되나요?)

#### 풀이 (Explanation)
x86 아키텍처 및 C 언어 호출 규약(`cdecl`, `stdcall` 등)에서는 함수가 종료되면서 32비트 정수 타입(`int`, `long` 등)을 반환할 때 **`EAX` 레지스터**에 저장하도록 약속되어 있습니다.

#### 답 (Answer)
**`EAX` 레지스터 (EAX register)**

---

### 3번 문제

> **How does a program using the STDCALL calling convention clean up the stack after a procedure call?**  
> (STDCALL 호출 규약을 사용하는 프로그램은 프로시저 호출 후 스택을 어떻게 정리하나요?)

#### 풀이 (Explanation)
STDCALL 방식은 **피호출자(Callee, 호출된 프로시저)**가 스택 정리의 책임을 집니다. 프로시저가 종료될 때 **`ret N`** 명령어(여기서 $N$은 전달받은 매개변수들의 총 바이트 수)를 실행하여 리턴과 동시에 스택 포인터(`ESP`)를 $N$만큼 자동으로 증가시켜 매개변수 공간을 정리합니다.

#### 답 (Answer)
**피호출자(Callee)**가 종료될 때 **`ret N`** 명령어를 사용하여 스택 포인터(`ESP`)를 자동으로 증가시킴으로써 스택을 정리합니다.

---

### 4번 문제

> **How is the LEA instruction more powerful than the OFFSET operator?**  
> (LEA 명령어가 OFFSET 연산자보다 어떻게 더 강력한가요?)

#### 풀이 (Explanation)
- `OFFSET` 연산자는 **어셈블 시점(Assembly-time)**에 작동하므로 전역 변수나 정적 데이터의 오프셋 주소만 가져올 수 있습니다.
- `LEA` 명령어는 **프로그램 실행 시점(Runtime)**에 주소를 계산하므로, 스택 프레임 내의 지역 변수나 매개변수의 주소를 구할 수 있고 complex 간접 주소 지정 방식(예: `lea eax, [ebx + ecx * 4 + 8]`)을 통한 빠른 산술 연산도 가능합니다.

#### 답 (Answer)
**`OFFSET`은 어셈블 시점의 정적 주소만 가져올 수 있지만, `LEA`는 실행 시점(Runtime)에 주소를 계산하므로 스택의 지역 변수/매개변수 주소를 구할 수 있고 복잡한 주소 계산 연산이 가능합니다.**

---

### 5번 문제

> **In the C++ example shown in Section 8.2.3, how much stack space is used by a variable of type int?**  
> (Section 8.2.3에 제시된 C++ 예제에서, `int` 타입의 변수는 얼마만큼의 스택 공간을 사용하나요?)

#### 풀이 (Explanation)
32비트 x86 환경에서 C++의 `int` 데이터 타입은 **4바이트 (32비트)** 크기를 가지며, 스택 메모리도 4바이트(DWORD) 단위로 할당됩니다.

#### 답 (Answer)
**4바이트 (4 bytes)**

---

### 6번 문제

> **What advantages might the C calling convention have over the STDCALL calling convention?**  
> (C 호출 규약(cdecl)은 STDCALL 호출 규약에 비해 어떤 장점을 가지고 있나요?)

#### 풀이 (Explanation)
`cdecl`은 **호출자(Caller)**가 스택을 정리하므로, 매 호출 시 전달된 매개변수 바이트 수만큼 스택을 복구할 수 있습니다. 따라서 C언어의 `printf`, `scanf`와 같은 **가변 인자 함수(Variable Argument Functions)**를 구현하고 호출할 수 있다는 큰 장점이 있습니다.

#### 답 (Answer)
**`printf`와 같은 가변 인자 함수(Variable Argument Functions)를 지원할 수 있다는 점입니다.**

---

### 7번 문제

> **(True/False): When using the PROC directive, all parameters must be listed on the same line.**  
> (참/거짓: PROC 지시어를 사용할 때, 모든 매개변수는 반드시 같은 줄에 나열되어야 하나요?)

#### 풀이 (Explanation)
MASM에서 `PROC` 지시어로 프로시저를 선언할 때, 각 매개변수 뒤에 쉼표(`,`)를 붙이면 **여러 줄(Multiple lines)**에 걸쳐 나누어 작성할 수 있습니다.

#### 답 (Answer)
**False (거짓)**

---

### 8번 문제

> **(True/False): If you pass a variable containing the offset of an array of bytes to a procedure that expects a pointer to an array of words, the assembler will flag this as an error.**  
> (참/거짓: 워드 배열의 포인터를 요구하는 프로시저에 바이트 배열의 오프셋이 담긴 변수를 전달하면, 어셈블러는 이를 에러로 표시하나요?)

#### 풀이 (Explanation)
어셈블러 입장에서 포인터는 단순한 32비트 메모리 주소값(DWORD)입니다. 어셈블러는 포인터가 가리키는 실제 메모리 데이터 타입(`BYTE`, `WORD` 등)까지 엄격하게 검사하지 않으므로 에러를 발생시키지 않고 정상적으로 어셈블합니다.

#### 답 (Answer)
**False (거짓)**

---

### 9번 문제

> **(True/False): If you pass an immediate value to a procedure that expects a reference parameter, you can generate a general-protection fault.**  
> (참/거짓: 참조 매개변수를 요구하는 프로시저에 즉시값을 전달하면, 일반 보호 오류(General-Protection Fault)가 발생할 수 있나요?)

#### 풀이 (Explanation)
참조 매개변수는 메모리 주소를 기대합니다. 주소 대신 단순 숫자(즉시값)를 전달하면 프로시저가 해당 숫자를 주소로 착각하여 잘못된 메모리 영역을 읽거나 쓰려고 시도하며, 이로 인해 운영체제에 의해 **일반 보호 오류(GPF)**가 발생합니다.

#### 답 (Answer)
**True (참)**

---


### 1번 문제

> **Here is a calling sequence for a procedure named AddThree that adds three doublewords (assume that the STDCALL calling convention is used):**
> ```assembly
> push 10h
> push 20h
> push 30h
> call AddThree
> ```
> **Draw a picture of the procedure’s stack frame immediately after EBP has been pushed on the runtime stack.**  
> (세 개의 더블워드를 더하는 AddThree 프로시저의 호출 순서가 위와 같을 때, EBP가 push된 직후의 스택 프레임을 그림으로 나타내세요.)

#### 답 (Answer)

```text
       +-----------------------+  [높은 주소 (Higher Memory)]
       |          10h          |  [EBP + 16] (첫 번째 매개변수)
       +-----------------------+
       |          20h          |  [EBP + 12] (두 번째 매개변수)
       +-----------------------+
       |          30h          |  [EBP + 8]  (세 번째 매개변수)
       +-----------------------+
       |    Return Address     |  [EBP + 4]  (복귀 주소)
EBP -> +-----------------------+
ESP -> |       Saved EBP       |  [EBP / ESP] (저장된 이전 EBP)
       +-----------------------+  [낮은 주소 (Lower Memory)]
```

---

### 2번 문제

> **Create a procedure named AddThree that receives three integer parameters and calculates and returns their sum in the EAX register.**  
> (세 개의 정수 매개변수를 받아 이들의 합을 계산하여 EAX 레지스터로 반환하는 AddThree 프로시저를 작성하세요.)

#### 답 (Answer)

```assembly
;---------------------------------------------------
; AddThree
; 세 정수를 입력받아 합을 계산하여 EAX로 반환함
; Receives: val1, val2, val3 (정수 매개변수 3개)
; Returns:  EAX = val1 + val2 + val3
;---------------------------------------------------
AddThree PROC,
    val1: DWORD,
    val2: DWORD,
    val3: DWORD

    mov eax, val1       ; 첫 번째 매개변수를 EAX에 복사
    add eax, val2       ; 두 번째 매개변수를 더함
    add eax, val3       ; 세 번째 매개변수를 더함

    ret                 ; 결과는 EAX에 저장되어 반환됨
AddThree ENDP
```

---




## 문제 (Question)

**3. Declare a local variable named pArray that is a pointer to an array of doublewords.**
(DWORD(더블워드) 배열을 가리키는 포인터 타입의 `pArray`라는 이름의 지역 변수를 선언하세요.)

---

## 풀이 (Explanation)

MASM 어셈블리 언어에서 프로시저 내부의 지역 변수(Local Variable)는 **`LOCAL`** 지시어를 사용하여 선언합니다.

1. **`LOCAL` 지시어 위치:**
   - `LOCAL` 지시어는 프로시저(`PROC`) 내부의 가장 첫 번째 줄(실행 가능한 명령어 이전)에 위치해야 합니다.

2. **포인터 타입 선언:**
   - 32비트 환경에서 메모리 주소(포인터)는 4바이트(DWORD) 크기를 가집니다.
   - 더블워드(DWORD) 데이터 타입의 배열을 가리키는 포인터는 **`PTR DWORD`** 지시어를 타입 지정자로 사용하여 명확하게 포인터 변수임을 나타냅니다. (단순히 `DWORD`로 선언해도 4바이트 주소 공간이 할당되지만, 포인터임을 명시하기 위해 `PTR DWORD`를 사용하는 것이 좋습니다.)

---

## 답 (Answer)

### 1. 프로시저 내부 선언 문장 (단독 선언)

```assembly
LOCAL pArray:PTR DWORD
```

---

### 2. 실제 프로시저 내 사용 예시

```assembly
MyProcedure PROC
    LOCAL pArray:PTR DWORD    ; DWORD 배열을 가리키는 포인터 지역 변수 선언

    ; 프로시저 코드 작성
    ret
MyProcedure ENDP
```

---



## 문제 (Question)

**4. Declare a local variable named buffer that is an array of 20 bytes.**
(20바이트 크기의 배열인 `buffer`라는 이름의 지역 변수를 선언하세요.)

---

## 풀이 (Explanation)

MASM 어셈블리 언어에서 지역 배열(Local Array) 변수를 선언할 때는 **`LOCAL`** 지시어와 함께 배열의 크기를 대괄호 `[ ]`로 지정합니다.

1. **지역 배열 선언 구문:**
   - `LOCAL 변수명[배열크기]:데이터타입` 형태 구문을 사용합니다.
   - 20바이트 크기의 배열이므로 변수명 뒤에 `[20]`을 붙이고 타입은 `BYTE`로 지정합니다.

2. **스택 프레임 동작 방식:**
   - 어셈블러가 이 선언을 만나면 프로시저 시작 부분(Prologue)에서 스택 포인터(`ESP`)를 20바이트만큼 감산(`sub esp, 20`)하여 스택 영역에 20바이트의 지역 공간을 자동으로 할당합니다.

---

## 답 (Answer)

### 1. 지역 변수 선언 문장 (단독 선언)

```assembly
LOCAL buffer[20]:BYTE
```

---

### 2. 실제 프로시저 내 사용 예시

```assembly
MyProcedure PROC
    LOCAL buffer[20]:BYTE    ; 20바이트 크기의 지역 배열 선언

    ; 프로시저 코드 작성
    ret
MyProcedure ENDP
```

---



## 문제 (Question)

**5. Declare a local variable named pwArray that points to a 16-bit unsigned integer.**
(16비트 부호 없는 정수를 가리키는 `pwArray`라는 이름의 지역 변수를 선언하세요.)

---

## 풀이 (Explanation)

어셈블리 언어(MASM)에서 지역 변수를 선언하고 포인터 타입을 지정하는 방법은 다음과 같습니다.

1. **데이터 타입 구분:**
   - **16비트 부호 없는 정수(16-bit unsigned integer):** 어셈블리 키워드로 **`WORD`**에 해당합니다.
   - **포인터(Pointer):** 특정 데이터 타입을 가리키는 포인터임을 나타내기 위해 **`PTR`** 지시어를 조합합니다. 따라서 `PTR WORD`는 "WORD 타입 데이터를 가리키는 포인터 주소"를 의미합니다.

2. **`LOCAL` 지시어 활용:**
   - 프로시저 내부 첫 줄에 `LOCAL 변수명:타입` 형식으로 선언합니다.
   - 32비트 아키텍처 환경에서 포인터 변수 자체의 크기는 메모리 주소 크기인 4바이트(DWORD)로 스택에 할당되며, 가리키는 대상의 타입 정보를 `PTR WORD`로 지정하게 됩니다.

---

## 답 (Answer)

### 1. 지역 변수 선언 문장 (단독 선언)

```assembly
LOCAL pwArray:PTR WORD
```

---

### 2. 실제 프로시저 내 사용 예시

```assembly
MyProcedure PROC
    LOCAL pwArray:PTR WORD    ; 16비트 정수(WORD)를 가리키는 포인터 지역 변수 선언

    ; 프로시저 코드 작성
    ret
MyProcedure ENDP
```

---



## 문제 (Question)

**6. Declare a local variable named myByte that holds an 8-bit signed integer.**
(8비트 부호 있는 정수를 저장하는 `myByte`라는 이름의 지역 변수를 선언하세요.)

---

## 풀이 (Explanation)

어셈블리 언어(MASM)에서 8비트 정수 데이터 타입은 다음과 같이 구분됩니다.

1. **데이터 타입 선택:**
   - **`BYTE`**: 일반적인 8비트 무부호(Unsigned) 정수 또는 범용 8비트 데이터
   - **`SBYTE`**: 8비트 **부호 있는 정수(Signed Byte)**. 부호 비트(2의 보수 표현 방식)를 고려하는 정수임을 명시할 때 사용합니다.

2. **`LOCAL` 지시어를 통한 선언:**
   - 프로시저 내부에서 `LOCAL myByte:SBYTE` 형태로 선언합니다.
   - 단, 스택 메모리는 4바이트(DWORD) 단위로 정렬되는 특성이 있으므로 1바이트 크기의 변수라도 스택 프레임상에는 정렬 기준에 맞춰 공간이 확보됩니다.

---

## 답 (Answer)

### 1. 지역 변수 선언 문장 (단독 선언)

```assembly
LOCAL myByte:SBYTE
```
*(참고: 부호를 구별하지 않는 기본 8비트 타입인 `LOCAL myByte:BYTE` 형태도 허용됩니다.)*

---

### 2. 실제 프로시저 내 사용 예시

```assembly
MyProcedure PROC
    LOCAL myByte:SBYTE    ; 8비트 부호 있는 정수(SBYTE) 지역 변수 선언

    ; 프로시저 코드 작성
    ret
MyProcedure ENDP
```

---


## 7번 문제

> **Declare a local variable named myArray that is an array of 20 doublewords.**  
> (20개의 더블워드(DWORD) 요소로 구성된 `myArray`라는 이름의 지역 변수(배열)를 선언하세요.)

### 풀이 (Explanation)
MASM에서 32비트 정수 데이터 타입인 **`DWORD`** 타입의 지역 배열을 선언할 때는 `LOCAL 변수명[배열크기]:데이터타입` 구문을 사용합니다. 

### 답 (Answer)
```assembly
LOCAL myArray[20]:DWORD
```

---

## 8번 문제

> **Create a procedure named SetColor that receives two stack parameters: forecolor and backcolor, and calls the SetTextColor procedure from the Irvine32 library.**  
> (스택 매개변수인 `forecolor`와 `backcolor` 두 개를 받아, Irvine32 라이브러리의 `SetTextColor` 프로시저를 호출하는 `SetColor` 프로시저를 작성하세요.)

### 풀이 (Explanation)
Irvine32 라이브러리의 `SetTextColor` 프로시저는 `EAX` 레지스터에 글자색과 배경색의 색상 속성 조합 값을 전달받습니다.
- 색상 값 계산 방식: `(backcolor * 16) + forecolor` (또는 `backcolor`를 왼쪽으로 4비트 시프트 한 후 `forecolor`를 더함)
- `SetColor` 프로시저는 매개변수를 받아 이 계산을 수행한 후 `EAX`에 저장하고 `SetTextColor`를 호출합니다.

### 답 (Answer)
```assembly
;---------------------------------------------------
; SetColor
; 글자색과 배경색을 설정합니다.
; Receives: forecolor (DWORD), backcolor (DWORD)
;---------------------------------------------------
SetColor PROC,
    forecolor: DWORD,
    backcolor: DWORD

    mov eax, backcolor
    shl eax, 4              ; backcolor * 16 (상위 4비트로 이동)
    add eax, forecolor      ; 글자색 추가
    call SetTextColor       ; Irvine32 라이브러리 함수 호출

    ret
SetColor ENDP
```

---

## 9번 문제

> **Create a procedure named WriteColorChar that receives three stack parameters: char, forecolor, and backcolor. It displays a single character, using the color attributes specified in forecolor and backcolor.**  
> (세 개의 스택 매개변수 `char`, `forecolor`, `backcolor`를 받아, 지정된 색상 속성을 사용하여 단일 문자를 출력하는 `WriteColorChar` 프로시저를 작성하세요.)

### 풀이 (Explanation)
1. 8번 문제에서 만든 `SetColor` 프로시저(또는 `SetTextColor`)를 호출하여 색상을 지정합니다.
2. 출력할 문자를 `AL` 레지스터에 저장한 후 Irvine32의 `WriteChar` 프로시저를 호출하여 화면에 문자를 출력합니다.

### 답 (Answer)
```assembly
;---------------------------------------------------
; WriteColorChar
; 지정된 글자색/배경색 속성으로 문자를 출력합니다.
; Receives: char (BYTE/DWORD), forecolor (DWORD), backcolor (DWORD)
;---------------------------------------------------
WriteColorChar PROC,
    char: BYTE,
    forecolor: DWORD,
    backcolor: DWORD

    ; 1. 색상 설정 (8번 문제의 SetColor 활용 또는 직접 계산)
    INVOKE SetColor, forecolor, backcolor

    ; 2. 문자 출력 (Irvine32의 WriteChar는 AL 레지스터 사용)
    mov al, char
    call WriteChar

    ret
WriteColorChar ENDP
```

---

## 10번 문제

> **Write a procedure named DumpMemory that encapsulates the DumpMem procedure in the Irvine32 library. Use declared parameters and the USES directive. The following is an example of how it should be called: INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array.**  
> (Irvine32 라이브러리의 `DumpMem` 프로시저를 캡슐화하는 `DumpMemory` 프로시저를 작성하세요. 선언된 매개변수와 `USES` 지시어를 사용해야 합니다. 호출 예시: `INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array`)

### 풀이 (Explanation)
Irvine32의 `DumpMem` 프로시저는 메모리를 덤프하여 출력할 때 다음 레지스터들을 입력으로 받습니다:
- `ESI`: 배열의 시작 메모리 주소
- `ECX`: 배열 요소의 개수
- `EBX`: 요소의 크기(1: BYTE, 2: WORD, 4: DWORD)

`USES` 지시어를 사용하여 프로시저 종료 시 `EBX`, `ECX`, `ESI` 레지스터가 원래 상태로 복원되도록 보장합니다.

### 답 (Answer)
```assembly
;---------------------------------------------------
; DumpMemory
; Irvine32의 DumpMem을 호출하는 래퍼(Wrapper) 프로시저
; Receives: address (포인터), elementCount (요소 개수), elementSize (요소 크기)
;---------------------------------------------------
DumpMemory PROC USES ebx ecx esi,
    address: PTR DWORD,
    elementCount: DWORD,
    elementSize: DWORD

    mov esi, address        ; 메모리 시작 주소 -> ESI
    mov ecx, elementCount   ; 요소 개수 -> ECX
    mov ebx, elementSize    ; 요소 단위 크기 -> EBX

    call DumpMem            ; Irvine32 메모리 덤프 호출

    ret
DumpMemory ENDP
```

---

## 11번 문제

> **Declare a procedure named MultArray that receives two pointers to arrays of doublewords, and a third parameter indicating the number of array elements. Also, create a PROTO declaration for this procedure.**  
> (더블워드(DWORD) 배열 포인터 2개와 배열 요소 개수를 나타내는 세 번째 매개변수를 받는 `MultArray` 프로시저를 작성하고, 이 프로시저의 `PROTO` 프로토타입 선언문도 작성하세요.)

### 풀이 (Explanation)
1. **`PROTO` 선언문:** 프로시저 호출 시 어셈블러가 타입 검증을 할 수 있도록 프로시저 원형(Prototype)을 정의합니다.
2. **`PROC` 정의문:** 매개변수로 DWORD 포인터 2개(`PTR DWORD`)와 요소 개수(`DWORD`)를 선언합니다.

### 답 (Answer)

#### 1. PROTO 프로토타입 선언문
```assembly
MultArray PROTO,
    ptrArray1: PTR DWORD,
    ptrArray2: PTR DWORD,
    count: DWORD
```

#### 2. MultArray 프로시저 정의
```assembly
;---------------------------------------------------
; MultArray
; Receives: ptrArray1 (PTR DWORD), ptrArray2 (PTR DWORD), count (DWORD)
;---------------------------------------------------
MultArray PROC,
    ptrArray1: PTR DWORD,
    ptrArray2: PTR DWORD,
    count: DWORD

    ; 프로시저 구체 로직 작성 위치 (예: 배열 요소 간 곱셈 수행)

    ret
MultArray ENDP
```
