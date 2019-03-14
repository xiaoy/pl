--[[
    Exercise6.3: Sometimes, a language with proper-tail calls
    is called *properly tail recursive*, with the argument that
    this property is revlevant only when we have recursive calls.
    (Without recursive calls, the maximum call depth of a program
    would be statically fixed.)
    
    SHow that this argument does not hold in a dynamic language like
    Lua: write a program that performs an unbounded call chain without
    recursion.
--]]

n = math.random( 999)

function f()
    n = n - 1;
    if n < 0 then
        return nil
    else
        return 'i = 1;'
    end
end

load(f)()