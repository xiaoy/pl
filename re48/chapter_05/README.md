# Chapter5: 探寻代码里重要特征
当今的软件都非常的庞大，但这并不是说所有的功能都是程序员自己写的。很多时候引用了公共库，这时候通过查找编译后代码里的特征反向找到使用的库。如果能找到所使用库的源代码，反编译工作将事半功倍。

## 5.1 可执行文件特征

### 5.1.1 Microsoft Visual C++
MSVC 版本和DLLS可以被导入：

| Marketing ver. | Internal ver. | CL.EXE ver. | DLLs imported              | Release date       |
| :------------- | :------------ | :---------- | :------------------------- | :----------------- |
| 6              | 6.0           | 12.00       | msvcrt.dll msvcp60.dll     | June 1998          |
| .NET(2002)     | 7.0           | 13.00       | msvcrt70.dll msvcp70.dll   | February 13, 2002  |
| .NET(2003)     | 7.1           | 13.00       | msvcrt71.dll msvcp71.dll   | April 24, 2003     |
| 2005           | 8.0           | 14.00       | msvcrt80.dll msvcp80.dll   | November 7, 2005   |
| 2008           | 9.0           | 15.00       | msvcrt90.dll msvcp90.dll   | November 19, 2007  |
| 2010           | 10.0          | 16.00       | msvcrt100.dll msvcp100.dll | April 12, 2010     |
| 2012           | 11.0          | 17.00       | msvcrt110.dll msvcp110.dll | September 12, 2012 |
| 2013           | 12.0          | 18.00       | msvcrt120.dll msvcp120.dll | October 17, 2013   |

msvcp*.dll 包含有C++相关的函数，如果被导入很有可能是C++程序。

#### 名字混淆
名字通常使用 `?`开头。

### 5.1.2 GCC
除了 *NIX 目标平台， GCC在win32环境也存在，以 *Cygwin* 和 *MinGW*的形式存在。

* 变量名通常使用 `_Z`字符开头
* *Cygwin* 通常 *cygwin1.dll* 被导入
* *MinGW* 通常 *msvcrt.dll* 被导入

### 5.1.3 Intel Fortran
libifcoremd.dll，libifprotmd.dll 以及 libiomp5md.dll(OpenMP支持)可能会被导入。

libifcoremd.dll 有许多函数使用 `for_` 作为函数开头，代表*Fortran*。

### 5.1.4 Watcom,OpenWatcom
名字通常以 *W*开始。例如以下为类对应的无参数返回*void*的函数：

> W?method$\_class\$n__V

## 5.2 和外部世界通信(函数级别)
通过函数的输入参数和返回值来判断函数的作用。

## 5.3 和外部世界通信(win32)
通过外部的输入和输出可以得到某些函数要完成的任务。

