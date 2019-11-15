# Chapter3: 稍微高级的例子
## 3.1 双重否定
将非零转换为1(布尔true)，零转换为0(布尔false)使用 `!!`语句。
```C++
int convert_to_bool(int a)
{
    return !!a;
}
```

转换为汇编,使用 x86 msvc v19.14，优化参数为 O1
```asm
_a$ = 8 ; size = 4
_convert_to_bool PROC ; COMDAT
  xor eax, eax
  cmp DWORD PTR _a$[esp-4], eax
  setne al
  ret 0
_convert_to_bool ENDP
```

其中`setne al`，如果输入结果不为零，设置 *al* 为1，否则不执行任何操作。

普通写法如下：
```C++
int convert_to_bool(int a)
{
    if(a)
        return 1;
    else
        return 0;
}
```
可读性更高，编译器编译结果一致。

## 3.2 strstr() 例子
GCC 有时会使用部分字符串，C/C++ 标准函数`strstr()` 用来查找子字符串，下面代码来验证这件事：

```C++
#include <string.h>
#include <stdio.h>

int main()
{
    char* s = "Hello, world!";
    char* w = strstr(s, "world");
    
    printf("%p, [%s]\n", s, s);
    printf("%p, [%s]\n",w, w);
}
```

GCC 将字符串拆分为两个，MS 分配了两个字符串。

## 3.3 温度转化
面向初学者非常流行的一个程序，将华氏温度转换为摄氏温度。公式为：

> C = 5.(F-32)/9

还可以加入简单错误处理：

* 检查输入格式是否正确
* 检查转换为摄氏温度是否低于绝对零度(-273)

### 3.3.1 整数版本
```C++
#include <stdio.h>
#include <stdlib.h>

int main()
{
    int celsius, fahr;
    printf("Enter temperature in Fahrenheit:\n");
    if(scanf("%d", &fahr) != 1)
    {
        printf("Error while parsing your input\n");
        exit(0);
    }

    celsius = 5 * (fahr - 32) / 9;

    if(celsius < -273)
    {
        printf("Error: incorrect temperature!\n");
        exit(0);
    }

    printf("Celsius: %d\n", celsius);
}
```

注意以下几点：

* `printf()`的地址被加载到 ESI 寄存器，所以后续调用函数只需调用`call ESI`。这是编译器常用技术，如果代码里重复调用同一个函数，并且有空闲寄存器。
* 在`ADD EAX, -32` 这条指令，使用加法代替减法，是否能优化，和各家硬件实现相关。
* 当乘以5时，使用 LEA 指令:`lea ecx, DOWRD PTR[eax + eax * 4]`。还有一种替代方式为:`SHL EAX, 2 / ADD EAX, EAX`。
* 对于除9，使用乘法代替，具体原理后续有说明。

浮点数版本的主要介绍了FPU和SIMD的使用。

## 3.4 斐波那契数列
程序如下：

```C++
#include <stdio.h>

void fib(int a, int b, int limit)
{
    printf("%d\n", a + b);
    if(a + b > limit)
        return;
    fib(b, a + b, limit);
}

int main()
{
    printf("0\n1\n1\n");
    fib(1, 1, 20);
}
```

此程序主要说明了递归调用导致不断分配栈空间的问题。

## 3.5 CRC32 计算例子
程序如下：
```C++
typedef unsigned long ub4;
typedef unsigned char ub1;
static const ub4 crctab[256] ={0x0000000, 0x77073906 ...};

ub4 crc(const void *key, ub4 len, ub4 hash)
{
    ub4 i;
    const ub1 *key = key;
    for(hash = len, i = 0; i < len; ++i)
    {
        hash = (hash >> 8) ^ crctab[(hash & 0xff) ^ k[i]];
    }
    return hash;
}
```

主要说明了移位，异或，与操作。

## 3.6 网络地址计算例子
主要介绍了IP地址，掩码概念。

## 3.7 循环，多个迭代变量
通过优化迭代器的数量，以及将乘法变为加法来优化代码：

```C++
#include <stdio.h>

void f(int *a1, int *a2, size_t cnt)
{
    size_t i;
    for(i = 0; i < cnt; i++)
        a1[i * 3] = a2[i * 7];
}
```

优化后的三个迭代变量：

```C++
#include <stdio.h>

void f(int *a1, int *a2, size_t cnt)
{
    size_t i;
    size_t idx1 = 0; idx2 = 0;
    for(i = 0; i < cnt; i++)
    {
        a1[idx1] = a2[idx2];
        idx1 += 3;
        idx2 += 7;
    }
}
```

