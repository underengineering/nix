local worker = worker.Worker.start([[
    local sender = worker.sender
    local receiver = worker.receiver

    sender:send("Hello world")
    -- while true do
    --     local value = receiver:recv()
    --     if not value then break end
    --     print("Worker got", value)
    --     sender:send(value)
    -- end
]])

local tx, rx = worker:sender(), worker:receiver()
tx:send(1)

print("Dead:", worker:dead())
if false then
    while true do
        local p = io.read("l")
        if #p == 0 then
            print("Sending nil")
            tx:send(nil)
            break
        else
            print("Sending", p)
            tx:send(p)
        end

        print("Received", rx:recv())
    end
end

local out = worker:join()
if out then
    utils.print_table(out)
end

print("Dead:", worker:dead())
