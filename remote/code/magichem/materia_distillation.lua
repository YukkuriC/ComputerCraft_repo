-- input peripheral names
if #arg < 3 then
    print('USAGE: materia_distillation item_input distillation_output mirror_labyrinth')
    return
end

local src, dst, mirror = table.unpack(arg)
local invSrc = peripheral.wrap(src)
local slotsSrc = invSrc.size()
local pMirror = peripheral.wrap(mirror)

local batch_count = 8
local target_percent = 0.7

ITEM_MAP = {
    -- essentia
    ender = "ender_air_bottle",
    air = "hay_block",
    fire = "blaze_block",
    water = "clay",
    earth = "clay",
    arcane = "budding_amethyst",
    verdant = "mana_pool",
    fleshy = "slime_block",
    nourishing = "hay_block",

    -- admixture
    storm = "lightning_rod",
    firmament = "starfield",
    realm = "lodestone",
    color = "dye"
}
SPARE_ITEM = 'rarefied_waste'

function moveItem(itemId, cnt)
    cnt = cnt or batch_count
    for i = 1, slotsSrc, 1 do
        local detail = invSrc.getItemDetail(i)
        if detail and string.match(detail.name, itemId) then
            return invSrc.pushItems(dst, i, cnt)
        end
    end
    return 0
end

while 1 do
    local movedSome = false
    for materia, item in pairs(ITEM_MAP) do
        local myPercent = pMirror.getPercent(materia)
        if myPercent < target_percent then
            local cnt = moveItem(item)
            print(string.format("moving %d %s for mat. %s (%.2f%%)", cnt, item, materia,
                (target_percent - myPercent) * 100))
            movedSome = true
        end
    end
    if movedSome then
        sleep(1)
    else
        local cnt = moveItem(SPARE_ITEM, 64)
        print(string.format("spare, consuming %d waste", cnt))
        sleep(5)
    end
end
