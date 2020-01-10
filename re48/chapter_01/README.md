# chapter 01:代码模式
## 1.1 方法
作者学习C语言，以及后面的C++时，先写一小段代码，编译之后查看汇编代码。这种方法让他很容易理解自己所写代码运行原理。当前可以使用[godbolt](https://godbolt.org/)来在线汇编代码。

### 练习
作者在学习汇编语言时，经常将C语言函数编译为汇编代码，然后自己使用汇编语言重写函数，重写时使用最少的代码来实现。当前编译器的优化已经非常棒了，但是如果想加强自己的汇编能力，可以自己将C语言函数转换为汇编，然后和编译器汇编结果对比。

### 优化等级和调试信息
源码可以被不同的编译器通过不同等级优化来编译。典型编译器有三个等级：

1. 等级零优化意味着优化全关
2. 下一等级的优化结果将会包含一些调试信息，重要特性是机器码可以对应到相关源代码
3. 最高等级的优化可能将部分源码从结果中去除或修改


## 1.2 基础
### 1.2.1 CPU 简介
#### 一些概念
* **指令**：CPU 基础命令，每种CPU都有自己的指令集架构(instruction set architecture-ISA)
* **机器码**：CPU 直接执行的代码。每个指令由几个字节编码
* **汇编代码**：助记码和一些扩展，相比机器编码简单一些
* **CPU 寄存器**：每个CPU都有固定个数的寄存器。寄存器可以认为是代码里使用的零时变量

#### 不同指令集架构
* x86 ISA 是可变长度指令，所以当64-bit出来时，不影响旧的指令集
* ARM 是精简指令CPU设计，使用固定长度指令，过去有一些优点，ARM有如下三种指令集
  * 开始所有的ARM指令编码为4字节长度，称作 “ARM Mode”
  * 后面发现可以使用更少的字节编码，因此添加了另外一个称作“Thumb Mode”指令集，使用2字节编码，当ARMv7出来时，发现2字节编码不够了，所以有些指令使用4字节编码，称作“Thumb-2”，2字节和4字节编码都存在，合称“Thumb mode”
  * 当ARM64出来时，使用4字节编码，称作“ARM64”


## 1.3 空函数
最简单的函数就是啥事不做的函数
```c++
void f()
{
    return;
}
```

### 1.3.1 X86
X86 平台下优化后的汇编代码如下：
```asm
f:
    ret
```

### 1.3.2 ARM
```asm
f   PROC
    BX lr
    ENDP
```
在ARM 指令集返回地址没有存在当前栈上，而是在链接寄存器(link register)，因此 `BX LR` 指令跳转到调用后的地址。

### 1.3.3 MIPS
MIPS 有两种寄存器命名方式：数字方式（从 \$0 到 \$31)，或者是（\$V0, \$A0,...）

GCC 汇编输出通过数字寄存器：
```asm
j $31
nop
```

使用IDA 使用名字：
```asm
j $ra
nop
```

第一条指令是跳转指令(J or JR)返回到调用控制流程，跳转到 \$31(or \$RA) 寄存器，这和 ARM里的链接寄存器同理。

### 1.3.4 空函数的用处
调试函数，使用宏来调用一些调试代码。

发布一些版本，可以通过宏来控制编译对应的功能代码。

## 1.4 函数返回值
另外一个简单的函数是返回一个常量值：
```C++
int f()
{
    return 123;
}
```

### 1.4.1 x86
GCC 和 MSVC 优化输出汇编结果
```asm
f:
    mov eax, 123
    ret
```
前一个指令将123放入 eax寄存器，通常用来存放返回值，第二条指令返回到调用所在地址。

### 1.4.2 ARM
```asm
f   PROC
    MOV r0, #0x7b   ; 123
    BX  lr
    ENDP
```

ARM 使用 寄存器 R0来存放返回值，因此123拷贝到 R0。

