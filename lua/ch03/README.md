# 3 表达式
## 3.1 算数运算符
二元操作符：'+'(加法）, '-'（减法）, '*'(乘法） , '/' （除法）, '^' (指数) , '%'  (求余)  
一元操作符：'-' (负数)

```lua
a % b == a - math.floor(a/b)*b
```
实数操作非常有趣的应用。 x % 1 小数部分，x - x % 1 整数部分

## 3.2 关系运算符
| 小于 | 大于 | 小于等于 | 大于等于 |等于  | 不等于 |
| --- | --- | --- | --- | --- | --- |
| < | > | <= | >= | == | ~= |
所有运算符返回布尔值  
lua 首先检查类型是否相同，在比较值  
table 和 userdata 类型检查引用是否相同  
只有数值和字符串可以比较大小，字符串大小按照字母表格顺序判断

## 3.3 逻辑运算符
逻辑操作符有  and, or, not  
所有逻辑操作将false 和 nil 当做false，其他为true  
and 操作符返回第一个值，当第一个参数为false时， 否则返回第二个值  
or 操作符返回第一个值，当第一个参数为true时，否则返回第二个值  

操作符妙用
```lua 
x = x or v
if not x then x = v end

a and b or c
a ? b : c
max = (x > y) and x or y
```
## 3.4 连接
lua 里通过 '..' 连接字符串，如果是number 类型，则转换为string在连接

## 3.5 长度运算符
长度操作符作用在strings和talbes， strings返回bytes数，talbes返回数列长度  

长度妙用
```lua
print(a[#a])                -- prints the last value of sequence 'a'
a[#a] = nil                 -- removes the last value
a[#a + 1] = v               -- appends 'v' to the end of the list
 ```
 
如果数列有空洞，长度不可预测，长度操作符进可以正确返回使用1,....,n 的数列长度  
如果数列有空洞，自己维护数列长度

## 3.6 优先级
lua 操作符优先级如下，从高到低

|       操作符  |
| --- | --- | --- | --- | --- | --- |
| ^ |  |  |  |  |  |
| not |#  | - |  |  |  |
| * | / | % |  |  |  |
| + | - |  |  |  |  |
| .. |  |  |  |  |  |
| < | > | <= | >= | ~= | == |
| and |  |  |  |  |  |
| or |  |  |  |  |  |

如果对操作符优先级有疑问，使用小括号

## 3.7 tables 构造

构造是创建和初始化tables的表达式  
标记风格的初始化
``` lua
a = { x=10, y=20}
a = {}; a.x=10; a.y=20      -- 直接初始化的速度更快，因为初始化已知table大小
```

列表风格的初始化
``` lua
days = {"Sunday", "Monday", "Tuesday", "WednesDay", "Thursday", "Friday", "Saturday"}
```

也可以混用
``` lua
polyline = {color="blue",
               thickness=2,
               npoints=4,
               {x=0,    y=0},
               {x=-10, y=0},
               {x=-10, y=1},
               {x=0,    y=1}        
```

方括号初始化
```lua
opnames = {["+"] = "add", ["-"] = "sub", ["*"] = "mul", ["/"] = "div"}
```

初始化也可以使用分号，对于不同块的部分，可以使用分号分割
``` lua
{x=10, y=45; "one", "two", "three"}
```