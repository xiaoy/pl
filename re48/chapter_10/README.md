# chapter10:动态二进制检测
*DBI*  工具可以看做是更高级和快速的调试器。

## 10.1 使用 PIN DBI 来截获 XOR
*PIN* 是来自Intel的 *DBI* 工具。这个工具可以直接运行编译后的二进制文件并且可以插入任何指令。

加密软件是 `XOR` 指令的重度用户，作者使用 **WinRAR** 加密码的方式压缩文件，同时通过 *PIN* 来统计 `XOR`的调用。

作者准备了两个文件：test1.bin(30720字节)以及 test2.bin(5547752字节)。

关闭 *ASLR-Address Space Layout Randomization*，这样 *PIN* 在调用`XOR`指令的地址(RIP)将保持一致，方便对比。

执行如下命令：

```shell
c:\pin-3.2-81205-msvc-windows\pin.exe -t XOR_ins.dll -- rar a -pLongPassword tmp.rar test1.bin
c:\pin-3.2-81205-msvc-windows\pin.exe -t XOR_ins.dll -- rar a -pLongPassword tmp.rar test2.bin
```

*PIN* 运行后，得到相应运行 `XOR` 的地址和次数，然后找到相应地址对应的代码，得到如下结论：

* 文件大的，运行 `XOR` 指令次数多
* 使用了 *AES* 加密算法
* 使用了 *SHA-1* 

## 10.2 使用 PIN 破解 Minesweeper

前面章节讲了破解Windows XP 下的 Minesweeper。

Windows Vista 和 7 上的 Minesweeper 不同，也许是使用C++编写，格子信息没有存在全局数组，而是存在分配的栈内存上。

### 10.2.1 追踪 rand() 调用
因为 Minesweeper 随机放置地雷，需要调用 `rand()` 或相似的函数。所以追踪随机函数调用来通过日志打印返回值和返回地址，通过游戏的格子数以及随机函数的调用次数，很快定位到放置地雷的函数`Board::placeMines()`。

### 10.2.2 使用自己的函数替换 rand() 调用
将随机函数返回值替换为零，和 Windows XP 下的表现不一致，在破坏了随机函数后，地雷还是按一定的规则排布。

### 10.2.3 窥视地雷的放置
随机函数不影响生成地雷，当随机函数返回0时，只导致地雷位置连成了一条线。

如果用程序员自己的思路实现，代码大概如下：

```C++
for(int i; i < mines_total; ++i)
{
    // get coordinates using rand()
    // put a cell: in other words, modify a block allocated in heap
}
```

如何获取堆内存被修改的信息？

1) 通过追踪 `malloc()/realloc()/free()` 的调用得知堆分配
2) 追踪所有内存写入(慢)
3) 截断随机函数调用

当前算法就变为：

1) 标记所有在第一次和第二次调用 `rand()` 函数中间堆内存被修改的时刻
2) 当堆被释放时(调用 `free()`)时，输出其内容

只有 4 个堆内存在第一次和第二次随机函数调用中间被修改。最大的堆内存大小是0x140字节，转换为32位整数，就是0x50个，对应十进制数为80。当前是 9*9的棋盘，很明显80就是对应内容。通过调查发现这块内存是2维数组，将其内容打印出来得到雷的分布。