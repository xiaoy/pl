# Chapter 4: 数据转移，寻址，运算
本章主要介绍转移数据和运算指令。大部分内容介绍基本寻址模式，例如直接寻址，立刻寻址，间接寻址，通过寻址来处理数组。深入下去后，将展示如何创建循环，以及一些基础操作符，列如 **OFFSET, PTR, LENGTHOF**。

## 4.1 数据转移指令
### 4.1.1 简介
当使用类似于 Java 和 C++ 的编程语言，编译器有严格的语法类型检查防止开发者犯错，比如变量和数据的错误匹配。相反的汇编语言允许你通过执行处理器指令做任何你想做的事情。换句话说，汇编语言强制你注意数据存储和机器相关的细节。当编写汇编语言时，必须清楚处理器的限制。事实上，X86处理器有出名的*复杂指令集(complex instruction set)*，提供了非常多的做事方式。

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

### 4.1.5 Zero/Sign 整数扩展
`MOV`命令不能直接拷贝小的操作数到大的操作数。但是可以通过先将目标大的操作数初始化为零，或者为一。然后再修改目标寄存器的低位数据即可。

```asm
.data
count WORD 1
signedVal SWORD -16
.code
mov ecx, 0
mov cx, count       ; ecx = 00000001h

; 负数的时候值不对
mov ecx, 0
mov cx, signedVal   ; ecx = 0000FFF0h (+65,520)

; 需要初始化为1
mov ecx, 0FFFFFFFh
mov cx, signedVal   ; ecx = FFFFFFF0h (-16)
```

`MOVZX(move with zero-extend)` 指令拷贝源数据到目标数据使用零补齐16-bit或32-bit操作数。此指令只用在无符号整型。三种情况：
> MOVZX reg32, reg/mem8  
> MOVZX reg32, reg/mem16  
> movzx reg16, reg/mem8

`MOVSX(move with sign-extend)`指令拷贝源操作数到目标操作数使用符号位（sign-extends）补齐16-bit或32-bit操作数。此指令只用在有符号整型。三种情况：
> movsx reg32, reg/mem8  
> movsx reg32, reg/mem16  
> movsx reg16, reg/mem8

### 4.1.6 LAHF和SAHF指令
`LAHF(load status flags into AH)`指令拷贝EFLAGS寄存器低字节到`AH`，标志位：Sign，Zero，Auxiliary Carry， Parity，Carry 被拷贝到`AH`。

`SAHF(store AH into status flags)`指令拷贝`AH`数据到EFLAGS低字节。

### 4.17 XCHG 指令
`XCHG(exchange data)`指令交换两个操作数的内容。三种情况：
> XCHG reg, reg  
> XCHG reg, mem  
> XCHG mem, reg

`XCHG` 和 `MOV`指令遵循一样的规则。
### 4.18 直接偏移（Direct-Offset）操作数
给变量名添加位移，创建直接偏移变量。本质上是变量名字是内存地址，添加偏移量对应访问偏移量内存地址。`mov`指令是将对应内存地址的数据拷贝到寄存器，因此变量加偏移量可以选择加方括号（[])，但是方括号可以清晰说明取对应地址的值。偏移量的单位是`Byte`，因此不同类型的变量偏移量不同。例子如下：
```asm
.data
    arrayB BYTE 10h, 20h, 30h, 40h, 50h
.code
    mov al, arrayB          ; al = 10h
    mov al, [arrayB + 1]    ; al = 20h
    mov al, [arrayB + 2]    ; al = 30h
```
需要注意的是，汇编器不会对越界访问检查，所以需要开发者自己检测引用在范围内。

### 4.1.9 示例程序
CPU 标志位和Visual Studio Debugger 对应如下：

| Flag Name | Overflow | Direction | Interrupt | Sign  | Zero  | Aux Carry | Parity | Carry |
| :-------: | :------: | :-------: | :-------: | :---: | :---: | :-------: | :----: | :---: |
|  Symbol   |    OV    |    UP     |    EI     |  PL   |  ZR   |    AC     |   PE   |  CY   |

## 4.2 加法和减法
### 4.2.1 INC 和 DEC 指令
`INC(increment)` 和 `DEC(decrement)` 指令，分别让寄存器或内存加一和减一。语法如下:

> INC reg/mem  
> DEC reg/mem

标志位`Overflow，Sign，Zero，Auxiliary Carry，Parity flags` 会根据目标操作数的值改变。`Carry flag` 不受影响。

### 4.2.2 ADD 指令
`ADD`指令将源操作数加到同一长度的目标操作数，语法如下：

