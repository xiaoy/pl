# 4 Statements
## 4.1 赋值
赋值是基础功能修改变量和tables的值
```lua
a = "hello" .. "world"
t.n = t.n + 1
```
lua 允许多变量赋值，将一个序列的值，赋值给一个序列的变量，两个序列的元素都通过逗号分割
```lua
a, b = 10, 2 * x
```

在多变量赋值，lua 首先执行变量运算，再将值赋值变量，利用这个特性，可以方便交换两个变量
```lua
x, y = y, x
a[i], a[j] = a[j], a[i]
```
lua会调整对应值和变量的数量，如果变量没有对应值，则赋值为nil，如果值没有对应变量，则忽略值
```lua
a, b, c = 0, 1
print(a, b, c)                  --> 0   1   nil
a, b = a + 1, b + 1, b + 2      --> value of b+2 is ignored
print(a, b)                     --> 1, 2
a, b, c = 0
print(a, b, c)                  --> 0   nil  nil
```
lua 多变量赋值效率没有单行赋值效率高，但是类似交换变量很方便，最大的用处是函数返回多变量值

## 4.2 局部变量和代码块
除去全局变量，lua支持局部变量，通过local 关键字创建局部变量
```lua
j = 10                     -- global variable
local i = 1                -- local variable
```
局部变量的生命周期只存在自己的区块里
```lua
x = 10
local i = 1             -- local to the chunk

while i <= x do
    local x = i * 2     -- local to the while body
    print(x)            --> 2, 4, 6, 8, ...
    i = i + 1
end

if i > 20 then
    lcoal x              -- local to the "then" body
    x = 20
    print(x + 2)         -- (would print 22 if test succeeded)
else
    print(x)             --> 10 (the global one)
end

print(x)                 --> 10 (the global one)
```
交互式模式下，每一行都是独立一个块（除非不是一个完整命令），为解决这个问题，使用关键字**do-end**  
**do**  代码块可以很好的控制局部变量
```lua
do
    local a2 = 2 * a
    lcoal d = (b^2 - 4 * a * c) ^(1/2)
    x1 = (-b + d)/a2
    x2 = (-b - d)/a2
end                 -- scope of 'a2' and 'd' ends here
print(x1, x2)
```
使用局部变量是好的编程风格，当可以使用局部变量时。使用局部变量有如下好处： 
* 局部变量可控，滥用局部变量，导致全局变量环境混乱不可维护。  
* 访问局部变量的速度更快。 
* 局部变量超出自己区域时，生命周期结束，垃圾回收器将释放它的值。

Lua按照表达式处理局部变量的申明，意味着局部变量的赋值和全局变量赋值规则一样

一个非常通用的方式
```lua
local foo = foo
```
代码通过局部变量保存全局变量。   
这种方式可用作先保留全局变量，如果在后面的操作中全局保量被修改，可以通过局部变量反向保存回去。  
并且可以通过局部保存的方式，在后面的引用中加快访问速度。  

许多语言必须在代码块的开头申明变量，一些人认为在代码中间申明变量是坏的实践。恰恰相反，当使用时在申明一个变量，可以防止没有初始化这个变量，并且减少了变量和使用变量代码块之间的距离，提高了可读性。

## 4.3 控制结构
Lua 提供了小而方便的系列控制结构，`if` 当做条件判断，`while, repeat, for`  用作循环迭代。所有的控制结构有个显示的结尾标记：`end` 结束`if, for, while` 结构；`until` 结束`repeat` 结构

控制结构的条件表达式可以使任何值，牢记Lua将所有值当为true，除了false和nil。

### if then else
`if` 表达式测试条件然后执行then的部分或者else部分，else是可选的，如果要添加多重ifs可以使用`elseif`，但只需要一个`end`。lua没有switch，使用条件语句亦可替代。

```lua
if a < 0 then a = 0 end
if a < b then return a else return b end
if line > MAXLINES then
    showpage()
    line = 0
 end
 
if op == "+" then
    r = a + b
elseif op == "-" then
    r = a - b
elseif  op == "*" then
    r = a * b
elseif op == "/" then
    r = a / b
else
    error("invalid operation")
end
```

### while
条件为真时重复执行`while`代码块，直到条件为`false`或者`break`。先执行条件判断，如果为真，执行`while`代码体，否则跳过。
```lua
local i = 1
while a[i] do
    print(a[i])
    i = i + 1
end
```
### repeat
如名字所示，`repeat-until` 表达式重复执行代码体直到条件为真时退出。先执行代码体，最后判断条件，并且在`until`时，代码块里的local变量在生命周期里。
```lua
local sqr = x / 2
repeat
    sqr = (sqr + x / sqr)/2
    local error = math.abs(sqr^2 - x)
until error < x / 10000         -- local 'error' still visible here
```
### Numeric for
语法如下：
```lua
for var = exp1, exp2, exp3 do
    <something>
end
```
`for` 通过exp1和exp2的值为执行区间，exp3的值为阶梯数，exp3是可选的，默认为1。
```lua
for i = 1, f(x) do print(i) end
for i = 10, 1, -1 do print() end
```
`for` 循环有几个精妙之处：

* 在循环开始之前，三个表达式会执行唯一一次
* 控制变量是循环结构内自动申明的局部变量，生命周期只在控制区里
* 修改控制变量，将会导致循环次数不可预料的，如果想结束`for`循环，使用`break`关键字


### Generic for
通用`for`循环遍历所有iterator函数返回的变量
```lua
for k, v in pairs(t) do print(k, v) end
```
`pairs` 是一个遍历函数，提供正确的遍历函数即可使用通用`for`，比如:
 遍历文件行 `io.lines`  
 遍历table `pairs`  
 遍历序列 `ipairs`  
 遍历string `sring.gmatch`
 
通用`for`的控制循环变量是local变量，只可以在循环内使用。

## 4.4 break, return, and goto
`break` 和 `return` 语句用来跳出代码块，`goto`可以跳转到函数内任何一点。  

使用`break`跳出循环，并且只能在循环内部使用（for, repeat, while`），跳出循环后，程序在循环结束的点继续执行。

`return` 语句返回零时结果在函数内，或者结束函数。每个函数的结尾有一个隐式的返回，所以不用自己手动添加，当不需要返回任何值时。

因为语法原因，return只能出现在代码块的最后一条语句。换句话说return只能出现在`end,  else, until` 之前，如果想在程序中间使用返回，使用`do-end`
```lua
local i = 1
while a[i] do
    if a[i] == v then return i end
end

function foo()
    return                  --<< syntax error
    do return end -- ok
    <other statements>
 end
```
`goto` 语句使当前程序跳转到对应label执行。对于goto是否对编程有害有很大的争议，并且是否要从编程语言里除去。无论如何有许多语言认为提供goto语句是好的。小心使用goto，它将是非常强有力的机制，提高代码质量。

在lua里使用`goto`非常简单，goto后面跟随合法的标签名。标签的语法有些绕，两个冒号后，名字，在加两个冒号 ，`::name::`。这样绕的意图就是让程序员三思，在使用goto前

Lua有一些限制，当使用goto跳转时，
 * label遵循可见性规则，不能跳转到代码块里的label。其实就是只能同一代码层级跳转
 * 只能在同一个函数里跳转
 * 不能跳跃局部变量的范围