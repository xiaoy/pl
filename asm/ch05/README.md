# 函数
代码到了一定长度维护难度变大，并且有些代码需要复用，函数被用来解决这两个问题。

## 5.1 栈操作
后进先出(Last-in, First-out called LIFO)的数据结构。

### 5.1.1 运行栈 (32-Bit Mode)
*runtime stack*是CPU直接管理的内存数组，使用ESP(extend stack pointer)寄存器，就是传说中的栈指针寄存器(stack pointer register)。ESP寄存器存储指向栈的32-bit偏移量。修改ESP很罕见，ESP的修改都是通过调用指令而间接修改。比如指令`CALL, RET, PUSH, POP`。

ESP总是指向最后入栈值的位置。

栈的两种操作方式：

* *PUSH* 操作，栈地址指针减少4bit并且将目标值拷贝到指针指向的位置。因为运行栈是从高到低增长，所以有新值进入，栈指针减小。
* *POP* 操作，从栈上删除当前指针指向的值，然后栈指针值增加（增加量为栈元素大小）指向上一个元素

栈的应用

* 寄存器的临时存储区域，方便寄存器的存储和读取
* 函数返回变量放在栈上
* 通过栈传递函数变量
* 函数里临时变量的存储

### 5.1.2 PUSH 和 POP 指令
#### PUSH 指令
`PUSH`指令降低ESP的值（16-bit减少2，32-bit减少4），然后将源操作值拷贝到ESP指向的位置，语法如下：

> PUSH reg/mem16  
> PUSH reg/mem32  
> PUSH imm32

#### POP 指令
`POP`指令现将ESP指向的值拷贝到对应的目标操作数，然后增加ESP值。语法如下：

> POP reg/mem16  
> pop reg/mem32

#### PUSHFD 和 POPFD 指令
`PUSHFD`指令将32-bit EFLAGS寄存器保存到栈上，`POPFD`将栈上的值返回到EFLAGS。

#### PUSHAD，PUSHA，POPAD 和 POPA
`PUSHAD`指令压入所有32-bit通用寄存器到栈上，按照顺序：`EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI`。`POPAD`指令按照反向顺序弹出队列值。

`PUSHA`指令压入所有16-bit通用寄存器到栈上，按照顺序：`AX, CX, DX, BX, SP, BP, SI, DI`，`POPA`指令按照反向顺序弹出队列值。

## 5.2 定义和使用函数
### 5.2.1 PROC 指令
#### 定义函数
函数就是以return语句结束的程序语句块别名。函数使用`PROC`和 `ENDP` 指令加函数名来申明。如果不是启动函数，都以 `RET`指令结束。`RET`强制CPU返回到函数调用的地方。

```asm
sample PROC  
.  
.
ret
sample ENDP
```

#### 函数中的Labels
默认条件下，labels的作用域为自己所申明的函数里。也可以通过在label后面加双冒号(::)来申明为全局label。但这种方式不推荐，因为跳转出函数会破坏当前堆栈。

#### 函数注释
一个非常的好的习惯是为自己的程序添加清晰和可读的文档，以下是为函数添加注释的一些建议：

* 函数要完成任务的描述
* 输入参数列表和用途，以 **Receives** 做标签
* 返回值描述，使用 **Returns** 做标签
* 特殊条件要求，称作*前置条件*，函数调用的必要条件。使用 **Requires** 做标签


### 5.2.2 CALL和RET 指令
`CALL`指令通过指引处理器跳转到函数所在内存地址来执行函数代码。函数使用`RET`指令将处理器返回到函数被调用的地址。调用机制如下：

* `CALL`指令将返回地址压入栈，然后将函数地址赋值给指令指针寄存器
* `RET`指令从栈上弹出返回地址到指令指针寄存器
* 32-bit使用 EIP寄存器，16-bit使用IP寄存器

### 5.2.3 网状函数调用
每次函数的调用将下一条执行指令的地址压入栈，当函数返回时，将执行指令弹出到指令指针寄存器。

### 5.2.4 通过寄存器传递函数参数
函数如果没有参数，则此函数就不能作为输入输出功能单元，没有通用性。因为寄存器是全局的，因此可以使用寄存器充当函数参数，但是使用寄存器当变量，一定确保使用完恢复寄存器的值。

### 5.2.5 例子：整数数组求和
```asm
;-----------------------------------------------------
; ArraySum
;
; Calculates the sum of an array of 32-bit integers.
; Receives: ESI = the array offset
; ECX = number of elements in the array
; Returns: EAX = sum of the array elements
;-----------------------------------------------------
ArraySum PROC
    push esi                        ; save ESI, ECX
    push ecx
    mov eax, 0                      ; set the sum to zero

L1: add eax,[esi]                   ; add each integer to sum
    add esi,TYPE DWORD              ; point to next integer
    loop L1                         ; repeat for array size

    pop ecx                         ; restore ECX, ESI
    pop esi
    ret                             ; sum is in eax
ArraySum ENDP
```
### 5.2.6 保存和加载寄存器
调用函数需要保存和恢复寄存器，这件事本身麻烦，并且容易忘记对称压入和弹出。所以提供了`USES`操作符。自动来做这件事，`USES`跟在 `PROC`后面，要使用的寄存器放在后面，空格或tab隔开。

