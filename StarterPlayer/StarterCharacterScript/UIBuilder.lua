local Utility = require(script.Parent:WaitForChild("Utility"))

local UIBuilder = {}

function UIBuilder.setupPostFX(Lighting)
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect.Name == "_NW_FX" then
            effect:Destroy()
        end
    end

    local fx = Instance.new("Folder")
    fx.Name = "_NW_FX"
    fx.Parent = Lighting

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "_NW_FX"
    cc.Contrast = 0.10
    cc.Saturation = 0.18
    cc.TintColor = Color3.fromRGB(215, 240, 255)
    cc.Parent = fx

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "_NW_FX"
    bloom.Intensity = 0.28
    bloom.Threshold = 1.0
    bloom.Size = 16
    bloom.Parent = fx
end

function UIBuilder.createUI(lp, constants)
    local BASE_W = constants.BASE_W
    local BASE_H = constants.BASE_H
    local FONT_UI = constants.FONT_UI

    local gui = Instance.new("ScreenGui")
    gui.Name = "NeonWild2D"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = lp:WaitForChild("PlayerGui")

    local backdrop = Instance.new("Frame")
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BorderSizePixel = 0
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.Parent = gui
    backdrop.ZIndex = 0

    local root = Instance.new("Frame")
    root.BackgroundTransparency = 1
    root.Size = UDim2.fromScale(1, 1)
    root.Parent = gui
    root.ZIndex = 1

    local canvasHolder = Instance.new("Frame")
    canvasHolder.BackgroundTransparency = 1
    canvasHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    canvasHolder.Position = UDim2.fromScale(0.5, 0.5)
    canvasHolder.Size = UDim2.fromOffset(BASE_W, BASE_H)
    canvasHolder.Parent = root
    canvasHolder.ZIndex = 10

    local scale = Instance.new("UIScale")
    scale.Scale = 3
    scale.Parent = canvasHolder

    local canvas = Instance.new("Frame")
    canvas.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    canvas.BorderSizePixel = 0
    canvas.Size = UDim2.fromOffset(BASE_W, BASE_H)
    canvas.Parent = canvasHolder
    canvas.ZIndex = 10
    canvas.ClipsDescendants = true

    local function mkLayer(z)
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.Size = UDim2.fromOffset(BASE_W, BASE_H)
        f.ZIndex = z
        f.Parent = canvas
        return f
    end

    local worldLayer = mkLayer(11)
    local marksLayer = mkLayer(12)
    local xpLayer = mkLayer(13)
    local pickLayer = mkLayer(14)
    local bulletLayer = mkLayer(15)
    local enemyLayer = mkLayer(16)
    local playerLayer = mkLayer(17)
    local partLayer = mkLayer(18)
    local hudLayer = mkLayer(19)

    local scoreLbl = Instance.new("TextLabel")
    scoreLbl.BackgroundTransparency = 1
    scoreLbl.Size = UDim2.fromOffset(160, 16)
    scoreLbl.Position = UDim2.fromOffset(6, 6)
    scoreLbl.Font = FONT_UI
    scoreLbl.TextSize = 12
    scoreLbl.TextXAlignment = Enum.TextXAlignment.Left
    scoreLbl.TextYAlignment = Enum.TextYAlignment.Top
    scoreLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    scoreLbl.TextStrokeTransparency = 0.75
    scoreLbl.Text = "SCORE 0"
    scoreLbl.ZIndex = 19
    scoreLbl.Parent = hudLayer

    local lvlLbl = Instance.new("TextLabel")
    lvlLbl.BackgroundTransparency = 1
    lvlLbl.Size = UDim2.fromOffset(160, 16)
    lvlLbl.Position = UDim2.fromOffset(6, 20)
    lvlLbl.Font = FONT_UI
    lvlLbl.TextSize = 12
    lvlLbl.TextXAlignment = Enum.TextXAlignment.Left
    lvlLbl.TextYAlignment = Enum.TextYAlignment.Top
    lvlLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lvlLbl.TextStrokeTransparency = 0.75
    lvlLbl.Text = "LV 1"
    lvlLbl.ZIndex = 19
    lvlLbl.Parent = hudLayer

    local xpBack = Instance.new("Frame")
    xpBack.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
    xpBack.BorderSizePixel = 0
    xpBack.Size = UDim2.fromOffset(96, 6)
    xpBack.Position = UDim2.fromOffset(6, 36)
    xpBack.ZIndex = 19
    xpBack.Parent = hudLayer

    local xpFill = Instance.new("Frame")
    xpFill.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
    xpFill.BorderSizePixel = 0
    xpFill.Size = UDim2.fromOffset(0, 6)
    xpFill.ZIndex = 19
    xpFill.Parent = xpBack

    local xpTxt = Instance.new("TextLabel")
    xpTxt.BackgroundTransparency = 1
    xpTxt.Size = UDim2.fromOffset(120, 16)
    xpTxt.Position = UDim2.fromOffset(108, 34)
    xpTxt.Font = FONT_UI
    xpTxt.TextSize = 10
    xpTxt.TextXAlignment = Enum.TextXAlignment.Left
    xpTxt.TextYAlignment = Enum.TextYAlignment.Top
    xpTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
    xpTxt.TextStrokeTransparency = 0.8
    xpTxt.Text = "0/0"
    xpTxt.ZIndex = 19
    xpTxt.Parent = hudLayer

    local hearts = {}
    for i = 1, 10 do
        local h = Instance.new("Frame")
        h.BorderSizePixel = 0
        h.BackgroundColor3 = Color3.fromRGB(255, 90, 110)
        h.BackgroundTransparency = 0.05
        h.Size = UDim2.fromOffset(8, 8)
        h.Position = UDim2.fromOffset(BASE_W - 6 - (i * 9), 8)
        h.ZIndex = 19
        h.Parent = hudLayer
        hearts[i] = h
    end

    local title = Instance.new("Frame")
    title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    title.BackgroundTransparency = 0.45
    title.Size = UDim2.fromScale(1, 1)
    title.Visible = true
    title.Parent = root
    title.ZIndex = 200

    local titleText = Instance.new("TextLabel")
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.fromScale(1, 1)
    titleText.Font = FONT_UI
    titleText.TextSize = 22
    titleText.TextColor3 = Color3.fromRGB(210, 240, 255)
    titleText.TextStrokeTransparency = 0.75
    titleText.TextWrapped = true
    titleText.Text = "NEON WILD\n\nWASD MOVE\nMOUSE AIM + LMB FIRE\nTOUCH RIGHT SIDE AIM+FIRE\nSPACE = DASH\n\nTAP/CLICK TO START"
    titleText.Parent = title
    titleText.ZIndex = 201

    local over = Instance.new("Frame")
    over.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    over.BackgroundTransparency = 0.45
    over.Size = UDim2.fromScale(1, 1)
    over.Visible = false
    over.Parent = root
    over.ZIndex = 200

    local overText = Instance.new("TextLabel")
    overText.BackgroundTransparency = 1
    overText.Size = UDim2.fromScale(1, 1)
    overText.Font = FONT_UI
    overText.TextSize = 24
    overText.TextColor3 = Color3.fromRGB(255, 120, 120)
    overText.TextStrokeTransparency = 0.75
    overText.TextWrapped = true
    overText.Text = "GAME OVER\n\nTAP/CLICK TO RESTART"
    overText.Parent = over
    overText.ZIndex = 201

    local lvl = Instance.new("Frame")
    lvl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lvl.BackgroundTransparency = 0.30
    lvl.Size = UDim2.fromScale(1, 1)
    lvl.Visible = false
    lvl.Parent = root
    lvl.ZIndex = 260

    local lvlTitle = Instance.new("TextLabel")
    lvlTitle.BackgroundTransparency = 1
    lvlTitle.Size = UDim2.new(1, 0, 0, 80)
    lvlTitle.Position = UDim2.new(0, 0, 0, 18)
    lvlTitle.Font = FONT_UI
    lvlTitle.TextSize = 28
    lvlTitle.TextColor3 = Color3.fromRGB(90, 220, 255)
    lvlTitle.TextStrokeTransparency = 0.75
    lvlTitle.Text = "LEVEL UP!"
    lvlTitle.Parent = lvl
    lvlTitle.ZIndex = 261

    local optContainer = Instance.new("Frame")
    optContainer.BackgroundTransparency = 1
    optContainer.Size = UDim2.new(1, 0, 0, 260)
    optContainer.Position = UDim2.new(0, 0, 0.5, -110)
    optContainer.Parent = lvl
    optContainer.ZIndex = 261

    local function mkOpt(i)
        local row = Instance.new("TextButton")
        row.AutoButtonColor = true
        row.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
        row.BorderSizePixel = 0
        row.Size = UDim2.new(0, 560, 0, 78)
        row.Position = UDim2.new(0.5, -280, 0, (i - 1) * 90)
        row.Text = ""
        row.Parent = optContainer
        row.ZIndex = 262

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(90, 220, 255)
        stroke.Transparency = 0.55
        stroke.Parent = row

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 10)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = row

        local icon = Instance.new("Frame")
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.fromOffset(44, 44)
        icon.Position = UDim2.fromOffset(0, 8)
        icon.Parent = row
        icon.ZIndex = 263

        local titleLbl = Instance.new("TextLabel")
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size = UDim2.new(1, -54, 0, 26)
        titleLbl.Position = UDim2.fromOffset(54, 2)
        titleLbl.Font = FONT_UI
        titleLbl.TextSize = 24
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextYAlignment = Enum.TextYAlignment.Top
        titleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        titleLbl.TextStrokeTransparency = 0.78
        titleLbl.Text = "UPGRADE"
        titleLbl.Parent = row
        titleLbl.ZIndex = 263

        local subLbl = Instance.new("TextLabel")
        subLbl.BackgroundTransparency = 1
        subLbl.Size = UDim2.new(1, -54, 0, 22)
        subLbl.Position = UDim2.fromOffset(54, 34)
        subLbl.Font = FONT_UI
        subLbl.TextSize = 14
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.TextYAlignment = Enum.TextYAlignment.Top
        subLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        subLbl.TextStrokeTransparency = 0.85
        subLbl.Text = ""
        subLbl.Parent = row
        subLbl.ZIndex = 263

        return row, titleLbl, subLbl, icon
    end

    local opt1, t1, sub1, ico1 = mkOpt(1)
    local opt2, t2, sub2, ico2 = mkOpt(2)
    local opt3, t3, sub3, ico3 = mkOpt(3)

    local reticle = Instance.new("Frame")
    reticle.BackgroundTransparency = 1
    reticle.Size = UDim2.fromOffset(0, 0)
    reticle.AnchorPoint = Vector2.new(0.5, 0.5)
    reticle.Position = UDim2.fromOffset(-9999, -9999)
    reticle.ZIndex = hudLayer.ZIndex
    reticle.Parent = hudLayer

    local vhs = Instance.new("Frame")
    vhs.BackgroundTransparency = 1
    vhs.Size = UDim2.fromOffset(BASE_W, BASE_H)
    vhs.Parent = canvasHolder
    vhs.ZIndex = 9999

    local scan = Instance.new("Frame")
    scan.BackgroundTransparency = 1
    scan.Size = UDim2.fromOffset(BASE_W, BASE_H)
    scan.Parent = vhs
    scan.ZIndex = 10000

    local noise = Instance.new("Frame")
    noise.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    noise.BackgroundTransparency = 0.985
    noise.BorderSizePixel = 0
    noise.Size = UDim2.fromOffset(BASE_W, BASE_H)
    noise.Parent = vhs
    noise.ZIndex = 10001

    local topBand = Instance.new("Frame")
    topBand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topBand.BackgroundTransparency = 0.992
    topBand.BorderSizePixel = 0
    topBand.Size = UDim2.fromOffset(BASE_W, math.floor(BASE_H / 3))
    topBand.Position = UDim2.fromOffset(0, 0)
    topBand.Parent = vhs
    topBand.ZIndex = 10002

    return {
        gui = gui,
        root = root,
        backdrop = backdrop,
        canvasHolder = canvasHolder,
        canvas = canvas,
        scale = scale,
        worldLayer = worldLayer,
        marksLayer = marksLayer,
        xpLayer = xpLayer,
        pickLayer = pickLayer,
        bulletLayer = bulletLayer,
        enemyLayer = enemyLayer,
        playerLayer = playerLayer,
        partLayer = partLayer,
        hudLayer = hudLayer,
        scoreLbl = scoreLbl,
        lvlLbl = lvlLbl,
        xpFill = xpFill,
        xpTxt = xpTxt,
        hearts = hearts,
        title = title,
        over = over,
        lvl = lvl,
        titleText = titleText,
        overText = overText,
        opt1 = opt1,
        opt2 = opt2,
        opt3 = opt3,
        t1 = t1,
        t2 = t2,
        t3 = t3,
        sub1 = sub1,
        sub2 = sub2,
        sub3 = sub3,
        ico1 = ico1,
        ico2 = ico2,
        ico3 = ico3,
        reticle = reticle,
        vhs = vhs,
        scan = scan,
        noise = noise,
        topBand = topBand,
    }
