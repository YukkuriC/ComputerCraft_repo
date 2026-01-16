-- input peripheral names
if #arg < 2 then
    print('USAGE: mechanical_crafting_helper crafter_side marker_id')
    return
end

local crafter_side, marker_id = table.unpack(arg)
print(string.format("checking marker %s on side %s", marker_id, crafter_side))

local inputBox = peripheral.wrap(crafter_side)

-- loop check crafter inventory
while 1 do
    local hasMarker = false
    local anyItem = false
    for slot = 1, inputBox.size() do
        local item = inputBox.getItemDetail(slot)
        if item ~= nil then
            anyItem = true
            if item.name == marker_id then
                hasMarker = true
            end
        end
    end

    if anyItem and not hasMarker then
        redstone.setOutput(crafter_side, true)
        sleep(0.05)
        redstone.setOutput(crafter_side, false)
    end

    sleep(1)
end
