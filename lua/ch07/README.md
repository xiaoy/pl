# 7 遍历器和通用for
## 7.1  遍历器和闭包
能遍历集合所有元素的构造函数称作遍历器。每次调用函数，返回集合的下一个元素。  
遍历器需要记录一些状态值，方可遍历所有元素。闭包为这种任务提供了很好的机制。 

添加一个简易版list遍历器，每次返回list的一个元素 。
```lua
function values(t)
    local i = 0
    return function() i = i + 1; return t[i] end
 end
 -- values 函数是工厂，每次调用工厂，创建一个新的闭包函数(遍历器)，这个闭包函数内部记录了t和i的值。每次调用遍历器，返回list下一个值，当最后返回nil时，遍历结束。
 t = {10, 20, 30)
 iter = values(t)                   -- 创建遍历器
 while true do
    local element = iter()       -- 调用遍历器
    if element == nil then break end
    print(element)
end
-- 使用通用for可以更简单，毕竟for的设计初衷就是做这类的事情
t = {20, 20, 30)
for elemnt in values(t) do
    print(element)
end
```

## 7.2 通用for的语法
通用for的语法如下：
```lua
for <var-list> in <exp-list> do
    <body>
end
```
展开后的语法如下：
```lua
-- 更加精确的表现形式语法
for var_1, ..., var_n in <explist> do <block> end

-- 展开后，带下划线的参数是lua内部维护的，var_1, ... ,var_n 是遍历器返回值，和多重赋值一样，多退少补
-- _f 是遍历器函数
-- _s 固定参数
-- _var 初始化参数
-- var_1->var_n 是遍历返回变量
do
    local _f, _s, _var = <explist>
    while true do
        local var_1, ... , var_n = _f(_s, _var)
        _var = var_1
        if _var == nil then break end
        <block>
     end
 end
```
## 7.3 无状态遍历器
无状态遍历器，自身内部不保存状态，通过参数调用遍历器。遍历器只有两个参数。 
ipairs就是一个无状态遍历器工厂函数，下面来看例子：
```lua
-- ipairs 的使用
a = {"one", "two", "three"}
for i, v in ipairs(a) do
    print(i, v)
end

-- ipairs 的实现
local function iter(t, i)
    i = i + 1
    local v = a[i]
    if v then
        return i, v
    end
end

function ipairs (a)
    return iter, a, 0
end
```

## 7.4  复杂状态遍历器
当遍历器需要更多的变量时，两种解决方案：

* 使用闭包
* 使用table 当做参数

使用table的例子：
```lua
local iterator
function allwords()
    local state = {line = io.read(), pos = 1}
    return iterator, state
end

function iterator (state)
    while state.line do
        -- search for next word
        local s, e = string.find(state.line, "%w+", state.pos)
        if s then
            state.pos = e + 1
            return string.sub(state.line, s, e)
        else
            state.line = io.read()
            state.pos   = 1
        end
    end
    return nil
end
```

使用闭包更加高效，比起使用table，两个原因:

* 创建闭包效率高于创建table
* 访问 非局部变量速度快于访问table成员变量

## 7.5 真正的遍历器
遍历器提供连续的值，并没有遍历功能，称作“生成器”更合理些。但是由于历史原因就这样叫了。 
但是也可以实现遍历器。这种遍历的器的结构，就是遍历器内部自己遍历，传递对应的函数即可。
例子如下：
```lua
function allwords (f)
    for line in io.lines() do
        for word in string.gmatch(line, "%w+") do
            f(word)
        end
    end
end

-- 定义对应的函数
allwords(print)             -- print 

-- 统计单词数量
local count = 0
allwords(function (w)
    if w == "hello" then count = count + 1 end
end)
print(count)
```
生成器风格的遍历器和遍历器对比

* 两种实现方式，开销差不多
* 使用遍历器风格方式实现遍历简单一些
* 生成器风格的扩展性更强
    * 允许并行运行多个遍历器
    * 内部可以使用break和return关键字