end

function UIBuilder.rebuildScanlines(UI, constants)
    Utility.clearChildren(UI.scan)
    for y = 0, constants.BASE_H - 1, 2 do
        local l = Instance.new("Frame")
        l.BorderSizePixel = 0
        l.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        l.BackgroundTransparency = 0.90
        l.Size = UDim2.fromOffset(constants.BASE_W, 1)
        l.Position = UDim2.fromOffset(0, y)
        l.ZIndex = 10000
        l.Parent = UI.scan
    end
end

function UIBuilder.updateScale(UI, cam, constants)
    local vp = cam.ViewportSize
    local sx = math.floor(vp.X / constants.BASE_W)
    local sy = math.floor(vp.Y / constants.BASE_H)
    local sc = math.max(1, math.min(sx, sy))
    UI.scale.Scale = sc
    UI.canvasHolder.Position = UDim2.fromOffset(math.floor(vp.X * 0.5), math.floor(vp.Y * 0.5))
end

local function mkRect(parent, x, y, w, h, col, alpha)
    local r = Instance.new("Frame")
    r.BorderSizePixel = 0
    r.BackgroundColor3 = col
    r.BackgroundTransparency = alpha or 0
    r.Size = UDim2.fromOffset(w, h)
    r.Position = UDim2.fromOffset(x, y)
    r.ZIndex = parent.ZIndex
    r.Parent = parent
    return r