### 1.4.3 MIPS
GCC 汇编输出如下：
```asm
j   $31
li  $2, 123
```

IDA 使用名字：
```asm
jr $ra
li $v0, 0x7B
```

`$2 (or $V0)` 寄存器用来存储函数返回值。`LI` 代表 "Load Immediate"，等价 `MOV`。

另外的指令是跳转指令(J or JR)返回到调用地址。

由于RISC的“branch delay slot”特性，拷贝指令在跳转指令前优先执行。

## 1.5 Hello,world
经典的开篇程序。
```C++
#include <stdio.h>

int main()
{
    printf("hello, world\n");
    return 0;
}
```

### 1.5.1 x86
MSVC 编译，命令如下：
> cl 1.cpp /Fa1.asm

/Fa 开关让编译器生成汇编 listing 文件

汇编结果如下：
```asm
_DATA SEGMENT
$SG7386 DB 'hello, world', 0aH, 00H
_DATA ENDS

_main PROC
  push ebp
  mov ebp, esp
  push OFFSET $SG7386           ; 传递字符串地址
  call _printf
  add esp, 4                    ; 返回栈空间
  xor eax, eax
  pop ebp
  ret 0
_main ENDP
```

GCC，编译后 使用 IDA打开结果如下，intel 风格：

```asm
main                proc near
var_10              = dword ptr -10h
                    push ebp
                    mov ebp,esp
                    and esp, 0FFFFFF0h          ; 对齐到 16字节
                    sub esp, 10h                ; 分配 16字节空间
                    mov eax, offset aHelloWorld ; "hello, world\n"
                    mov [esp+10h+var_10], eax   ; 将地址存放在eax
                    call _printf
                    mov eax, 0
                    leave                       ; 等价于 mov esp, ebp 以及 pop ebp
                    retn
main                endp
```

GCC:AT&T 语法，去除宏后的精简代码如下：
```asm
.LC0:
        .string "hello, world\n"

main:
        pushl %ebp
        movl %esp, %ebp
        andl $-16, %esp
        subl $16, %esp
        movl $.LC0, (%ebp)
        call printf
        movl $0, %eax
        leave
        ret
```
Intel 和 AT&T语法区别如下：

* 源和目标操作数顺序相反
    * intel语法为 `<instruction> <desination operand> <source operand>`
    * AT&T语法为 `<instruction> <source operand> <desination operand>`
    * 简单的记忆方式，intel可以认为是 **=**，AT&T 认为是 **->**
* AT&T：在寄存器名字前，寄存器名字前要添加 `%`，在数字前要加 `$` ，方括号被圆括号代替
* AT&T：指令添加后缀来定义操作数长度
    *  q -> quad(64 bits)
    *  l -> long(32 bits)
    *  w -> word(16 bits)
    *  b -> byte(8 bits)

### 1.5.2 x86-64
64-bit MSVC:

```asm
$SG5081 DB 'hello, world', 0aH, 00H

main PROC
$LN3:
  sub rsp, 40 ; 00000028H               ; shadow space，用来保存，和后续恢复寄存器值
  lea rcx, OFFSET FLAT:$SG5081
  call printf
  xor eax, eax
  add rsp, 40 ; 00000028H
  ret 0
main ENDP
```
Win64，函数前4个参数通过寄存器`RCX,RDX,R8,R9`来传递，其余的通过栈来传递，好处是寄存器访问速度快。

GCC:x86-64 linux:

```asm
.LC0:
  .string "hello, world"
main:
  push rbp
  mov rbp, rsp
  mov edi, OFFSET FLAT:.LC0
  call puts
  mov eax, 0
  pop rbp
  ret
```

Linux, BSD 和 Mac OSX 前6个参数通过寄存器 `RDI,RSI,RDX,RCX,R8,R9`，其余用栈来传递。

地址传到edi是因为，`mov edi, OFFSET FLAT:.LC0` 只使用5字节编码，如果使用 64位需要7字节编码。

