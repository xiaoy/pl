-- exercise 5.4
-- Exercise 5.4: Write a function that receives an array and prints all
-- combinations of the elements in the array.

function  combination(arr, data, n, m, index, depth)
    n = n or #arr
    if depth == m then
        for i = 0, #data do 
            io.write(data[i])
        end
        io.write("\n")
        return
    end
    for i = index, n do
        data[depth] = arr[i] 
        combination(arr, data, n, m, i + 1, depth + 1)
    end
end

arr = {1, 2, 3, 4, 5}
combination(arr, {}, 5, 5, 1, 0)