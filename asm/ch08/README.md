# Chapter 08: 高级函数
## 8.1 简介
这章主要介绍函数调用底层，重点在运行时堆栈方面。这章对于C和C++程序员非常有价值，他们通常在调试操作系统或驱动底层函数式必须查看堆栈上的信息。

大多数现代语言在调用函数之前将参数压在栈上。函数通常将局部变量也存储在栈上。研究相关细节对于学习C++和Java非常有帮助。我们将展示参数如何通过引用传递，局部变量如何创建和销毁，以及递归如何实现。本章未，将解释不同的内存模型以及MASM使用的语言相关指令。参数也可以通过寄存器和栈一起传递。这是64-bit模式下的实例，微软创建的Microsoft x64 调用约定。

## 8.2 栈帧(Stack Frames)
### 8.2.1 栈参数
*stack frame(or activation record)* 是栈上的一块用来传递参数，函数返回地址，局部变量，和保存寄存器值。栈帧通过以下步骤创建：

  1. 传递参数，如果有，压入栈
  2. 函数被调用，导致函数的返回地址压入栈
  3. 当函数开始执行，EBP压在栈上
  4. EBP设置为ESP的值。从这点起，EBP作为函数的参数的基准索引
  5. 如果有局部变量，通过减少ESP的值来扩展空间
  6. 如果有寄存器需要保存，压入栈

栈帧的结构直接受程序的内存模型和参数传递方式相关。

### 8.2.2 寄存器参数的缺点

* 寄存器的数量有限
* 寄存器有特殊作用，比如ECX用来LOOP的循环计数
* 在使用寄存器时需要在使用前先保存，后续在复原，维护困难，容易出错

参数传递两种方式

*  值传递，将值压入栈
*  引用传递，将地址压入栈

### 8.2.3 访问栈参数
高等级语言在调用函数时有各种各样的初始化和访问参数的方式。我们将使用C和C++语言作为例子。步骤如下：

* *序言*(函数开始时)调用语句将EBP寄存器的值压入栈，然后让EBP指向栈顶
* 通常，需要保存的寄存器压入栈，然后在函数返回之前再恢复
* 函数结束时，*结语*调用语句将EBP恢复，然后 RET 指令返回到调用者之后的地址

AddTwo 例子，以下代码使用C语言，接收两个整数参数，返回他们的和：

```C
int AddTwo(int x, int y)
{
    return x + y;
}
```

当调用 `AddTwo(5, 6)` 堆栈如下：

![](res/AddTwoStack.png)

对应的汇编语言如下：

```asm
AddTwo PROC
    push ebp
    mov ebp, esp
AddTwo ENDP
```

使用EBP作为基准地址来访问两个参数，通常32-bit返回变量存储在EAX。以下为实现AddTwo函数完整代码：

```asm
AddTwo PROC
    push ebp
    mov ebp, esp
    mov eax, [ebp + 12]
    add eax, [ebp + 8]
    pop ebp
    ret
AddTwo ENDP
```

有的程序员喜欢使用常量符号来代替显示栈变量，让程序可读性更高。

```asm
y_param EQU [ebp + 12]
x_param EQU [ebp + 8]

AddTwo PROC
    push ebp
    mov ebp, esp
    mov eax, y_param 
    add eax, x_param 
    pop ebp
    ret
AddTwo ENDP
```

当程序调用完毕，返回后需要清除堆栈，将压入的参数释放掉，两个原因：

* 栈空间资源有限
* 如果在函数里调用函数，当返回上级函数时，ret 直接将当前栈顶的值返回，如果不清除栈中的参数，返回值是错误的值

### 8.2.4 32-bit 调用约定 (calling conventions)
在这部分呈现两种在Windows环境最常用的32-bit程序调用约定。

* C 语言创建的 *C 调用约定*，C语言用在Unix和Windows系统上
* *STDCALL调用约定*，描述调用 Windows API 接口的协议

