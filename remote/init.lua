-- https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
function disk_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end
if not DISK_PATH then
    DISK_PATH = disk_path()
    -- add path to package
    if package then
        package.path = package.path .. ';' .. DISK_PATH .. '?.lua;' .. DISK_PATH .. 'libs/?.lua'
    end
end

-- auto patch all codes inside ./patches
local dir_patches = DISK_PATH .. 'patches/'
for _, sub in pairs(fs.list(dir_patches)) do
    dofile(dir_patches .. sub)
end