### 1.5.3 GCC-其他
匿名C-字符串是 const 类型，分配在常量段的C-字符串不可改变，编译器也许使用部分字符串来优化。

```C++
#include <stdio.h>

int f1()
{
    printf("world\n");
}

int f2()
{
    printf("hello world\n");
}

int main()
{
    f1();
    f2();
}
```

MSVC 正常是分配两个字符串，GCC编译如下：
```asm
f1  proc near
s   = dword ptr -1Ch
    sub esp, 1Ch
    mov [esp+1Ch+s], offset s ; "world\n"
    call _puts
    add esp, 1Ch
    retn
f1 endp

f2 proc near
    s = dword ptr -1Ch
    sub esp, 1Ch
    mov [esp+1Ch+s], offset aHello ; "hello "
    call _puts
    add esp, 1Ch
    retn
f2 endp

aHello db 'hello '
s db 'world',0xa,0
```
## 1.6  函数前戏和后戏(Function prologue and epilogue)
函数执行前代码指纹：
```asm
push ebp                    ; save the value of ebp
mov ebp,esp                 ; set the value of ebp to the esp value
sub esp,X                   ; allocate space on the stack for local variables
```

函数执行后代码指纹
```asm
    mov esp, ebp
    pop ebp
    ret 0
```
## 1.7 栈
栈是计算机科学最基础的数据结构。

栈是进程里的一块内存，栈指针(esp, rsp)在x86，或x64 指向这块内存。有两种操作：

1. `push` 指令将操作数写入内存，并且栈指针大小减小
2. `pop` 将栈顶的值写入操作数，并且栈指针增大

### 1.7.1 为啥栈是反向的
在计算机刚发明时，有栈和堆两种类型的内存，堆从小到大增长，栈从大到小增长。

### 1.7.2 栈的用处
#### 保存返回地址
在x86架构下，当使用 `call` 指令调用另一个函数时，在 `call`之后的地址保存在栈，然后跳转到`call`对应的操作值。

`call` 指令等价于：`push address_after_call / jmp operand_address`。

`RET` 从栈获取值，然后跳转到对应的地址。`RET`指令等价于：`pop tmp / jmp tmp`。

#### 传递函数参数
在x86架构传递参数最流行的方式称作“cdecl”：
```asm
push arg3
push arg2
push arg1
call f
add esp, 12     ; 4*3=12
```

被调用函数通过栈指针获取参数。函数`f()` 的栈结构如下：

| 栈地址  | 内容                                |
| :------ | :---------------------------------- |
| ESP     | return address                      |
| ESP+4   | argument#1, markded in IDA as arg_0 |
| ESP+8   | argument#2, markded in IDA as arg_4 |
| ESP+0xC | argument#3, markded in IDA as arg_8 |
| ...     | ...                                 |

被调用函数没有被传递参数的个数信息。类似`printf()`函数通过 *%* 来获取参数个数。

传递参数还可以使用全局变量，但是在递归调用时，每层的调用，都需要独立参数。并且不是线程安全的。

#### 局部变量存储
函数通过让栈指针向栈底方向减少即可为局部变量分配空间。函数`alloca()` 在栈上分配空间，不需要调用`free`释放。

#### 1.7.3 栈的典型布局
在32-bit环境中，在函数开头在第一条指令运行前，栈结构如下：

| 栈地址  | 内容                                     |
| :------ | :--------------------------------------- |
| ...     | ...                                      |
| ESP-0xC | local variable#2, marked in IDA as var_8 |
| ESP-8   | local variable#1, marked in IDA as var_4 |
| ESP-4   | saved value of EBP                       |
| ESP     | return address                           |
| ESP+4   | argument#1, markded in IDA as arg_0      |
| ESP+8   | argument#2, markded in IDA as arg_4      |
| ESP+0xC | argument#3, markded in IDA as arg_8      |
| ...     | ...                                      |


