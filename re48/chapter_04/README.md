# Chapter4:Java
## 4.1 简介
反编译*JVM-bytecode*相比*低等级x86代码*容易一些，原因如下：

* 关于数据类型有更多的信息
* JVM 内存模型更加的严格和清晰
* Java编译器不做任何优化(JVM JIT 在运行时优化)，所以在class 文件里的*byte-code*可读性很高

JVM的知识可以用在哪里：

* 对于class文件的快速和粗暴的补丁任务，不需要重编译和反编译
* 分析混淆代码
* 创建自己的混淆器
* 创建一个代码(后端)生成器生成在JVM上运行的代码(比如 Scala, Clojure, etc)

反编译class文件的命令如下：

> javap -c -verbose

## 4.2 返回值
在Java的通识里，Java 没有”自由“的函数，它们都是”方法“。本质意思是Java的函数都必须定义在类里。

先看最简单的函数，返回一个值：

```Java
public class ret
{
    public static int main(String[] args)
    {
        return 0;
    }
}
```

Java 版本为:1.8.0 编译命令为：

> javac ret.java


反编译指令为：

> javap -c -verbose ret.class

反编译代码为：

```Java
public static int main(java.lang.String[]);
descriptor: ([Ljava/lang/String;)I
flags: (0x0009) ACC_PUBLIC, ACC_STATIC
Code:
    stack=1, locals=1, args_size=1
        0: iconst_0
        1: ireturn
```

Java 开发者决议在编程中0是最频繁使用的常量之一，因此这里分离出长度为 short one-byte的`iconst_0`指令压入 0。这里还有 `iconst_1`，`iconst_2`，etc，一直到 `iconst_5`。

`iconst_m1` 压入 -1。

JVM使用栈来传递调用函数的参数以及返回变量。所以`iconst_0`将0压入栈， `ireturn` 将整数值从栈顶(TOS-Top of stack)返回。

Java 返回值对应关系如下：

* 当返回值是`-1,0,1,3,4,5`这些常量，使用JVM内置指令压入栈，然后使用`ireturn`
* 当返回值是16bit长度时，使用指令`sipush 1234`，sipush(short integer)，然后使用`ireturn`
* 当返回值是32bit长度时，使用指令`ldc #2    // int 12345678`，因为指令长度不超过32bit，因此常量放在常量池，然后通过索引加载到栈，最后使用`ireturn`
* 当返回值是`boolean`类型时，使用指令`iconst_1`或`iconst_0`压入栈，然后使用`ireturn`
* 当返回值是`char`类型时，使用指令`bipush 65    // 'A' = 65`压入栈，然后使用`ireturn`
* 当返回值是`long/double`类型时，使用指令`ldc2_w #2     // long 123456790123456789l`压入栈，本质是将两个字(word 32位)压入栈，然后使用`lreturn/dreturn`
* 当返回值是`float`类型时，使用指令`ldc #2  // float 123.456f`压入栈，和`int`类型一致，因为都是32bit，返回时使用`freturn`
* 当没有返回值是，使用指令`return`

## 4.3 简单计算函数
简单的计算函数：

```Java
public class calc
{
    public static int half(int a)
    {
        return a/2;
    }
}
```
结果如下：

```Java
public static int half(int);
descriptor: (I)I
flags: (0x0009) ACC_PUBLIC, ACC_STATIC
Code:
    stack=2, locals=1, args_size=1
    0: iload_0
    1: iconst_2
    2: idiv
    3: ireturn
```

`iload0` 将第零个参数压入栈。

`iconst2`将 2 压入栈，前两个指令执行完栈结构如下：

```Java
        +---+
TOS   ->| 2 |
        +---+
        | a |
        +---+
```

`idiv`使用TOS上的两个值，使用第二个除以第一个，然后将结构留在栈顶：

```Java
        +--------+
TOS   ->| result |
        +--------+
```

总结：
* `{0}_load_{1}`，将函数参数压入栈，参数0为数据类型，比如：`int,long,float, double`，参数1对应的插槽(slot)，每个插槽为32bit长度
* `{0}add/div/mul` 参数0为数据类型
* `{0}return` 参数0为数据类型，用来返回值