优化后的两个迭代变量

```C++
#include <stdio.h>

void f(int *a1, int *a2, size_t cnt)
{
    size_t idx1 = 0; idx2 = 0;
    size_t last_idx2 = cnt * 7;
    for(;;;)
    {
        a1[idx1] = a2[idx2];
        idx1 += 3;
        idx2 += 7;
        if(idx2 == last_idx2)
        {
            break;
        }
    }
}
```

## 3.8 Duff's device
介绍将缓存置为0的方式，最笨的方式是按照字节清零，但是这样浪费了内存带宽，比如32位内存带宽，每次可以执行32位清零，剩余的在按照字节处理。

本节介绍了64位清零函数：

```C++
#include <stdint.h>
#include <stdio.h>

void bzero(uint8_t *dst, size_t count)
{
    if(count &(~7))
    {
        for(int i = 0; i < count >> 3; ++i)
        {
            *(uint64_t*)dst = 0;
        }
    }

    switch(count & 7)
    {
        case 7: *dst++ = 0;
        case 6: *dst++ = 0;
        case 5: *dst++ = 0;
        case 4: *dst++ = 0;
        case 3: *dst++ = 0;
        case 2: *dst++ = 0;
        case 1: *dst++ = 0;
        case 0:
            break;
    }
}
```

## 3.9 使用乘法来实现除法
函数如下：

```C++
int f(int a)
{
    return a/9;
}
```

通过如下算法实现：

> result = x / 9 = x . 1/9 = x. 1.MagicNumber / 9.MagicNumber

通过找到: 954437177 / 2^(32+1) 来优化：

```asm
a$ = 8
f PROC ; COMDAT
  mov eax, 954437177 ; 38e38e39H
  imul ecx
  sar edx, 1
  mov eax, edx
  shr eax, 31
  add eax, edx
  ret 0
f ENDP
```

## 3.10 字符串转数字(atoi())
代码如下：
```C++
int my_atoi(char* s)
{
    int rt = 0;
    while(*s)
    {
        rt = rt * 10 + (*s - '0');
        ++s;
    }
    
    return rt;
```

汇编如下：x64 mvsc v19.14
```asm
s$ = 8
my_atoi PROC ; COMDAT
  xor eax, eax
  jmp SHORT $LN10@my_atoi
$LL2@my_atoi:
  lea edx, DWORD PTR [rax+rax*4]
  movsx eax, r8b
  lea eax, DWORD PTR [rax+rdx*2]
  add eax, -48 ; ffffffffffffffd0H
  inc rcx
$LN10@my_atoi:
  mov r8b, BYTE PTR [rcx]
  test r8b, r8b
  jne SHORT $LL2@my_atoi
  ret 0
my_atoi ENDP
```

其中要注意的是 `rt * 10` 通过两次 lea 指令实现。

以下为完善版，仅仅是更加健壮。

```C++
int my_atoi(char* s)
{
    int negative = 0;
    int rt = 0;
    if(*s == '-')
    {
        negative = 1;
        s++;
    }
    while(*s)
    {
        if(*s < '0' || *s > '9')
        {
            printf("Error! Unexpected char:'%c'\n", *s);
            exit(0);
        }
        rt = rt * 10 + (*s - '0');
        s++;
    }
    
    if(negative)
        return -rt;
    return rt;
}
```

## 3.11 内联函数
编译器直接将小的函数体的指令代替函数的调用来加快速度，因为调用函数有开销。还可以使用 `inline` 关键字来强制编译器内联函数。

许多函数都被编译器直接内联：`strcpy(), strcmp(), strlen(), strcat(), memset(), memcmp(), memcpy()`。

## 3.12 C99 限制
首先来看函数：

```C++
void f1(int *x, int *y, int *sum, int *product, int *sum_product, int *update_me, size_t s)
{
    for(int i = 0; i < s; i++)
    {
        sum[i] = x[i] + y[i];
        product[i] = x[i] * y[i];
        update_me[i] = i * 123;
        sum_product[i] = sum[i] + product[i];
    }
}
```

这段程序中 `update_me` 指针可能指向 `sum`,`product` 其中一个，所以在执行 `sum_product[i] = sum[i] + product[i]` 时需要重新从内存加载 `sum` 和 `product`，但如果确定`update_me`和他们无关，则直接可以使用已经计算好，存在寄存器的值。