## 1.8 printf() 多参数
带参数*Hello, World!* 程序：
```C++
#include <stdio.h>

int main()
{
    printf("a=%d; b=%d; c=%d", 1, 2, 3);
    return 0;
}
```

函数调用总结：

### x86
```asm
...
PUSH 3rd argument
PUSH 2nd argument
PUSH 1st argument
CALL function
; modify stack pointer (if needed)
```

### x64(MSVC)
```asm
MOV RCX, 1st argument
MOV RDX, 2nd argument
MOV R8, 3rd argument
MOV R9, 4th argument
...
PUSH 5th, 6th argument, etc. (if needed)
CALL function
; modify stack pointer (if needed)
```

### x64(GCC)
```asm
MOV RDI, 1st argument
MOV RSI, 2nd argument
MOV RDX, 3rd argument
MOV RCX, 4th argument
MOV R8, 5th argument
MOV R9, 6th argument
...
PUSH 7th, 8th argument, ect. (if need)
CALL function
; modify stack pointer (if needed)
```

## 1.9 scanf()
scanf 程序
```C++
#include <stdio.h>

int main()
{
    int x;
    printf("Enter X:\n");
    scanf("%d", &x);
    printf("You entered %d...\n", x);
    return 0;
}
```

### 关于指针
* 当大的数组，结构体，对象做为另一个函数的参数通过拷贝传递效率太低，如果传递地址在通过地址访问内容则简单高效
* 如果被调用函数需要修改参数，在将这些参数返回，如果通过拷贝来实现，就是非常低效的做法
* 在C/C++里指针是内存地址，x86 内存地址占用32-bit，x86-64 占用64-bit
* 指针类型只是在编译阶段用来检查代码操作是否合法，编译后的代码没有指针类型信息


### x86 MSVC
```asm
_DATA SEGMENT
$SG4502 DB 'Enter x:', 0aH, 00H
$SG4503 DB '%d', 00H
$SG4504 DB 'You entered:%d', 0aH, 00H
_DATA ENDS

_x$ = -4 ; size = 4
_main PROC
    push eb
    mov ebp, esp
    push ecx                                ; 为局部变量分配空间
    push OFFSET $SG4502                     ; 压入printf 第一个参数字符串地址
    call _printf
    add esp, 4                              ; 释放_printf 参数占用的空间
    lea eax, DWORD PTR _x$[ebp]             ; 将 [ebp + _$x] 的值(x的地址)存入eax
    push eax                                ; 将 x 的地址放入栈
    push OFFSET $SG4503                     ; 将 scanf 用的首个字符串参数放入栈
    call _scanf                     
    add esp, 8                              ; 释放scanf 调用使用的两个参数空间
    mov ecx, DWORD PTR _x$[ebp]             ; 将x对应地址内容移入ecx
    push ecx                                ; 将ecx 压入栈
    push OFFSET $SG4504                     ; 将_printf 需要的第二个参数压入栈
    call _printf                            
    add esp, 8                              ; 释放_printf 参数占用空间
    xor eax, eax
    mov esp, ebp
    pop ebp
    ret 0
_main ENDP
```
### 全局变量
#### MSVC

* 未初始化全局变量不分配内存，在代码里标记为未初始化，当程序运行到相关位置，为变量分配内存
* 对于全局初始化变量，直接在data 段分配内存

#### gcc
gcc 和 MSVC 策略一致，在存储段名字有区别

* 未初始化变量在 `_bss` 段
* 初始化变量在 `_data` 段 


## 1.10 访问传递参数
调用函数通过栈传递参数，被调用函数在x86 32 使用栈访问参数，64位根据不同编译器不同，首先通过固定数量寄存器传递参数，剩余的使用栈传递。


## 1.11 关于更多的函数返回值
x86 函数执行结果存储在 EAX 寄存器。