end

local function mkEntityContainer(layer)
    local c = Instance.new("Frame")
    c.BackgroundTransparency = 1
    c.Size = UDim2.fromOffset(0, 0)
    c.AnchorPoint = Vector2.new(0.5, 0.5)
    c.Position = UDim2.fromOffset(0, 0)
    c.ZIndex = layer.ZIndex
    c.Parent = layer
    return c
end

local function mkPixelRing(parent, radius, col, alpha)
    local d = radius * 2
    local c = Instance.new("Frame")
    c.BackgroundTransparency = 1
    c.Size = UDim2.fromOffset(d, d)
    c.AnchorPoint = Vector2.new(0, 0)
    c.Position = UDim2.fromOffset(-radius, -radius)
    c.ZIndex = parent.ZIndex
    c.Parent = parent

    local cx = radius - 0.5
    local cy = radius - 0.5
    local rr = radius - 0.5

    local used = {}
    local steps = math.max(32, math.floor(8 * math.pi * radius + 0.5))
    for i = 0, steps - 1 do
        local a = (i / steps) * math.pi * 2
        local x = cx + math.cos(a) * rr
        local y = cy + math.sin(a) * rr
        local px = math.floor(x + 0.5)
        local py = math.floor(y + 0.5)
        if px >= 0 and px < d and py >= 0 and py < d then
            local key = px * 1000 + py
            if not used[key] then
                used[key] = true
                local p = Instance.new("Frame")
                p.BorderSizePixel = 0
                p.BackgroundColor3 = col
                p.BackgroundTransparency = alpha or 0
                p.Size = UDim2.fromOffset(1, 1)
                p.Position = UDim2.fromOffset(px, py)
                p.ZIndex = parent.ZIndex
                p.Parent = c
            end
        end
    end

    return c