比如文件和注册表的访问：[Process Monitor](http://go.yurichev.com/17301)可以进行非常基础的分析

对于网络的访问，Wireshark 非常有用。

但总有不得不探寻程序内部实现的时候。

首要的事情就是查找调用的那些系统API和标准库。如果程序分为主执行程序和一组DLL文件，有时候在DLL里的函数名字有帮助。

如果对什么导致`MessageBox()`弹出指定的文本感兴趣，我们可以尝试在数据段找到此文本，然后找到传递给`MessageBox()`函数的点。

### 5.3.1 Windows API里常用的函数
程序里会引入很多系统库和标准库，所以熟知一些常用库里的函数名字非常有帮助。

一些函数使用 `-A`开头为 ASCII 版本，使用`-W`开头的为Unicode版本。

* 注册表访问(advapi32.dll):`RgeEnumKeyEx,RegEnumValue, RegGetValue, RetOpenKeyEx, RegQueryValueEX`
* 访问 `.ini`文本文件(kernel32.dll):`GetPrivateProfileString`
* 确认框(user32.dll):`MessageBox,MessageBoxEx, CreateDialog, SetDlgItemText, GetDlgItemText`
* 资源访问:(user32.dll):`LoadMenu`
* TCP/IP 网络(ws2_32.dll): `WSARecv, WSASend`
* 文件访问 (kernel32.dll):`createFile, ReadFile, ReadFileEx, WriteFile, WriteFileEx`
* 高层访问网络(wininet.dll):`WinHttpOpen`
* 检查可执行文件数字签名(wintrust.dll):`WinVerfityTrust`
* 标准MSVC库(msvcr*.dll):`assert, itoa, itoa, open, printf, read, strcmp, atol, atoi, fopen, fread, fwrite, memcmp, rand, strlen, strstr, strchr`

### 5.3.2 增加有效时间
通常是将注册时间写入注册表，所以通过修改注册表可以修改安装时间。

另一种方式修改`GetLocalTime` 和`GetSystemTime` 这两个函数来达到破解的目的。

### 5.3.3 删除注册弹框
通过拦截函数`MessageBox, CreateDialog, CreateWindows`找到对应弹出注册框的地方。

### 5.3.4 tracer: 拦截在指定库里的所有函数
使用`tracer`可以设定 INT3 断点，只触发一次，但可以设置指定dll里的所有函数：

> --one-time-INT3-bp:somedll.dll!.*

或者还可以指定筛选，比如指定 xml 开头的函数：

> --one-time-INT3-bp:somedll!xml.*

## 5.4 字符串

### 5.4.1 文本字符串

* C/C++ 使用零结尾(zero-terminated)字符串
* Borland Delphi 使用8bit或16-bit 字符串开头
* Unicode是将字符对应成数字的标准，而不是具体的方法
* UTF-8是动态编码，ASCII占用8-bit不变，其他按照UTF-8的定义来编码
* UTF-16LE win32 函数使用的编码。每个字符占用16bit
* Base64 将二进制数据转换为文本字符串，算法将3个资金之字节转换为4个打印字符：26个拉丁字母(大小写),数组，加号(+),以及(/)，64个字符。

### 5.4.2 寻找二进制里的字符串

探寻二进制里可读字符串是分析的第一步，**grep** 命令，**Hiew(Alt-F6)**，以及**ProcessMonitor**都是查看字符串的好帮手。

### 5.4.3 错误/调试信息

应用程序输出的日志信息，以及错误日志会暴露程序中用到的字符串，通过这些信息可以知道调用堆栈，函数名，以及使用的字符串。

### 5.4.4 可疑的神奇字符串

一些看起来非常可以的神奇字符串通常用作后门，比如*TP-Link WR740 home router* 路由器的后门，使用了字符串*userRpmNatDebugRpm26525557*。

## 5.5 调用 assert()
汇编代码里有调用`assert`宏，调用此宏需要传递参数，这些参数包含文件名，以及assert的条件语句，通过这些信息搜索google，可以查到有用的信息。

## 5.6 常量

* 熟悉常用常数，比如：`10=0xA, 100=0x64,1000=0x3E8, 10000=0x2710`
* 转换常量，比如:`0xAAAAAAAA(0B10101010101010101010101010101010),0x5555555(0b01010101010101010101010101010101)`
* 常用算法，比如MD5使用的常量初始化，CRC16/CRC32

### 5.6.1 神奇数字
许多文件使用一个或多个数字来文件头。比如：

* Win32 和 MS-DOS 可执行文件使用 **"MZ"** 开头
* **MIDI** 文件使用**MThd**开头
* 日期的格式比较固定，比如 **0x19870116**，所以也是一项信息
* DHCP使用神奇数字**63538263**

### 5.6.2 特殊常量
一些常量反复出现，可能有特殊的意义，比如输入框的长度限制。

### 5.6.3 搜索常量
在 IDA里使用*Alt-B* 或 *Alt-l*。或使用 *binary grep*。

## 5.7 查找正确的指令

* 先通过IDA导出 *lst* 文件
* 再通过 *grep* 命令筛选出可能指令
* 在这些指令点下断点，使用工具tracer
* 输入常量数字后，通过查看寄存器和指令确认找到代码执行点

## 5.8 可疑代码模式

* `xor` 指令用来加密，解密，以及将寄存器设置为0
* `loop` 手写汇编，因为编译器不是用`loop`，使用`jmp`

## 5.9 当tracing时使用神奇数字
使用tracer调试时，输入参数使用自定义数字，帮助迅速定位到程序调用点。

## 5.10 循环
连续几个指令执行了相同的次数，基本判断是在循环处理数据。

* 不同的文件有自己的模式
* 内存快照对比，可以找出程序执行过程

## 5.11 ISA 检测
最简单的方式使用 IDA，objdump 或其他反汇编器。

辨别反编译的结果是否正确，需要熟悉不同架构下的代码指令，如果汇编代码中出现不同平台的指令，必然是不正确的反编译。