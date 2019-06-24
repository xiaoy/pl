# Chapter 10 结构体和宏
## 10.1 结构体
*结构体(struct)*是逻辑相关一组变量模板或模式。在结构体里的变量称作*字段(field)*。程序语句可以将结构体当做单一实体访问，或可以访问单独字段。结构体通常包含不同类型字段，联合体通常也包含多个标识符，但标识符共用内存。

结构体提供了一种简易组织数据的方法以及在函数间相互传递的形式。假设要传递与硬盘驱动相关的20种不同参数到函数。调用这种函数非常容易出错，甚至搞混参数顺序，或者传递错误的参数数量。相应的，你可以通过将数据放在结构体里，然后通过传递结构体的地址到函数。这将使用最小的栈空间(只需要占用一个地址空间)，并且在调用的函数里还可以修改结构体的内容。

结构体在汇编语言里几乎和C/C++里的结构体一致。花费很小的精力，你就可以将来自MS-Windows API库里的结构体转换到汇编语言里使用。大多数的调试器可以显示结构体的独立字段内容。

使用结构体需要如下三个步骤：

1. 定义结构体
2. 申明一个或多个结构体类型变量，称作结构体变量
3. 添加运行时指令访问结构体字段

### 10.1.1 定义结构体
定义结构体使用 `STRUCT` 和 `ENDS` 命令符。在结构体内部，字段的定义与定义普通变量的语法一致。结构体可以几乎可以包含任意数量的字段：

```asm
name STRUCT  
    field-declarations  
name ENDS
```

当结构体字段有初始化变量时，创建结构体变量时字段使用结构体定义时默认值。你可以使用各种类型的变量初始化字段：

* 未定义：? 操作符让字段内容变为未定义
* 字符串：字符数组被包含在双引号里
* 整数：整数常量和整数表达式
* Arrays: `DUP`操作符初始化数组元素

以下 **Employee** 结构体描述了雇员的信息。以下结构体的定义必须出现在对**Employee**变量申明之前。

```asm
Employee STRUCT
    IdNum       BYTE "000000000"
    LastName    BYTE  30 DUP(0)
    Years       WORD 0
    SalaryHistory DWORD 0, 0, 0, 0
Employee ENDS
```

以下是结构体内存布局的线性呈现：

![](res/struct_memory_layout.png)

#### 数据结构字段对齐
为了最好的内存I/O性能，结构体成员应当和他们的对应的数据类型对齐到对应地址。否则，CPU需要使用更多的时间访问成员。以下表列出了Microsoft C 和 C++编译器以及Win32 API函数对齐信息：

| 成员类型     | 对齐                         |
| :----------- | :--------------------------- |
| BYTE,SBYTE   | 对齐到8-bit(byte)边界        |
| WORD,SWORD   | 对齐到16-bit(word)边界       |
| DWORD,SDWORD | 对齐到32-bit(doubleword)边界 |
| QWORD        | 对齐到64-bit(quadword)边界   |
| REAL4        | 对齐到32-bit(doubleword)边界 |
| REAL8        | 对齐到64-bit(doubleword)边界 |
| structure    | 成员里的最大对齐值           |
| union        | 首个成员对齐                 |

在汇编语言里，`ALIGN` 命令符设置地址对齐到下一个字段或变量：

> ALIGN datatype

以下为两个例子：

```asm
; 让 myVar和 doubleword边界对齐
.data
ALIGN DWORD
myVar DWORD ?

; 对齐 结构体 Employee
Empolyee STRUCT
    IdNum           BYTE "00000000"         ; 9
    LastName        BYTE 30 DUP(0)          ; 30
    ALIGN           WORD                    ; 1 byte added
    Years           WORD 0                  ; 2
    ALIGN           DWORD                   ; 2 bytes added
    SalaryHistory   DWORD   0,0,0,0         ; 16
Empolyee ENDS                               ; 60 total
```
### 10.1.2 申明结构体变量 
结构体变量可以被申明以及使用特定的值初始化。语法如下，这里 *structType* 已经使用 **STRUCT** 命令符定义：

> identifier structureType <initializer-list>

*identifier* 和**MASM**中其他变量名的命名规则一致。*initializer-list* 是可选的，如果使用，如果有多个字段初始化，使用逗号隔开：

> initializer [, initializer] ...

空的尖括号 <> 导致结构体使用定义时所对应的初始值。同样的，可以选择字段赋值。赋值给字段的顺序为从左到右，匹配结构体里定义的字段顺序。以下为 **COORD**和**Employee**例子：

```asm
.data
point1  COORD <5, 10>               ; X = 5, Y = 10
point2  COORD <20>                  ; X = 20, Y = ?
point3  COORD <>                    ; X = ?, Y= ?
worker  Employee <>                 ; (default initializers)
```