#### C 调用约定
C 和 C++ 编程语言使用这种调用约定。函数参数被反向压入栈，这种方式用简单的方式解决了清理运行栈的问题：当调用一个函数后，只需使用ESP寄存器加上变量大小总和。以下为调用 `AddTwo(5, 6)` 例子：

```asm
Example PROC
    push 6
    push 5
    call AddTwo
    add esp, 8              ; remove arguments from the stack
    ret
Example ENDP
```

#### STDCALL 调用约定
通过给 `RET` 指令传递整数值来清除栈空间。本质原理都是让ESP加上对应的参数长度。

```asm
AddTwo PROC
    push ebp
    mov ebp, esp            ; base of stack frame
    mov eax, [ebp + 12]     ; second parameter
    add eax, [ebp + 8]      ; first parameter
    pop ebp
    ret 8                   ; clean up the stack
AddTwo ENDP
```

两者的区别：

* **STDCALL 调用约定**减少了调用函数的代码并确保调用函数后栈空间肯定被清除
* **C 调用约定** 可以定义可变参数函数，比如 C语言里的 `printf` 函数

#### 保存和恢复寄存器
使用 `POP` 和 `PUSH` 指令实现恢复和保存寄存器，注意的是在设置EBP为ESP值之后，这样的好处是参数的步长不变，最后在RET返回之前按照压入的逆序弹出。

### 8.2.5 局部变量
在高级语言里，在单个函数里变量的创建，使用和销毁称作*局部变量*。局部变量在运行栈上创建，通常在基准指针（EBP）下面。在汇编时不能初始化，在运行时初始化。

以下C++函数定义两个局部变量：
```C++
void MySub()
{
    int x = 10;
    int y = 20;
}
```

汇编代码对应如下：

```asm
MySub PROC
    push ebp
    mov ebp, esp
    sub esp, 8                  ; create locals
    mov DWORD PTR[ebp - 4], 10  ; x
    mov DWORD PTR[ebp - 8], 20  ; y
    mov esp, ebp                ; remove locals from stack
    pop ebp
    ret
MySub ENDP
```

需要注意的是由于函数内部为局部变量创建了空间，在函数退出之前，需要删除空间，不然 ESP指向的函数返回地址为局部变量地址。

也可以使用常量符号来让函数变的更加易读：

```asm
X_local EQU DWORD PTR[EBP - 4]
Y_local EQU DWORD PTR[EBP - 8]
MySub PROC
    push ebp
    mov ebp, esp
    sub esp, 8                  ; create locals
    mov X_local, 10             ; x
    mov Y_local, 20             ; y
    mov esp, ebp                ; remove locals from stack
    pop ebp
    ret
MySub ENDP
```
### 8.2.6 引用参数
将变量地址作为参数传递到函数里，然后通过访问参数变量值，再通过间接操作数修改变量值，这是引用传递的原理。

以下为 ArrayFill 函数例子：

```asm
ArrayFill proc
    push ebp 
    mov ebp, esp 
    pushad
    mov esi, [ebp + 12]
    mov ecx, [ebp + 8]
    cmp ecx, 0
    je L2
L1:
    mov eax, 1000
    call RandomRange
    mov [esi], ax
    add esi, type word 
    loop L1
L2:
    popad
    pop ebp
    ret 8
ArrayFill end
```
### 8.2.7 LEA 指令
`LEA` 指令返回间接变量的地址。因为间接变量包含一个或多个寄存器变量，因此他们的步长在运行时计算。

C++ 例子如下：

```C++
void makeArray()
{
    char myString[30];
    for(int i = 0; i < 30; i++)
        myString[i] = '*'; 
}
```

翻译为汇编为：

```asm
makeArray proc
    push ebp
    mov ebp, esp
    sub esp, 32                 ; myString is at EBP -30
    lea esi, [ebp - 30]         ; load address of MyString
    mov ecx, 30                 ; loop counter
L1:
    mov byte ptr[esi], '*'      ; fill one position
    inc esi                     ; move to next
    loop L1                     ; continue util ecx = 0
    add esp, 32                 ; remove the array (restore esp)
    pop ebp
    ret
makeArray endp
```
### 8.2.8 ENTER 和 LEAVE 指令
`ENTER` 指令自动为函数创建栈帧，它执行以下三个操作：