## 4.4 JVM 内存模型
x86和其他低级环境使用栈来传递参数或局部变量，JVM 不同：

* 局部变量数据(local variable array-LVA)。用来存储函数参数和局部变量，`istore`将值设置到LVA
* 操作栈。用来计算和调用其他函数时传递参数，低等级环境(x86)做不到直接操作具体的栈内容
* 堆用来存放对象和数组

## 4.5 简单函数调用
以下为调用`Math.random()`返回范围为[0.0,1.0)的随机数，此函数返回范围为[0.0, 0.5)的随机数。

```Java
public class HalfRandom
{
    public static double f()
    {
        return Math.random()/2;
    }
}
```

```Java
...
#7 = Methodref          #8.#9          // java/lang/Math.random:()D
#8 = Class              #10            // java/lang/Math
#9 = NameAndType        #11:#12        // random:()D
#10 = Utf8               java/lang/Math
#11 = Utf8               random
#12 = Utf8               ()D
#13 = Double             2.0d
...

public static double f();
descriptor: ()D
flags: (0x0009) ACC_PUBLIC, ACC_STATIC
Code:
    stack=4, locals=0, args_size=0
        0: invokestatic  #7                  // Method java/lang/Math.random:()
        3: ldc2_w        #13                 // double 2.0d
        6: ddiv
        7: dreturn
```

函数调用说明如下：

* `invokestatic` 调用函数`Math.random()`，将结果返回到栈顶
* 将常量2.0d 加载到栈
* 执行`ddiv`将结构留在栈顶
* `dreturn` 返回结果

## 4.6 调用 beep()
代码如下：

```Java
public class Beep
{
    public static  void main(String[] args) {
       java.awt.Toolkit.getDefaultToolkit().beep();
    }
}
```

编译后代码如下：

```Java
...
  #7 = Methodref          #8.#9          // java/awt/Toolkit.getDefaultToolkit:()Ljava/awt/Toolkit;

  #8 = Class              #10            // java/awt/Toolkit
  #9 = NameAndType        #11:#12        // getDefaultToolkit:()Ljava/awt/Toolkit;
 #10 = Utf8               java/awt/Toolkit
 #11 = Utf8               getDefaultToolkit
 #12 = Utf8               ()Ljava/awt/Toolkit;
 #13 = Methodref          #8.#14         // java/awt/Toolkit.beep:()V
 #14 = NameAndType        #15:#6         // beep:()V
 #15 = Utf8               beep
...
  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: (0x0009) ACC_PUBLIC, ACC_STATIC
    Code:
      stack=1, locals=1, args_size=1
         0: invokestatic  #7                  // Method java/awt/Toolkit.getDefaultToolkit:()Ljava/awt/Toolkit;
         3: invokevirtual #13                 // Method java/awt/Toolkit.beep:()V
         6: return

```

说明：
* `invokestatic` 先获得`Toolkit`对象
* 调用`beep`函数时需要`this`指针，通过栈顶传递

## 4.7 线性随机生成器
代码如下：

```Java
public class LCG
{
    public static int rand_state;

    public void my_srand(int init)
    {
        rand_state = init;
    }

    public static int RNG_a = 1664525;
    public static int RNG_c = 1013904223;

    public int my_rand()
    {
        rand_state = rand_state * RNG_a;
        rand_state = rand_state + RNG_c;
        return rand_state & 0x7fff;
    }
        
}
```

首先在构造函数之前，初始化静态变量：

```Java
static {};
descriptor: ()V
flags: (0x0008) ACC_STATIC
Code:
    stack=1, locals=0, args_size=0
        0: ldc           #19                 // int 1664525
        2: putstatic     #13                 // Field RNG_a:I
        5: ldc           #20                 // int 1013904223
        7: putstatic     #16                 // Field RNG_c:I
    10: return
```

接下来是两个函数编译结果：