需要注意的几点：

* 可以选择初始化指定的字段，其他字段留空即可
* 字符串初始化如果比对应字段长度短，剩余空间初始化为空格而不是0
* 如果是数组初始化，如果有剩余空间，则使用零填充

使用 `DUP` 操作符创建结构体数组：

```asm
NumPoints = 3
AllPoints COORD NumPoints DUP(<0, 0>)
```

为了最好的处理器性能，使用结构体最大长度的字段类型来对齐结构体变量在内存边界。比如 *Employee* 结构体包含 **DWORD**字段，因此对齐如下：

```asm
.data
ALIGN DWORD
person Employee <>
```
### 10.1.3 结构体变量引用 
结构体可以使用 **TYPE** 和 **SIZEOF** 操作符返回长度。

引用已命名结构体成员需要结构体变量当做属性。以下为几个例子：

```asm
; 以下常量表达式在汇编阶段生成对应值
TYPE Employee.SalaryHistory         ; 4
LENGTHOF Empolyee.SalaryHistory     ; 4
SIZEOF Empolyee.SalaryHistory       ; 16
TYPE Empolyee.Years                 ; 2

; 以下为运行时引用 worker
.data
worker Employee <>
.code
mov dx, worker.Years
mov woker.SalaryHistory, 20000              ; first salary
mov [woker.SalaryHistory + 4], 30000        ; second salary

; 使用 OFFSET 操作符
mov edx, OFFSET worker.LastName
```

#### 间接和索引操作
间接操作使用寄存器(例如 ESI)去索引结构体成员。间接寻址提供灵活性，尤其是传递结构体地址到函数或使用结构体数组。在引用间接操作数时需要`PTR`操作符：

```asm
mov esi, OFFSET worker
mov ax, (Employee PTR [esi]).Years
```

通过索引来访问结构体数组。假设 **department**是五个 Employee的数组对象。以下语句访问employee的**Years**字段。

```asm
.data
department Employee 5 dup(<>)
.code
mov esi, TYPE Employee
mov department[esi].Years, 4
```

### 10.1.4 例子：显示系统时间 

[显示系统时间代码](ShowTime.asm)

### 10.1.5 网状结构体 
*结构体* 可以包含其他结构体实例。例如，**Rectangle** 可以通过左上角和右下角来定义：

```asm
Rectangle STRUCT
    UpperLeft COORD <>
    LowerRight COORD <>
Rectangle ENDS
```

Rectangle变量可以重写或不重写独立**COORD**字段来申明。比如以下例子：

```asm
rect1 Rectangle < >
rect2 Rectangle { }
rect3 Rectangle {{10, 10}, {50, 20}}
rect4 Rectangle <<10, 10>, <50, 20>>
```

访问结构体例子如下：

```asm
; 直接引用访问
mov rect1.UpperLeft.X, 10

; 间接访问
mov esi, OFFSET rect1
mov (Rectangle PTR [esi]).UpperLeft.Y, 10

; OFFSET 可以返回独立结构体字段指针
mov edi, OFFSET rect2.LowerRight
mov (COORD PTR [edi]).X, 50
mov edi, OFFSET rect2.LowerRight.X
mov WORD PTR [edi], 50
```
### 10.1.6 例子：醉鬼走路 

[醉鬼走路代码](Walk.asm)

### 10.1.7 申明和使用联合体
在结构体中每个字段相对首字节有固定步长，所有在联合体里的字段都是从首字节开始。联合体的存储长度和它最长的字段长度一致。当不被结构体包含时，联合体使用**UNION**和**ENDS**命令符来定义：

```asm
unionname UNION
    union-fields
unionname ENDS
```

如果嵌套在结构体里，语法如下：

```asm
structname STRUCT
    structure-fields
    UNION unionname
        union-fields
    ENDS
structname ENDS
```

联合体字段的申明和结构体规则一致，除了每个字段只有一个初始值。(本质是共享内存，初始化时如果有多个不同的初始值，按照类型最长的字段初始化)。

## 10.2 宏
### 10.2.1 简介
*宏函数(macro procedure)*是汇编语言语句的别名块。一次定义，任何地方都可以调用。当你调用宏程序，就相当于是将这块代码插入到宏调用对应的地址。这是一种自动插入代码的方式，也称作*内敛展开(inline expansion)*。