* 将EBP压入栈  (push ebp)
* 设置EBP为栈的基准值 (mov ebp, esp)
* 为局部变量保留空间 (sub esp, numbytes)

`ENTER` 有两个操作数：第一个参数是常量，用来申明为局部变量保留的空间大小。第二个参数用来申明函数的嵌套层级，语法如下：

> ENTER numbytes, nestinglevel

两个操作数都为立即数，*Numbytes* 总是为4的倍数，用来让ESP的值双字节对齐。*nestingLevel* 申明从调用函数的栈帧里拷贝的栈帧指针数量。在当前程序中总是为零。

  `LEAVE` 指令结束函数的栈帧。它反向执行 `ENTER` 指令来恢复函数开始调用时ESP和EBP的值。 

### 8.2.9 LOCAL 命令符
`LOCAL` 命令符是 `ENTER` 指令的高等级替换。`LOCAL` 使用名字和类型申明一个或多个局部变量(`ENTER`只申请空间)。如果使用`LOCAL` 必须在**PROC** 的下一行使用。语法如下：

> LOCAL varlist

*varlist* 是变量列表，通过逗号分割，可选择跨越多行。每个变量的定义格式如下：

> label : type

*label* 为变量名，*type* 为标准类型(WORD, DWORD, etc)。

`LOCAL`  和 `LEVEL` 配合使用。

### 8.2.10 Microsoft x64 调用约定
Microsoft 在64-bit程序里传递参数和调用函数遵循一致方案，称作 *Microsoft X64 calling convension*。这一调用约定被 C/C++ 编译器，以及Windows API 库使用。以下是使用此约定的特征和要求：

1. CALL 指令从RSP（stack pointer) 寄存器减去8，因为地址是64 bits长度
2. 前四个传递给函数的参数存储在寄存器RCX，RDX，R8，和 R9中，参数和寄存器的关系是一一对应，大于四个参数从左到右使用栈传递
3. 参数长度小于64 bits长的，不会使用零扩展高位，因此高位的值是未知数
4. 如果返回数是整数或长度小于等于64 bits，它将被放置在 RAX寄存器里
5. 调用者需要在栈上负责分配至少32 bytes的影子（shadow）空间，因此在调用函数时可以选择性的将寄存器存储在这个区域
6. 在调用函数时，栈指针（RSP）必须以16-byte为边界对齐。`CALL` 指令将8-byte 返回地址压入栈，所以调用程序必须从栈指针减去8，以及加上为寄存器分配空间减去的32
7. 调用者需要在函数调用完毕后负责移除所有在栈上的参数以及影子空间
8. 返回值大于64 bits则被放在栈上，ECX指向返回值地址
9. RAX，RCX，RDX，R8，R9，R10，R11 寄存器经常被函数修改，因此如果想在调用函数时保留寄存器的值，则现将寄存器值压入栈中，函数退出时在从栈中弹出
10. RBX，RBP，RDI，RSI，R12，R14，以及R15寄存器，函数在调用结束时必须保留调用前的原值

## 8.3 递归
自己直接或间接调用自己的函数称作*递归函数*。在处理重复模式的数据结构非常有用。比如链表和各种各样的连接图。

使用递归时需要注意递归结束的时机，如果是无限循环，由于每次调用要压入返回地址，很快栈空间不足，程序崩溃退出。

### 8.3.1 递归求和
通过输入变量n，然后使用递归进行 1...n 的求和，代码如下：

[求和代码](RecursiveSum.asm)

### 8.3.2 递归计算级数
C++ 代码如下：

```C++
int factorial(int n)
{
    if (n == 0)
        return 1;
    else
        return n * factorial(n-1)
}
```

汇编代码为：

[级数代码](Fact.asm)

## 8.4 INVOKE, ADDR, PROC, 和 PROTO
这些指令都是 *MASM* 提供的高级指令，方便函数的定义和调用，最终还是被*MASM*翻译为汇编指令。

