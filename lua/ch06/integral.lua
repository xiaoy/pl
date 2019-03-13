-- 6.1

function integral(func, a, b)
    local sum = 0
    local detX = 1e-6
    for i = a, b, detX do
        sum = sum + detX * func(i + detX)
    end
    return sum 
end

function squr(x)
    return x * x;
end

print(integral(squr, 1, 2))