C99 标准引入了关键字`restrict` 来指定指针在本区域内没有穿插引用的问题，编译器即可直接使用寄存器计算值。


```C++
void f1(int* restrict x, int* restrict y, int* restrict sum, int* restrict product, int* restrict sum_product, int* restrict update_me, size_t s)
{
    for(int i = 0; i < s; i++)
    {
        sum[i] = x[i] + y[i];
        product[i] = x[i] * y[i];
        update_me[i] = i * 123;
        sum_product[i] = sum[i] + product[i];
    }
}
```

## 3.13 无条件判断 abs() 函数
正常的取绝对值函数都需要条件语句判断。

```C++
int my_abs(int i)
{
    if(i<0)
        return -i;
    else
        return i;
}
```

gcc 通过巧妙的方式来实现不需要条件语句实现取绝对值，首先来看 x86-64 gcc 4.91 优化等级为 O1

```asm
abs:
  mov edx, edi
  sar edx, 31
  mov eax, edi
  xor eax, edx
  sub eax, edx
  ret
```

如果为负数，执行流程如下：
* edx为负，则 `sar` 指令导致 `edx = 0xFFFFFFFF`
* 再执行`xor`指令后，对输入参数取反
* 再执行 `sub eax, edx`，相当于对输入参数取反，然后加 1 的操作
* 整个流程等价于将负数取反

如果为正数，执行流程如下：
* edx为正数，则`sar` 指令导致 `edx = 0`
* 再执行`xor`指令后，输入参数不变
* 再执行`sub eax, edx`，eax 还是不变
* 整个流程相当于直接返回正数

x86-64 gcc 9.2 优化等级为 O1
```asm
  mov eax, edi
  cdq
  xor eax, edx
  sub eax, edx
  ret
```

使用 `cdq`指令，直接将eax的符号位扩展到edx，更加高效。

## 3.14 变参函数
实现函数求平均值，函数参数为多个，参数结尾参数为 -1，代码如下：

```C++
#include <stdio.h>
#include <stdarg.h>

int arith_mean(int v, ...)
{
    int sum = v, count = 1;
    int i;
    va_list args;
    va_start(args, v);
    while(1)
    {
        i = va_arg(args, int);
        if(i == -1)
            break;
        sum = sum + i;
        count++;
    }
    va_end(args);
    return sum / count;
}

int main()
{
    printf("%d\n", arith_mean(1, 2, 7, 10, 15, -1));
}
```

本质上是将栈当做无限长度数组，通过取第一个变量的地址，挨个取其他变量。

## 3.15 字符串修剪
去除字符串结尾换行符(CR/LF)
```C++
char* str_trim(char *s)
{
    char c;
    int str_len;
    for(str_len = strlen(s); str_len > 0 && (c = s[str_len - 1]); str_len--)
    {
        if(c == '/n' || c == '/r')
        {
            s[str_len - 1] = 0;
        }
        else
        {
            break;
        }
    }
    return s;
}
```

不同编译器的优化方式，比如 MSVC 将 str_len 展开。

## 3.16 toupper() 函数
将小写字母变为大写字母：
```C++
char toupper(char c)
{
    if(c >= 'a' && c <= 'z')
    {
        return c - 'a' + 'A';
    }
    else
    {
        return c;
    }
}
```

x86 msvc v19.14 优化等级：O1
```asm
_c$ = 8 ; size = 1
_toupper PROC ; COMDAT
  mov cl, BYTE PTR _c$[esp-4]
  lea eax, DWORD PTR [ecx-97]
  cmp al, 25 ; 00000019H
  ja SHORT $LN2@toupper
  lea eax, DWORD PTR [ecx-32]
  ret 0
$LN2@toupper:
  mov al, cl
  ret 0
_toupper ENDP
```

优化利用两点：
* 通过减去 'a'的值为 97，如果是在 [97, 122] 这个范围内，大小写值差 32
* 如果是大写字母，小于97，但是如果使用无符号来看，负数肯定远远大于这个范围

## 3.17 混淆
混淆是为了对反编译工程师隐藏代码(代码本意)。

混淆代码有以下几种方式：

* 字符串混淆，打乱连续字符串
* 在代码里加入垃圾代码
* 自己实现虚拟机

## 3.18 C++
### 3.18.1 类
本质上C++类几乎和结构体内部一致。

区别如下：

* 构造函数
* 函数调用会传递 `this` 指针
* 函数名字 *乱序*，通过函数名字，参数类型组合出名字，来实现多态

