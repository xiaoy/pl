-- Exercise 3.5: How can you check whether a value is boolean
-- without using the type function?

function isboolean(var)
    return var == true or var == false
end

print("isboolean(true):", isboolean(true))
print("isboolean(false):", isboolean(false))
print("isboolean(666):", isboolean(666))
print("isboolean('abc'):", isboolean('abc'))
print("isboolean('nil'):", isboolean('nil'))