* 如果是byte类型或char类型，寄存器最低部分EAX(AL)保存。
* 如果是float 类型，FPU寄存器 ST(0)来保存
* 如果是多个变量，可以通过结构体，或数组传递

## 1.12 指针
* 用来通过函数修改变量
* 返回多个变量

## 1.13 GOTO 操作符
汇编层相当于无条件跳转。

## 1.14 条件跳转
x86 条件跳转
```asm
CMP register, register/value
Jcc true ; cc=condition code
false:
... some code to be executed if comparison result is false ...
JMP exit
true:
... some code to be executed if comparison result is true ...
exit:
```

## 1.15 switch/case/default
x86 switch 跳转
```asm
MOV REG, input
CMP REG, 4 ; maximal number of cases
JA default
SHL REG, 2 ; find element in table. shift for 3 bits in x64.
MOV REG, jump_table[REG]
JMP REG

case1:
    ; do something
    JMP exit
case2:
    ; do something
    JMP exit
case3:
    ; do something
    JMP exit
case4:
    ; do something
    JMP exit
case5:
    ; do something
    JMP exit
default:
    ...
exit:
    ....
jump_table  dd case1
            dd case2
            dd case3
            dd case4
            dd case5
```
## 1.16 循环
循环整数范围2-9，程序框架如下：

```asm
    mov [counter], 2 ; initialization
    jmp check
body:
    ; loop body
    ; do something here
    ; use counter variable in local stack
    add [counter], 1 ; increment
check:
    cmp [counter], 9
    jle body
```

在非优化代码里：
```asm
    MOV [counter], 2 ; initialization
    JMP check
body:
    ; loop body
    ; do something here
    ; use counter variable in local stack
    MOV REG, [counter] ; increment
    INC REG
    MOV [counter], REG
check:
    CMP [counter], 9
    JLE body
```
## 1.17 深入字符串
字符串使用`/0` 结尾，通过此特性来取得字符串长度，或分割字符串，当然使用其他特殊符号也可以分割字符串。

## 1.18 使用其他指令替换运算指令
在追求极致优化时，一个指令可能被另一个指令代替或一组指令代替。例如 `ADD` 和 `SUB` 可以相互替换。

### 1.18.1 乘法
* 很小的乘数可以使用加法替代，比如乘 2，可以使用两次加法代替
* 对于 2^n 可以使用向左移 n 次代替
* 还可以使用 移位，减法，加法组合


### 1.18.2 除法
* 使用右移代替除法
  
## 1.19 浮点运算单元
浮点运算单元有自己的处理器 FPU，使用环形栈寄存器。所有运算在浮点寄存器之间发生。

## 1.20 数组
数组是相同类型变量，内存里连在一起的变量。

访问数组元素就是计算元素所在地址。

## 1.21 顺路一提
指向数组的指针和首个元素的地址是同一回事。

## 1.22 位操作
类似于 C/C++的移位操作 `<<` 或 `>>`，x86的移位指令为`SHR/SHL`(无符号)以及`SAR、SHL`(有符号)

### 检测指定位(编译阶段)
检测 0b1000000 bit(0x40) 是否在寄存器中：
```C++
if (input&0x40)
    ...
```

```asm
TEST REG, 40h
JNZ is_set
; bit is not set
```

### 检测指定位(运行时)
将第 n 位 移动到最右边，然后和 1 求和操作
```C++
if ((value>>n)&1)
    ...
```

```asm
; REG = input_value
; CL = n
SHR REG, CL
AND REG, 1
```

或者将 1 左移 n 位，然后和 输入值求和
```C++
if (value & (1<<n))
    ...
```

```asm
; CL = n
MOV REG, 1
SHL REG, CL
ADN input_value, REG
```

### 设置指定位(编译时)
```C++
value = value | 0x40;
```

```asm
OR REG, 40h
```
### 设置指定位(运行时)
```C++
value = value | (1<<n);
```