### 8.4.1 INVOKE 命令符
`INVOKE`命令符，只可以用在32-bit模式下，将参数压入栈（压入的顺序和 `MODEL`命令符指定的语言相关），并调用函数。语法如下：

> INVOKE procedureName [,argumentList]

*ArgumentList* 是逗号隔开的参数列表。

### 8.4.2 ADDR 操作符
`ADDR` 操作符，只可以用在32-bit模式下，当使用`INVOKE` 调用函数时，可以用来传递指针参数。传递给`ADDR`的参数必须是汇编时常量。

### 8.4.3 PROC 命令符
在32-bit模式下， `PROC` 命令符语法如下：

> label PROC [attributes] [USES reglist], parameter_list

Label 是用户自定义标签符合第三章变量的命名规则即可。Attributes 有以下几种类型：

|    属性     |  描述  |
| :---------: | :---: |
|  distance   | NEAR 或 FAR。标识assembler 生成的RET指令类型                                                             |
|  langtype   | 标识调用约定（参数传递方式）例如 C，PASCAL，或 STDCALL。覆盖.MODEL 命令符申明的语言类型                      |
| visibility  | 标识函数对于其他模块的可见性。可以选择 PRIVATE，PUBLIC(default)，和 EXPORT。如果可见性是 EXPORT，链接器将函数名字放在导出表中用来段执行。EXPORT同时开启PUBLIC可见性 |
| prologuearg |                                                          标识参数前期和后期影响代（affecting generation）                                                   |

参数列表是指用逗号隔开的多个参数，参数语法如下：

> paramName:type

type 可以是：`BYTE,SBYTE,WORD,SWORD,DWORD,SDWORD,FWORD,QWORD,TBYTE` 。也可是限定类型，指向已知类型的指针。

当使用多个参数后，MASM会生成以下代码：

```asm
    push ebp
    mov ebp, esp
    .
    .
    leave
    ret (n * 4)             ; n 为参数个数
```

申明传递参数的协议，如果指定了对应的语言类型，不是用 `INVOKE` 调用函数的话，需要自己正确传递参数，反之MASM生成正确传递参数的函数。

### 8.4.4 PROTO 命令符
在64-bit模式下，我们使用 `PROTO` 命令符申明函数为程序外部函数。

在32-bit模式下，`PROTO` 更加强大，因为可以包含函数参数列表。函数原型申明函数名字和参数列表，这在未定义函数前，使用函数即可验证传递给函数的参数是否匹配。MASM要求使用`INVOKE` 调用函数时，必须有原型申明或者函数定义在 `INVOKE` 之前。

### 8.4.5 参数分类
函数参数通过调用程序和被调用函数之间的数据转移来分类：

* **Input**：传入函数内部的参数，通常函数内部只使用此参数参与运算，而不修改此值。就算修改此值后，对于外部传递时的值不影响。
* **Output**：将变量地址通过参数传递，在函数内部修改地址索引的值，对应指向此地址的变量皆修改
* **Input-Output**：传入函数内部参数运算，同时最终对应地址上的值别修改

### 8.4.6 例子：交换两个整数

[整数交换](Swap.asm)

### 8.4.7 调试提示
传递参数容易出错的几个点：

* 参数长度误传，比如Swap函数中dword的长度为4，如果第二参数长度不对，则获取的值为错误值
* 传递错误指针，比如Swap函数中需要传递dword指针，如果传递byte指针，则不能获得想要的结果
* 传递立即数，由于参数指针地址是运行时才获得，如果将立即数传递为参数，将导致不可预知结果

### 8.4.8 WriteStackFrame 函数
在 Irvine32库里含有一个函数 **WriteStackFrame** 显示当前函数调用栈帧。函数原型如下：

