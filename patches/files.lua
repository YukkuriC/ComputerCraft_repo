function fs.walk(path, outputs)
    if not path then
        path = 'disk/'
    elseif string.sub(path, #path) ~= '/' then
        path = path .. '/'
    end
    if not outputs then
        outputs = {}
    end

    for _, sub in pairs(fs.list(path)) do
        -- exclude .git, .vscode, etc.
        if string.sub(sub, 0, 1) ~= '.' then
            local subRoot = path .. sub
            if fs.isDir(subRoot) then
                fs.walk(subRoot, outputs)
            else
                table.insert(outputs, path .. sub)
            end
        end
    end
    return outputs
end
