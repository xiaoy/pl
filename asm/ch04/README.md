# Chapter 4: 数据转移，寻址，运算
本章主要介绍转移数据和运算指令。大部分内容介绍基本寻址模式，例如直接寻址，立刻寻址，间接寻址，通过寻址来处理数组。深入下去后，将展示如何创建循环，以及一些基础操作符，列如 **OFFSET, PTR, LENGTHOF**。

## 4.1 数据转移指令
### 4.1.1 简介
当使用类似于 Java 和 C++ 的编程语言，编译器有严格的语法类型检查防止开发者犯错，比如变量和数据的错误匹配。相反的汇编语言允许你通过执行处理器指令做任何你想做的事情。换句话说，汇编语言强制你注意数据存储和机器相关的细节。当编写汇编语言时，必须清楚处理的限制。事实上，X86处理器有出名的*复杂指令集(complex instruction set)*，提供了非常多的做事方式。

如果细心学习本章内容，本书剩余内容学习起来会平滑很多。随着程序例子的变的复杂，都要依靠本章的掌握的基本工具。

### 4.1.2 操作类型
X86 指令格式：
> [label:] menmonic [operands] [ ; comment]

指令有零，一，二 或三个操作值，这里为了清除，忽略label和comment：
> mnemonic  
> mnemonic [destination]  
> mnemonic [destination], [source]  
> mnemonic [destination], [source-1], [source-2]

这里有三种类型的操作数：

* 立即数：使用数字或字符表达式
* 寄存器：使用CPU的寄存器
* 内存：引用内存地址

### 4.1.3 直接内存操作数
变量名是数据在数据段的偏移量引用。
```asm
.data
var1 BYTE 10h

.code
mov al, var1       ; 使用指令解引用地址内容，将var1的值拷贝到al

; 假设var1的所在位置的步长为 10400h，翻译为机器码后
A0 00010400
; A0为操作码，00010400 为偏移量
```

### 4.1.4 MOV 指令
`MOV` 指令拷贝源操作数到目标操作数。首个操作数为目标，第二个为源：
> MOV destination, source

使用规则如下：

* 两个操作数的长度必须相同
* 两个操作数不能裙式内存操作数
* 指令指针寄存器（IP，EIP，RIP）不能为目标操作数

一下入标准`MOV`指令格式：
> MOV reg, reg  
> MOV mem, reg  
> MOV reg, mem 
> MOV mem, imm 
> MOV reg, imm

内存到内存可以使用寄存器到中间变量。

#### 覆盖值
通过改写寄存器不同部分的值来修改32位寄存器值，例子如下：
```asm
.data
oneByte BYTE 78h
oneWord WORD 1234h
oneDword DWORD 12345678h

.code
mov eax, 0              ; EAX = 00000000h
mov al, oneByte         ; EAX = 00000078h 
mov ax, oneWord         ; EAX = 00001234h
mov eax, oneDword       ; EAX = 12345678h
mov ax, 0               ; EAX = 00000000h
```
## 4.2 加法和减法

## 4.3 数据相关操作符和指令

## 4.4 间接寻址

## 4.5 跳转和循环指令

## 4.6 64-bit编程