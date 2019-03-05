-- this example for 9.3

-- this is printResult
function printResult(a)
    for i = 1, #a do
        io.write(a[i])
    end
    io.write("\n")
end

-- this is normal permgen
function permgenNormal(a, n)
    n = n or #a
    if n <= 1 then
        printResult(a)
    else
        for i = 1, n do
            a[n], a[i] = a[i], a[n]
            permgenNormal(a, n - 1)
            a[n], a[i] = a[i], a[n]
        end
    end
end

permgenNormal({'a', 'b', 'c'})

-- this is coroutine permgen 
function permgen(a, n)
    n = n or #a
    if n <= 1 then
        coroutine.yield(a)
    else
        for i = 1, n do
            a[n], a[i] = a[i], a[n]
            permgen(a, n - 1)
            a[n], a[i] = a[i], a[n]
        end
    end
end

function permutations(a)
    local co = coroutine.create( function()
        permgen(a)
    end)

    return function()
        local code, res = coroutine.resume(co)
        return res
    end
end

print('coroutine:')
for p in permutations{'a', 'b', 'c'} do
    printResult(p)
end