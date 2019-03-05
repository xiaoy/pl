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
协程最经典的模型是生产消费问题。协程提供了理想工具匹配生产者和消费者，因为 resume-yield 转换调用者和被调用者的关系。

管道是基于多进程共享内存的一种实现，进程切换消耗高。  
协程是非抢占式多线程的一种实现方式，协程之间的切换，就是函数调用。

## 9.3 协程实现遍历器
循环遍历器是典型的**生产-消费**模式：遍历器生产，循环消费。  
使用`coroutine.wrap`函数返回一个函数，调用这个函数即可`resume`协程。
```lua
-- 正常装配遍历器
function permutations(a)
    local co = coroutine.create(function() permgen(a) end)
    return function()
        local code, res = coroutine.resume()
        return res
    end
end

-- 使用 warp 函数装配
function permutations(a)
    return coroutine.wrap(function() permgen(a) end)
end
```
`coroutine.wrap` 比起 `coroutine.create` 使用起来更加简单，但不会返回错误，只会抛出异常。可扩展性没有`coroutine.create`灵活。

## 9.4 非竞争式多线程
协程允许某种方式的协作线程。每个协程等价于一个线程。通过 `yield-resume` 切换控制。但是和多线程比起来，协程是*非抢占式*的，当一个协程运行起来，不能从外部停止。

由于协程运行时会将整个进程占用，只有协程运行结束，才回到主流程。所以这里使用多协程模拟多线程，要对应做的事情支持异步回调。