# chapter6：系统相关
## 6.1 传递函数参数(调用方法)
### 6.1.1 cdecl
调用C/C++ 函数传递参数的方式，当函数调用完毕需要还原栈指针(ESP)的调用前的状态。

```asm
push arg3
push arg2
push arg1
call function
add esp, 12         ; return esp
```

### 6.12 stdcall
和*cdecl*传递参数的方式一致，但是ESP的状态是被调用函数维护，通过执行`RET x`，`x = arguments number * sizeof(int)`。

```asm
push arg3
push arg2
push arg1

call function

funciton:
...do something...
ret 12
```

对于变参函数，使用*cdecl*在编译时，知道参数的个数，直接通过`add`指令重置esp，对于*stdcall*，需要函数在执行时，通过遍历字符串得到参数个数，然后在通过`ret x`来重置esp。

### 6.1.3 fastcall
一些参数通过寄存器传递，其他使用栈传递，每家编译器对*fastcall*实现不一致。被调用函数来重置esp。**MSVC**和**GCC** 头两个参数通过 **ECX**和**EDX**来传递，其他使用栈。

```asm
push arg3
mov edx, arg2
mov ecx, arg1
call function

function:
.. do something ..
ret 4
```

### 6.1.4 thiscall
在 C++里将对象通过`this`指针传递给函数。

**MSVC** 通过 **ECX** 寄存器传递，**GCC** 函数的首个参数为`this`指针。

### 6.1.5 x86-64
#### Windows x64
前四个参数通过`RCX,RDX,R8,R9`传递，其他通过栈传递。被调用函数需要准备32 bytes(4 64-bit)空间来存储寄存器，函数处理内容多的时候，寄存器不够用时，可以从保留地址找到函数参数。

被调用函数需要自己维护**ESP** 寄存器。

传递`this`指针通过**ECX**。

#### Linux 64
传递参数方式和Windows一致，但是使用6个寄存器`RDI,RSI,RDX,RCX,R8,R9`，并且不需要申请额外空间来存储寄存器值。

### 6.1.6 返回float和double 类型
在 Win64 通过 **XMM0** 寄存器，其他通过 FPU 的**ST(0)** 寄存器。

### 6.1.7 修改栈内容
由于函数返回后，栈指针**ESP**会被还原，所以修改栈上的内容没有意义。

### 6.1.8 函数参数使用指针
在当前函数里的栈空间是安全的，局部变量指针可以传递给其他函数进行修改，在函数退出前时有效的。

## 6.2 线程局部存储(Thread Local Storage)
*TLS*是一个数据区域，每个线程有独立区域。C++ 11 标准里新加了修饰词`thread_local`来申明*TLS*变量。

```C++
#include <iostream>
#include <thread>

thread_local int tmp = 3;
int main()
{
    std::count << tmp<<std::endl;
}
```

## 6.3 系统调用(syscall-s)
运行在系统中的进程分为两类：一类由访问硬件的全部权利("kernel space")，另一类没有("user space")。

系统内核和驱动通常是第一类。所有应用程序在第二类。

系统调用(syscal-s)是连接这两类进程的通道。

linux 中使用 `int 0x80`参数通过EAX

Windows 中使用 `int 0x2e` 或指令 `SYSENTER`

## 6.4 Linux
### 6.4.1 非固定地址代码(Positin-independent code-pic)

在Linux里动态库(.so 文件)，加载一次，然后所有进程共享，如何做到所有进程正确调用动态库函数？

动态库通过编译参数`gcc -fPIC -shared` 来指定编译的库函数在调用库变量时使用相对位置，正常获取变量内容，都是通过变量地址去获取。

Linux的巧妙之处就在于动态库函数指令地址和变量地址之间的距离是确定的，所以使用指令执行地址加上两者之间的距离，即可正确映射到正确的动态库变量地址。

#### Windows
Windows里没有**PIC**这种机制。当Windows的加载器需要加载到另一个不同的基址进程，通过"补丁(patches)"修改dll在内存里的函数和变量地址，来让程序正常调用dll变量和函数。

因此Windows不同基址进程不能共享加载到内存里的dll，因为每个进程都需要根据自己的地址修改dll的地址。

### 6.4.2 LD_PRELOAD hack in Linux
此参数用来提前加载指定动态库，这就可以让自己指定的动态库函数顶替程序使用到的动态库。

## 6.5 Windows NT
### 6.5.1 CRT(win32)
程序在执行`main()`函数前会做一些准备和维护工作，然后将控制权交给`main()`函数。这个预先运行的代码称作启动代码(startup-code)或CRT代码(C RunTime)。

`main()`函数使用从命令行传递管理的参数数组以及环境变量数组。事实上是字符串传递到程序，CRT代码通过空格将字符串分割。CRT代码同时也准备环境变量数组(envp)内容。

Win32 GUI程序使用`WinMain`代替`main`，并且有自己的参数：

```C++
int CALLBACK WinMain(
  _In_ HINSTANCE hInstance,
  _In_ HINSTANCE hPreInstance,
  _In_ LPSTR lpCmdLine,
  _In_ int nCmdShow
)
```