end

local function mkPixelCross(parent, col, alpha, arm)
    local a = arm or 4
    local c = Instance.new("Frame")
    c.BackgroundTransparency = 1
    c.Size = UDim2.fromOffset(0, 0)
    c.AnchorPoint = Vector2.new(0.5, 0.5)
    c.Position = UDim2.fromOffset(0, 0)
    c.ZIndex = parent.ZIndex
    c.Parent = parent
    mkRect(c, -a, 0, a * 2 + 1, 1, col, alpha or 0)
    mkRect(c, 0, -a, 1, a * 2 + 1, col, alpha or 0)
    return c
end

local function mkCenteredCrossIcon(parent, col)
    Utility.clearChildren(parent)
    local host = Instance.new("Frame")
    host.BackgroundTransparency = 1
    host.Size = UDim2.fromOffset(44, 44)
    host.AnchorPoint = Vector2.new(0.5, 0.5)
    host.Position = UDim2.fromOffset(19, 20)
    host.ZIndex = parent.ZIndex
    host.Parent = parent

    local sc = Instance.new("UIScale")
    sc.Scale = 4
    sc.Parent = host

    local center = Instance.new("Frame")
    center.BackgroundTransparency = 1
    center.Size = UDim2.fromOffset(0, 0)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.fromOffset(22, 22)
    center.ZIndex = parent.ZIndex
    center.Parent = host

    mkPixelCross(center, col, 0.0, 5)
