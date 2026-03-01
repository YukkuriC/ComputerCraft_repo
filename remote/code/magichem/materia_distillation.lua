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
    precious = 'inert_wisdom_stone',
    mineral = 'emerald_block',
    -- nigredo = "vex_armor_trim",
    nigredo = "coast_armor_trim",
    albedo = "snout_armor_trim",
    citrinitas = "spire_armor_trim",
    rubedo = "beacon",

    -- admixture
    storm = "lightning_rod",
    firmament = "starfield",
    realm = "lodestone",
    acid = "diavrosite",
    energy = 'mana_fluxfield',
    light = 'glowstone',
    potential = 'inert_wisdom_stone',
    monster = "blaze_block",
    destruction = 'tnt',
    -- curse = 'infested_stone',
    curse = 'end_crystal',
    color = "dye",
    bone = "bone",
    creature = "lens_tripwire",
    healing = 'rune_lust',
    gourmet = 'rune_gluttony',
    adornment = 'invisibility_cloak',

    -- admixture from exaltation
    depths = 'terrarium_depths'
    -- rubedo = 'scarlet_coral'
}
SPARE_ITEM = 'rarefied_waste'
BATCH_OVERRIDE_MAP = {
    color = 32,
    bone = 32
}

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
            local cnt = moveItem(item, BATCH_OVERRIDE_MAP[materia])
            local needPercent = (target_percent - myPercent) * 100
            if cnt > 0 then
                print(string.format("%s(%.1f%%) = %d %s", materia, needPercent, cnt, item))
                movedSome = true
            else
                print(string.format("%s(%.1f%%) needs %s but lack", materia, needPercent, item))
            end
        end
    end
    if movedSome then
        sleep(1)
    else
        local cnt = moveItem(SPARE_ITEM, 64)
        if cnt > 0 then
            print(string.format("spare, consuming %d waste", cnt))
        end
        sleep(5)
    end
end
