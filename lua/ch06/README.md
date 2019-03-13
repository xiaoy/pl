# 6 高级函数
Lua 函数是具有合适"词法区域"的一等变量。

**一等变量**意味着函数是一个变量和普通`numbers，strings`有相同权利。可以保存函数到变量，可以当参数传递，可以当返回值。

**词法区域**意味着函数可以访问上层包围函数。

函数是变量，申明变量的方式赋值。正常定义函数的方式并没有返回值，这是Lua使用了函数定义*语法糖*。
```lua
function foo (x) return 2*x end             -- 语法糖，为了好看
foo = function (x) return 2*x end          -- 本质上是定义函数，然后返回变量，可以将function (x) body end  看做是函数构造器
```
函数构造器返回的函数叫做匿名函数，正常情况将变量赋值给全局变量，在一些情况下会直接使用匿名函数。
```lua
network = {
    {name = "grauna", IP = "210.26.30.34"},
    {name = "arraial",  IP = "210.26.30.23"},
    {name = "lua",      IP = "210.26.23.12"},
    {name = "derain",  IP = "210.26.23.20"},
    
    table.sort(network, function(a, b) return (a.name > b.name) end)
}
```

函数如果只有一个参数，称作高阶函数。高阶函数没有特殊的权利，只是通过参数传递函数，使得高阶函数更加灵活。

## 6.1 闭包
当我们写一个函数A被包含在函数B中时，A函数可以访问B函数里所有变量，这种特性叫做*词法区域*。B函数的局部变量在A函数里既不是局部变量，也不是全局变量，称作非局部变量。
```lua
function newCounter ()
    local i = 0
    return function ()
        i = i + 1
        return i
   end
end

c = newCounter()
print(c1())         --> 1
print(c2())         --> 2
```
利用闭包，存储值
```lua
function digitButtion (digit)
    return Buttion{ label = tostring(digit),
                        action = function ()
                                        add_to_display(dight)
                                    end
                        }
end
```

利用闭包，修改全局函数
```lua
do
    local oldSin = math.sin
    local k = math.pi / 180
    math.sin = function (x)
        return oldSin(x * k)
    end
end
```

## 6.2 非全局函数
很明显函数不仅可以存储为全局变量，也可以存储在table字段或局部变量中。  
table三种存储方式：
```lua
-- first
Lib = {}
Lib.foo = function (x,y) return x + y end
Lib.goo = function(x,y) return x -y end

-- second, constructors
Lib = {
    foo = function(x,y) return x + y end,
    goo = function(x,y) return x - y end
}

-- lua 其他语法
Lib = {}
function Lib.foo (x,y) return x + y end
function Lib.goo (x,y) return  x + y end
```

函数存储为局部变量，则只能在局部变量所在的区域内访问。定义局部函数如下：
```lua
-- 返回局部变量
local f = function (<params>)
    <body>
end

-- 语法糖
local function f (<params>)
    <body>
end
```

在定义局部函数时，如果使用当前函数递归调用则需要注意先后顺序
```lua
-- 1 错误方式
local fact = function(n)
    if n == 0 then return 1
    else return  n * fact(n-1)          -- 错误，这里fact还没有定义好，会访问全局fact
end

-- 2 正确方式
local fact
fact = function(n)
    if n == 0 then return 1
    else return n * fact(n-1)
end

-- 3 也可以是用局部函数申明方式，这种申明方式展开为方式2
local function fact(n)
    if n == 0 then return 1
    else return n * fact(n -1)
end

-- 4 如果递归调用非自身函数，需要先申明
local f, g
function g()
    <some code> f()     <some code>
end

function f()
    <some code> g()    <some code>
end
```

## 6.3 正确的尾部调用
尾部调用的底层实现机制是`goto`，看如下例子：
```lua
function g(n)
    n = n * 2
    return f(n - 1)
end

-- 伪代码，调用g函数
push n        --1
call g        --2
ret           --3

-- f 函数的汇编
f prog
    <code>              --201
f pend
--  正常调用,g函数的汇编函数
g prog
    mov eax, n          --101
    mul eax, 2          --102
    sub eax, 1          --103
    push eax            --104
    call f              --105    调用函数语法
    ret                 --106
g pend

-- 尾部调用
g prog
    mov eax, n          --101
    mul eax, 2          --102
    sub eax, 1          --103
    push eax            --104
    goto 201            --105    跳转到地址201开始执行
g pend
```
通过这种调用方式，不需要保存g函数的堆栈，直接跳转到f函数执行，执行完不返回g函数，返回调用g函数指令的下一条指令。

以下几个错误的尾部调用（并不是尾部调用）
```lua
function f (x) g(x) end

function foo(x) return g(x) + 1 end

function foo(x) return x or g(x) end

function foo(x) return (g(x)) end
```
