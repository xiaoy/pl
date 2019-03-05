-- example for 9.4
-- direct download

local socket = require("socket")
local host = "www.w3.org"

function get(host, file)
    local c = assert(socket.connect(host, 80))
    c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
    local count = 0
    while true do
        local s, status, partial = c:receive(2^10)
        local text = s or partial
        count = count + #text
        if status == "closed" then 
            break
        end
    end
    c:close()
    print(file, count)
end

get(host, "/TR/html1401/html140.txt")
get(host, "/TR/2002/REC-xhtml1-20020801/xhtml1.pdf")
get(host, "/TR/REC-html32.html")
get(host, "/TR/2000/REC-DOM-Level-2-Core-20001113/DOM2-Core.txt")