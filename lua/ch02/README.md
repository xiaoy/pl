# 2 类型和数值
lua是动态语言，不需要申明数据类型，解释器自推导数据类型
lua 有八种基础类型：

| 基础类型 |
| --- |
| nil |
| boolen |
| number |
| string |
| userdata |
| function |
| thread |
| table |

`type`函数返回数据类型
## 2.1 Nil
Nil 类型只有一个值nil，主要作用是区分其他值。nil作为不存在的值来区分可使用的值。全局变量默认为nil，赋值为nil可以删除全局变量

## 2.2 Booleans
boolean类型有两个值，false 和 true。但是在lua里任何值都可以做条件判断，只有false和nil 为false其他任何值为true

## 2.3 Numbers
number 类型 是双精度浮点型
## 2.4 Strings
string 在lua里有特殊含义：字符序列  
string 在lua里不可修改，修改字符串是通过创建新的字符串
```lua
a = "one string"
b = string.gsub(a, "one", "another")
```
lua 自动管理string的内存，通过操作符'#' (长度操作符）获取字符串长度

lua使用单引号或双引号申明字符串，他们的区别是可以在对方的字符串里不使用转义符，直接使用

使用单引号或双引号，依照项目风格，统一使用即可

字符串可以使用C-like 转义字符

| escape sequence | comment |
| --- | --- |
| \a | bell |
| \b | back space |
| \f | form feed |
| \n | newline |
| \r | carriage return |
| \t  | horizontal tab |
| \v | vertical tab |
| \\ | backslash |
| \\" | double quote |
| \\' | single quote|

可以使用数字表示字符,通过转义符，两种格式 \ddd 和 \x\hh， 十进制的三位数，十六进制的两位数，因为字符是8bit

### Long strings
使用双方括号申明长字符传，首个字符为换行符将会被忽略，字符串里可以任意使用字符，不用转义符

可以在方括号中间加等号，开始(`[===[`)和结束(`]===]`)匹配即可，注释同样的道理(`--[==]`)

在长字符传里使用特殊字符在编辑器里可能显示异常，使用数字换行更好一些。 对于超长行，可以使用\z (lua 5.2)

### 转换
有number的操作符，将会隐形转换数据类型为number类型
```lua
print("10" + 1)             --> 11
print("10" + "1")           --> 11
print("-5.3e-10" * "2")     --> -1.06e-09
print("hello" + 1)          -- ERROR (cannot convert "hello")
```

lua 不仅在表达式里使用隐性转换，调用函数在需要number类型时，也隐形转换，比如 math.sin

通过使用 `..` 连接字符串
```lua
print(10 .. 20)                 --> 1020
line = io.read()
n = tonumber(line)              -- try to convert it to a number

print(tostring(10) == "10")     --> true
```

## 2.5 Tables
tables type 通过关联数组实现。关联数据可以使用任何类型数据索引，除了nil类型

tables 是唯一数据结构实现机制

tables 在lua里既不是数值也不是变量，而是对象

无法申明tables,只能通过构造表达式构造

tables是匿名的，指向tables的变量和tables没有固定关联，tables的引用为零时，将被从内存释放

Lua提供了`a.name` 作为`a["name"]`的语法糖

Lua 使用1作为数组的起始值，通过 "#" 获取tables长度

## 2.6 函数
函数是一等值，程序可以通过变量引用函数，可以作为变量传递
lua 可以调用lua函数，也可以调用C函数，lua的库都是C语言实现的

## 2.7 Userdata 和 线程
userdata 类型变量用来存储任意C变量