```asm
ArraySum PROC USES esi ecx
    mov eax,0
L1:
    add eax,[esi]
    add esi, TYPE WORD
    loop L1

    ret
ArraySum ENDP
```

使用`USES`需要注意的是EAX寄存器，因为EAX被当做返回值，如果`USES`使用了EAX，在函数结尾EAX会被恢复。

## 5.3 链接外部库
### 5.3.1 背景信息
需要外部链接的函数，必须提前使用 `PROTO` 指令申明。链接库分为动态库和静态库，库包含被汇编为机器码的指令。静态库的链接过程为：汇编器从静态库拷贝对应的代码到链接的单元模块。动态库运行时跳转到对应的地址运行，动态库所有程序公用一份。程序汇编时先将外部链接函数地址留空，等到汇编结束，再将函数调用地址补上。

## 5.4 Irvine32库
### 5.4.1 创建库的动机
16bit汇编编程在DOS 环境下，只提供简单的函数（INT 21h services）来实现输入输出功能。为了显示一个字符需要复杂的程序，这样的学习曲线太过于陡峭。所以提供汇编库来解决这个问题。

### 5.4.2 简介
命令符界面是定义好长度和宽度的Windows窗口。

### 5.4.3 独立函数介绍
在Irvine32库里如下函数对于学习汇编非常实用。

```asm
; 关闭文件
; inputs: eax->fileHandle
; CloseFile
mov eax, fileHandle
call CloseFile

; 清除console window
; Clrscr
call Clrsrc

; 创建文件，打开文件用来输入
; inputs: edx->fileName addr
; CreateOutputFile
mov edx, OFFSET filename
call CreateOutputFile

; 换行，在当前行写入 0Dh 0Ah
; Crlf
call  Crlf

; 延迟指令执行
; inputs: eax->delay time(millisenconds)
; Delay
mov eax, 1000
call Delay

; 以16进制显示一段内存
; inputs: ESI->starting address
;         ECX->number of units
;         EBX->unit size
; DumpMem
.data
array DWORD 1, 2, 3, 4, 5, 6, 7, 8, 9, 0Ah, 0Bh
.code
main PROC
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
    mov ebx, type array
    call DumpMem

; 显示寄存器和标志位
; DumpRegs
call DumpRegs

; 将程序命令行执行程序参数拷贝到一个以null结束的字符串
; inputs:edx->offset of an array at least 129 bytes
; outputs:Carry flag, 如果为空设置，如果有值，清除
; GetCommandTail

; 返回console 窗口尺寸
; outputs:DX->number of columns, AX->number of rows.range->[0, 255]
; GetMaxXY

; 返回零点到当前的毫秒
; outputs:EAX
; GetMseconds

; 返回窗口前景和后景颜色
; outputs:AL(high-4bit)->background color, AL(low-4bit)->foreground color
; GetTextColor

; 设置光标位置
; inputs:dh->Y-coordinate default range[0, 79], DL->X-coordinate
; Gotoxy

; 探测AL里的值是否为ASCII
; inputs:AL
; outputs: Zero flag->yes,set the flag or clear the flag
; IsDigit

; 确认框
; inputs:EDX->content
;       :EBX->title, if the EBX is zero, the title is empty
; MsgBox

; 询问框
; inputs:EDX->content
;       :EBX->title, if the EBX is zero, the title is empty
; outpus:EAX->IDYES(6) or IDNO(7)
; MsgBoxAsk

; 打开一个存在的文件用来读取内容
; inputs:EDX->filename offset
; outputs:EAX->file handle, read error resultis:INVALID_HANDLE_VALUE
; call OpenInputFile

; 将无符号10进制字符串转为32-bit二进制
; inputs:EDX->offset string
;       :ECX->string length
; outputs:EAX->result, CF = 0 转换有效值

; 将有符号10进制字符串转换为32-bit二进制
; inputs:EDX->offset string
;       ;ECX->string length
; outputs:EAX->result, 超出范围Overflow flag设置，并打印错误 

; 返回32-bit随机数
; outputs:EAX
; Random32

; 产生随机种子，使用当前时间，精确到 百分之一秒
; Randomize

; 产生范围内随机数range[0, n)
; inputs:EAX->n
; outputs:EAX
; RandomRange

; 读取按键字符
; outputs:AL, 若果是扩展字符，则AL=0，AH Keyboard scan code
; ReadChar

; 读取32-bit无符号整形，起始的空格被忽略，读取内从非数字断开
; outputs:EAX
; ReadDec

; 读取文件内容
; inputs:EAX->open file handle
;       :EDX->buffer of offset
;       :ECX->maximum number of bytes to read
; outputs:EAX->count of number of bytes read form the file, if CF is clear
;        :EAX->system error number, if CF is set
; ReadFromFile

; 读取16进制返回32-bit二进制
; outputs:EAX
; ReadHex 

; 读取32-bit有符号整数返回32-bit二进制
; outputs:EAX
; ReadInt

; 读取字符串
; inputs:EDX->offset of buffer
;       :ECX->maximum number of characters + 1
; outpus:EAX->number of read characters
; ReadString

; 返回null结尾字符串长度
; inputs:EDX->string offset
; ouputs:EAX->string length
; Str_length

; 打印字符串 "Press any key to continue..."，等待用户按下任意键
; WaitMsg

; 将整数以ASCII二进制格式打印
; inputs:EAX->integer
; WriteBin


; 将整数以指定宽度ASCII二进制格式打印
; inputs:EAX->integer
;        EBX->diplay size in bytes
; WriteBinB

; 窗口显示字符
; inputs:AL->character
; WriteChar

; 窗口显示无符号32-bit整形，不用零补全宽度
; inputs:EAX->unsigned integer
; WriteDec

; 窗口显示十六进制32-bit无符号整形，用零补齐宽度
; inputs:EAX->unsigned integer
; WriteHex


; 窗口显示特定宽度十六进制32-bit无符号整形，用零补齐宽度
; inputs:EAX->unsigned integer
;        EBX->diplay size in bytes
; WriteHexB

; 窗口显示有符号32-bit整形，不用零补齐宽度
; inputs:EAX-signed integer
; WriteInt

; 窗口显示null结尾字符串
; inputs:EDX->offset string
; WriteString

; 写入文件
; inputs:EAX->file handle
;        EDX->offset of buffer
;        ECX->number of byte to write in
; outputs:EAX->if greater then zero, count of bytes write in file, or error
; WriteToFile

; 显示最近一次应用产生的错误到窗口
; WriteWindowsMsg
```

