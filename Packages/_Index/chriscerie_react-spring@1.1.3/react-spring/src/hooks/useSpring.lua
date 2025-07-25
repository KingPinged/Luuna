local React = require(script.Parent.Parent.React)
local useSprings = require(script.Parent.useSprings)

local isRoact17 = not React.reconcile

if isRoact17 then
    return function(props, deps: {any}?)
        local isFn = type(props) == "function"

        local styles, api = useSprings(
            1,
            if isFn then props else {props},
            if isFn then deps or {} else deps
        )

        return styles[1], api
    end
end

return function(hooks, props, deps: {any}?)
    local isFn = type(props) == "function"

    local styles, api = useSprings(
        hooks,
        1,
        if isFn then props else {props},
        if isFn then deps or {} else deps
    )

    return styles[1], api
end