> ADD dest, source

*source* 不变，加法的结果存储在目标操作数。`ADD`的操作数规则和`MOV`相同。

标志位`Carry, Overflow，Sign，Zero，Auxiliary Carry，Parity flags` 会根据目标操作数的值改变。

### 4.2.3 SUB 指令
`SUB`指令从目标操作数减去同一长度的源操作数，其操作数规则和`MOV`相同。语法如下：

> SUB dest, source

标志位`Carry, Overflow，Sign，Zero，Auxiliary Carry，Parity flags` 会根据目标操作数的值改变。

### 4.2.4 NEG指令
`NEG`指令通过将数字转换为其二进制补码来反转数字符号。语法如下：

> NEG reg  
> NEG mem

标志位`Carry, Overflow，Sign，Zero，Auxiliary Carry，Parity flags` 会根据目标操作数的值改变。

### 4.2.5 实现算数运算表达式
表达式为：
> Rval = -Xval + (Yval -Zval)

汇编实现如下：
```asm
.data
Rval SWORD ?
Xval SWORD 26
Yval SWORD 30
Zval SWORD 40

.code
; -Xval
mov eax, Xval
neg eax

; Yval - Zval
mov ebx, Yval
sub ebx, Zval

; Rval = -Xval + (Yval - Zval)
add eax, ebx
mov Zval, eax
```

### 4.2.6 被加法和减法影响的标志位
通过CPU状态码来检查运算结果，状态码说明如下：

* `Carray` 标志位指示无符号整数溢出。例如操作数目标为8-bit操作数，但运算结果大于 1111111，此标志位被设置
* `Overflow` 标志位指示有符号整数溢出
* `Zero` 标志位指示操作结果为零
* `Sign` 标志位指示操作结果为负数，最高有效位被置为一，则标志位被设置
* `Parity` 标志位指示是否在目标操作数最低有效BYTE有偶数个一
* `Auxiliary Carray` 当最低有效BYTE的从第三位借位或进位，此标志位被设置

#### 无符号操作：Zero, Carry, Auxiliary Carray
```asm
; zero flag
;   0 0 0 0 0 0 0 1
; - 0 0 0 0 0 0 0 1
;-------------------
;   0 0 0 0 0 0 0 0 
mov ecx, 1
sub ecx, 1                      ; ecx = 0, zf = 1

; 加法 carry flag
;   1 1 1 1 1 1 1 1
; + 0 0 0 0 0 0 0 1
;-------------------
; 1 0 0 0 0 0 0 0 0
mov al, 0FFh
add al, 1                       ; al = 00, cf = 1

; 减法 carry flag
;   0 0 0 0 0 0 0 1     (1)
; + 1 1 1 1 1 1 1 0     (-2)
;-------------------
; 1 1 1 1 1 1 1 1 1
mov al, 1
sub al, 2                       ; al = FFh, cf = 1

; auxiliary carry flag
;   0 0 0 0 1 1 1 1
; + 0 0 0 0 0 0 0 1
;-------------------
;   0 0 0 1 0 0 0 0
mov al, 0Fh
add al, 1                       ; ac = 1

; parity
;   1 0 0 0 1 1 0 0
; + 0 0 0 0 0 0 1 0
;-------------------
;   1 0 0 0 1 1 1 0
mov al, 10001100
add al, 00000010                ; al = 1000110, pf = 1
```

#### 有符号操作：Sign and Overflow Flags
```asm
; sign flag
;   0 0 0 0 0 1 0 0
; - 0 0 0 0 0 1 0 1
;-------------------
;   1 1 1 1 1 1 1 1
mov al, 4
sub al, 5                      ; al = - 1, sf = 1

; overflow flag，两个正数相加为负数，两个负数相加为正数，溢出
; 硬件通过进位和最高位进行异或操作来设置 overflow flag
;   0 1 1 1 1 1 1 1
; + 0 0 0 0 0 0 0 1
;-------------------
;   1 0 0 0 0 0 0 0
mov al, +127
add al, 1                       ; OF = 1

; neg 指令
mov al, -128                ; al = 10000000b
neg al                      ; al = 10000000b, of = 1
```
CPU不识别是否为有符号整数，只对二进制数进行运算操作，最后根据系列逻辑布尔规则，得到最后的标志位。所以需要开发者自己根据需求使用标志位和运算结果。

