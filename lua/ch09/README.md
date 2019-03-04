# 协程
协程和线程的相似之处：线性执行，自己有单独的堆栈，局部变量，指令指针，和其他协程共享去不变量以及其他资源。  
协程和线程的不同之处：线程在多核机器上并行运行。协程是协作运行，在给定时间只有一个协程在运行，并且只有协程主动挂起，协程才挂起。

## 9.1 协程基础
协程相关的函数都实现在`coroutine` table。协程有四种状态：挂起，运行中，死亡，正常。
协程函数：
```lua
-- 创建协程，参数为函数，返回变量类型为 thread
local co = coroutine.create(function() print("hi") end)

-- 返回协程状态 (suspended)
print(coroutine.status(co))

-- 恢复协程，状态变为 running
coroutine.resume(co)

-- 当协程执行完，返回后，状态变为 dead
print(coroutine.status(co))
```
协程的精华就在于在协程执行的函数里调用`yield` 函数，通过此函数重新挂起协程。当协程遇到函数`yield`时，挂起协程，直到`resume`调用时，首先返回函数`yield`变量，然后继续执行结束，或者遇到写一个`yield`函数时再次挂起。

`resume` 函数返回**true**时，后面的参数来自`yield`函数参数  
传给`resume` 额外的参数，也会被`yield` 返回  
当协程执行完，`resume`返回协程返回值  
```lua
-- 返回 yield 参数
co = coroutine.create(function(a, b)
    coroutine.yield(a + b, a - b)
    end)

print(coroutine.resume(co, 20, 10))     --> true 30 10

-- 返回 resume 额外参数
co = coroutine.create(function(x)
        print("co1", x)
        print("co2", coroutine.yield())
    end)

coroutine.resume(co, "hi")          --> col hi
coroutine.resume(co, 4, 5)          --> co2 4 5

-- 返回函数返回值
co = coroutine.create(function()
        return 6, 7
    end)

print(coroutine.resume(co))         --> true 6 7
```

## 9.2 管道和过滤
