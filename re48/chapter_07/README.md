# Chapter 7: 工具
## 7.1 二进制分析
以下工具不需要运行进程：

* (免费，开源) [ent](http://www.fourmilab.ch/random/)：entropy 分析工具
* [Hiew](http://hiew.ru)：用来修改二进制文件里的代码，有汇编器和反汇编器
* (免费，开源) [GHex](https://wiki.gnome.org/Apps/Ghex)：Linux下的16进制编辑器
* (免费，开源) xxd and od：标准UNIX dump 工具
* (免费，开源) strings：*NIX工具用来搜索二进制文件里的ASCII字符串
* (免费，开源) [Binwalk](http://binwalk.org/)：用来分析固件系统
* (免费，开源) 搜素二进制文件里的字节序列

### 7.1.1 反汇编器

* IDA
* Binary Ninja
* (免费，开源) zynamics BinNavi
* (免费，开源) objdump
* (免费，开源) readelf

### 7.1.2 反编译器

Hex-Rays

### 7.1.3 补丁对比
两个可执行文件对比，使用以下工具：

* (免费) zynamics BinDiff
* (免费，开源) Diaphora

## 7.2 动态分析
### 7.2.1 调试器
用在正在运行的系统或运行的进程的工具。

* (免费) OllyDbg，非常流行的用户模式 win32 调试器
* (免费，开源) GDB，逆向工程师不流行，程序员很流行
* (免费，开源) LLDB
* WinDbg：Windows 内核调试器
* IDA 有内置调试器
* (免费，开源) Radare AKA rada.re AKA r2，图形界面：ragui
* (免费，开源) tracer

### 7.2.2 库调用追踪
ltrace

### 7.2.3 系统调用追踪
strace / dtruss

### 7.2.4 网络嗅探

* Writeshark
* tcpdump

### 7.2.5 Sysinternals

* Process Explore
* Handle
* VMMAP
* TCPView
* Process Monitor

### 7.2.6 Valgrind

免费，开源工具，用来探测内存泄露

### 7.2.7 模拟器

* (免费，开源) QEMU：模拟多种CPU和架构
* (免费，开源) DosBOx：MS-DOS 模拟器
* (免费，开源) SimH：老的电脑模拟器

## 7.3 其他工具

* Microsoft Visual Studio 简易版
* Compiler Explorer

### 7.3.1 计算器
逆向人员使用的计算器至少支持，十进制，十六进制以及二进制，同样支持异或，移位等操作

* IDA 有内置计算器 ("?")
* rada.re 有 rax2
* windows 计算器
* 作者自己写的 [progcalc](https://github.com/DennisYurichev/progcalc)