-- exercise 5.1
-- Exercise 5.1: Write a function that receives an arbitrary number
-- of strings and returns all of them concatenated together

function contact_str(...)
    local args = table.pack(...)
    if args.n == 0 then
        return "no arguments"
    end
    local str = ''
    for i = 1, args.n do
        str = str .. tostring(args[i])
    end
    return str 
end

local str = "" 
print(contact_str(str, 'a', 'b', '123', 'i ', ' love', ' lua' ))
print(contact_str(true))
print(contact_str())