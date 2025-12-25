local Utility = {}

function Utility.clamp(x, a, b)
    return math.max(a, math.min(b, x))
end

function Utility.lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.dist(ax, ay, bx, by)
    local dx = ax - bx
    local dy = ay - by
    return math.sqrt(dx * dx + dy * dy)
end

function Utility.clearChildren(inst)
    for _, child in ipairs(inst:GetChildren()) do
        child:Destroy()
    end
end

return Utility
