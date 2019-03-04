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

r = coroutine.resume(co, "hi")          --> col hi
r = coroutine.resume(co, 4, 5)          --> co2 4 5

-- 返回函数返回值
co = coroutine.create(function()
        return 6, 7
    end)

print(coroutine.resume(co))         --> true 6 7