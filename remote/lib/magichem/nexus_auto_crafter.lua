-- requires: MNAOverpowered & AdvancedPeripherals
local function buildCrafter(nexus, me_bridge, item_input, item_output)
    local pME = peripheral.wrap(me_bridge)
    local pNexus = peripheral.wrap(nexus)

    local function isIdle(stage) -- according to AlchemicalNexusScreen.java L164
        return stage == 0 or stage == 3
    end

    local function craftWithItems(target)
        local success, msg = pME.craftItem({
            name = target,
            count = 1
        })
        if not success then
            print(string.format("error when crafting %s: %s", target, msg))
            return
        end

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
            pNexus.fillRequiredItems(item_input)

            local failsafe = 0
            local started = false
            while 1 do
                sleep(1)
                local stageCrafting, stageAnim = table.unpack(pNexus.getStage())
                local idle = isIdle(stageAnim)
                if stageCrafting + 1 ~= i or stageAnim == 0 then
                    -- print('stage ' .. i .. ' finished')
                    if started then
                        break
                    end
                elseif idle then
                    failsafe = failsafe + 1
                    if failsafe >= 5 then
                        for slot = 3, 7 do -- flow back
                            pNexus.pushItems(item_input, i)
                        end
                        pNexus.fillRequiredItems(item_input)
                        failsafe = 0
                    end
                else
                    started = true
                end
            end
        end

        -- collect output
        for i = 8, 16 do
            pNexus.pushItems(item_output, i)
        end

        print('Done.')
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

    sleep(10) -- wait for grid init
    while 1 do
        if not processMap(targetMap) then
            if not processMap(targetMapSecondary) then
                sleep(10)
            end
        end
    end
end

local function craft_cmd(nexus, me_bridge, item_input, item_output)
    local pME = peripheral.wrap(me_bridge)
    local craftWithItems = buildCrafter(nexus, me_bridge, item_input, item_output)

    while 1 do
        print("Input crafting target id:")
        craftWithItems(io.read())
    end
end

return {
    stock_keeper = stock_keeper,
    craft_cmd = craft_cmd
}