### 5.4.4 库测试程序
* [Ingeger I/O test](InputLoop.asm)
* [Random Integers](TestLib2.asm)
* [Performance Timing](TestLib3.asm)

## 5.5 64-bit 汇编编程
### 5.5.1 Irvine64 库
```asm
; 换行
; Crlf

; 64位随机数 [0, 2^64 - 1]
; outputs:RAX
; Random64

; 设置随机种子
; Randomize

; 读取64-bit 有符号整数，回车符结束输入
; output:RAX
; ReadInt64

; 读取字符串，回车符结束输入
; input:RDX->存储字符串地址,RCX->最大可输入字符值加1
; output:RAX->输入字符长度
; ReadString

; 字符串对比
; input:RSI->source string, RDI->target string
; output:Zero,Carry flag as same the CMP instruction
; Str_compare

; 拷贝字符串
; input:RSI->srouce string offset, RDI->target string offset
; Str_copy

; 返回null结尾字符串长度
; input:RCX->string offset
; output:RAX->string length
; Str_length

; 显示64-bit有符号整数
; input:RAX
; WriteInt64

; 显示64-bit 16进制整数
; input:RAX
; WriteHex64

; 显示16进制数1-byte，2-byte，4-byte or 8-byte 格式
; input:RAX->display value, RBX->diplay size(1,2,4,8)
; WriteHexB

; 显示null结尾字符串
; input:RDX->input string offset
; WriteString
```
### 5.5.2 调用64-bit函数
使用`CALL`即可调用函数。
```asm
mov rax, 12345678h
call WriteHex64
```

由于64位库没有使用include先包含申明的函数，所以要自己添加 **PROTO**指令来提前申明要使用的函数。
```asm
ExitProcess PROTO
WriteHex64 PROTO
```
### 5.5.3 x64 调用规则
Microsoft遵循调用64-bit函数的规则，称作 *Microsoft x64 Calling Convention* 。这个规则被C/C++编译器使用，也被 **Windows Application Programming Interface (API)**使用。这个规则只用在调用Windows API，或者调用C或者C++实现的函数。以下是基本条例：

1. `CALL`指令将`RSP`的值减8，因为地址是64-bit长
2. 前四个函数参数依次放在 `RCX,RDX,R8,R9`寄存器
3. 分配至少32bytes的长度用来存储寄存器参数的值，自个过程是需要开发者自己维护
4. 当调用函数，RSP的值必须按16-byte对齐。`CALL`指令压入8-byte返回值在栈上，因此调用程序必须将栈指针减8


### 5.5.4 调用函数例子
[CallProc_64.asm](CallProc_64.asm)