```asm
WriteStackFrame PROTO,
    numParam:DWORD,                 ; number of passed parameters
    numLocalVal:DWORD,              ; number of DWordLocal Variables
    numSavedReg:DWORD               ; number of of saved registers

; hold the name of procedure
WriteStackFrameName PROTO,
    numParam:DWORD,                 ; number of passed parameters
    numLocalVal:DWORD,              ; number of DWordLocal Variables
    numSavedReg:DWORD               ; number of of saved registers
    procName:PTR BYTE               ; null-terminated string
``` 
## 8.5 创建多模块程序
源文件过大很难维护并且汇编很慢。将文件拆分成多个包含文件，但是每个源文件的修改任然需要汇编所有文件。更好的方案是将程序拆分为模块（汇编模块）。每个模块独立汇编，因此修改一个文件只需汇编对应的源文件。最终链接器将所有汇编后的文件（OBJ files）合并为一个可执行文件。链接同样数量的object 模块比起汇编数量想当的源文件需要时间少很多。

这里有量有种方式创建多模块程序：

* 传统方式，使用 `EXTERN` 命令符，或多或少在X86汇编器上可以移植
* 第二种方式，使用Microsoft's 高级 `INVOKE and PROTO` 指令，这两个指令简化函数调用以及隐藏底层细节。


### 8.5.1 隐藏和抛出函数名字
将函数变为私有，这是使用封装原则将函数隐藏在模块中同时避免在不同模块中相同名字的冲突。

MASM 默认所有的函数为PUBLIC，如果想让函数为私有可以使用 PRIVATE 标记符：

> mySub PORC PRIVATE

还可以在模块中第一行申明所有函数为私有，然后再标识公有函数：

> OPTION PROC:PRIVATE  
> PUBLIC sub1, sub2, sub3

还可以在函数定义时重写函数访问属性：

```asm
mySub PROC PUBLIC
.
mySub ENDP
```
### 8.5.2 调用外部函数
使用 `EXTERN` 命令符来调用当前模块外的函数，标识函数名字和栈帧大小。语法如下：

> EXTERN sub1@n:PROC

sub1 为函数名字，@n 为使用栈空间大小，一个参数为4，n 个参数为 n * 4。

使用 `PROTO` 命令符简单一些：

> AddTwo PROTO, val1:DWORD, val2:DWORD


### 8.5.3 跨模块使用变量和符号
#### 导出变量和符号
变量和符号默认是私有的，使用`PUBLIC` 指令导出指定名字。

```asm
    PUBLIC count, SYM1
    SYM1 = 10
    .data
    count DWORD 0
```
#### 访问外部变量和符号
使用 `EXTERN` 命令符来访问变量和符号定义在外部模块：

> EXTERN name : type

如果是符号（通过 EQU 和 = 定义的），type使用 ABS。以下为例子：

> EXTERN one :WORD, two:SDWORD, three:PTR BYTE, four:ABS

#### 使用 带EXTERNDEF的INCLUDE 文件
`EXTERNDEF` 代替PUBLIC 和 EXTERN的作用，可以在一个文件里申明，然后在其他模块使用：

```asm
; vars.inc
EXTERNDEF count:DWORD, SYM1:ABS
```
定义一个代码模块，其中使用 vars.inc

```asm
; sub1.asm
.386
.model flat, STDCALL
INCLUDE vars.inc
SYS1 = 0
.data
count DWORD = 0
END
```

## 8.6 参数的高级使用
传递参数需要注意的一些细节。
### 8.6.1 使用USES操作符对栈的影响
因为使用了USES之后，在返回地址下面会压入要保存的寄存器值，这时候ESP和参数之间的距离需要加上压入寄存器的值。

### 8.6.2 在栈上传递8-bit和 16-bit参数
在32-bit模式下传递栈参数，最佳方案是传递32-bit操作数。尽管可以压入16-bit操作数，这样做会阻止ESP双字节对齐。也会导致内存页错误以及降低运行时效率。因此在传递8-bit或16-bit参数时扩展到32-bit再传递。

### 8.6.3 传递64-bit参数
将高位首先压入栈，再将低位压入栈，这样的话低位在低地址，高位在高地址。符合小端顺序，在访问时也很方便。

### 8.6.4 非双字节局部变量
无论大小都是按照32-bit为单位分配局部变量。