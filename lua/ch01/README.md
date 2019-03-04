# 1 基础
## 1.1 代码块
代码表达式之间不需要使用分隔符，同一行的表达式可以使用分号分格
```lua
a = 1; b = a * 2
a = 1  b = a * 2        -- ugly, but valid
```
使用dofile 函数加载lua文件

## 1.2 语法方面
可以使用任意字符，数字，下划线命名，但不可以使用数字开头
避免使用下划线加大写字母的组合，lua里有特殊使用

lua 关键字

|关  | 键 | 字 |  |  |
| --- | --- | --- | --- | --- |
| and | break | do | else | elseif |
| end | false | goto | for | function |
| if | in | local | nil | not |
| or | repeat | return | then | true |
| until | while |  |  |  |
lua 大小写敏感

lua 注释
```lua
--[[
    print(10)       -- 多行注释
--]]

---[[
    print(10)      -- 取消多行注释
--]]
```
## 1.3 全局变量
全局变量不需要申明，如果未初始化，默认值为nil， 如果将全局变量赋值为nil，变量对应的内存会被回收