CRT code 也准备这些参数。`main()`函数返回的值被当做退出值，当做`ExitProcess`调用。通常每个编译器有自己的CRT代码。

C++的全局变量初始化也发生在CRT代码运行时，在`main`函数之前。

当然编译器也有支持不调用CRT的，比如 MSVC指定编译选项`/ENTRY`来设置调用点。

### 6.5.2 Win32 PE
PE(Portable Executable)是在Windows上的可执行文件。*.exe*，*.dll* 和*.sys*文件的区别是：*.exe* 和 *.sys*通常没有导出表(exports)，只有导入表(imports)。

一个DLL文件，类似于其他PE文件，有一个入口(Orignal Entry Point - OEP)函数`DllMain()`，但这个入口函数啥也不做。*.sys*通常是设备驱动。作为驱动，Windows要求PE文件里包含checksum来验证正确性。

从Windows Vista 开始，驱动文件必须要有数字签名，否则将加载失败。

#### 术语
* 模块(Module)-独立文件，*.exe* 或 *.dll*
* 进程(Process)-加载到内存里正在运行的程序。通常包含一个 *.exe*文件和多了个 *.dll* 文件
* 进程内存(Process memory)-进程使用的内存。每个进程有自己的内存区域。它们用来加载模块，供栈和堆使用，以及其他
* 虚拟地址(Virtual Address-VA)-在程序运行中使用的地址
* 基础地址(Base address of module)-进程内存中加载模块的地址。如果基础地址已经被其他加载的模块占用，系统加载器会修改基础地址
* 相对地址(Relative virtual address)-虚拟地址减去基础地址，许多在PE文件表里地址使用**RVA**地址
* 导入地址表(Import address table-IAT)-导入符号地址数组。有时，`IMAGE_DIRECTORY_ENTRY_IAT`数据目录指向IAT。IDA会为IAT分配伪段名字 `.idata`
* 导入名字表(Import names table-INT)-导入符号名字数组

#### 基础地址
每个dll都有自己的基础地址，如果一个程序中使用的dll使用了相同的基础地址，后加载的dll会被加载器加载到往后的空闲内存，在第二个dll的地址将会被修正。

也可以通过设置参数 `IMAGE_DLL_CHARACTERISTICS_DYNAMIC_BASE` 来让加载的dll基础地址随机。一个是减少不同dll使用相同基础地址冲突问题，另一个是可以增加安全性，比如windows的核心dll的基础地址固定，shellcode 就可以直接使用固定地址调用系统函数。

#### 子系统
PE文件里有 *subsystem* 字段，通常如下：

* native (.sys-driver)，调用本地api，不适用win32 api
* console 控制台应用
* GUI (图形界面应用)

#### 系统版本(OS version)
PE 文件制定最低运行自身的Windows版本。

#### 段(sections)
段用来分离代码和数据，以及数据到常量数据。

* 代码段，设置 `IMAGE_SCN_CNT_CODE` 或 `IMAGE_SCN_MEM_EXECUTE` 标记来标识这是可执行代码
* 数据段，设置 `IMAGE_SCN_CNT_INITIALIZED_DATA`，`IMAGE_SCN_MEM_READ`，`IMAGE_SCN_MEM_WRITE` 标记
* 未初始化数据段，设置 `IMAGE_SCN_CNT_UNINITIALIZED_DATA`，`IMAGE_SCN_MEM_READ`，`IMAGE_SCN_MEM_WRITE` 标记
* 常量段，设置 `IMAGE_SCN_CNT_INITIALIZED_DATA`，`IMAGE_SCN_MEM_READ`，未设置`IMAGE_SCN_MEM_WRITE` 标记，阻止写入此段

每个段在PE文件里可能有个名字，但并不是很重要，常用的短命子如下：

* .text 代码段
* .data 数据段
* .rdata 常量段
* .idata 导入段
* .edata 导出段
* .pdata 存储异常信息的段
* .reloc 迁移段
* .bss 未初始化数据段
* .tls 线程局部空间
* .rsrc 资源段

### 6.5.3 Windows SEH

在Windows里，SEH(Structured Exception Handling)异常处理机制。

每个运行进程有SEH处理链，每个 TIB(Thread information block)有一个最新处理异常函数的地址。

当异常发生(除零，错误地址访问，用户通过调用`RasiseException()`函数触发的异常)，系统找到TIB里的最后一个处理函数并调用它，将此刻所有的CPU状态信息，以及异常类型传递给函数。

异常函数处理异常，如果可以处理，则处理。如果处理不了，通知系统无法处理，系统继续调用处理链条里的下一个函数，知道找到可以处理异常的函数。直到最终显示Windows自己的异常处理窗口。

### 6.5.4 Windows NT: 戒严部分(Critical section)
戒严部分在所有系统的多线程环境非常重要，大多数用在保证某一时刻只有一个线程可以访问一些数据，同时阻止其他线程介入。

进入戒严部分，首先会判断`LockCount`，如果没有线程锁定，即可增加此值，当其他线程进入时，就需要等待。当退出时，`LockCount`减一，释放锁定。