## 4.3 数据相关操作符和指令
操作符和指示符不是可执行指令，协助汇编器获得地址以及数组长度。

 * **OFFSET** 操作符返回变量数据闭合段的步长
 * **PTR** 操作符重载操作数默认长度
 * **TYPE** 返回操作数的长度（bytes）或数组元素长度
 * **LENGTHOF** 操作符返回数组元素个数
 * **SIEOF** 操作符返回数组初始化长度（bytes)
 * **LABEL** 指示符重定义变量长度属性

### 4.3.1 OFFSET 操作符
```asms
.data
bVal BYTE ?
myArray WORD 1, 2, 3, 4, 5
bigArray DWORD 500 DUP(?)
pArray DWORD bigArray

.code
mov esi, OFFSET bVal            ; 返回地址
mov esi, offset myArray + 4     ; 返回第三个变量地址
mov esi, pArray                 ; pArray 指向 bigArray
```

### 4.3.2 ALIGN 指示符
**ALIGN** 指示符将变量对齐到 `byte, word, doubleword`或段落边界。语法如下：

>  ALIGN bound

因为CPU处理偶数倍地址的数据需要时钟周期少于基数倍地址。[参考](https://developer.ibm.com/articles/pa-dalign/)

### 4.3.3 PTR 操作符
配合类型重新制定变量读取大小。
```asm
.data
myDouble DWORD 12345678h
wordList WORD 5678h, 1234h

.code
mov ax, WORD PTR myDouble       ; ax = 5678h
mov ax, WORD PTR [myDouble + 2] ; ax = 1234h

mov eax, DWORD PTR wordList     ; eax = 12345678h
```

### 4.3.4 TYPE 操作符
返回操作数长度，或数组元素长度。
```asm
.data
var1 BYTE ?     ; type var1 == 1
var2 WORD ?     ; type var2 == 2
var3 DWORD ?    ; type var3 == 4
var4 QWORD ?    ; type var4 == 8
```

### 4.3.5 LENGTHOF 操作符
返回同一行数组元素个数。
```asm
.data
byte1       BYTE    10, 20, 30          ; lengthof byte1    == 3
array1      WORD    30 DUP(?), 0, 0     ; lengthof array1   == 30 + 2
array2      WORD    5 DUP(3 DUP(?))     ; lengthof array2   == 5 * 3
array3      DWORD   1, 2, 3, 4          ; lengthof array3   == 4
digitStr    BYTE    "12345678",0        ; lengthof digitStr == 9
myArray     BYTE    10, 20, 30, 40, 50  ; lengthof myArray  == 5
            BYTE    60, 70, 80, 90, 100
```

### 4.3.6 SIZEOF 操作符
返回变量的`LENGTHOF` 乘 `TYPE`。
```asm
.data
intArray WORD 32 DUP(0)         ; sizeof intArray == 64
```

### 4.3.7 LABEL 指示符
在插入`LABEL`的地方，申明对应长度的变量，不占用内存空间。
```asm
.data
val16   LABEL WORD
val32   DWORD 12345678h

.code
mov ax, val16               ; AX = 5678h
mov dx, [val16 + 2]         ; DX = 1234h
```
## 4.4 间接寻址
使用直接寻址的方式操作数组不灵活，使用寄存器记录变量地址，通过修改寄存器的值来操作变量的方式称作间接寻址。

### 4.4.1 间接操作值
保护模式下，32-bit常用寄存器（EAX，EBX，ECX，EDX，ESI，EDI，EBP，ESP）包围在中括号中为间接操作值。

```asm
.data
byteVal BYTE 10h
.code
mov esi, OFFSET byteVal
mov al, [esi]               ; AL = 10h
mov bl, 20h
mov [esi], bl               ; byteVal = 20h
```

当汇编器不能需要操作数长度信息时，可以使用 `PTR`指定， 比如：

```asm
.data
byteVal BYTE 10h
.code
mov esi, OFFSET byteVal
inc BYTE PTR [esi]          ; 指示长度为byte
```

### 4.4.2 数组
间接操作值是遍历数组的理想工具。

```asm
.data
arrayB BYTE 10h, 20h, 30h
.code
mov esi, OFFSET arrayB
mov al, [esi]                   ; AL = 10h
inc esi
mov al, [esi]                   ; AL = 20h
inc esi
mov al, [esi]                   ; AL = 30h
```

### 4.4.4 索引操作数（Indexed Operands）
通过寄存器加上一个常量来寻址的方式称作索引操作数。MASM两种方式：

> constant[reg]         ; 方式1
> [constant + reg]      ; 方式2

方式一通过汇编器将变量地址作为constant来寻址：

```asm
.data
arrayB BYTE 10h, 20h, 30h
.code
mov esi, 0
mov al, arrayB[esi]         ; AL = 10h
```

方式二通过寄存器获取变量地址在加上常量来寻址：

```asm
.data
arrayW  WORD 1000h, 2000h, 3000h
.code
mov esi, OFFSET arrayW
mov ax, [esi]           ; AX = 1000h
mov ax, [esi + 2]       ; AX = 2000h
mov ax, [esi + 4]       ; AX = 3000h
```

在实地址模式下使用16-bit集群器当做索引操作数，只可以使用 `SI,DI,BX,BP`，并且`BP`用在寻址栈上变量时使用。

在索引数组变量时，通过变量长度和索引值来计算步长。结合 `TYPE` 计算更加灵活。

```asm
.data
arrayD DWORD 1, 2, 3, 4
.code
mov esi, 3
mov eax, arrayD[esi * 4]                ; EAX = 4

mov eax, arrayD[esi * TYPE arrayD]      ; 更加灵活 
```

### 4.4.4 指针
保存另一个变量地址的变量称作*指针* 。指针变量有两种申明方式：

```asm
.data
arrayB BYTE     10h, 20h, 30h, 40h
arrayW WORD     1000h, 2000h, 3000h
ptrB   DWORD    arrayB                  ; 方式1
ptrW   DWROD    OFFSET arrayW           ; 方式2
```

#### 使用 `TYPEDEF`操作符
**TYPEDEF** 操作符用来创建用户自定义类型。**TYPEDEF** 是理想的创建指针变量的工具。

```asm
PBTYE TYPEDEF PTR BYTE

.data
arrayB BYTE 10h, 20h, 30h, 40h
ptr1 PBYTE ?                        ; 未初始化
ptr2 PBTYE arrayB                   ; 指向数组
```

## 4.5 跳转和循环指令
通常CPU顺序加载执行指令，转移控制或者分支的方法来改变语句执行的顺序，两种基本方法：

* 无条件跳转，使用`JMP`命令直接跳转到对应地址
* 条件跳转，达到相应条件，跳转到对应地址

### 4.5.1 JMP 指令
JMP 指令无条件跳转到目标地址，语法如下：

> JMP destination

JMP指令的原理是将目标地址移动到指令寄存器，当下调指令执行时，即可执行到对应位置

### 4.5.2 LOOP 指令
LOOP 指令根据ECX计数器来循环，ECX自动作为计数器每次循环减1，语法如下：

> LOOP desination

循环目标地址必须在当前地址的 -128到127 bytes范围内，执行LOOP分两个步骤：

* ECX减一
* 判断ECX不等于0，继续循环，如果为0，执行循环的下一跳指令

如果循环套循环，需要自己先存储ECX的值，等执行完嵌入的循环后，在将ECX还原。

### 4.5.3 在Visual Studio Debugger显示数组
在debugging状态时，通过窗口按钮 Debug->Windows->Memory->Memory 1，在memory的窗口输入：`&arrName`来显示数组内容，arrName 为数组名字。

### 4.5.4 数组求和
汇编数组加法思路为：

1. 计数器赋值为数组长度
2. 数组索引赋值为0
3. 数组总和赋值为0
4. 创建循环标签
5. 标签内容为从第n个数组元素加入数组总和
6. 调用循环标签

[代码](SumArray.asm)

### 4.5.5 拷贝字符串
源字符串和目标字符串长度需要一致，因为mov 只有两个操作符，所以需要先将源字符转移到寄存器，再从寄存器转移到目标字符串

## 4.6 64-bit编程
### 4.6.1 MOV 指令
`MOV`指令64位和32位大致相同，有如下区别：

* 源操作数为8-bit,16-bit,32-bit立即数转移到64-bit寄存器，到会导致未修改位清零
* 源操作数为32-bit内存变量转移到64-bit寄存器，未修改位清零。但是8-bit和16-bit只修改对应位
* `MOVSXD`允许源操作数为32-bit寄存器或内存操作数
* `OFFSET`操作符生成64-bit地址
* `LOOP`指令使用RCX做为计数器

### 4.6.2 64-bit 版本SumArray
[代码](SumArray64.asm)

### 4.6.3 加法和减法
寄存器的操作只涉及自己长度的位，不会改变超出自己范围的位。
```asm
mov rax, 0FFFFFFFFh             ; fill lower 32 bit
add rax, 1                      ; rax = 10000000h

mov rax, 0FFFFh                 ; rax = 000000000000FFFF
mov bx, 1
add ax, bx                      ; RAX = 000000000000000

mov rax, 0FFh                   ; RAX = 000000000000FF
mov bl, 1
add al, bl                      ; RAX = 00000000000000
```