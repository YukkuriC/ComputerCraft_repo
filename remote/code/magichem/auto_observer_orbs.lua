-- input peripheral names
if #arg < 6 then
    print('USAGE: auto_observer_orbs input cache_sun cache_moon cache_star redstone_sun redstone_moon [target_count=16]')
    return
end

local input, cache_sun, cache_moon, cache_star, redstone_sun, redstone_moon, target_count = table.unpack(arg)
target_count = tonumber(target_count or 16)

if 'helpers' then
    function getLightMode()
        if redstone.getAnalogInput(redstone_sun) >= 3 then
            return 'sun'
        elseif redstone.getAnalogInput(redstone_moon) >= 4 then
            return 'moon'
        else
            return 'star'
        end
    end
end

if 'vars' then
    allObservers = {peripheral.find('magichem:astral_observer')}
    inputBox = peripheral.wrap(input)

    caches = {
        sun = cache_sun,
        moon = cache_moon,
        star = cache_star
    }
    cacheBoxes = {
        sun = peripheral.wrap(cache_sun),
        moon = peripheral.wrap(cache_moon),
        star = peripheral.wrap(cache_star)
    }

    targets = {
        sun = 'magichem:solar_orb',
        moon = 'magichem:lunar_orb',
        star = 'magichem:sidereal_orb'
    }

    GLASS_ORB = 'magichem:glass_orb'
end

if 'actions' then
    function dumpObservers(changeMode)
        for _, ob in pairs(allObservers) do
            local item = ob.getItemDetail(1)
            if item ~= nil then
                if item.name == GLASS_ORB then
                    if changeMode then
                        ob.pushItems(caches[lightModeNow], 1)
                    end
                else
                    ob.pushItems(input, 1)
                end
            end
        end
    end

    function fillObservers(target)
        -- count collection chest counts
        local glassOrbItems = {}
        for slot = 1, inputBox.size() do
            local item = inputBox.getItemDetail(slot)
            if item ~= nil then
                if item.name == GLASS_ORB then
                    item.slot = slot
                    table.insert(glassOrbItems, item)
                elseif item.name == targets[lightModeNow] then
                    target = target - item.count
                end
            end
        end

        -- count all product & collect empty observers
        local emptyObservers = {}
        for _, ob in pairs(allObservers) do
            local item = ob.getItemDetail(1)
            if item == nil then
                table.insert(emptyObservers, ob)
            else
                target = target - item.count
            end
        end

        -- collect non-empty item slot & count
        local cacheBox = cacheBoxes[lightModeNow]
        local cacheContents = {}
        for slot = 1, cacheBox.size() do
            local item = cacheBox.getItemDetail(slot)
            if item ~= nil then
                item.slot = slot
                table.insert(cacheContents, item)
                target = target - item.count
            end
        end

        -- fill cache to observers
        while #emptyObservers > 0 and #cacheContents > 0 do
            local lastEmpty = table.remove(emptyObservers)
            local lastItem = cacheContents[#cacheContents]
            lastItem.count = lastItem.count - lastEmpty.pullItems(caches[lightModeNow], lastItem.slot, 1)
            if lastItem.count <= 0 then
                cacheContents[#cacheContents] = nil
            end
        end
        -- fill glass orbs from input
        while target > 0 and #emptyObservers > 0 and #glassOrbItems > 0 do
            local lastEmpty = table.remove(emptyObservers)
            local lastItem = glassOrbItems[#glassOrbItems]
            local pulled = lastEmpty.pullItems(input, lastItem.slot, 1)
            lastItem.count = lastItem.count - pulled
            target = target - pulled
            if lastItem.count <= 0 then
                glassOrbItems[#glassOrbItems] = nil
            end
        end
    end
end

-- run
lightModeNow = getLightMode()
print('light mode:', lightModeNow)

while 1 do
    -- on switch mode
    local newLightMode = getLightMode()
    if newLightMode ~= lightModeNow then
        dumpObservers(true)
        lightModeNow = newLightMode
        print('light mode ->', lightModeNow)
    else
        dumpObservers(false)
    end
    fillObservers(20)
    sleep(1)
end
