-- Exercise 1.1: Run the factorial example. What happens
-- to your program if you enter a negative number? Modify
-- the example to avoid this problem.

-- when entering a negative number in the factorial 
-- it will statck overflow

-- defines factorial funcion
function fact(n)
    if n < 0 then
        return nil
    elseif n == 0 then
        return 1
    else
        return n * fact(n - 1)
    end
end

print("enter a number:")
a = io.read("*n")
ret = fact(a)

if ret == nil then
    print("bad number entered")
else
    print(ret)
end