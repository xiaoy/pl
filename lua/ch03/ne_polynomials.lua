-- Exercise 3.4: Can you write a function from the previous
-- item so that it uses at most n additions and n multiplications
-- (and no exponentiations)?
function polynomial_sum(coefficients, x)
    local sum = 0
    local mutiply_ret = 1 
    for i = 1, #coefficients do
        sum = sum + coefficients[i] *  mutiply_ret
        mutiply_ret = mutiply_ret * x 
        print(coefficients[i], mutiply_ret, sum)
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