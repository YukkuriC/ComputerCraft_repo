-- requires: MNAOverpowered & AdvancedPeripherals
local function buildCrafter(nexus, me_bridge, item_input, item_output)
    local pME = peripheral.wrap(me_bridge)
    local pNexus = peripheral.wrap(nexus)

    local function craftWithItems(target)
        pME.craftItem({
            name = target,
            count = 1
        })

        if 'init recipe' then
            while pNexus.getItemDetail(2) do
                -- print('waiting for existing task to finish')
                sleep(5)
                existRecipe = pNexus.getRecipe()
            end

            -- print('set recipe to: ' .. target)
            pNexus.setRecipe(target)
        end

        -- each stage
        for i = 1, pNexus.getTotalStages(), 1 do
            -- print('filling items for stage ' .. i)
            while pNexus.fillRequiredItems(item_input) <= 0 do
                sleep(1)
            end

            local started = i > 1
            local failsafe = 0
            while 1 do
                sleep(1)
                failsafe = failsafe + 1
                local stages = pNexus.getStage()
                if stages[1] + 1 ~= i or stages[2] == 0 then
                    if started then
                        -- print('stage ' .. i .. ' finished')
                        break
                    end
                elseif stages[2] > 0 then
                    started = true
                end
                if failsafe >= 10 then
                    pNexus.fillRequiredItems(item_input)
                    failsafe = 0
                end
            end
        end

        -- collect output
        for i = 8, 16, 1 do
            pNexus.pushItems(item_output, i)
        end
    end

    return craftWithItems
end

local function stock_keeper(nexus, me_bridge, item_input, item_output, targetMap, targetMapSecondary)
    local pME = peripheral.wrap(me_bridge)
    local craftWithItems = buildCrafter(nexus, me_bridge, item_input, item_output)

    local function processMap(map)
        if not map then
            return false
        end
        local ret = false
        for itemId, targetCount in pairs(map) do
            local exist = pME.getItem({
                name = itemId
            })
            local count = exist and exist.amount or 0
            if count < targetCount then
                print(string.format('lacking %d %s, start crafting', targetCount - count, itemId))
                craftWithItems(itemId)
                ret = true
            end
        end
        return ret
    end

    while 1 do
        if not processMap(targetMap) then
            if not processMap(targetMapSecondary) then
                sleep(10)
            end
        end
    end
end

return {
    stock_keeper = stock_keeper
}
