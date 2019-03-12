-- 4.2
-- four ways unconditional loop
-- goto just in lua 5.3
-- for used to iterator array
-- while used to alwasy do task, when something happy then break
-- repeat used to first do things, then decide wether to quit
-- goto just used to jump label

function for_loop(func)
    for i = 1, math.huge do
        func()
    end
end

function while_loop(func)
    while true do
        func()
    end
end

function repeat_loop(func)
    repeat
        func()
    until false
end

function goto_loop(func)
    ::loop::
    func()
    goto loop
end