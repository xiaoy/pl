-- Exercise 3.3: We can represent a polynomial in Lua as a list
-- of coefficients, such as {a0, a1, ..., an}.
-- Write a function that receives a polynomial (represented as
-- a table) and a value for x and returns the polynomial value.

function polynomial_sum(coefficients, x)
    local sum = 0
    for i = 1, #coefficients do
        sum = sum + coefficients[i] * x^(i - 1)
        print(coefficients[i], x^(i - 1), sum)
    end
    return sum
end


print("input the coefficients size:")
local size = io.read("*n")

local coefficients = {}
print("input the coeficients:")
for i = 1, size do
    coefficients[i] = io.read("*n")
end

print("input the x, use ctrl-d to stop")
while true do
    local x = io.read("*n")
    print("sum(" .. x .. ") = ", polynomial_sum(coefficients, x))
end

