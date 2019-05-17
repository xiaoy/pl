# Chapter 6: 条件流程
本章学习让程序拥有做决策的能力，其实就是条件语句，跳转语句，循环语句。

## 6.1 条件分支
程序通过CPU的状态变量来控制程序流程，本章从最基础的条件语句到最后组合出一个完整的程序。

## 6.2 布尔和比较语句
布尔指令简介：

| 操作符 | 描述                                                                    |
| ------ | ----------------------------------------------------------------------- |
| AND    | 逻辑与操作符，作用于源操作数和目标操作数                                |
| OR     | 逻辑或操作符，作用于源操作数和目标操作数                                |
| XOR    | 逻辑异或操作符，作用于源操作数和目标操作数                              |
| NOT    | 逻辑否操作符，作用于目标操作数                                          |
| TEST   | 对源操作数和目标操作数经行与操作，但不改变目标操作数，只修改CPU状态标志 |

### 6.2.1 CPU 状态标志
布尔指令对CPU 标志位的作用如下：

* 操作数的结果为零，Zero 标志位被设置
* 目标操作数的最高位产生进位，则 Carry 标志位被设置
* Sign标志位是目标操作数的最高位，意味着如果Sign被设置，结果为负，如果被清除，结果为正（零也为正）
* 当指令产生的结果超出有符号结果范围，Overflow 标志位被设置
* 在操作数的最低BYTE有偶数个一，则 Parity 标志位被设置

### 6.2.2 AND 指令
`AND` 指令对两个操作数进行逐位与操作，最后将结果写入目标操作数，语法为：

> AND destination, source

操作数必须相同长度，组合如下：

> AND reg, reg  
> AND reg, mem  
> AND reg, imm  
> AND mem, reg  
> AND mem, imm

`AND` 指令可以清除操作数的某一位，而不影响其他位，这种技术称作 *遮罩*。

`AND` 指令总是清除 Overflow 和 Carry 标志位，修改 Sign，Zero，和 Parity 标志位。

### 6.2.3 OR 指令
`OR` 指令对两个操作数逐位或操作，最后将结果写入目标操作数，语法为：

> OR destination, source

操作数组合和`AND`一致。

`OR` 指令总是清除 Carray 和 Overflow 标志位，修改 Sign，Zero， 和 Parity 标志位。

### 6.2.4 Bit-Mapped 集合
使用bit位组成集合，通过集合的操作结果来实现一些功能，比如权限管理。

集合操作有以下操作：

```asm
.data
SetX = 100000000000000000000000000111
SetY = 100000000000100000110111011001

.code
; 差集
mov eax, SetX
not eax

; 交集
mov eax, SetX
and eax, SetY

; 并集
mov eax, SetX
or eax, SetY 
```
### 6.2.5 XOR 指令
`XOR` 指令对两个操作数逐位执行与或操作，最后将结果写入目标操作数，语法为：

> XOR destination, source

操作数和 `AND, OR`操作数组合一致。

 
`XOR` 指令总是清除 Carray 和 Overflow 标志位，修改 Sign，Zero， 和 Parity 标志位。
通过`XOR` 操作可以检查一个操作数是否含有奇数或偶数个一。

```asm
; 校验8bit数
mov al, 10110101b           ; 5 bits = 奇数个
xor al, 0                   ; Pariy flag clear

mov al, 11001100b           ; 4bits = 偶数个
xor al, 0                   ; Parity flag set

; 校验 16 bit，通过高位和低位进行异或操作，因为是高低两个数：
; 1.高位和低位相同位置都为零的排除，执行结果为零，不影响统计一的个数
; 2.高位和低位相同位置都为一的排除，执行结果为零，高位和低位都有一，本身是偶数
; 3.高位和低位相同位置值不同，异或结果为一，产生的结果即可校验奇偶
mov ax, 64C1h               ; 0110 0100 1100 0001
xor ah, al                  ; Parity flag set

; 校验 32 bit，四byte依次异或来校验
```

### 6.2.6 NOT 指令
`NOT` 指令将操作数的所有bit反转。产生的结果称作操作数的补码。语法如下：

> NOT reg  
> NOT mem