```Java
public void my_srand(int);
descriptor: (I)V
flags: (0x0001) ACC_PUBLIC
Code:
    stack=1, locals=2, args_size=2
        0: iload_1
        1: putstatic     #7                  // Field rand_state:I
        4: return

public int my_rand();
  descriptor: ()I
  flags: (0x0001) ACC_PUBLIC
  Code:
    stack=2, locals=1, args_size=1
       0: getstatic     #7                  // Field rand_state:I
       3: getstatic     #13                 // Field RNG_a:I
       6: imul
       7: putstatic     #7                  // Field rand_state:I
      10: getstatic     #7                  // Field rand_state:I
      13: getstatic     #16                 // Field RNG_c:I
      16: iadd
      17: putstatic     #7                  // Field rand_state:I
      20: getstatic     #7                  // Field rand_state:I
      23: sipush        32767
      26: iand
      27: ireturn
```

`getstatic`将对应标签的值压入栈，`putstatic`将栈顶的值写入对应标签对应值。

## 4.8 条件跳转
先来看一段简单代码：

```Java
public class abs
{
    public static int abs(int a)
    {
        if(a < 0)
        {
            return -a;
        }
        return a;
    }
}
```

编译结果如下：
```Java
public static int abs(int);
  descriptor: (I)I
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=1, locals=1, args_size=1
       0: iload_0
       1: ifge          7
       4: iload_0
       5: ineg
       6: ireturn
       7: iload_0
       8: ireturn
```

如果栈顶的值大于等于0，`ifge`跳转到步长7，同时类似于`ifxx`的指令将比较的值从栈顶弹出。

条件跳转指令总结：

* `if_{0}cmp{1}`比较两个参数,参数一为数据类型比如`i,d,f,b`，参数二为比较参数`ge,le,ne`分别为*大于等于,小于等于，不等于*，并且会弹出两个对比参数
* `ifge,ifle,ifne` 分别为*大于等于零，小于等于零，不等于零*
  
## 4.9 传递参数
程序实现了简单的`min()/max()`函数：

```Java
public class minmax
{
    public static int max(int a, int b)
    {
        if(a > b)
        {
            return a;
        }
        return b;
    }

    public static int min(int a, int b)
    {
        if(a > b)
        {
            return b;
        }
        return a;
    }

    public static void main(String[] args)
    {
        int a = 123, b = 456;
        int maxV = max(a, b);
        int minV = min(a, b);
        System.out.println(maxV);
        System.out.println(minV);
    }
}
```

编译后的结果为：

```Java
public static int max(int, int);
  descriptor: (II)I
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=2, args_size=2
       0: iload_0
       1: iload_1
       2: if_icmple     7
       5: iload_0
       6: ireturn
       7: iload_1
       8: ireturn

public static int min(int, int);
  descriptor: (II)I
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=2, args_size=2
       0: iload_0
       1: iload_1
       2: if_icmple     7
       5: iload_1
       6: ireturn
       7: iload_0
       8: ireturn

public static void main(java.lang.String[]);
  descriptor: ([Ljava/lang/String;)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=5, args_size=1
       0: bipush        123
       2: istore_1
       3: sipush        456
       6: istore_2
       7: iload_1
       8: iload_2
       9: invokestatic  #7                  // Method max:(II)I
      12: istore_3
      13: iload_1
      14: iload_2
      15: invokestatic  #13                 // Method min:(II)I
      18: istore        4
      20: getstatic     #16                 // Field java/lang/System.out:Ljava/io/PrintStream;
      23: iload_3
      24: invokevirtual #22                 // Method java/io/PrintStream.println:(I)V
      27: getstatic     #16                 // Field java/lang/System.out:Ljava/io/PrintStream;
      30: iload         4
      32: invokevirtual #22                 // Method java/io/PrintStream.println:(I)V
      35: return
```

要注意的是`istore_{0}` 第一个参数只能是`1,2,3`，超过`3`之后使用`istore number`指令。此指令是将栈顶的值放入局部变量数组，并且将栈顶值弹出。

这里和x86不一致的是，`istore`指令只有一个目标参数，因此就会出现重复的向栈顶压入值，然后转移到局部变量数组，都转入结束，再压入栈。

`iload`和`istore`是一对指令，分别用来从局部变量数组获取值，以及写入值。每个函数有自己的局部变量数组和栈。
## 4.10 位
Java的位操作和x86非常相似，只是有类型区别，比如`ishl,ior,ixor`。同时还有数组类型转换，比如`i2l`。
## 4.11 循环
`for`循环代码如下：

