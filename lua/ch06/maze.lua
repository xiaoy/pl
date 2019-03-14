-- Exercise 6.4: As we have seen, a tail call is a goto in
-- disguise. Using this idea, reimplement the simple maze
-- game from section 4.4 using tail calls. Each block
-- should become a new function, and each goto becomes
-- a tail call.-

function room1()
    print("room1")
    local move = io.read()
    if move == "south" then
        return room3()
    elseif move == "east" then
        return room2()
    else
        print("invalid move")
        return room1()
    end
end
    

function room2()
    print("room2")
    local move = io.read()
    if move == "south" then
        return room4()
    elseif move == "west" then
        return room1()
    else
        print("invalid move")
        return room2()
    end
end

function room3()
    print("room3")
    local move = io.read()
    if move == "north" then
        return room1()
    elseif move == "east" then
        return room4()
    else
        print("invalid move")
        return room3()
    end
end

function room4()
    print("Congratulations, you won!")
end
room1()