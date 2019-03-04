# 8 编译，运行，和错误
尽管 Lua是解释执行语言，Lua先将源码预编译为中间码，在执行中间码。解释执行语言的主要特点是：是否可以执行动态生成的代码。

8.1 编译
`loadfile` 从文件加载代码块，并编译，然后将编译后的代码块返回为一个函数。`loadfile` 不会引发错误，而是返回错误码，因此我们可以处理错误。
`dofile` 函数定义如下
```lua
function dofile(filename)
    local f = asset(loadfile(filename))
    return f()
end
```
对于简单任务，`dofile` 很方便 ，因为调用一次完成所有工作。但是`loadfile` 更加灵活。当发生错误，`loadfile`返回 `nil`以及错误消息。并且当我们需要多次执行一个文件的时候，可以调用`loadfile`一次，在执行多次。

`load` 函数和`loadfile`很相似，除了它从字符串读取代码块。
```lua
f = load("i = i + 1")
i = 0
f(); print(i)           --> 1
f(); print(i)           --> 2
```
`load` 函数非常强大，我们要谨慎使用。比起其他方案，它是效率低的函数，并会产生难以理解的代码。

通过直接调用`load` 函数返回值，实现快速且脏的 `dostring`
```lua
load(s)()

-- 清晰错误日志版本
asset(load(s))()
```

`load`函数编译的代码块在全局环境中，不在自身调用的词法区间。因此速度比起当前区域函数编译速度慢。
```lua
i = 32
local i = 0
f = load("i = i + 1; print(i)")             -- global i
g = function () i = i + 1; print(i) end  -- local i
f()             --> 33
g()            --> 1
```
`load` 函数的参数可以使*reader function*，reader function 可以返回部分代码块，直到返回nil时，`load` 函数执行。
```lua
f = load(io.lines(filename, "*L"))
-- io.lines 函数每次调用返回一行
-- io.lines(filename, 1024)  效率更高，每次读取1024 bytes
```
Lua将独立代码块当做可变参数的匿名函数主体，比如， `load("a = 1")` 返回一下表达式:
```lua
function (...) a = 1 end
```
就如其他函数，代码块可以申明局部变量。
```lua
f = load("local a = 10; print(a+20)")
f()         --> 30
```
`load` 函数执行后，返回匿名函数和错误日志。在项目中需要自己处理错误。
```lua
print(load("i i"))
--> nil [string "i i"]:1: ''=' expected near 'i'
```
`load` 函数没有任何边际效应。仅仅是将对应字符串编译成内部表现形式并将结果以匿名函数的形式返回。在Lua里函数定义是赋值表达式，这个过程发生在运行时，而不是编译时。
```lua
-- file 'foo.lua'
function foo(x)
    print(x)
end

-- 其他文件执行
f = loadfile("foo.lua")
-- 加载后foo.lua 只是被编译， foo函数没有赋值
print(foo)      --> nil
f()               --> defines 'foo'
foo("ok")      --> ok
```

## 8.2 预编译代码
 Lua 首先将代码预编译，然后在执行，Lua直接可以执行预编译的代码。相比执行源代码，执行预编译代码，速度更快。
 
 使用 `luac` 生成预编译文件-称作*二进制代码块*。
 ```lua
$luac -o prog.lc prog.lua   -- 生成预编译文件
$lua prog.lc                    -- 执行预编译文件
```
使用lua实现luac
```lua
p = loadfile(arg[1])
f = io.open(arg[2], "wb")
f:write(string.dump(p))
f:close()
```
`string.dump` :参数为Lua函数，将函数的预编译代码转为字符串

## 8.3 C Code
C程序使用前需要链接。很多流行操作系统，运行程序使用动态链接机制。标准C语言的没有动态链接的实现，因此没有可移植的办法。

通常Lua不包含标准C没有实现的机制。但是动态链接不一样，Lua将动态链接当做其他特性的基石。因此Lua打破了自己的可移植规则，实现了跨平台的动态链接机制。

```lua
local path = "/usr/local/lib/lua/5.1/socket.so"
-- 第一个参数为动态库路径
-- 第二个参数为函数名
-- 返回值为函数
local f = package.loadlib(path, "luaopen_socket")
```

## 8.4 Errors
人非圣贤孰能无过。因此要用最好的方式处理错误。Lua是扩展类型语言，通常是嵌入在应用程序中，当错误发生时，不会简单的崩溃，或退出。当错误发生时，Lua结束当前运行块，返回到应用。

正常处理错误的方式是使用`error` 函数
```lua
print "enter a number:"
n = io.read("n")
if not n then error("invalid input") end
```
使用`error` 的情景模式很普遍，Lua提供了内置函数 `assert` 来做这件事
```lua
print "enter a number:"
n = assert(io.read("*n"), "Invalid input")
-- 第一个参数为boolean，可以直接是表达式。当值为false时，产生错误
-- 第二个参数为字符串
```
当函数执行出现异常，通常两种处理方式：

* 返回错误码 （通常返回nil）
* 使用函数 `error` 函数抛出异常

对于可以直接检测的问题，抛出错误
```lua
-- 调用math.sin 函数，先检测输入值，在调用
if not tonumber(x) then
    error("invalid input")
else
    return math.sin(x)
end
```
对于有多重情况的问题返回错误码
```lua
local file, msg
repeat
    print "enter a file name:"
    local name = io.read()
    if not name then return end
    file, msg = io.open(name, "r")
    if not file then print(msg) end
until file
```

## 8.5 错误异常处理
使用`pcall` （protected call），处理异常。
当 `pcall` 调用用第一个参数在保护模式下，因此捕获所有函数运行时异常，两种情况：

* 当没有错误时，`pcall` 返回 **true** 以及函数返回值
* 当有错误时， `pcall` 返回  **false** 以及传给函数 `error` 的变量

```lua
locat status, err = pcall(function() error({code=121) end)
print(err.code) -->121
```

## 8.6 错误消息和追踪
尽管可以使用任何类型的值作为错误消息，通常使用字符串当做错误消息来描述发生了什么。当Lua内部执行错误时，Lua也会产生错误消息，其他消息都是传给 `error` 函数的值，当值为string时，Lua会添添加对应发生错误的位置和文件。

```lua
local status, error = pcall(function () a = "a" + 1 end)
print(err)
--> stdin:1 : attempt to perform arithmetic on a string value
lcoal status, error = pcall(function() error("my error") end)
print(err)
--> stdin: 1: my error
```

`error`  函数第二个参数指定错误等级， **1** 为自身函数错误， **2** 为外部调用传递参数错误。

当错误发生时，我们需要调用堆栈信息，但是`pcall`  函数里调用 `error`  函数会破坏调用堆栈。因此在 `error` 调用前，需要捕获异常。使用 `xpcall` 函数可以捕获异常。调用`xpcall` 需要传递*消息处理函数*。

* debug.debug 给出Lua提示，自己通过提示查找错误
* debug.track 产生额外的错误消息通过` traceback`