```Java
public class loop
{
    public static void main(String[] args)
    {
        for(int i = 0; i < 10; ++i)
        {
            System.out.println(i);
        }
    }
}
```

编译结果为：
```Java
public static void main(java.lang.String[]);
descriptor: ([Ljava/lang/String;)V
flags: (0x0009) ACC_PUBLIC, ACC_STATIC
Code:
    stack=2, locals=2, args_size=1
        0: iconst_0
        1: istore_1
        2: iload_1
        3: bipush        10
        5: if_icmpge     21
        8: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
       11: iload_1
       12: invokevirtual #13                 // Method java/io/PrintStream.println:(I)V
       15: iinc          1, 1
       18: goto          2
       21: return
```

注意以下几点：

* `istore_1`将0放入第一个插槽，而不是第0个，因为`main`函数的参数字符数组的引用占了第0个位置。
* `iinc` 两个参数，第一个为局部数组索引值，第二个为递增整数
* `goto` 指令跳转到对应的代码位置
## 4.12 switch()
`switch`语句通过`tableswitch`指令来实现：

```Java
public static void f(int a)
{
    switch(a)
    {
        case 0: System.out.println("zero");break;
        case 1: System.out.println("one");break;
        case 2: System.out.println("two");break;
        case 3: System.out.println("three");break;
        case 4: System.out.println("four");break;
        default: System.out.println("something unknown\n"); break;
    }
}
```

编译后结果为：

```Java
public static void f(int);
  descriptor: (I)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=1, args_size=1
       0: iload_0
       1: tableswitch   { // 0 to 4
                     0: 36
                     1: 47
                     2: 58
                     3: 69
                     4: 80
               default: 91
          }
      36: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      39: ldc           #19                 // String zero
      41: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      44: goto          99
      47: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      50: ldc           #24                 // String one
      52: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      55: goto          99
      58: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      61: ldc           #26                 // String two
      63: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      66: goto          99
      69: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      72: ldc           #28                 // String three
      74: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      77: goto          99
      80: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      83: ldc           #30                 // String four
      85: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      88: goto          99
      91: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      94: ldc           #32                 // String something unknown\n
      96: invokevirtual #21                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      99: return
```
## 4.13 数组
这里有两个简单数组函数：

```Java
public static void main(String[] argv) {
    int[] a = new int[10];    
    for(int i = 0; i < a.length; ++i)
    {
        a[i] = i;
    }
    dump(a);
}

public static void dump(int[] arr) {
    for(int i = 0; i < arr.length; ++i)
    {
        System.out.println(arr[i]);
    }
}
```

反编译后为：

```Java
public static void main(java.lang.String[]);
  descriptor: ([Ljava/lang/String;)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=3, locals=3, args_size=1
       0: bipush        10
       2: newarray       int
       4: astore_1
       5: iconst_0
       6: istore_2
       7: iload_2
       8: aload_1
       9: arraylength
      10: if_icmpge     23
      13: aload_1
      14: iload_2
      15: iload_2
      16: iastore
      17: iinc          2, 1
      20: goto          7
      23: aload_1
      24: invokestatic  #7                  // Method dump:([I)V
      27: return

public static void dump(int[]);
  descriptor: ([I)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=3, locals=2, args_size=1
       0: iconst_0
       1: istore_1
       2: iload_1
       3: aload_0
       4: arraylength
       5: if_icmpge     23
       8: getstatic     #13                 // Field java/lang/System.out:Ljava/io/PrintStream;
      11: aload_0
      12: iload_1
      13: iaload
      14: invokevirtual #19                 // Method java/io/PrintStream.println:(I)V
      17: iinc          1, 1
      20: goto          2
      23: return
```

Java数组核心实现如下：

* `newarray` 指令需要传递数组长度来生成一个数组引用
* `astore_n` 将对应栈顶的数组引用存储到本地数组索引为*n*的位置
* `aload_n` 加载本地数组索引为*n*的引用到栈
* `arraylength` 返回数组长度
* `iastore` 将整数存储到数组对应索引位置，需要三个参数，从栈顶到本指令分别为:数组引用，数组索引，赋值整数 

### 字符串数组
获取每月名称：

