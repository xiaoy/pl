-- 4.4
-- maze game not use goto
------  north -------
---west |room1|room2| east---
---     |room3|room4|
------  south -------

function goto_room1()
    print("room1")
    local move = io.read()
    if move == "south" then
        goto_room3()
    elseif move == "east" then
        goto_room2()
    else
        print("invalid move")
        goto_room1()
    end
end
    

function goto_room2()
    print("room2")
    local move = io.read()
    if move == "south" then
        goto_room4()
    elseif move == "west" then
        goto_room1()
    else
        print("invalid move")
        goto_room2()
    end
end

function goto_room3()
    print("room3")
    local move = io.read()
    if move == "north" then
        goto_room1()
    elseif move == "east" then
        goto_room4()
    else
        print("invalid move")
        goto_room3()
    end
end

function goto_room4()
    print("Congratulations, you won!")
end
goto_room1()