`NOT` 指令不影响任何标志位

### 6.2.7 TEST 指令
`TEST` 指令和 `AND` 指令运作原理一样，但是不修改目标操作值，只影响标志位。

`TEST`指令总是清除 Overflow 和 Carry 标志位，修改 Sign，Zero，和 Parity 标志位

### 6.2.8 CMP 指令
`CMP` 指令执行隐式的减法，使用源操作数，减目标操作数，但不修改目标操作数。操作值组合和`AND`指令一致。

`CMD` 指令修改 OverFlow, Sign, Zero, Carry, Auxiliary Carray 和 Parity 标志位。

当两个无符号操作数对比，影响的标志位如下：

| 对比结果            | ZF  | CF  |
| ------------------- | --- | --- |
| Desination < source | 0   | 1   |
| Desination > source | 0   | 0   |
| Desination = source | 1   | 0   |

两个有符号操作数对比，影响标志位如下：

| 对比结果            | 标志位   |
| ------------------- | -------- |
| Desination < source | SF != OF |
| Desination > source | SF = OF  |
| Desination = source | ZF = 1   |

### 6.2.9 设置和清除独立 CPU 标志
以下是如何单独设置或清除 Zero,Sign,Carry,Overflow 标志位。

```asm
; 设置和清除 Zero 标志位
test al, 0              ; set Zero flag
and  al, 0              ; set Zero flag
or   al, 0              ; clear Zero flag

; 设置和清除 Sign 标志位
 or  al, 80h            ; set Sign Flag
 and al, 7Fh            ; clear Sign flag

 ; 设置和清除Carry 标志位
 stc                    ; set Carry Flag
 clc                    ; clear Carry Flag

 ; 设置和清除Overflow 标志位
 mov al, 7Fh            ; AL = +127
 inc al                 ; AL = 80h (-128), OF = 1
 or  eax, 0             ; Clear Overflow flag
```

### 6.2.10 64-bit mode 布尔指令
大部分情况64bit指令在64-Bit 模式和 32-bit模式运行一致。但是当源操作数是 32-bit常数或寄存器，目标操作数的低位32bit受影响。

## 6.3 条件跳转

### 6.3.1 条件结构
x86指令集没有直接实现逻辑结构，可以结合comparisons 和 jumps 指令来实现。通过以下两步实现条件语句：

* 类似 `CMP, AND, SUB`指令修改CPU状态变量
* 条件跳转语句测试标志量来判断是否跳转到新地址

### 6.3.2 Jcond 指令
当状态标志量条件为真，条件跳转语句跳转到目标label。如果条件为假，继续下一条指令执行。语法如下：

> Jcond destination

### 6.3.3 跳转指令的条件类型
x86指令集有数量众多的条件跳转语句。它们能对比有符号和无符号整数然后根据独立的CPU标志位来执行操作。条件跳转语句可以分为四部分：

* 根据某个标志量跳转
* 根据操作数是否相等或(E)CX的值跳转
* 根据无符号操作值对比跳转
* 根据有符号操作值对比跳转

下表展示了根据 Zero，Carry，Overflow，Parity，和Sign 标志位跳转。

| 助记符 | 描述               | 标志量/寄存器 |
| ------ | ------------------ | ------------- |
| JZ     | 如果为零则跳转     | ZF=1          |
| JNZ    | 如果不为零则跳转   | ZF=0          |
| JC     | 如果进位则跳转     | CF=1          |
| JNC    | 如果不进位则跳转   | CF=0          |
| JO     | 如果溢出则跳转     | OF=1          |
| JNO    | 如果无溢出则跳转   | OF=0          |
| JS     | 如果有符号则跳转   | SF=1          |
| JNS    | 如果无符号则跳转   | SF=0          |
| JP     | 如果偶数个一则跳转 | PF=1          |
| JNP    | 如果奇数个一则跳转 | PF=0          |

#### 等于
根据值是否相等跳转列表如下：

| 助记符 | 描述                                 |
| ------ | ------------------------------------ |
| JE     | 如果相等则跳转（leftOp = rightOp)    |
| JNE    | 如果不相等则跳转（leftOp != rightOp) |
| JCXZ   | 如果CX = 0 则跳转                    |
| JECXZ  | 如果ECX = 0 则跳转                   |
| JRCXZ  | 如果RCX = 0 则跳转                   |

