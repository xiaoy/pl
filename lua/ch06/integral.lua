-- Exercise 6.1: Write a function integral that receives a function
-- f and returns an approximation of its integral

function integral(func, a, b)
    local sum = 0
    local detX = 1e-6
    for i = a, b, detX do
        sum = sum + detX * func(i)
    end
    return sum 
end

function f(x)
    return x * x;
end

print(integral(f, 1, 2))