end

function UIBuilder.createSpriteFactory(UI, constants)
    local BASE_W = constants.BASE_W
    local BASE_H = constants.BASE_H
    local WORLD_W = constants.WORLD_W
    local WORLD_H = constants.WORLD_H

    local function mkPlayerSprite(layer)
        local c = mkEntityContainer(layer)
        mkRect(c, -2, -1, 4, 2, Color3.fromRGB(90, 220, 255), 0)
        mkRect(c, -1, -3, 2, 2, Color3.fromRGB(90, 220, 255), 0)
        mkRect(c, -1, 1, 2, 2, Color3.fromRGB(90, 220, 255), 0)
        mkRect(c, -1, -1, 2, 2, Color3.fromRGB(255, 240, 180), 0)

        local auraHost = Instance.new("Frame")
        auraHost.BackgroundTransparency = 1
        auraHost.Size = UDim2.fromOffset(0, 0)
        auraHost.AnchorPoint = Vector2.new(0.5, 0.5)
        auraHost.Position = UDim2.fromOffset(0, 0)
        auraHost.ZIndex = layer.ZIndex
        auraHost.Parent = c

        local auraRing = mkPixelRing(auraHost, 10, Color3.fromRGB(90, 220, 255), 0.55)
        auraRing.Visible = false

        return c, auraRing, auraHost
    end

    local function mkEnemySprite(layer, typ)
        local c = mkEntityContainer(layer)

        if typ == 0 then
            mkRect(c, -3, -2, 6, 4, Color3.fromRGB(255, 120, 120), 0)
            mkRect(c, -2, -4, 4, 2, Color3.fromRGB(255, 120, 120), 0)
            mkRect(c, -2, 2, 4, 2, Color3.fromRGB(255, 120, 120), 0)
            mkRect(c, -1, -1, 1, 1, Color3.fromRGB(20, 20, 20), 0)
            mkRect(c, 0, -1, 1, 1, Color3.fromRGB(20, 20, 20), 0)
        elseif typ == 1 then
            mkRect(c, -2, -4, 4, 2, Color3.fromRGB(190, 120, 255), 0)
            mkRect(c, -4, -2, 8, 4, Color3.fromRGB(190, 120, 255), 0)
            mkRect(c, -2, 2, 4, 2, Color3.fromRGB(190, 120, 255), 0)
            mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20, 20, 20), 0)
        else
            mkRect(c, -5, -3, 10, 6, Color3.fromRGB(255, 170, 90), 0)
            mkRect(c, -3, -5, 6, 2, Color3.fromRGB(255, 170, 90), 0)
            mkRect(c, -3, 3, 6, 2, Color3.fromRGB(255, 170, 90), 0)
            mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20, 20, 20), 0)
        end

        local shieldHost = Instance.new("Frame")
        shieldHost.BackgroundTransparency = 1
        shieldHost.Size = UDim2.fromOffset(0, 0)
        shieldHost.AnchorPoint = Vector2.new(0.5, 0.5)
        shieldHost.Position = UDim2.fromOffset(0, 0)
        shieldHost.ZIndex = layer.ZIndex
        shieldHost.Parent = c

        local shieldRing = mkPixelRing(shieldHost, 7, Color3.fromRGB(255, 255, 255), 0.70)
        shieldRing.Visible = false

        return c, shieldRing, shieldHost
    end

    local function mkBulletSprite(layer, col)
        local c = mkEntityContainer(layer)
        mkRect(c, 0, 0, 1, 1, col, 0)
        return c
    end

    local function mkXpSprite(layer)
        local c = mkEntityContainer(layer)
        mkRect(c, -1, -1, 2, 2, Color3.fromRGB(90, 220, 255), 0)
        return c
    end

    local function mkPickupSprite(layer, kind)
        local c = mkEntityContainer(layer)
        local col = (kind == 0) and Color3.fromRGB(255, 90, 110)
            or ((kind == 1) and Color3.fromRGB(255, 240, 160) or Color3.fromRGB(180, 255, 220))
        mkRect(c, -2, -2, 4, 4, col, 0)
        mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20, 20, 25), 0.65)
        return c
    end

    local function setupGrid()
        Utility.clearChildren(UI.worldLayer)
        local gridV = {}
        local gridH = {}

        local function mkLine(vertical)
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
            f.BackgroundTransparency = 0.32
            f.ZIndex = UI.worldLayer.ZIndex
            f.Parent = UI.worldLayer
            if vertical then
                f.Size = UDim2.fromOffset(1, BASE_H)
            else
                f.Size = UDim2.fromOffset(BASE_W, 1)
            end
            return f
        end

        local vCount = math.floor((BASE_W + 200) / 20) + 3
        local hCount = math.floor((BASE_H + 200) / 20) + 3
        for _ = 1, vCount do
            table.insert(gridV, mkLine(true))
        end
        for _ = 1, hCount do
            table.insert(gridH, mkLine(false))
        end

        local border = Instance.new("Frame")
        border.BackgroundTransparency = 1
        border.Size = UDim2.fromOffset(0, 0)
        border.AnchorPoint = Vector2.new(0.5, 0.5)
        border.Position = UDim2.fromOffset(0, 0)
        border.ZIndex = UI.worldLayer.ZIndex
        border.Parent = UI.worldLayer

        local bt = Instance.new("Frame")
        bt.BorderSizePixel = 0
        bt.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        bt.BackgroundTransparency = 0.25
        bt.Size = UDim2.fromOffset(WORLD_W - 6, 1)
        bt.Position = UDim2.fromOffset(3, 3)
        bt.ZIndex = UI.worldLayer.ZIndex
        bt.Parent = border

        local bb = Instance.new("Frame")
        bb.BorderSizePixel = 0
        bb.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        bb.BackgroundTransparency = 0.25
        bb.Size = UDim2.fromOffset(WORLD_W - 6, 1)
        bb.Position = UDim2.fromOffset(3, WORLD_H - 3)
        bb.ZIndex = UI.worldLayer.ZIndex
        bb.Parent = border

        local bl = Instance.new("Frame")
        bl.BorderSizePixel = 0
        bl.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        bl.BackgroundTransparency = 0.25
        bl.Size = UDim2.fromOffset(1, WORLD_H - 6)
        bl.Position = UDim2.fromOffset(3, 3)
        bl.ZIndex = UI.worldLayer.ZIndex
        bl.Parent = border

        local br = Instance.new("Frame")
        br.BorderSizePixel = 0
        br.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        br.BackgroundTransparency = 0.25
        br.Size = UDim2.fromOffset(1, WORLD_H - 6)
        br.Position = UDim2.fromOffset(WORLD_W - 3, 3)
        br.ZIndex = UI.worldLayer.ZIndex
        br.Parent = border

        return gridV, gridH, border
    end

    return {
        mkPixelCross = mkPixelCross,
        mkCenteredCrossIcon = mkCenteredCrossIcon,
        mkPlayerSprite = mkPlayerSprite,
        mkEnemySprite = mkEnemySprite,
        mkBulletSprite = mkBulletSprite,
        mkXpSprite = mkXpSprite,
        mkPickupSprite = mkPickupSprite,
        setupGrid = setupGrid,
        mkPixelRing = mkPixelRing,
    }
end

return UIBuilder
