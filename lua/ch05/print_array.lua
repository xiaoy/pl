-- exercise 5.2
-- Exercise 5.2: Write a function that receives an array and prints all
-- the elements in that array. Consider the pros and cons of using
-- table.unpack in this function

function print_array( arr )
    if arr == nil then
        print("arr is nil")
    else
        for k, v in pairs(arr) do
            print(tostring(v))
        end
    end
end


a = {name = "lfwu", salary = 10000, info = {"lua"}}
b = {name = "wu", salary = 20000, age =nil, info = {x = 1, b = 2}}

print_array(a)
print_array(b)

-- table.unpack just can return array