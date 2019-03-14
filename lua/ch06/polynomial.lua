-- Exercise 6.2: Exercise 3.3 asked you to write a function that
-- receives a polynomial (represented as a table) and a value
-- for its variable, and returns the polynomial value.

function newpoly(t)
    return function(x)
        local sum = 0
        for i = 1, #t do
            sum = sum + t[i] * x^(#t-i)
        end
        return sum
    end
end

f = newpoly({3, 0, 1})

print("f(0)=" ,f(0))
print("f(5)=", f(5))
print("f(10)=", f(10))