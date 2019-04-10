function class(classSetup)
    local baseEnv = getfenv(classSetup)

    return function(...)
        local this = {
            ["public"] = {},
            ["private"] = {
                ["args"] = {...}
            }
        }

        function newPrivate(funcName, onFunc)
            this.private[funcName] = onFunc
        end

        function newPublic(funcName, onFunc)
            this.public[funcName] = onFunc
        end

        local newEnv = setmetatable({}, {
            __index = function(tbl, key)
                if (key == "this") then
                    return setmetatable(this.public, { __index = this.private })
                elseif (key == "private") then
                    return newPrivate
                elseif (key == "public") then
                    return newPublic
                else
                    return baseEnv[key]
                end
            end
        })

        setfenv(classSetup, newEnv)
        classSetup()

        return setmetatable({}, {
            __index = function(tbl, ind)
                if (this.public[ind] ~= nil) then
                    return this.public[ind]
                else
                    return baseEnv[ind]
                end
            end
        })
    end
end

return class
