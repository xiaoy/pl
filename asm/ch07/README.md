# Chapter 7: 整数运算
本章介绍二进制的移动和旋转技术，汇编语言强项中的一个技术。事实上，位操作是计算机图形学，数据加密，硬件操作中不可或缺的部分。这部分的指令在这些领域非常强力，高级语言只实现了部分，或者是平台相关的。
## 7.1 移动和旋转指令
移动bit位意味着在操作数内部向左或向右移动bit。x86处理器提供了丰富的指令集，如下：

| 指令 | 说明            |
| ---- | --------------- |
| SHL  | 向左移动位      |
| SHR  | 向右移动位      |
| SAL  | 向左算数移动位  |
| SAR  | 向右算数移动位  |
| ROL  | 向左旋转        |
| ROR  | 向右旋转        |
| RCL  | 旋转carry位向左 |
| RCR  | 旋转carry为向右 |
| SHLD | 双精度向左移位  |
| SHRD | 双精度向右移位  |

### 7.1.1 逻辑移动和算数移动
逻辑移动，空留出的位，值为零

![](res/logic_shift.png)

算数移动，空留出的位，值为符号位对应值

![](res/arithmetic_shift.png)

### 7.1.2 SHL 指令
`SHL`(shift left) 指令对操作数执行逻辑向左移位，最低位置置为零。最高位移动到Carry标志位，在Carry 标志位的值被覆盖。

![](res/shl.png)

`SHL` 指令语法如下：
> SHL destination, count

`SHL` 指令操作数组合如下：
> SHL reg, imm8  
> SHL mem, imm8  
> SHL reg, CL  
> SHL mem, CL

x86 处理器将imm8值按照 [0, 255]范围处理，CL 寄存器可以包含转移数量。以上格式对 `SHR, SAL, SAR, ROR, ROL, RCR, RCL` 指令都适用。

`SHL` 指令使得操作数执行按位乘法，向左移动操作位n，等价于让操作数乘以 2^n。
### 7.1.3 SHR 指令
`SHR`(shift right) 指令对操作数执行向右移位，最高位置置为零。最低位移动到Carry标志位，在Carry 标志位的值被覆盖。

![](res/shr.png)

`SHR` 指令使得操作数执行按位触发，向右移动操作位n，等价于让操作数除以 2^n。

### 7.1.4 SAL 和 SAR 指令
`SAL`指令和 `SHL` 执行结果一致。

![](res/sal.png)

`SAR` 保留符号位，然后向右移位。

![](res/sar.png)

### 7.1.5 ROL 指令
`ROL`(rotate left) 指令向左移动位，最高位拷贝到Carry标志位和最低位。

![](res/rol.png)

### 7.1.6 ROR 指令
`ROR`(rotate right) 指令向右移动位，最低位拷贝到Carry标志位和最高位。

![](res/ror.png)

### 7.1.7 RCL 和 RCR 指令
`RCL` (rotate carry left) 指令向左移动位，将Carry标志位拷贝到LSB（最低有效位），将MSB （最高有效位）拷贝到Carry标志位。

![](res/rcl.png)

`RCR` (roate carry right) 指令向右移动位，将Carry标志位拷贝到MSB（最高有效位），将LSB（最低有效位）拷贝到Carry 标志位。
![](res/rcr.png)

可以将Carry为看做多出来了一位。

### 7.1.8 有符号溢出
执行指令后产生的数，超出操作数的范围，Overflow 标志位设置为1。

```asm
    mov al, +127        ; AL = 01111111b
    rol al, 1           ; OF = 1, AL = 11111110b

    mov al, -128        ; AL = 10000000b
    shr al, 1           ; OF = 1, AL = 0100000b
```
### 7.1.9 SHLD/SHRD 指令
`SHLD` (shift left double) 指令将目标操作数向左移动指定位数，然后将这些空出的位使用源操作数最大有效位做为起始位，填充对应长度。源操作数不受影响，但是 Sign, Zero, Auxiliary, Parity, Carry 标志位受影响。

![](res/shld.png)

`SHLD` 指令语法如下：
> SHLD   dest, source, count

`SHRD` (shift right double) 指令将目标操作数向右移动指定位数，然后将这些空出的位使用源操作数最小有效位作为起始位，填充对应长度。源操作数不收影响。

![](res/shrd.png)

`SHLD` 和 `SHLD` 操作数组合相同，如下：
> SHLD reg16, reg16, CL/imm8  
> SHLD mem16, reg16, CL/imm8  
> SHLD reg32, reg32, CL/imm8  
> SHLD mem32, reg32, CL/imm8  


## 7.2 Shift 和 Rotate 应用
### 7.2.1 移动多个双字节

### 7.2.2 二进制乘法

### 7.2.3 显示二进制位

### 7.2.4 展开文件日期字段

## 7.3 乘法和除法指令
### 7.3.1 MUL 指令

### 7.3.2 IMUL 指令

### 7.3.3 估量程序执行时间

### 7.3.4 DIV 指令

### 7.3.5 有符号整数除法

### 7.3.6 实现算数表达式

## 7.4 扩展加法和减法
### 7.4.1 ADC 指令

### 7.4.2 扩展加法例子

### 7.4.3 SBB 指令

## 7.5 ASCLL 和 未打包十进制运算

### 7.5.1 AAA 指令

### 7.5.2 AAS 指令

### 7.5.3 AAM 指令

### 7.5.4 AAD 指令

## 7.6 打包十进制运算
###  7.6.1 DAA 指令

### 7.6.2 DAS 指令