```asm
; CL = n
MOV REG, 1
SHL REG, CL
OR input_value, REG
```
### 清除指定位(编译时)
```C++
value = value & (-0x40);
```

```asm
AND REG, 0FFFFFFBFh
```
### 清除指定位(运行时)
```C++
value = value & (~(1<<n))
```

```asm
; CL = n
MOV REG, 1
SHL REG, CL
NOT REG
AND input_value, REG
```
## 1.23 线性随机器
线性随机函数：
```C++
#include <stdint.h>

#define RNG_a 1664525
#define RNG_c 1013904223

static uint32_t rand_state;

void my_srand(uint32_t init)
{
    rand_state = init;
}

int my_rand()
{
    rand_state = rand_state * RNG_a;
    rand_state = rand_state + RNG_c;
    return rand_state & 0x7fff;
}
```
## 1.24 结构体
C/C++ 结构体是一组存在一起的可以为不同类型的变量。

结构体作为函数参数传递，本质是每个成员变量独立传递，或者是结构体展开传递。

结构体的占用内存空间，分两种情况：
* 默认是内存对齐，cpu 访问内存都是按照内存对齐方式访问
* 使用编译命令参数，或宏可以指定对齐方式，但是在 索尼的 ps硬件架构如果结构体不是内存对齐，程序将直接crash

结构体包含的结构体本质上还是一段内存，包含不同变量。

## 1.25 联合体
通过不同的变量类型读取同一个变量或内存内容。

## 1.26 FSCALE 浮点计算hack 
直接通过修改浮点数指数位来达到运算 `2^n`目的

## 1.27 函数指针
函数指针即为函数地址变量。

## 1.28 32-bit 环境下的 64位值
在32-bit环境，通用寄存器是32-bit，因此64-bit值通过一对 32-bit 变量来传递。

以下几种情形都为 32-bit 环境 64位值情况
* 64-bit 返回值通过 EDX:EAX 来存储
* 参数传递，通过32位传递，先高位，在低位
* 运算有对应的指令来协助完成，比如 `adc, shrd`
* 32bit 转换为 64-bit，先移动低位，然后使用 `cdq` 处理符号位
## 1.29 SIMD
Single Instruction, Multiple Data(SIMD)，一条指令，处理多个数据。

* SIMD 从x86 开始使用 MMX，新的8个 64-bit 寄存器：MM0-MM7，存放在 FPU中
* SSE 是 SIMD寄存器扩展到 128 bits，从FPU 分离出
* AVX SIMD的另一个扩展，256 bits

## 1.30 64 bits
### x86-64
从反编译工程师角度来看，最重要的变化如下：

* 几乎所有的寄存器（除了 FPU 和 SIMD）扩展到64位并且使用 **R** 前缀。
* 8 个额外的寄存器被添加。现在通用寄存器是：`RAX, RBX, RCX, RDX, RBP, RSP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15`。
* 依然可以访问旧的寄存器
* 新的 R8-R15 寄存器 有自己的低位寄存器：R8D-R15D(32-bit 部分),R8W-R15W(16-bit 部分)，R8L-R15L(8-bit 部分)
* Win 64， 函数调用不同，前四个参数存储在 `RCX, RDX, R8, R9` 中
* System V AMD64 ABI 使用 6个寄存器 `RDI, RSI, RDX, RCX, R8, R9`
* C/C++ int 类型依然是 32-bit
* 所有的指针为 64-bit


## 1.31 使用SIMD操作浮点数
只有XMM寄存器的低半部被使用来计算存储 IEEE 754 格式。所有的指令使用后缀 **SD**(Scalar Double-Precision)来计算浮点值。

使用SIMD 和 FPU 区别是：运算更加直观，不需要使用堆模型来计算。

如果想使用 *float* 来计算，只需要使用同样的指令，后缀修改为 **SS**(Scalar Single-Precision)。
## 1.32 ARM特殊细节

## 1.33 MIP 特殊细节