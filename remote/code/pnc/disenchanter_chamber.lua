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
    local hasInput = false
    for i = 1, raw_output.size() do
        local item = raw_output.getItemDetail(i)
        if item then
            hasInput = true
            local target = nil
            if item.enchantments then
                if item.name == 'minecraft:enchanted_book' and #item.enchantments == 1 then
                    -- put books to slot1
                    target = books
                else
                    -- recycle enchantments to output
                    target = input
                end
            elseif item.name == 'minecraft:book' then
                target = input
            else
                -- put equipments to slot2
                target = equipments
            end
            print(string.format('%s -> %s', item.name, target))
            raw_output.pushItems(target, i)
        end
    end
    if not hasInput then
        sleep(1)
    end
end