```Java
public class Month
{
    public static String[] months = new String[]
    {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"   
    };

    public  String get_month(int i) {
        return months[i];
    }
}
```

反编译后：

```Java
  public java.lang.String get_month(int);
    descriptor: (I)Ljava/lang/String;
    flags: (0x0001) ACC_PUBLIC
    Code:
      stack=2, locals=2, args_size=2
         0: getstatic     #7                  // Field months:[Ljava/lang/String;
         3: iload_1
         4: aaload
         5: areturn
      LineNumberTable:
        line 20: 0

  static {};
    descriptor: ()V
    flags: (0x0008) ACC_STATIC
    Code:
      stack=4, locals=0, args_size=0
         0: bipush        12
         2: anewarray     #13                 // class java/lang/String
         5: dup
         6: iconst_0
         7: ldc           #15                 // String January
         9: aastore
        10: dup
        11: iconst_1
        12: ldc           #17                 // String February
        14: aastore
        15: dup
        16: iconst_2
        17: ldc           #19                 // String March
        19: aastore
        20: dup
        21: iconst_3
        22: ldc           #21                 // String April
        24: aastore
        25: dup
        26: iconst_4
        27: ldc           #23                 // String May
        29: aastore
        30: dup
        31: iconst_5
        32: ldc           #25                 // String June
        34: aastore
        35: dup
        36: bipush        6
        38: ldc           #27                 // String July
        40: aastore
        41: dup
        42: bipush        7
        44: ldc           #29                 // String August
        46: aastore
        47: dup
        48: bipush        8
        50: ldc           #31                 // String September
        52: aastore
        53: dup
        54: bipush        9
        56: ldc           #33                 // String October
        58: aastore
        59: dup
        60: bipush        10
        62: ldc           #35                 // String November
        64: aastore
        65: dup
        66: bipush        11
        68: ldc           #37                 // String December
        70: aastore
        71: putstatic     #7                  // Field months:[Ljava/lang/String;
        74: return
```

需要注意的点如下：

* 静态变量成员在类初始化时调用
* `dup`指令复制栈顶变量，由于`aastore`每次弹出使用的变量，所以需要赋值一份供下次调用
* `anewarray`生成一个指向引用的数组

### 变参函数
变参函数通过数组来实现。

```Java
    public static void f(int... values) {
        for(int i = 0; i < values.length; ++i)
        {
            System.out.println(values[i]);
        }
    }
    public static void main(String[] args)
    {
        f(1, 2, 3, 4, 5);
    }
```

编译后的函数`f`为：

```Java
  public static void f(int...);
  descriptor: ([I)V
  flags: (0x0089) ACC_PUBLIC, ACC_STATIC, ACC_VARARGS
  Code:
    stack=3, locals=2, args_size=1
       0: iconst_0
       1: istore_1
       2: iload_1
       3: aload_0
       4: arraylength
       5: if_icmpge     23
       8: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
      11: aload_0
      12: iload_1
      13: iaload
      14: invokevirtual #13                 // Method java/io/PrintStream.println:(I)V
      17: iinc          1, 1
      20: goto          2
      23: return
```

对于函数`System.out.format()`不是同一类型的参数，全部使用引用`object`的方式，因为Java所有对象都继承于`object`。

### 多维数组
多维数组通过数组引用数组的方式来实现。实现方式如下：

* 通过指令`multianewarray`来创建*n*维数组，同时此指令的参数个数也为`n`
* 首先通过一维索引找到下一维度的数组，依次类推，直到操作一维数组

## 4.14 字符串
先来看一个字符串连接程序：

```Java
public static void main(String[] args)
{
    String str1 = "hello";
    String str2 = " world";
    StringBuilder sb = new StringBuilder();
    sb.append(str1);
    sb.append(str2);
    System.out.println(sb.toString());
}
```

编译为字节码后：

```Java
public static void main(java.lang.String[]);
  descriptor: ([Ljava/lang/String;)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=4, args_size=1
       0: ldc           #7                  // String hello
       2: astore_1
       3: ldc           #9                  // String  world
       5: astore_2
       6: new           #11                 // class java/lang/StringBuilder
       9: dup
      10: invokespecial #13                 // Method java/lang/StringBuilder."<init>":()V
      13: astore_3
      14: aload_3
      15: aload_1
      16: invokevirtual #14                 // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      19: pop
      20: aload_3
      21: aload_2
      22: invokevirtual #14                 // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      25: pop
      26: getstatic     #18                 // Field java/lang/System.out:Ljava/io/PrintStream;
      29: aload_3
      30: invokevirtual #24                 // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
      33: invokevirtual #28                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      36: return
```