宏通常定义在代码开始前，或者在单独的文件里通过 **INCLUDE** 命令符包含到文件里。宏在汇编器*预处理(preprocessing)*阶段展开。在这个阶段，预处理器读取宏定义然后扫描程序里其他代码。在宏被调用的每一点，汇编器插入一份宏源码(macro's source code)到程序里。

### 10.2.2 定义宏
宏定义使用`MACRO` 和 `ENDM` 命令符。语法如下：

```asm
macroname MACRO parameter-1, parameter-2...  
    statement-list  
ENDM
```

参数通过文本参数来占位，没有具体类型，在宏展开时检查语法错误。

### 10.2.3 调用宏
语法如下：

> macroname argument-1, argument-2, ...

### 10.2.4 额外的宏特性
#### 要求参数(Required Parameters)
使用**REQ**装饰，可以指定需要的宏参数。如果调用宏时和对应的参数不匹配，汇编器显示一条错误信息。

#### 宏注释
正常的注释在宏展开时也会展开，如果不想展开使用双分号(;;)。

#### ECHO 指令
**ECHO** 当程序在汇编时，指令向标准输出窗口写入一个字符串。

#### LOCAL 指令
宏代码里可以申明变量，如果宏展开很有可能出现重复定义的错误，所以使用LOCAL指令先申明label，然后在定义变量时使用此label，汇编器在汇编时，自动将变量名转换为唯一标识符。

```asm
makeString Macro text
    LOCAL string
    .data
    string BYTE text, 0
ENDM
```

展开后
```asm
makeString "Hello"
.data
??0000 BYTE "Hello",0
makeString "GoodBye"
.data
??0001 BYTE "GoodByte", 0
```

如果宏里既有变量还有数据，则代码使用对应宏展开的变量名。


### 10.2.5 使用书里定义的宏库(32-bit 模式)
以下为书本自带库的宏定义表：

| 宏名字        | 参数                              | 描述                                 |
| :------------ | :-------------------------------- | :----------------------------------- |
| mDump         | varName,useLabel                  | 显示一个变量，使用它的名字和默认属性 |
| mDumpMem      | address, itemCount, componentSize | 显示一段内存                         |
| mGotoxy       | X,Y                               | 设置平台窗口缓存中光标位置           |
| mReadString   | varName                           | 从键盘读取一个字符串                 |
| mShow         | itsName, format                   | 各种格式显示变量或寄存器             |
| mShowRegister | regName,regValue                  | 显示32-bit寄存器名字以及十六进制内容 |
| mWrite        | text                              | 将字符串写入窗口                     |
| mWriteSpace   | count                             | 将一个或多个空格写入窗口             |
| mWriteString  | buffer                            | 将字符串变量写入窗口                 |

```asm
; mShow
; 使用特定格式显示寄存器或变量名字或内容
; inputs: arg1->变量或寄存器名字
;         arg2->"HDIBN"
; H = hexadecimal
; D = unsigned decimal
; I = signed decimal
; B = binary
; N = append a newline
; 参数二的默认值为:"HIN"，此参数可以任意组合格式
```
### 10.2.6 例子：Wrappers
[使用宏代码](Wraps.asm)

## 10.3 条件汇编命令符
许多不同种类的条件汇编命令符和宏组合起来使用更加灵活。条件汇编命令指令语法如下：

```asm
IF condition
    statements
[ELSE
    statements]
ENDIF
```

这些命令符在汇编阶段生效，而 `.IF, .ENDIF` 是运行时生效。以下为条件命令表：

| 指令                  | 描述                                                                         |
| :-------------------- | :--------------------------------------------------------------------------- |
| IF expression         | 如果 expression的值为真(非零)，允许区域内的语句汇编                          |
| IFB <argument>        | 如果 argument 是空值，允许区域内的语句汇编，argument名字必须包含在尖括号里   |
| IFNB <argument>       | 如果 argument 不是空值，允许区域内的语句汇编，argument名字必须包含在尖括号里 |
| IFIDN <arg1>,<arg2>   | 如果两个参数相同（恒等）允许区域内语句汇编。比较时大小写敏感                 |
| IFIDNI <arg1>,<args2> | 如果两个参数相同 允许区域内语句汇编。比较时大小写敏感                        |
| IFDIF <arg1>,<arg2>   | 如果两个参数不相同，允许区域内语句汇编。比较时大小写敏感                     |
| IFDIFI <arg1>,<arg2>  | 如果两个参数不相同，允许区域内语句汇编。比较时大小写不敏感                   |
| IFDEF name            | 如果name已经被定义，允许区域内语句汇编                                       |
| IFNDEF name           | 如果name未被定义，允许区域内语句汇编                                         |
| ENDIF                 | 使用条件汇编指令对应的指令块结束指令                                         |
| ELSE                  | 如果之前的条件语句满足，则丢弃ELSE语句块，反之亦然                           |
| ELSEIF expression     | 如果之前的语句不满足，当前命令符执行语句为真，则使用当前语句块               |
| EXITM                 | 立即退出宏，后续宏语句不展开                                                 |

### 10.3.1 检查缺失的参数
使用对应的条件命令符检查宏函数参数。以下为宏函数检查传入参数是否为空代码：

```asm
mWriteString MACRO string
    IFB <string>
        ECHO ------------------------------------------
        ECHO *  Error: parameter missing in mWriteString
        ECHO *  (no code generated) 
        ECHO ------------------------------------------
        EXITM
    ENDIF
    push edx
    mov edx, OFFSET string
    call WriteString
    pop edx
ENDM
```
### 10.3.2 默认参数初始化
宏可以有默认初始化参数，如果宏函数参数为空，调用时将使用默认参数代替。语法如下：

> paramname := < argument >

(操作符的前后空格是可选择的)，比如 `mWriteln` 宏使用空格当做默认参数，例子如下：

```asm
mWriteln MACRO text:=<" ">
    mWrite text
    call Crlf
ENDM
```
### 10.3.3 布尔表达式
以下为关系操作符，可以用在含有 IF 或其他条件指令的常量布尔表达式。

| 关系操作符 | 描述       |
| :--------- | :--------- |
| LT         | 小于       |
| GT         | 大于       |
| EQ         | 等于       |
| NE         | 不等于     |
| LE         | 小于或等于 |
| GE         | 大于或等于 |

### 10.3.4 IF,ELSE,和 ENDIF 命令符
IF指令必须使用常量布尔表达式。表达式可以是整数常量，符号常量，或宏常量参数，但不能是寄存器或变量名。语法如下：

```asm
; IF and ENDIF
IF expression
    statement-list
ENDIF

; IF, ELSE, and ENDIF
IF expression
    statement-list
ELSE
    statement-list
ENDIF
```
### 10.3.5 IFIDN 和 IFIDI 命令符
IFDNI 指令对两个符号进行比较(大小写敏感)，符号名字也会比较，只有恒等才返回true。IFIDN比较两个符号是否相等(大小写敏感)。

比如判断某个参数是否为寄存器，例子如下：

```asm
;-----------------------------------------------------
mReadBuf MACRO bufferPtr, maxChars
; Reads from the keyboard into a buffer
; Receives: offset of the buffer, count of the maximum
; number of characters that can be entered. the second
; argument cannot be edx or EDX
;-----------------------------------------------------
    IFIDNI <maxChars>, <EDX>
        ECHO Warning: Second argument to mReadBuf cannot be EDX
        ECHO **************************************************
        EXITM
    ENDIF
    push ecx
    push edx
    mov edx,bufferPtr
    mov ecx,maxChars
    call ReadString
    pop edx
    pop ecx
ENDM
```
### 10.3.6 例子：Matrix 行求和
[Matrix 求和代码](CalcRowSum.asm)

### 10.3.7 特殊操作符
#### 替换操作符(&)
替换操作符解决了参数名引用冲突的问题。比如`mShowRegister` 宏显示32-bit寄存器名字和十六进制值。如果没有替换符，只能在单独使用字符串传递参数名。

```asm
mShowRegister MACRO regName
.data
tempStr BYTE " &regName", 0
```

#### 展开操作符 (%)
展开操作符展开文本宏或将常量表达式转换为文本。操作符两种方式：

1. 当时用 `TEXTEQU` % 操作符执行常量表达式并将结果转换为整数
2. 当 % 是代码首字母，这将使预处理器展开所有在同一行的文本宏和宏函数

显示行号：

```asm
Mul32 MACRO op1, op2, product
    IFIDNI <op2>, <EAX>
        LINENUM TEXTEQU %(@LINE)
        ECHO --------------------------------------------------
%       ECHO *  Error on line LINENUM: EAX cannot be the second        
        ECHO *  argument when invoking the MUL32 macro.
        ECHO --------------------------------------------------
    EXITM
    ENDIF
    push eax
    mov eax, op1
    mul op2
    mov product, eax
    pop eax
ENDM
```

#### 文本操作符 (<>)
文本操作符 (<>)组织一个或多个字符和符号为一个单独字符串。例如 `mWrite` 宏调用。

```asm
mWrite <"Line three", 0dh, 0ah>
```

#### 字符操作符 (!)
字符操作符将预先定义操作符当做正常字符。

### 10.3.8 宏函数
宏过程和宏函数的区别是宏函数有返回值。比如以下 `IsDefined` 宏函数。

```asm
IsDefined MACRO symbol
    IFDEF symbol
        EXITM <-1>              ;; True
    ELSE
        EXITM <0>               ;; False
    ENDIF
ENDM
```
## 10.4 定义重复块
MASM 有许多循环命令符来生成重复语句块：`WHILE, REPEAT,FOR and FORC`。和`LOOP`指令不同的是，这些指令运行在汇编阶段，使用常量作为循环条件和计数器：

* WHILE 命令符根据布尔表达式重复块语句
* REPEAT 命令符根据计数器重复块语句
* FOR 命令符遍历符号列表重复块语句
* FORC 命令符遍历字符串字符来重复块语句