#### 继承
继承通过在父类的内存布局后追加自己的变量。对应每个类的函数会根据类名，函数名，参数类型 生成对应的函数。当子类调用函数不存在时，去父类搜寻。对应调用函数在编译时决定。

#### 封装
通过关键字 `private, protected, public` 来标识函数，变量的访问权限，编译时用，编译结果并没有相应限制。

#### 多重继承
有多个父类时，内存布局按照继承关系的先后来布局，当访问后继承父类成员变量时，需要加上先继承父类大小的步长。

#### 虚方法
如果类申明了虚函数，编译器将生成对应类信息，称作RTTI(run time type infomation)。

在生成对象时，内存的首位第一个指针指向虚函数表，虚函数表里对应虚函数指针。

如果是多继承，继承父类虚函数指针，如果自身覆盖了父类虚函数，对应父类虚函数表中的函数被覆盖。自身申明了虚函数，自己的虚函数对应在父类虚函数表中。

参考：

[Reversing Microsoft Visual C++ Part II: Classes, Methods and RTTI](http://www.openrce.org/articles/full_view/23)

[C++ vtables](https://shaharmike.com/cpp/vtable-part1/)

### 3.18.2 ostream
`ostream`使用例子：

```c++
#include <iostream>

int main()
{
    std::cout << "Hello, world!\n";
}
```

x86 msvc v19.14 编译结果
```asm
_main PROC ; COMDAT
  push OFFSET ??_C@_0N@GIINEEDM@hello?5world?6?$AA@
  push OFFSET ?cout@std@@3V?$basic_ostream@DU?$char_traits@D@std@@@1@A ; std::cout
  call ??$?6U?$char_traits@D@std@@@std@@YAAAV?$basic_ostream@DU?$char_traits@D@std@@@0@AAV10@PBD@Z ; std::operator<<<std::char_traits<char> >
  pop ecx
  pop ecx
  xor eax, eax
  ret 0
_main ENDP
```

`operator <<` 操作符有实现字符串类型，在通过传递 `std::cout` 来将字符串输出到控制台。这样任意类都可以实现操作符 `operator <<`。

### 3.18.3 引用
C++里，引用和指针底层是一致的，但是引用在编译层更加安全。

引用和指针区别如下：

1. 指针可以重新赋值，引用不可以
2. 指针和引用都有自己的独立内存空间，但取引用的地址还是指向引用的值
3. 指针可以连环指向指针，引用只有一层
4. 指针可以指向nullptr，引用不可以直接指向nullptr
5. 指针可以通过算数运算访问数据
6. 指针是独立变量，引用指向对应指向值相同地址
7. 指针可以指向数组，引用不可以
8. 引用可以指向临时变量，指针不可以

### 3.18.4 STL
#### std::string
许多string库通过包含指向缓存的指针，长度变量，以及缓存容量的结构体来实现。

C++ 的字符串不是类，而是模板(basic_string)，这是为了支持各种类型的字符：至少支持 `char` 和 `wchar_t`。

MSVC 的基础结构如下：
```C++
struct std_string
{
    union
    {
        char buf[16];               // 字符串长度小于等于16，分配在栈上，否则分配在堆上
        char* ptr;
    }u;
    size_t size;
    size_t capacity;
};
```

GCC 的结构有一些差异，GCC返回指针指向缓存地址：

```C++
struct std_string
{
    size_t size;
    size_t capacity;
    size_t refcount;
};
```

#### std::list
有名的双链表，每个元素有两个指针，前向指针和后向指针。

`std::list` 特性如下：

* 前4byte为指针变量，变量内容为首个节点地址
* MSVC 实现在后面4byte记录列表长度，GCC获取长度需要遍历所有节点
* `list.begin()` 返回首个节点，`list.end()` 返回最后一个节点，MSVC空列表有一个节点放在首个节点位置，GCC放在最后一个节点
* `std::list`的最后一个节点的`next`指针指向首个节点。首个节点的`pre`指针指向最后一个节点
* `std::list<T>::iterator`变量的`++` 和 `--`操作，本质是指向下一个节点，或指向上一个节点
* C++11 加入了 `std::forward_list`为单向列表，只有`next`指针

MSVC 实现`list<Vector2>`结构如下：

```C++
struct Vector2
{
    int x;
    int y;
};

struct std_list
{
    struct Path* next;
    struct Path* pre;
    int x;
    int y;
};
```

#### std::vector
`std::vector` 是 C 数组的安全封装。MSVC 整型`vector<int>`数据结构如下：

```C++
struct vector_of_ints
{
    int* first;             // 首个元素指针
    int* last;              // 尾部元素指针
    int* end;               // buffer 结尾指针
};
```

`std::vector` 注意点如下：

* `std::vector` 每次压入元素后，如果空间不足，则需要重新申请内存空间，然后将旧的数据拷贝过去，MSVC增长为*50%*，GCC增长为*100%*
* `at` 函数有越界检查 `operator[]` 没有越界检查，但速度更快

#### std::map 和 std::set
二叉树是数据结构的基础。如名字所言，每个数的节点有至少和其他节点有两个链接。每个节点有*键* 和/或 *值*：`std::set`只有键值，`std::map`每个节点有键和值。

二叉树通常用来实现键-值对*字典("dictionaries")*。

二叉树有三个重要属性：

* 所有的键总是按照排序形式存储
* 任意类型键值存储消耗一致，因为二叉树算法不关心键值类型，只使用键值对比函数
* 相对`list`和数组的对象查找，查询键值非常快
* 实现字典的二叉树需要平衡，*红黑树(red-black tree)*，*AVL tree*是其实现算法

MSVC 实现`map<int, char*>` 结构如下：

```C++
struct Node
{
    struct Node* left;
    struct Node* parent;
    struct Node* right;
    char color;     // 0-red, 1-black
    char isNil;
    // set 只有key
    int key;
    char* value;
};

struct std_map
{
    struct Node* head;
    unsigned int size;
};
```

### 3.18.5 内存
在栈上分配内存:

```C++
void f()
{
    ...
    Class o = Class(...);
    ...
}
```

流程如下：

* 通过修改SP(stack pointer)，分配内存
* 函数退出前SP还原到之前的状态
* 并且析构函数调用

在堆上分配内存：

```C++
void f1()
{
    ...
    Class* o = new Class(...);
    ...
}

void f2()
{
    ...
    delete o;
    ...
}
```

流程如下：

* 调用`new`首先使用`malloc`在堆上分配内存，然后调用*构造函数*
* 释放堆上的内存必须显示调用`delete`，等价于先调用*析构函数*，在调用`free`

两种方式特性如下：

* 栈上分配内存速度快，退出作用域后自动释放，但是只能零时使用
* 栈上分配内存速度慢，需要主动释放内存，但是可长久保存内存引用内容

## 3.19 负数组索引
数组索引的访问原理为：

> 定义 *a* 为数组变量 
> 定义 *t* 为目标地址  
> 定义 *i* 为索引  
> t = a + i * sizeof(a[0])

所以如果 `i` 不同值，可以求出不同的`a`值。所以无论索引为 `0`还是为`1`，只要给出对应的`a`即可求出正确的解。


## 3.20 通过位操作将12-bit值存入数组
本节为练习课，通过8bit的数组存储12-bit的值。主要涉及到如何计算数组索引和通过位操作赋值数组和获取数组内容。

## 3.21 深入指针
指针本质是内存地址。但为啥不用地址而是要有`char*`指针类型，主要是为了让编译器来检查类型错误。

## 3.22 循环优化
通过减少使用变量数量，用巧妙的方式将变量合并。

## 3.23 深入结构体
结构体本质是连续变量，由此引出了以下几个问题:

* 结构体如果成员变量类型一致，则结构体和数组一致
* 结构体在内存的读写为了加快速度，默认会对齐内存，使用 `align` 和 `padded`来强制不对齐
* 结构体通过指针传递结构体，为了版本升级，可以在结构体里添加变量，来判断具体版本结构体

## 3.24 memmove() 和 memcpy()
* `memcpy()` 直接从源复制内存内容到目标，如果源和目标地址有重叠，则复制内容不正确
* `memmove()` 会判断是否用重叠，如果有重叠则从内存尾端开始往起始段复制，无重叠的话和 `memcpy`一致

## 3.25 setjmp/longjmp
`setjmp`设置对应的跳转点。`longjmp`触发跳转到`setjmp`设置的点。`setjmp`保存了调用点的寄存器变量，`longjmp`通过参数将寄存器变量恢复，然后跳转到`setjmp`的调用地址。

## 3.26 栈野路子hack
其实还是利用函数调用时的栈结构，通过参数类型，反向推算出整个栈上的值，然后就可以尽情修改和利用。

## 3.27 OpenMp
OpenMP是最简单实现简单算法并行的方式。