比较leftOp和rightOp对应于left（destination）和right（source）操作数在CMP指令里：

> CMP leftOp, rightOp

#### 无符号比较
根据无符号数对比来跳转，指令如下表：

| 助记符 | 描述                                          |
| ------ | --------------------------------------------- |
| JA     | 如果大于(above) (if leftOp > rightOp)则跳转   |
| JNBE   | 如果不小于等于（below or equal）和JA相同      |
| JAE    | 如果大于等于（if leftOp >= rightOp) 则跳转    |
| JNB    | 如果不小于（和JAE相同）则跳转                 |
| JB     | 如果小于（if leftOp < rightOp)则跳转          |
| JNAE   | 如果不大于等于（和JB）相同则跳转              |
| JBE    | 如果不小于或等于（if leftOp <= rightOp)则跳转 |
| JNA    | 如果不大于（和JBE相同）则跳转                 |

#### 有符号比较
根据有符号数对比来跳转，指令如下：

| 助记符 | 描述                                          |
| ------ | --------------------------------------------- |
| JG     | 如果大于(greater) (if leftOp > rightOp)则跳转   |
| JNLE   | 如果不小于等于（less or equal）和JG相同      |
| JGE   | 如果大于等于（if leftOp >= rightOp) 则跳转    |
| JNL    | 如果不小于（和JGE相同）则跳转                 |
| JL     | 如果小于（if leftOp < rightOp)则跳转          |
| JNGE   | 如果不大于等于（和JL）相同则跳转              |
| JLE    | 如果不小于或等于（if leftOp <= rightOp)则跳转 |
| JNG    | 如果不大于（和JLE相同）则跳转                 |

### 6.3.4 条件跳转应用
#### 状态标志位测试
汇编语言非常善于做bit测试。通常我们不想修改变量值，但是通过测试会修改标志位，因此得知被测试变量的情况。

```asm
; 测试第五位是否为一，来得知设备是否下线
mov  al, status
test al, 00100000b          ; test bit 5
jnz  DeviceOffline

; 测试0,1，4 位是否为一
mov  al, status
test al, 00010011b          ; test bit 0, 1, 4
jnz  InputDataByte 

; 只检测2,3,7位是否设置为一，首先屏蔽掉其他位
mov  al, status
and  al, 10001100b          ; mask bits 2,3,7
cmp  al, 10001100b          ; all bits set?
je   ResetMachine           ; yes: jump to label
```

#### 两个数中最大的数
以下例子比较EAX和EBX中的无符号数，较大的拷贝到edx
```asm
    mov edx, eax
    com eax, ebx
    jae L1
    mov edx, ebx
L1:
```

#### 三个数中最小的
以下的程序比价了无符号16-bit变量V1,V2,V3 并将最小的值拷贝到AX
```asm
.data
V1 WORD ?
V2 WORD ?
V3 WORD ?

.code
    mov ax, V1          ; assume V1 is smallest
    cmp ax, V2          ; if AX <= V2
    jbe L1              ; jump to L1
    mov ax, V2          ; else mov V2 to AX
L1: cmp ax, v3          ; if AX <= V3
    jbe L2              ; jump to L2
    mov ax, V3          ; else move V3 to AX
L2:

```

#### 循环直到某个键被按下
在下面32-bit程序，循环持续直到某个标准键被按下。来自 Irvine32 库的 *ReadKey* 方法如果没有键按下设置Zero 标志位位0。
```asm
.data
char BYTE ?
.code
L1: mov     eax, 10     ; create 10 ms delay
    call    Delay
    call    ReadKey     ; cheak for key
    jz      L1          ; repeat if no key
    mov     char, AL    ; save the character
``` 

#### 循序搜索数组
循序搜索数组，只到搜索到第一个满足条件的数，显示次数，如果为搜索到，显示未找到此数。

[程序链接](ArrayScan.asm)

#### 字符串简单加密
利用和同一个因子异或两次还原原值来加解密。
> ((X xor Y) xor Y) = X