需要注意以下几点：

* `new` 创建新的对象，并返回到栈
* `dup` 的作用是调用`invokespecial`后将`StringBuilder`对象弹出，所以需要`dup`在栈顶保留一个实例
* `pop` 的作用是因为`StringBuilder.append()`会返回一个实例对象
* `astore3` 会将栈顶的实例存储到局部变量数组

整个流程加载和弹出分别为对如下：

|         载入          |     弹出      |
| :-------------------: | :-----------: |
|          new          | invokespecial |
|          dup          |    astore3    |
|        aload3         | invokevirtual |
| invokevirtual->return |      pop      |
|        aload3         | invokevirtual |
| invokevirtual->return |      pop      |
|        aload3         | invokevirtual |

## 4.15 异常
首先来看改造后的获取月份对应的字符串：

```Java
    public static String get_month(int i) throws IncorrectMonthException
    {
        if(i < 0 || i > 11)
        {
            throw new IncorrectMonthException(i);
        }
        return months[i];
    }

    public static void main(String[] args)
    {
        try {
            String month = get_month(100);
            System.out.println(month); 
        } catch (IncorrectMonthException e) {
            System.out.println("incorrect month index:" + e.getIndex());
            e.printStackTrace();
        }
    }
```

然后是异常类:

```Java
public class IncorrectMonthException extends Exception
{
    private int index;

    public IncorrectMonthException(int index) 
    {
        this.index = index;
    }

    public int getIndex(){
        return index;
    }
}
```

反编译结果为：

```Java
public static java.lang.String get_month(int) throws IncorrectMonthException;
  descriptor: (I)Ljava/lang/String;
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=3, locals=1, args_size=1
       0: iload_0
       1: iflt          10
       4: iload_0
       5: bipush        11
       7: if_icmple     19
      10: new           #7                  // class IncorrectMonthException
      13: dup
      14: iload_0
      15: invokespecial #9                  // Method IncorrectMonthException."<init>":(I)V
      18: athrow
      19: getstatic     #12                 // Field months:[Ljava/lang/String;
      22: iload_0
      23: aaload
      24: areturn

public static void main(java.lang.String[]);
  descriptor: ([Ljava/lang/String;)V
  flags: (0x0009) ACC_PUBLIC, ACC_STATIC
  Code:
    stack=2, locals=2, args_size=1
       0: bipush        100
       2: invokestatic  #18                 // Method get_month:(I)Ljava/lang/String;
       5: astore_1
       6: getstatic     #22                 // Field java/lang/System.out:Ljava/io/PrintStream;
       9: aload_1
      10: invokevirtual #28                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      13: goto          36
      16: astore_1
      17: getstatic     #22                 // Field java/lang/System.out:Ljava/io/PrintStream;
      20: aload_1
      21: invokevirtual #34                 // Method IncorrectMonthException.getIndex:()I
      24: invokedynamic #38,  0             // InvokeDynamic #0:makeConcatWithConstants:(I)Ljava/lang/String;
      29: invokevirtual #28                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      32: aload_1
      33: invokevirtual #41                 // Method IncorrectMonthException.printStackTrace:()V
      36: return
    Exception table:
       from    to  target type
           0    13    16   Class IncorrectMonthException

```

在抛出异常的函数里，如果有参数越界，通过指令`athrow`抛出异常。

在主函数里有异常表，定义了`0-13`的指令如果有异常则捕获，捕获后目标代码行为`16`。

## 4.16 类
上面已经有所涉及通过`new` 指令申明一个对象，调用成员函数时需要传递`this`指针到函数，`this`指针指向实例所在的堆内存，调用静态成员函数，直接调用即可。

## 4.17 简单补丁
通过修改class文件里的指令，但是Java自己有`stack map`检测，这部分需要深入了解JVM整个运行原理。