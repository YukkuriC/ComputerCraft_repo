-- input peripheral names
local input, equipments, raw_output, books = table.unpack(arg)

if #arg < 4 then
    print('USAGE: disenchanter_chamber <input> <equipments> <raw_output> <books>')
    return
end

raw_output = peripheral.wrap(raw_output)

local function doPush(target, slot, name)
    print(string.format('pushing %s to %s', item, target))
end

print('STARTED...')
-- recycle output
while 1 do
    local sleepCum = 0
    local hasInput = false
    for i = 1, (raw_output.size() or 0) do
        local item = raw_output.getItemDetail(i)
        if item then
            local target = nil
            local targetStr = nil
            if item.enchantments then
                if item.name == 'minecraft:enchanted_book' and #item.enchantments == 1 then
                    -- put books to slot1
                    target = books
                    targetStr = 'books'
                else
                    -- recycle enchantments to output
                    target = input
                    targetStr = 'chamber'
                end
            elseif item.name == 'minecraft:book' then
                target = input
                targetStr = 'chamber'
            else
                -- put equipments to slot2
                target = equipments
                targetStr = 'equipments'
            end
            if raw_output.pushItems(target, i) > 0 then
                print(string.format('%s -> %s', item.name, targetStr))
                hasInput = true
            end
        end
    end
    if not hasInput then
        sleepCum = math.min(sleepCum + 1, 40)
        sleep(sleepCum / 20)
    else
        sleepCum = 0
    end
end