示例程序要做的事情：

1. 用户输入普通文本
2. 程序使用单个字符加密文本，产生加密文本
3. 程序解密加密文本，还原并且显示原文本

[程序链接](Encrypt.asm)

## 6.4 条件循环指令
### 6.4.1 LOOPZ 和 LOOPE 指令
`LOOPZ`(loop if zero) 指令和`LOOP`指令工作原理一致，除了附加条件：Zero 标志量被设置。语法如下：
> LOOPZ destination

`LOOPE`(loop is equal) 指令和 `LOOPZ`公用一样的操作码，完成的任务如下：

> ECX = ECX - 1  
> if ECX > 0 and ZF = 1, jump to detination

32位使用ECX，64位使用RCX。

### 6.4.2 LOOPNZ 和 LOOPNE 指令
`LOOPNZ` (loop if not zero) 指令是 `LOOPZ`的镜像，附加条件为：Zero标志量被清除。语法如下：
> LOOPNZ destination

`LOOPNE` 和 `LOOPNZ`公用一样的操作码，完成任务如下：

> ECX = ECX - 1  
> if ECX > 0 and ZF = 0, jump to desination

## 6.5 条件结构
### 6.5.1 结构块 IF 语句
执行条件语句两个步骤：

* 执行布尔表达式达到修改CPU标志量
* 通过CPU标志量的值来做跳转

### 6.5.2 组合表达式

#### 逻辑与操作
```c++
if ((al > bl) && (b1 > c1))
{
    x = 1
}
```
翻译为汇编
```asm
    cmp a1, b1
    ja L1
    jmp next
L1:
    cmp b1, c1
    ja L2
    jmp next
L2:
    mov x, 1
next:
```

优化版
```asm
    camp a1, b1
    jbe  next
    camp b1, c1
    jbe  next
    mov  x, 1
next:
```
#### 逻辑或操作

```c++
if ((al > bl) || (b1 > c1))
{
    x = 1
}
```

翻译为汇编

```asm
    cmp a1, b1
    ja  L1
    cmp b1, c1
    jbe next 
L1: mov x, 1
next:
```
### 6.5.3 WHILE 循环
`WHILE`循环在开始执行主体语句时先检测条件，如果满足条件开始执行，到结尾跳到开始。
```c++
// c++
while(val1 < val2)
{
    val1++;
    val2++;
}
```

翻译为汇编后
```asm
    mov eax, val1               ; copy variable to eax
beginwhile:
    cmp eax, val2               ; if not (val1 < val2)
    jnl endwhile                ; exit the loop
    inc eax                     ; val1++
    dec val2                    ; val2--
    jmp beginwhile              ; repeat the loop
endwhile:
    mov val1, eax               ; save new value for val1
```

#### while 和 if 结合例子
c++ 代码如下：
```c++
int array[] = {10, 60, 20, 33, 72, 89, 45, 65, 72, 18};
int sample = 50;
int arraySize = sizeof array / sizeof sample;
int index = 0;
int sum = 0;
while(index < arraySize)
{
    if(array[index] > sample)
    {
        sum += array[index];
    }
    index++;
}
```
汇编代码为：[Flowchar.asm](Flowchart.asm)

### 6.5.4 表格驱动选择
*表格驱动选择* 使用表格查询代替多路选择的一种结构方式。对于需要大量对比操作，表格查询非常优美简介的实现。

例子代码：[ProcTable.asm](ProcTable.asm)

## 6.6 Application：有限状态机
*有限状态机* (finite-state machine-FSM)是根据输入修改状态的机器或程序。通常使用图可以非常简介的表示FSM，图的节点可以表示状态，图之间的连接表示状态的转化。

[有限状态机有符号整数例子](finite.asm)

## 6.7 条件控制流语句
在32-bit模式下，MASM包含了许多高等级条件控制流程语句，帮助简化代码条件表达式。但是不支持64-bit模式。由于这是MASM特有的语法，所以如果要使用MASM进行工业级编程，还是有必要学习的，毕竟简化了程序员负担，还提高了程序的可读性，可维护性，以及少犯错误。
