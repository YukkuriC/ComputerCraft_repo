-- input peripheral names
if #arg < 2 then
    print('USAGE: skywrath_supply input output [redstone_side=top]')
    return
end

local input, output, redstone_side = table.unpack(arg)
redstone_side = redstone_side or 'top'

if 'vars' then
    allAltars = {peripheral.find('magichem:skywrath_altar')}
    print(string.format("found %s altars", #allAltars))
    inputBox = peripheral.wrap(input)
    -- outputBox = peripheral.wrap(output)

    recipeInputs = {
        ['mna:arcane_ash'] = 8,
        ['minecraft:torchflower'] = 3,
        ['magichem:verdigris'] = 30,
        ['minecraft:arrow'] = 6
    }
end

if 'helpers' then
    function getGroupCount(item)
        return recipeInputs[item.name] or 1
    end

    function trySort()
        local appearedIds = {}
        local allItems = inputBox.list()
        local sortedPtr = 1
        for i, item in pairs(allItems) do
            if appearedIds[item.name] or i ~= sortedPtr then
                inputBox.pushItems(input, i)
            end
            sortedPtr = sortedPtr + 1
            appearedIds[item.name] = 1
        end
    end

    function supplyAll()
        local allItems = inputBox.list()
        local hasSupplied = false
        local altarPtr = 1
        for i, item in pairs(allItems) do
            local supplyStep = getGroupCount(item)
            -- print(i, textutils.serialise(item), supplyStep)
            while item.count >= supplyStep and altarPtr <= #allAltars do
                local altar = allAltars[altarPtr]
                if not altar.getItemDetail(1) then
                    altar.pullItems(input, i, supplyStep)
                    item.count = item.count - supplyStep
                    hasSupplied = true
                end
                altarPtr = altarPtr + 1
            end
            if altarPtr > #allAltars then
                return hasSupplied
            end
        end
        return hasSupplied
    end

    function grabAll()
        for _, altar in pairs(allAltars) do
            altar.pushItems(output, 1)
        end
    end

end

while 1 do
    trySort()
    if supplyAll() then
        print('Strike!')
        redstone.setOutput(redstone_side, true)
        sleep(1)
        redstone.setOutput(redstone_side, false)
        sleep(5)
        grabAll()
    else
        grabAll()
        sleep(1)
    end
end
