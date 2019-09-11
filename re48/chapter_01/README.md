# chapter 01:代码模式
## 1.1 方法
作者学习C语言，以及后面的C++时，先写小片代码，编译之后查看汇编代码。这种方法让他很容易的理解自己所写代码运行原理。当前可以使用[godbolt](https://godbolt.org/)来在线汇编代码。

### 练习
作者在学习汇编语言时，经常将C语言函数编译为汇编，然后自己使用汇编语言重写函数，重写时使用最少的代码来实现。当前编译器的优化已经非常棒了，但是如果想加强自己的汇编能力，可以自己将C语言函数转换为汇编，然后和编译器汇编结果对比。

### 优化等级和调试信息
源码可以被不同的编译器通过不同等级优化来编译。典型编译器有三个等级：

1. 等级零优化意味着优化全关
2. 下一等级的优化结果将会包含一些调试信息，重要特性是机器码可以对应到相关源代码
3. 最高等级的优化可能将源码从结果中去除


## 1.2 基础
### 1.2.1 CPU 简介
#### 一些概念
* **指令**：CPU 基础命令，每种CPU都自己的指令集架构(instruction set architecture-ISA)
* **机器码**：CPU 直接执行的代码。每个指令由几个字节编码
* **汇编代码**：助记码和一些扩展，相比机器编码简单一些
* **CPU 寄存器**：每个CPU都有固定个数的寄存器。寄存器可以认为是编程里的零时变量

#### 不同指令集架构
* x86 ISA 是可变长度指令，所以当64-bit出来时，不影响旧的指令集
* ARM 是精简指令CPU设计，使用固定长度指令，过去有一些优点，ARM有如下三种指令集
  * 开始所有的ARM指令编码为4字节长度，称作 “ARM Mode”
  * 后面发现可以使用更少的字节编码，因此添加了另外一个称作“Thumb Mode”指令集，使用2字节编码，当ARMv7出来时，发现2字节编码不够了，所以有些指令使用4字节编码，称作“Thumb-2”，2字节和4字节编码都存在，合称“Thumb mode”
  * 当ARM64出来时，使用4字节编码，称作“ARM64”


## 1.3 空函数
最简单的函数可能就是啥事不做的函数
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

/$2 (or /$V0) 寄存器用来存储函数返回值。`LI` 代表 "Load Immediate"，等价 `MOV`。

另外的指令是跳转指令(J or JR)返回到调用地址。

跳转指令在拷贝指令前，但RISC的特性“branch delay slot”，在跳转后的指令优先执行。

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

/Fa 开关让编译器生成汇编 listing文件

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

GCC，编译后 使用 IDA打开结果如下：

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
## 1.6  函数前戏和后戏(Function prologue and epilogue)

## 1.7 栈

## 1.8 printf() 多参数

## 1.9 scanf()

## 1.10 访问传递参数

## 1.11 关于更多的函数返回值

## 1.12 指针

## 1.13 GOTO 操作符

## 1.14 条件跳转

## 1.15 switch/case/default

## 1.16 循环

## 1.17 深入字符串

## 1.18 使用其他指令替换运算指令

## 1.19 浮点运算单元

## 1.20 数组

## 1.21 顺路一提

## 1.22 操作指定位

## 1.23 线性随机器

## 1.24 结构体

## 1.25 联合体

## 1.26 FSCALE 替换

## 1.27 函数指针

## 1.28 32-bit 环境下的 64位值

## 1.29 SIMD

## 1.30 64 bits

## 1.31 使用SIMD操作浮点数

## 1.32 ARM特殊细节

## 1.33 MIP 特殊细节