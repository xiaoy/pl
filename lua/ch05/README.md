# 5 函数
 函数是抽象陈述和表达语句的核心机制。
 
 函数参数包含在小括号里，如果函数没有参数，用空的小括号。特殊情况是，如果函数只有一个参数且这个参数是文字字符串或表构造函数，小括号是默认的。
 ```lua
print "Hello World"         <-->    print("Hello World")
dofile 'a.lua'              <-->    dofile('a.lua')
print [[ a multi-line       <-->  print([[a multi-line
    message]]                       message]])
f{x=10, y=20}               <-->   f({x=10, y=20})
type{}                      <-->   type({})
```

lua 提供了对象调用函数的语法糖。o:foo(x)代替0.foo(o, x)。

lua传递参数的规则和初始化变量的规则一样，多退（discard）少补（nil），少补的特性可以实现默认参数的功能。
```lua
function incCount (n)
    n = n or 1
    count = count + n
 end
```

## 5.1 多返回结果
在一些编程情景中，多返回参数非常方便，比如 string.find 函数，返回字符串的起始和结束索引
```lua
s, e = string.find("hello Lua users", "lua")
print(s, e)         --> 7, 9
```
函数返回多个变量，当把参数罗列在 `return` 关键字后，比如找到一个数列里最大数和索引
```lua
function maximum (a)
    local mi = 1
    local m = a[mi]
    for i, #a do
        if a[i] > m then
            m = a[i], mi = i
        end
    end
    return m, mi
end
```
Lua 调整返回参数个数根据当前调用环境。两种情况如下：

1. 按照陈述调用，Lua忽略所有函数返回结果
2. 按照表达式调用，Lua只取第一个返回结果，如果只有一个表达式，或者是表达式列表的最后一个表达式，则返回所有结果
    1. 多个赋值
    2. 函数参数传递
    3. table 构造
    4. return 语句

如果在返回值添加了小括号，则只返回一个变量

Lua里有个特别的函数 `table.unpack` 传入数组，返回所有数组值
```lua
print(talbe.unpack{10, 20, 30})     --> 10  20  30
a, b = table.unpack{10, 20, 30}     --> a=10, b=20, 30 is discarded
```
upack 函数可以指定参数返回区间
```lua
print(table.unpack({"Sun", "Mon", "Tue", "Wed"}, 2, 3))     --> Mon     The
```

用Lua实现unpack函数
```lua
function unpack(t, i, n)
    i = i or 1
    n = n or #t
    if i < n then
        return unpack(t, i + 1, n)
    end
end
```
## 5.2 可变函数
通过(...)参数定义可变函数
```lua
function add(...)
    local s = 0
    for i, v in ipairs{...} do
        s = s + v
    end
    return s
end
print(add(3, 4, 10, 25, 12))        --> 54
```
可变参数有一下特性
* 可以用来构造table
* 可以给变量赋值
* 可以当做变量传递
* 可以当做函数返回值

由于使用table构造接收可变参数，在遍历table时，如果有空洞，导致table遍历不全。使用`table.pack` 函数会返回一个table，但是此table有个键值"n"标识table长度。
```lua
function nonils(...)
    local arg = table.pack(...)
    for i = i, arg.n do
        if arg[i] == nil then return false end
    end
    return true
end
```
## 5.3 命名参数
Lua参数传递机制通过占位：当调用函数，参数通过匹配位置一一对应。Lua没有提供命名参数的机制，但是可以通过构造table来实现命名参数传递。
```lua
rename {old="temp.lua", new="temp1.lua"}
function rename (arg)
    return os.rename(arg.old, arg.new)
end
```
