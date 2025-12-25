local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local SHOW_VERSION = true
local GAME_VERSION = "0.1.0"

local BASE_W = 220
local BASE_H = 130
local WORLD_W = 2200
local WORLD_H = 1400
local FLOOR_Y = 8

local STATE_TITLE = 0
local STATE_PLAY = 1
local STATE_OVER = 2
local STATE_LEVEL = 3

local FONT_UI = Enum.Font.Arcade

local function clamp(x,a,b) return math.max(a, math.min(b,x)) end
local function lerp(a,b,t) return a + (b-a)*t end
local function dist(ax,ay,bx,by) local dx=ax-bx local dy=ay-by return math.sqrt(dx*dx+dy*dy) end

local function clearChildren(inst)
	for _,c in ipairs(inst:GetChildren()) do
		c:Destroy()
	end
end

local function setupPostFX()
	for _,e in ipairs(Lighting:GetChildren()) do
		if e.Name == "_NW_FX" then e:Destroy() end
	end
	local fx = Instance.new("Folder")
	fx.Name = "_NW_FX"
	fx.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "_NW_FX"
	cc.Contrast = 0.10
	cc.Saturation = 0.18
	cc.TintColor = Color3.fromRGB(215,240,255)
	cc.Parent = fx

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "_NW_FX"
	bloom.Intensity = 0.28
	bloom.Threshold = 1.0
	bloom.Size = 16
	bloom.Parent = fx
end
setupPostFX()

local function mkGui()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NeonWild2D"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.Parent = lp:WaitForChild("PlayerGui")

	local backdrop = Instance.new("Frame")
	backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1,1)
	backdrop.Parent = gui
	backdrop.ZIndex = 0

        local root = Instance.new("Frame")
        root.BackgroundTransparency = 1
        root.Size = UDim2.fromScale(1,1)
        root.Parent = gui
        root.ZIndex = 1

        local versionLabel = Instance.new("TextLabel")
        versionLabel.BackgroundTransparency = 1
        versionLabel.AnchorPoint = Vector2.new(0.5, 0)
        versionLabel.Position = UDim2.fromScale(0.5, 0)
        versionLabel.Size = UDim2.fromOffset(180, 14)
        versionLabel.Font = FONT_UI
        versionLabel.TextSize = 10
        versionLabel.TextColor3 = Color3.fromRGB(220,220,220)
        versionLabel.TextStrokeTransparency = 0.8
        versionLabel.TextXAlignment = Enum.TextXAlignment.Center
        versionLabel.TextYAlignment = Enum.TextYAlignment.Top
        versionLabel.Text = "VERSION " .. GAME_VERSION
        versionLabel.Visible = SHOW_VERSION
        versionLabel.ZIndex = 40
        versionLabel.Parent = root

	local canvasHolder = Instance.new("Frame")
	canvasHolder.BackgroundTransparency = 1
	canvasHolder.AnchorPoint = Vector2.new(0.5,0.5)
	canvasHolder.Position = UDim2.fromScale(0.5,0.5)
	canvasHolder.Size = UDim2.fromOffset(BASE_W, BASE_H)
	canvasHolder.Parent = root
	canvasHolder.ZIndex = 10

	local scale = Instance.new("UIScale")
	scale.Scale = 3
	scale.Parent = canvasHolder

	local canvas = Instance.new("Frame")
	canvas.BackgroundColor3 = Color3.fromRGB(10,12,16)
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
	scoreLbl.TextColor3 = Color3.fromRGB(220,220,220)
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
	lvlLbl.TextColor3 = Color3.fromRGB(220,220,220)
	lvlLbl.TextStrokeTransparency = 0.75
	lvlLbl.Text = "LV 1"
	lvlLbl.ZIndex = 19
	lvlLbl.Parent = hudLayer

	local xpBack = Instance.new("Frame")
	xpBack.BackgroundColor3 = Color3.fromRGB(40,44,58)
	xpBack.BorderSizePixel = 0
	xpBack.Size = UDim2.fromOffset(96, 6)
	xpBack.Position = UDim2.fromOffset(6, 36)
	xpBack.ZIndex = 19
	xpBack.Parent = hudLayer

	local xpFill = Instance.new("Frame")
	xpFill.BackgroundColor3 = Color3.fromRGB(90,220,255)
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
	xpTxt.TextColor3 = Color3.fromRGB(200,200,200)
	xpTxt.TextStrokeTransparency = 0.8
	xpTxt.Text = "0/0"
	xpTxt.ZIndex = 19
	xpTxt.Parent = hudLayer

	local hearts = {}
	for i=1,10 do
		local h = Instance.new("Frame")
		h.BorderSizePixel = 0
		h.BackgroundColor3 = Color3.fromRGB(255,90,110)
		h.BackgroundTransparency = 0.05
		h.Size = UDim2.fromOffset(8, 8)
		h.Position = UDim2.fromOffset(BASE_W - 6 - (i*9), 8)
		h.ZIndex = 19
		h.Parent = hudLayer
		hearts[i] = h
	end

	local title = Instance.new("Frame")
	title.BackgroundColor3 = Color3.fromRGB(0,0,0)
	title.BackgroundTransparency = 0.45
	title.Size = UDim2.fromScale(1,1)
	title.Visible = true
	title.Parent = root
	title.ZIndex = 200

	local titleText = Instance.new("TextLabel")
	titleText.BackgroundTransparency = 1
	titleText.Size = UDim2.fromScale(1,1)
	titleText.Font = FONT_UI
	titleText.TextSize = 22
	titleText.TextColor3 = Color3.fromRGB(210,240,255)
	titleText.TextStrokeTransparency = 0.75
	titleText.TextWrapped = true
	titleText.Text = "NEON WILD\n\nWASD MOVE\nMOUSE AIM + LMB FIRE\nTOUCH RIGHT SIDE AIM+FIRE\nSPACE = DASH\n\nTAP/CLICK TO START"
	titleText.Parent = title
	titleText.ZIndex = 201

	local over = Instance.new("Frame")
	over.BackgroundColor3 = Color3.fromRGB(0,0,0)
	over.BackgroundTransparency = 0.45
	over.Size = UDim2.fromScale(1,1)
	over.Visible = false
	over.Parent = root
	over.ZIndex = 200

	local overText = Instance.new("TextLabel")
	overText.BackgroundTransparency = 1
	overText.Size = UDim2.fromScale(1,1)
	overText.Font = FONT_UI
	overText.TextSize = 24
	overText.TextColor3 = Color3.fromRGB(255,120,120)
	overText.TextStrokeTransparency = 0.75
	overText.TextWrapped = true
	overText.Text = "GAME OVER\n\nTAP/CLICK TO RESTART"
	overText.Parent = over
	overText.ZIndex = 201

	local lvl = Instance.new("Frame")
	lvl.BackgroundColor3 = Color3.fromRGB(0,0,0)
	lvl.BackgroundTransparency = 0.30
	lvl.Size = UDim2.fromScale(1,1)
	lvl.Visible = false
	lvl.Parent = root
	lvl.ZIndex = 260

	local lvlTitle = Instance.new("TextLabel")
	lvlTitle.BackgroundTransparency = 1
	lvlTitle.Size = UDim2.new(1,0,0,80)
	lvlTitle.Position = UDim2.new(0,0,0,18)
	lvlTitle.Font = FONT_UI
	lvlTitle.TextSize = 28
	lvlTitle.TextColor3 = Color3.fromRGB(90,220,255)
	lvlTitle.TextStrokeTransparency = 0.75
	lvlTitle.Text = "LEVEL UP!"
	lvlTitle.Parent = lvl
	lvlTitle.ZIndex = 261

	local optContainer = Instance.new("Frame")
	optContainer.BackgroundTransparency = 1
	optContainer.Size = UDim2.new(1,0,0,260)
	optContainer.Position = UDim2.new(0,0,0.5,-110)
	optContainer.Parent = lvl
	optContainer.ZIndex = 261

	local function mkOpt(i)
		local row = Instance.new("TextButton")
		row.AutoButtonColor = true
		row.BackgroundColor3 = Color3.fromRGB(30,34,48)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(0, 560, 0, 78)
		row.Position = UDim2.new(0.5, -280, 0, (i-1)*90)
		row.Text = ""
		row.Parent = optContainer
		row.ZIndex = 262

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = Color3.fromRGB(90,220,255)
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
		titleLbl.TextColor3 = Color3.fromRGB(240,240,240)
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
		subLbl.TextColor3 = Color3.fromRGB(180,180,180)
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
reticle.Size = UDim2.fromOffset(0,0)
reticle.AnchorPoint = Vector2.new(0.5,0.5)
reticle.Position = UDim2.fromOffset(-9999, -9999)
reticle.ZIndex = hudLayer.ZIndex
reticle.Parent = hudLayer

        local touchLayer = Instance.new("Frame")
        touchLayer.BackgroundTransparency = 1
        touchLayer.Size = UDim2.fromScale(1,1)
        touchLayer.ZIndex = 9000
        touchLayer.Parent = gui

        local function mkStick(xScale)
                local holder = Instance.new("Frame")
                holder.BackgroundTransparency = 1
                holder.AnchorPoint = Vector2.new(0.5, 0.5)
                holder.Position = UDim2.fromScale(xScale, 0.82)
                holder.Size = UDim2.fromOffset(120, 120)
                holder.Parent = touchLayer

                local base = Instance.new("Frame")
                base.BackgroundColor3 = Color3.fromRGB(25, 26, 34)
                base.BackgroundTransparency = 0.3
                base.BorderSizePixel = 0
                base.Size = UDim2.fromOffset(86, 86)
                base.AnchorPoint = Vector2.new(0.5, 0.5)
                base.Position = UDim2.fromScale(0.5, 0.5)
                base.Parent = holder

                local outline = Instance.new("UIStroke")
                outline.Thickness = 2
                outline.Color = Color3.fromRGB(80, 110, 160)
                outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                outline.Parent = base

                local handle = Instance.new("Frame")
                handle.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
                handle.BorderSizePixel = 0
                handle.Size = UDim2.fromOffset(30, 30)
                handle.AnchorPoint = Vector2.new(0.5, 0.5)
                handle.Position = UDim2.fromScale(0.5, 0.5)
                handle.Parent = base

                return {
                        holder = holder,
                        base = base,
                        handle = handle,
                        radius = 34,
                        defaultPos = holder.Position,
                }
        end

        local leftStick, rightStick = nil, nil
        local dashButton = nil

        if UserInputService.TouchEnabled then
                leftStick = mkStick(0.18)
                rightStick = mkStick(0.82)

                dashButton = Instance.new("TextButton")
                dashButton.AutoButtonColor = false
                dashButton.Text = "DASH"
                dashButton.Font = FONT_UI
                dashButton.TextSize = 16
                dashButton.TextColor3 = Color3.fromRGB(240, 240, 240)
                dashButton.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
                dashButton.BorderSizePixel = 0
                dashButton.AnchorPoint = Vector2.new(0.5, 0.5)
                dashButton.Size = UDim2.fromOffset(90, 44)
                dashButton.Position = UDim2.fromScale(0.5, 0.78)
                dashButton.ZIndex = touchLayer.ZIndex
                dashButton.Parent = touchLayer

                local dbStroke = Instance.new("UIStroke")
                dbStroke.Thickness = 2
                dbStroke.Color = Color3.fromRGB(255, 120, 140)
                dbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                dbStroke.Parent = dashButton
        end

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
	noise.BackgroundColor3 = Color3.fromRGB(255,255,255)
	noise.BackgroundTransparency = 0.985
	noise.BorderSizePixel = 0
	noise.Size = UDim2.fromOffset(BASE_W, BASE_H)
	noise.Parent = vhs
	noise.ZIndex = 10001

	local topBand = Instance.new("Frame")
	topBand.BackgroundColor3 = Color3.fromRGB(255,255,255)
	topBand.BackgroundTransparency = 0.992
	topBand.BorderSizePixel = 0
	topBand.Size = UDim2.fromOffset(BASE_W, math.floor(BASE_H/3))
	topBand.Position = UDim2.fromOffset(0,0)
	topBand.Parent = vhs
	topBand.ZIndex = 10002

return {
gui=gui, root=root, backdrop=backdrop,
canvasHolder=canvasHolder, canvas=canvas, scale=scale,
worldLayer=worldLayer, marksLayer=marksLayer, xpLayer=xpLayer, pickLayer=pickLayer, bulletLayer=bulletLayer, enemyLayer=enemyLayer, playerLayer=playerLayer, partLayer=partLayer, hudLayer=hudLayer,
scoreLbl=scoreLbl, lvlLbl=lvlLbl, xpFill=xpFill, xpTxt=xpTxt, hearts=hearts,
title=title, over=over, lvl=lvl, titleText=titleText, overText=overText,
opt1=opt1, opt2=opt2, opt3=opt3,
t1=t1, t2=t2, t3=t3, sub1=sub1, sub2=sub2, sub3=sub3,
ico1=ico1, ico2=ico2, ico3=ico3,
reticle=reticle,
touchLayer=touchLayer, leftStick=leftStick, rightStick=rightStick, dashButton=dashButton,
versionLabel=versionLabel,
vhs=vhs, scan=scan, noise=noise, topBand=topBand
}
end

local UI = mkGui()

local function rebuildScanlines()
	clearChildren(UI.scan)
	for y=0,BASE_H-1,2 do
		local l = Instance.new("Frame")
		l.BorderSizePixel = 0
		l.BackgroundColor3 = Color3.fromRGB(0,0,0)
		l.BackgroundTransparency = 0.90
		l.Size = UDim2.fromOffset(BASE_W, 1)
		l.Position = UDim2.fromOffset(0, y)
		l.ZIndex = 10000
		l.Parent = UI.scan
	end
end
rebuildScanlines()

local function updateScale()
	local vp = cam.ViewportSize
	local sx = math.floor(vp.X / BASE_W)
	local sy = math.floor(vp.Y / BASE_H)
	local sc = math.max(1, math.min(sx, sy))
	UI.scale.Scale = sc
	UI.canvasHolder.Position = UDim2.fromOffset(math.floor(vp.X*0.5), math.floor(vp.Y*0.5))
end
updateScale()
cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

local function pointInGui(gui, pos)
        if not gui then return false end
        local p = gui.AbsolutePosition
        local s = gui.AbsoluteSize
        return (pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y)
end

local function setStickHandle(stick, offset)
        if not stick then return end
        local r = stick.radius
        local v = offset
        if v.Magnitude > r then
                v = v.Unit * r
        end
        stick.handle.Position = UDim2.new(0.5, v.X, 0.5, v.Y)
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
	c.Size = UDim2.fromOffset(0,0)
	c.AnchorPoint = Vector2.new(0.5,0.5)
	c.Position = UDim2.fromOffset(0,0)
	c.ZIndex = layer.ZIndex
	c.Parent = layer
	return c
end

local function circlePoints(r)
	local pts = {}
	local x = r
	local y = 0
	local err = 0
	while x >= y do
		pts[#pts+1] = Vector2.new( x,  y)
		pts[#pts+1] = Vector2.new( y,  x)
		pts[#pts+1] = Vector2.new(-y,  x)
		pts[#pts+1] = Vector2.new(-x,  y)
		pts[#pts+1] = Vector2.new(-x, -y)
		pts[#pts+1] = Vector2.new(-y, -x)
		pts[#pts+1] = Vector2.new( y, -x)
		pts[#pts+1] = Vector2.new( x, -y)
		y += 1
		if err <= 0 then err += 2*y + 1 end
		if err > 0 then x -= 1 err -= 2*x + 1 end
	end
	return pts
end

local function mkPixelRing(parent, radius, col, alpha)
	local d = radius * 2
	local c = Instance.new("Frame")
	c.BackgroundTransparency = 1
	c.Size = UDim2.fromOffset(d, d)
	c.AnchorPoint = Vector2.new(0,0)
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
				p.Size = UDim2.fromOffset(1,1)
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
	c.Size = UDim2.fromOffset(0,0)
	c.AnchorPoint = Vector2.new(0.5,0.5)
	c.Position = UDim2.fromOffset(0,0)
	c.ZIndex = parent.ZIndex
	c.Parent = parent
	mkRect(c, -a, 0, a*2+1, 1, col, alpha or 0)
	mkRect(c, 0, -a, 1, a*2+1, col, alpha or 0)
	return c
end

local function mkCenteredCrossIcon(parent, col)
	clearChildren(parent)
	local host = Instance.new("Frame")
	host.BackgroundTransparency = 1
	host.Size = UDim2.fromOffset(44,44)
	host.AnchorPoint = Vector2.new(0.5, 0.5)
	host.Position = UDim2.fromOffset(19,20)
	host.ZIndex = parent.ZIndex
	host.Parent = parent
	
	local sc = Instance.new("UIScale")
	sc.Scale = 4
	sc.Parent = host

	local center = Instance.new("Frame")
	center.BackgroundTransparency = 1
	center.Size = UDim2.fromOffset(0,0)
	center.AnchorPoint = Vector2.new(0.5,0.5)
	center.Position = UDim2.fromOffset(22,22)
	center.ZIndex = parent.ZIndex
	center.Parent = host

	mkPixelCross(center, col, 0.0, 5)
end

local function mkIcon(parent, id)
	local col = Color3.fromRGB(90,220,255)
	if id == 0 then col = Color3.fromRGB(255,210,120)
	elseif id == 1 then col = Color3.fromRGB(90,220,255)
	elseif id == 2 then col = Color3.fromRGB(180,255,220)
	elseif id == 3 then col = Color3.fromRGB(255,240,160)
	elseif id == 4 then col = Color3.fromRGB(255,120,120)
	elseif id == 5 then col = Color3.fromRGB(190,120,255)
	elseif id == 6 then col = Color3.fromRGB(90,220,255)
	elseif id == 7 then col = Color3.fromRGB(255,240,160)
	elseif id == 8 then col = Color3.fromRGB(180,255,220)
	elseif id == 9 then col = Color3.fromRGB(255,90,110)
	elseif id == 10 then col = Color3.fromRGB(255,210,120)
	elseif id == 11 then col = Color3.fromRGB(255,240,160)
	end
	mkCenteredCrossIcon(parent, col)
end

local PAL = {
	A = Color3.fromRGB(55,105,65),
	B = Color3.fromRGB(80,140,90),
	C = Color3.fromRGB(35,75,45),
	D = Color3.fromRGB(120,95,70),
	E = Color3.fromRGB(90,70,55),
	R = Color3.fromRGB(110,120,135),
	S = Color3.fromRGB(75,85,100),
	K = Color3.fromRGB(40,44,58),
}

local function mkPixelSpriteFromPattern(layer, pattern, palette)
	local h = #pattern
	local w = 0
	for i=1,h do w = math.max(w, #pattern[i]) end

	local c = Instance.new("Frame")
	c.BackgroundTransparency = 1
	c.Size = UDim2.fromOffset(w, h)
	c.AnchorPoint = Vector2.new(0.5,0.5)
	c.Position = UDim2.fromOffset(0,0)
	c.ZIndex = layer.ZIndex
	c.Parent = layer

	for y=1,h do
		local row = pattern[y]
		for x=1,#row do
			local ch = string.sub(row, x, x)
			local col = palette[ch]
			if col then
				local p = Instance.new("Frame")
				p.BorderSizePixel = 0
				p.BackgroundColor3 = col
				p.BackgroundTransparency = 0
				p.Size = UDim2.fromOffset(1,1)
				p.Position = UDim2.fromOffset(x-1, y-1)
				p.ZIndex = layer.ZIndex
				p.Parent = c
			end
		end
	end
	local outline = Instance.new("UIStroke")
	outline.Thickness = 1
	outline.Color = Color3.fromRGB(0,0,0)
	outline.Transparency = 0.70
	outline.Parent = c
	return c
end

local TREE_PAT = {
	"....CC....",
	"...CAAC...",
	"..CAA AAC..",
	"..CAA AAC..",
	"...CAAC...",
	"....CC....",
	".....D....",
	".....D....",
	"....EDD...",
	"....EDD...",
}
local TREE_PAT2 = {
	".....CC.....",
	"....CAA C....",
	"...CAA AAC...",
	"...CAA AAC...",
	"....CAA C....",
	".....CC.....",
	"......D.....",
	"......D.....",
	".....EDD....",
	".....EDD....",
	"......D.....",
}
local ROCK_PAT = {
	"...RRR....",
	"..RRRRR...",
	".RRRSSRR..",
	".RRSSSRR..",
	"..RRRRR...",
	"...RRR....",
}
local ROCK_PAT2 = {
	"..RRRRR..",
	".RRSSSRR.",
	"RRSSSSSRR",
	"RRSSSSSRR",
	".RRSSSRR.",
	"..RRRRR..",
}
local BUSH_PAT = {
	"..BBBBB..",
	".BBAAABB.",
	"BBBAAABBB",
	"BBBAAABBB",
	".BBAAABB.",
	"..BBBBB..",
}
local STUMP_PAT = {
	"..DDDDD..",
	".DDEEEDD.",
	".DEEEEED.",
	".DEEEEED.",
	".DDEEEDD.",
	"..DDDDD..",
}

local function mkLandmarkSprite(layer, t, r)
	local bucket = (r >= 10.5) and 2 or 1
	local pat
	if t == 0 then
		pat = (bucket==2) and TREE_PAT2 or TREE_PAT
	elseif t == 1 then
		pat = (bucket==2) and ROCK_PAT or ROCK_PAT2
	elseif t == 2 then
		pat = BUSH_PAT
	else
		pat = STUMP_PAT
	end
	return mkPixelSpriteFromPattern(layer, pat, PAL)
end

local function mkPlayerSprite(layer)
	local c = mkEntityContainer(layer)
	mkRect(c, -2, -1, 4, 2, Color3.fromRGB(90,220,255), 0)
	mkRect(c, -1, -3, 2, 2, Color3.fromRGB(90,220,255), 0)
	mkRect(c, -1,  1, 2, 2, Color3.fromRGB(90,220,255), 0)
	mkRect(c, -1, -1, 2, 2, Color3.fromRGB(255,240,180), 0)

	local auraHost = Instance.new("Frame")
	auraHost.BackgroundTransparency = 1
	auraHost.Size = UDim2.fromOffset(0,0)
	auraHost.AnchorPoint = Vector2.new(0.5,0.5)
	auraHost.Position = UDim2.fromOffset(0,0)
	auraHost.ZIndex = layer.ZIndex
	auraHost.Parent = c

	local auraRing = mkPixelRing(auraHost, 10, Color3.fromRGB(90,220,255), 0.55)
	auraRing.Visible = false

	return c, auraRing, auraHost
end

local function mkEnemySprite(layer, typ)
	local c = mkEntityContainer(layer)

	if typ == 0 then
		mkRect(c, -3, -2, 6, 4, Color3.fromRGB(255,120,120), 0)
		mkRect(c, -2, -4, 4, 2, Color3.fromRGB(255,120,120), 0)
		mkRect(c, -2,  2, 4, 2, Color3.fromRGB(255,120,120), 0)
		mkRect(c, -1, -1, 1, 1, Color3.fromRGB(20,20,20), 0)
		mkRect(c,  0, -1, 1, 1, Color3.fromRGB(20,20,20), 0)
	elseif typ == 1 then
		mkRect(c, -2, -4, 4, 2, Color3.fromRGB(190,120,255), 0)
		mkRect(c, -4, -2, 8, 4, Color3.fromRGB(190,120,255), 0)
		mkRect(c, -2,  2, 4, 2, Color3.fromRGB(190,120,255), 0)
		mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20,20,20), 0)
	else
		mkRect(c, -5, -3, 10, 6, Color3.fromRGB(255,170,90), 0)
		mkRect(c, -3, -5, 6, 2, Color3.fromRGB(255,170,90), 0)
		mkRect(c, -3,  3, 6, 2, Color3.fromRGB(255,170,90), 0)
		mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20,20,20), 0)
	end

	local shieldHost = Instance.new("Frame")
	shieldHost.BackgroundTransparency = 1
	shieldHost.Size = UDim2.fromOffset(0,0)
	shieldHost.AnchorPoint = Vector2.new(0.5,0.5)
	shieldHost.Position = UDim2.fromOffset(0,0)
	shieldHost.ZIndex = layer.ZIndex
	shieldHost.Parent = c

	local shieldRing = mkPixelRing(shieldHost, 7, Color3.fromRGB(255,255,255), 0.70)
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
	mkRect(c, -1, -1, 2, 2, Color3.fromRGB(90,220,255), 0)
	return c
end

local function mkPickupSprite(layer, kind)
	local c = mkEntityContainer(layer)
	local col = (kind==0) and Color3.fromRGB(255,90,110) or ((kind==1) and Color3.fromRGB(255,240,160) or Color3.fromRGB(180,255,220))
	mkRect(c, -2, -2, 4, 4, col, 0)
	mkRect(c, -1, -1, 2, 2, Color3.fromRGB(20,20,25), 0.65)
	return c
end

local function setupGrid()
	clearChildren(UI.worldLayer)
	local gridV = {}
	local gridH = {}

	local function mkLine(vertical)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = Color3.fromRGB(22,24,32)
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
	for i=1,vCount do table.insert(gridV, mkLine(true)) end
	for i=1,hCount do table.insert(gridH, mkLine(false)) end

	local border = Instance.new("Frame")
	border.BackgroundTransparency = 1
	border.Size = UDim2.fromOffset(0,0)
	border.AnchorPoint = Vector2.new(0.5,0.5)
	border.Position = UDim2.fromOffset(0,0)
	border.ZIndex = UI.worldLayer.ZIndex
	border.Parent = UI.worldLayer

	local bt = Instance.new("Frame")
	bt.BorderSizePixel = 0
	bt.BackgroundColor3 = Color3.fromRGB(60,80,120)
	bt.BackgroundTransparency = 0.25
	bt.Size = UDim2.fromOffset(WORLD_W-6, 1)
	bt.Position = UDim2.fromOffset(3, 3)
	bt.ZIndex = UI.worldLayer.ZIndex
	bt.Parent = border

	local bb = Instance.new("Frame")
	bb.BorderSizePixel = 0
	bb.BackgroundColor3 = Color3.fromRGB(60,80,120)
	bb.BackgroundTransparency = 0.25
	bb.Size = UDim2.fromOffset(WORLD_W-6, 1)
	bb.Position = UDim2.fromOffset(3, WORLD_H-3)
	bb.ZIndex = UI.worldLayer.ZIndex
	bb.Parent = border

	local bl = Instance.new("Frame")
	bl.BorderSizePixel = 0
	bl.BackgroundColor3 = Color3.fromRGB(60,80,120)
	bl.BackgroundTransparency = 0.25
	bl.Size = UDim2.fromOffset(1, WORLD_H-6)
	bl.Position = UDim2.fromOffset(3, 3)
	bl.ZIndex = UI.worldLayer.ZIndex
	bl.Parent = border

	local br = Instance.new("Frame")
	br.BorderSizePixel = 0
	br.BackgroundColor3 = Color3.fromRGB(60,80,120)
	br.BackgroundTransparency = 0.25
	br.Size = UDim2.fromOffset(1, WORLD_H-6)
	br.Position = UDim2.fromOffset(WORLD_W-3, 3)
	br.ZIndex = UI.worldLayer.ZIndex
	br.Parent = border

	return gridV, gridH, border
end

local gridV, gridH, borderContainer = setupGrid()

local function canvasToWorld(cx, cy, camX, camY)
	return camX + (cx - BASE_W*0.5), camY + (cy - BASE_H*0.5)
end

local function normScreenXY(x, y)
	local inset = GuiService:GetGuiInset()
	return x - inset.X, y - inset.Y
end

local function screenToCanvas(sx, sy)
	local sc = UI.scale.Scale
	local absPos = UI.canvasHolder.AbsolutePosition
	local x, y = normScreenXY(sx, sy)
	local cx = (x - absPos.X) / sc
	local cy = (y - absPos.Y) / sc
	return cx, cy
end

local upgrades = {
        { id=0, name="DMG +1", desc="BULLETS HIT HARDER" },
	{ id=1, name="FIRE RATE", desc="SHOOT FASTER" },
	{ id=2, name="PICKUP RADIUS", desc="COLLECT FARTHER" },
	{ id=3, name="MULTI SHOT", desc="MORE BULLETS" },
	{ id=4, name="BACK SHOT", desc="SHOOT BEHIND" },
	{ id=5, name="SIDE SHOT", desc="LEFT AND RIGHT" },
	{ id=6, name="AURA", desc="PASSIVE DAMAGE" },
	{ id=7, name="PIERCE", desc="BULLETS GO THROUGH" },
	{ id=8, name="DASH CD", desc="DASH MORE OFTEN" },
	{ id=9, name="MAX HP +1", desc="TOUGHER BODY" },
	{ id=10, name="BULLET SPEED", desc="FASTER PROJECTILES" },
	{ id=11, name="CRIT", desc="RARE BIG HITS" }
}

local moveKeys = {
        W=false, A=false, S=false, D=false,
        Up=false, Down=false, Left=false, Right=false
}
local gamepadMove = Vector2.new(0,0)
local moveTouch = { id=nil, origin=nil, offset=Vector2.new(0,0), radius=34 }
local aimTouchCenter = nil
local aimTouchRadius = (UI.rightStick and UI.rightStick.radius) or 34

local state = STATE_TITLE
local score = 0
local bestScore = 0

local spawnTimer = 0
local spawnInterval = 1.05
local shakeT = 0
local shakeAmp = 0

local function shake(t, amp)
	shakeT = math.max(shakeT, t)
	shakeAmp = math.max(shakeAmp, amp)
end

local function setState(s)
	state = s
	UI.title.Visible = (s == STATE_TITLE)
	UI.over.Visible = (s == STATE_OVER)
	UI.lvl.Visible = (s == STATE_LEVEL)
end

local parts = {}
local function spawnParticle(x, y, vx, vy, life, kind)
	local col = Color3.fromRGB(255,255,255)
	if kind == 0 then col = Color3.fromRGB(255,255,255)
	elseif kind == 1 then col = Color3.fromRGB(255,140,120)
	elseif kind == 2 then col = Color3.fromRGB(255,240,200)
	else col = Color3.fromRGB(255,210,120)
	end
	local ui = Instance.new("Frame")
	ui.BorderSizePixel = 0
	ui.BackgroundColor3 = col
	ui.BackgroundTransparency = 0.0
	ui.Size = UDim2.fromOffset(1, 1)
	ui.Position = UDim2.fromOffset(0,0)
	ui.ZIndex = UI.partLayer.ZIndex
	ui.Parent = UI.partLayer
	table.insert(parts, {x=x,y=y,vx=vx,vy=vy,t=0,life=life,ui=ui})
end

local function hitSpark(x, y)
	for i=1,6 do
		local a = math.random()*math.pi*2
		local sp = 18 + math.random()*37
		spawnParticle(x, y, math.cos(a)*sp, math.sin(a)*sp, 0.10 + math.random()*0.10, 0)
	end
end

local function popFX(x, y, n)
	for i=1,n do
		local a = math.random()*math.pi*2
		local sp = 10 + math.random()*32
		spawnParticle(x, y, math.cos(a)*sp, math.sin(a)*sp, 0.18 + math.random()*0.25, 1)
	end
end

local function muzzleSpark(x, y, dx, dy)
	for i=1,2 do
		spawnParticle(x, y, dx*(18 + math.random()*8), dy*(18 + math.random()*8), 0.06 + math.random()*0.05, 3)
	end
end

local pl = {
	maxHp=5, hp=5,
	level=1, xp=0, xpToNext=18, wantLevelUp=false,
	damage=1, fireCD=0, fireRate=0.14, bulletSp=74,
	shotCount=1, backShot=false, sideShot=false, pierce=0,
	pickupR=18, dashCD=0, dashBaseCD=1.2,
	invulnT=0, invuln=false,
	auraR=0, auraDps=0, auraAcc=0,
	critChance=0,
	lastAimX=1, lastAimY=0,
	fireHeld=false,
	touchAim=false, touchId=nil, touchScreenX=0, touchScreenY=0,
	char=nil, hum=nil, root=nil,
	ui=nil, auraRing=nil, auraHost=nil, auraRadLast=-1
}

local enemies = {}
local bullets = {}
local xps = {}
local picks = {}
local marks = {}

local savedX, savedY = WORLD_W*0.5, WORLD_H*0.5

local function upgradeAllowed(id)
	if id==3 and pl.shotCount>=3 then return false end
	if id==4 and pl.backShot then return false end
	if id==5 and pl.sideShot then return false end
	if id==6 and pl.auraR>=46 then return false end
	if id==7 and pl.pierce>=3 then return false end
	if id==1 and pl.fireRate<=0.055 then return false end
	if id==8 and pl.dashBaseCD<=0.55 then return false end
	return true
end

local function applyUpgrade(id)
	if id==0 then pl.damage += 1
	elseif id==1 then pl.fireRate = math.max(0.05, pl.fireRate * 0.88)
	elseif id==2 then pl.pickupR += 8
	elseif id==3 then pl.shotCount = math.min(3, pl.shotCount + 1)
	elseif id==4 then pl.backShot = true
	elseif id==5 then pl.sideShot = true
	elseif id==6 then pl.auraR = math.min(50, pl.auraR + 10) pl.auraDps += 0.35
	elseif id==7 then pl.pierce = math.min(3, pl.pierce + 1)
	elseif id==8 then pl.dashBaseCD = math.max(0.5, pl.dashBaseCD * 0.85)
	elseif id==9 then pl.maxHp += 1 pl.hp = math.min(pl.maxHp, pl.hp + 1)
	elseif id==10 then pl.bulletSp = math.min(120, pl.bulletSp * 1.12)
	elseif id==11 then pl.critChance = math.min(0.22, pl.critChance + 0.05)
	end
	popFX(savedX, savedY, 10)
	shake(0.06, 1.7)
end

local function pick3Upgrades()
	local out = {}
	local tries = 0
	while #out < 3 and tries < 300 do
		tries += 1
		local u = upgrades[math.random(1, #upgrades)]
		if upgradeAllowed(u.id) then
			local dup=false
			for _,p in ipairs(out) do if p.id==u.id then dup=true end end
			if not dup then table.insert(out, u) end
		end
	end
	while #out < 3 do
		table.insert(out, {id=2,name="PICKUP RADIUS",desc="COLLECT FARTHER"})
	end
	return out
end

local currentUp = nil

local function showLevelUp()
	currentUp = pick3Upgrades()
	UI.t1.Text = currentUp[1].name
	UI.sub1.Text = currentUp[1].desc
	UI.t2.Text = currentUp[2].name
	UI.sub2.Text = currentUp[2].desc
	UI.t3.Text = currentUp[3].name
	UI.sub3.Text = currentUp[3].desc
	mkIcon(UI.ico1, currentUp[1].id)
	mkIcon(UI.ico2, currentUp[2].id)
	mkIcon(UI.ico3, currentUp[3].id)
	setState(STATE_LEVEL)
end

UI.opt1.MouseButton1Click:Connect(function() if state==STATE_LEVEL then applyUpgrade(currentUp[1].id) setState(STATE_PLAY) end end)
UI.opt2.MouseButton1Click:Connect(function() if state==STATE_LEVEL then applyUpgrade(currentUp[2].id) setState(STATE_PLAY) end end)
UI.opt3.MouseButton1Click:Connect(function() if state==STATE_LEVEL then applyUpgrade(currentUp[3].id) setState(STATE_PLAY) end end)

local function getPlayerXY()
	if not pl.root then return savedX, savedY end
	return pl.root.Position.X, pl.root.Position.Z
end

local function forceStayOnFloor()
	if not pl.root then return end
	local p = pl.root.Position
	pl.root.CFrame = CFrame.new(p.X, FLOOR_Y, p.Z)
	pl.root.AssemblyLinearVelocity = Vector3.new(0,0,0)
	pl.root.AssemblyAngularVelocity = Vector3.new(0,0,0)
end

local function setPlayerXY(x,y)
	if not pl.root then
		savedX, savedY = x, y
		return
	end
	x = clamp(x, 8, WORLD_W-8)
	y = clamp(y, 8, WORLD_H-8)
	pl.root.CFrame = CFrame.new(x, FLOOR_Y, y)
	pl.root.AssemblyLinearVelocity = Vector3.new(0,0,0)
	pl.root.AssemblyAngularVelocity = Vector3.new(0,0,0)
	savedX, savedY = x, y
end

local function resolveObstacles(x,y,r,vx,vy)
	for _,lm in ipairs(marks) do
		if lm.solid then
			local rr = r + lm.r*0.72
			local dx = x - lm.x
			local dy = y - lm.y
			local d2 = dx*dx + dy*dy
			if d2 < rr*rr and d2 > 1e-4 then
				local d = math.sqrt(d2)
				local push = rr - d
				local nx = dx/d
				local ny = dy/d
				x += nx*push
				y += ny*push
				vx *= 0.75
				vy *= 0.75
			end
		end
	end
	x = clamp(x, 8, WORLD_W-8)
	y = clamp(y, 8, WORLD_H-8)
	return x,y,vx,vy
end

local function genLandmarks()
	marks = {}
	clearChildren(UI.marksLayer)
	local n = 240
	for i=1,n do
		local x = math.random(20, WORLD_W-20)
		local y = math.random(20, WORLD_H-20)
		local d = dist(x,y, WORLD_W*0.5, WORLD_H*0.5)
		if d >= 140 then
			local t = math.random(0,3)
			local r = (t==0) and (9 + math.random()*5) or ((t==1) and (6 + math.random()*6) or ((t==2) and (7 + math.random()*5) or (6 + math.random()*3)))
			local solid = (t==1 or t==2)
			local ui = mkLandmarkSprite(UI.marksLayer, t, r)
			table.insert(marks, {x=x,y=y,r=r,t=t,solid=solid,ui=ui})
		end
	end
end

local function resetGame()
	score = 0
	spawnTimer = 0
	spawnInterval = 1.05
	shakeT = 0
	shakeAmp = 0
	enemies = {}
	bullets = {}
	xps = {}
	picks = {}
	parts = {}
	clearChildren(UI.enemyLayer)
	clearChildren(UI.bulletLayer)
	clearChildren(UI.xpLayer)
	clearChildren(UI.pickLayer)
	clearChildren(UI.partLayer)
	clearChildren(UI.playerLayer)

	pl.maxHp=5 pl.hp=5
	pl.level=1 pl.xp=0 pl.xpToNext=18 pl.wantLevelUp=false
	pl.damage=1 pl.fireCD=0 pl.fireRate=0.14 pl.bulletSp=74
	pl.shotCount=1 pl.backShot=false pl.sideShot=false pl.pierce=0
	pl.pickupR=18 pl.dashCD=0 pl.dashBaseCD=1.2
	pl.invulnT=0 pl.invuln=false
	pl.auraR=0 pl.auraDps=0 pl.auraAcc=0
	pl.critChance=0
	pl.lastAimX=1 pl.lastAimY=0
	pl.fireHeld=false
	pl.touchAim=false pl.touchId=nil
	pl.auraRadLast=-1

	pl.ui, pl.auraRing, pl.auraHost = mkPlayerSprite(UI.playerLayer)

	genLandmarks()

	savedX, savedY = WORLD_W*0.5, WORLD_H*0.5
	setPlayerXY(savedX, savedY)
end

local function spawnEnemy()
	local px, py = getPlayerXY()
	local ang = math.random()*math.pi*2
	local distSpawn = 120 + math.random()*80
	local x = clamp(px + math.cos(ang)*distSpawn, 8, WORLD_W-8)
	local y = clamp(py + math.sin(ang)*distSpawn, 8, WORLD_H-8)

	local roll = math.random(1,100)
	local typ = 0
	if roll >= 70 and roll < 92 then typ = 1 end
	if roll >= 92 then typ = 2 end

	local diff = 1 + score*0.02 + pl.level*0.55
	local r = (typ==2) and (6 + math.random()*1.3) or (3.8 + math.random()*2.0)
	local hpBase = (typ==0) and 3 or ((typ==1) and 4 or 10)
	local hp = hpBase + diff*0.7 + math.random(0,2)
	local sp = (typ==0) and (18 + diff*0.65) or ((typ==1) and (15 + diff*0.55) or (11 + diff*0.35))

	local ui, shieldRing, shieldHost = mkEnemySprite(UI.enemyLayer, typ)
	table.insert(enemies, {x=x,y=y,vx=0,vy=0,r=r,hp=hp,sp=sp,typ=typ,t=0,ui=ui,shieldRing=shieldRing,shieldHost=shieldHost,shieldRadLast=-1})
end

local function killEnemy(e)
	score += (e.typ==0 and 1 or (e.typ==1 and 2 or 5))
	popFX(e.x, e.y, 18)
	shake(0.06, 2.0)
	if e.ui then e.ui:Destroy() end

	local xpCount = (e.typ==2) and math.random(6,9) or math.random(2,4)
	for i=1,xpCount do
		local a = math.random()*math.pi*2
		local spd = 10 + math.random()*30
		local ui = mkXpSprite(UI.xpLayer)
		table.insert(xps, {x=e.x,y=e.y,vx=math.cos(a)*spd,vy=math.sin(a)*spd,t=0,ui=ui,val=1})
	end

	if math.random() < 0.08 then
		local kind = math.random(0,2)
		local ui = mkPickupSprite(UI.pickLayer, kind)
		table.insert(picks, {x=e.x,y=e.y,vx=0,vy=0,t=0,kind=kind,ui=ui})
	end
end

local function shoot(dirx, diry)
	local px, py = getPlayerXY()

	local function addShot(dx,dy)
		local bx = px + dx*6
		local by = py + dy*6
		local dmg = pl.damage
		if math.random() < pl.critChance then
			dmg += math.max(1, math.floor(dmg*1.2))
		end
		local col = (pl.pierce>0) and Color3.fromRGB(255,240,160) or Color3.fromRGB(255,210,120)
		local ui = mkBulletSprite(UI.bulletLayer, col)
		table.insert(bullets, {x=bx,y=by,vx=dx*pl.bulletSp,vy=dy*pl.bulletSp,r=0.75,dmg=dmg,pierce=pl.pierce,life=0,ui=ui})
		muzzleSpark(bx, by, dx, dy)
	end

	local spread = 0.12
	local shots = pl.shotCount
	for i=1,shots do
		local ang = 0
		if shots==2 then ang = (i==1) and -spread or spread end
		if shots==3 then ang = (i==1) and -spread or ((i==2) and 0 or spread) end
		local c = math.cos(ang) local s = math.sin(ang)
		local dx = dirx*c - diry*s
		local dy = dirx*s + diry*c
		local m = math.sqrt(dx*dx+dy*dy)
		if m > 1e-6 then dx/=m dy/=m end
		addShot(dx,dy)
	end
	if pl.backShot then addShot(-dirx, -diry) end
	if pl.sideShot then
		addShot(-diry, dirx)
		addShot(diry, -dirx)
	end
end

local function gainXP(v)
	pl.xp += v
	if pl.xp >= pl.xpToNext then
		pl.xp -= pl.xpToNext
		pl.level += 1
		pl.xpToNext = math.floor(18 + (pl.level^1.35)*6.0)
		pl.wantLevelUp = true
	end
end

local function updateHUD()
	UI.scoreLbl.Text = "SCORE "..tostring(score)
	UI.lvlLbl.Text = "LV "..tostring(pl.level)
	local t = (pl.xpToNext>0) and clamp(pl.xp/pl.xpToNext, 0, 1) or 0
	UI.xpFill.Size = UDim2.fromOffset(math.floor(96*t+0.5), 6)
	UI.xpTxt.Text = tostring(pl.xp).."/"..tostring(pl.xpToNext)

	for i=1,#UI.hearts do
		local h = UI.hearts[i]
		h.Visible = (i <= pl.maxHp)
		if i <= pl.hp then
			h.BackgroundColor3 = Color3.fromRGB(255,90,110)
			h.BackgroundTransparency = 0.05
		else
			h.BackgroundColor3 = Color3.fromRGB(70,70,85)
			h.BackgroundTransparency = 0.15
		end
	end

	if state==STATE_OVER then
		UI.overText.Text = "GAME OVER\n\nSCORE "..score.."\nBEST "..bestScore.."\n\nTAP/CLICK TO RESTART"
	end
end

local function updateVHS()
	UI.noise.BackgroundTransparency = 0.985 + (math.random()*0.012)
	UI.noise.Position = UDim2.fromOffset(math.random(-1,1), math.random(-1,1))
	UI.topBand.BackgroundTransparency = 0.990 + (math.random()*0.007)
	UI.topBand.Position = UDim2.fromOffset(math.random(-1,1), math.random(0,1))
end

local camX, camY = WORLD_W*0.5, WORLD_H*0.5

local function updateCamera2D()
	local px, py = getPlayerXY()
	camX = lerp(camX, px, 0.12)
	camY = lerp(camY, py, 0.12)
end

local function updateGridAndBorder()
	local vx0 = camX - BASE_W*0.5
	local vy0 = camY - BASE_H*0.5

	local startX = math.floor((vx0 - 80)/20)*20
	for i=1,#gridV do
		local worldX = startX + (i-1)*20
		local cx = math.floor((worldX - vx0) + 0.5)
		gridV[i].Position = UDim2.fromOffset(cx, 0)
	end

	local startY = math.floor((vy0 - 80)/20)*20
	for i=1,#gridH do
		local worldY = startY + (i-1)*20
		local cy = math.floor((worldY - vy0) + 0.5)
		gridH[i].Position = UDim2.fromOffset(0, cy)
	end

	local bx = (0 - camX) + BASE_W*0.5
	local by = (0 - camY) + BASE_H*0.5
	borderContainer.Position = UDim2.fromOffset(math.floor(bx+0.5), math.floor(by+0.5))
end

local function updateSprites(shakeOffX, shakeOffY)
	local function place(ui, wx, wy, extraVis)
		local cx = (wx - camX) + BASE_W*0.5 + shakeOffX
		local cy = (wy - camY) + BASE_H*0.5 + shakeOffY
		ui.Position = UDim2.fromOffset(math.floor(cx+0.5), math.floor(cy+0.5))
		local pad = extraVis or 40
		ui.Visible = (cx > -pad and cx < BASE_W+pad and cy > -pad and cy < BASE_H+pad)
		return cx, cy
	end

	for _,lm in ipairs(marks) do place(lm.ui, lm.x, lm.y, 90) end
	for _,o in ipairs(xps) do place(o.ui, o.x, o.y, 50) end
	for _,p in ipairs(picks) do place(p.ui, p.x, p.y, 50) end
	for _,b in ipairs(bullets) do place(b.ui, b.x, b.y, 50) end
	for _,e in ipairs(enemies) do place(e.ui, e.x, e.y, 80) end

	local px, py = getPlayerXY()
	if pl.ui then
		place(pl.ui, px, py, 80)
		if pl.invuln and (math.floor(tick()*12)%2==0) then
			pl.ui.Visible = false
		end
	end
end

local function updateReticle()
	if state ~= STATE_PLAY then
		UI.reticle.Position = UDim2.fromOffset(-9999, -9999)
		return
	end
	if UserInputService.TouchEnabled then
		if pl.touchAim then
			local cx, cy = screenToCanvas(pl.touchScreenX, pl.touchScreenY)
			UI.reticle.Position = UDim2.fromOffset(math.floor(cx+0.5), math.floor(cy+0.5))
		else
			UI.reticle.Position = UDim2.fromOffset(-9999, -9999)
		end
	else
		local mp = UserInputService:GetMouseLocation()
		local cx, cy = screenToCanvas(mp.X, mp.Y)
		UI.reticle.Position = UDim2.fromOffset(math.floor(cx+0.5), math.floor(cy+0.5))
	end
end

clearChildren(UI.reticle)
mkPixelCross(UI.reticle, Color3.fromRGB(90,220,255), 0.0, 4)

local function onCharacter(char)
	pl.char = char
	pl.hum = char:WaitForChild("Humanoid")
	pl.root = char:WaitForChild("HumanoidRootPart")

	pl.hum.AutoRotate = false
	pl.hum.WalkSpeed = 0
	pl.hum.JumpPower = 0

	for _,d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CastShadow = false
			if d.Name ~= "HumanoidRootPart" then
				d.Transparency = 1
			end
		end
	end

	setPlayerXY(savedX, savedY)
	forceStayOnFloor()
end

lp.CharacterAdded:Connect(onCharacter)
if lp.Character then onCharacter(lp.Character) end

local dashQueued = false
ContextActionService:BindAction("NW_DASH", function(_, inputState)
        if inputState == Enum.UserInputState.Begin then
                if state==STATE_PLAY then dashQueued=true end
        end
        return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)

local function queueDash()
        if state==STATE_PLAY then dashQueued = true end
end

if UI.dashButton then
        UI.dashButton.Activated:Connect(queueDash)
end

local function resetMoveTouch()
        moveTouch.id = nil
        moveTouch.origin = nil
        moveTouch.offset = Vector2.new(0,0)
        setStickHandle(UI.leftStick, Vector2.new(0,0))
        if UI.leftStick and UI.leftStick.defaultPos then
                UI.leftStick.holder.Position = UI.leftStick.defaultPos
        end
end

local function updateMoveTouch(pos)
        if not moveTouch.origin then return end
        local delta = pos - moveTouch.origin
        moveTouch.offset = delta
        moveTouch.radius = UI.leftStick and UI.leftStick.radius or 34
        setStickHandle(UI.leftStick, delta)
end

local function resetAimStick()
        aimTouchCenter = nil
        setStickHandle(UI.rightStick, Vector2.new(0,0))
        if UI.rightStick and UI.rightStick.defaultPos then
                UI.rightStick.holder.Position = UI.rightStick.defaultPos
        end
end

local function setAimFromPosition(pos)
        if not aimTouchCenter then return end
        local delta = pos - aimTouchCenter
        local r = aimTouchRadius
        if delta.Magnitude > r then
                delta = delta.Unit * r
        end
        setStickHandle(UI.rightStick, delta)
        pl.touchAim = true
        pl.touchScreenX = aimTouchCenter.X + delta.X
        pl.touchScreenY = aimTouchCenter.Y + delta.Y
        pl.fireHeld = true
end

local function getMoveVector()
        if moveTouch.id then
                local r = math.max(1, moveTouch.radius)
                local vx = moveTouch.offset.X / r
                local vy = moveTouch.offset.Y / r
                local m = math.sqrt(vx*vx + vy*vy)
                if m > 1 then vx/=m vy/=m end
                return vx, vy
        end

        local vx = 0
        if moveKeys.D or moveKeys.Right then vx += 1 end
        if moveKeys.A or moveKeys.Left then vx -= 1 end

        local vy = 0
        if moveKeys.S or moveKeys.Down then vy += 1 end
        if moveKeys.W or moveKeys.Up then vy -= 1 end

        vx += gamepadMove.X
        vy += gamepadMove.Y

        local m = math.sqrt(vx*vx + vy*vy)
        if m > 1 then vx/=m vy/=m end
        return vx, vy
end

local function computeAimDir()
        local px, py = getPlayerXY()
        if UserInputService.TouchEnabled then
                        if pl.touchAim then
                                local cx, cy = screenToCanvas(pl.touchScreenX, pl.touchScreenY)
                                local wx, wy = canvasToWorld(cx, cy, camX, camY)
                                local dx, dy = wx - px, wy - py
                                local m = math.sqrt(dx*dx+dy*dy)
                                if m > 1e-6 then return dx/m, dy/m end
                        end
                        return 0,0
        else
                local mp = UserInputService:GetMouseLocation()
                local cx, cy = screenToCanvas(mp.X, mp.Y)
                local wx, wy = canvasToWorld(cx, cy, camX, camY)
                local dx, dy = wx - px, wy - py
                local m = math.sqrt(dx*dx+dy*dy)
                if m > 1e-6 then return dx/m, dy/m end
                return 0,0
        end
end

local function resetTouchAim()
        pl.touchAim = false
        pl.touchId = nil
        pl.fireHeld = false
        resetAimStick()
end

UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then moveKeys.W = true end
                if input.KeyCode == Enum.KeyCode.A then moveKeys.A = true end
                if input.KeyCode == Enum.KeyCode.S then moveKeys.S = true end
                if input.KeyCode == Enum.KeyCode.D then moveKeys.D = true end
                if input.KeyCode == Enum.KeyCode.Up then moveKeys.Up = true end
                if input.KeyCode == Enum.KeyCode.Down then moveKeys.Down = true end
                if input.KeyCode == Enum.KeyCode.Left then moveKeys.Left = true end
                if input.KeyCode == Enum.KeyCode.Right then moveKeys.Right = true end
                if input.KeyCode == Enum.KeyCode.Space then queueDash() end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if state==STATE_TITLE then setState(STATE_PLAY) return end
                if state==STATE_OVER then resetGame() setState(STATE_PLAY) return end
                if state==STATE_PLAY then pl.fireHeld = true end
        end

        if input.UserInputType == Enum.UserInputType.Touch then
                local pos = Vector2.new(input.Position.X, input.Position.Y)
                local vp = cam.ViewportSize

                if state==STATE_TITLE then setState(STATE_PLAY) return end
                if state==STATE_OVER then resetGame() setState(STATE_PLAY) return end

                if UI.dashButton and pointInGui(UI.dashButton, pos) then queueDash() return end

                if state==STATE_PLAY then
                        local leftRegion = UI.leftStick and (pointInGui(UI.leftStick.holder, pos) or pos.X <= vp.X*0.35)
                        if leftRegion then
                                moveTouch.id = input
                                local origin = UI.leftStick.base.AbsolutePosition + UI.leftStick.base.AbsoluteSize*0.5
                                if not pointInGui(UI.leftStick.holder, pos) then
                                        origin = pos
                                        UI.leftStick.holder.Position = UDim2.fromOffset(origin.X, origin.Y)
                                end
                                moveTouch.origin = origin
                                moveTouch.radius = UI.leftStick.radius
                                updateMoveTouch(pos)
                                return
                        end

                        local rightRegion = UI.rightStick and (pointInGui(UI.rightStick.holder, pos) or pos.X >= vp.X*0.65)
                        if rightRegion then
                                pl.touchAim = true
                                pl.touchId = input
                                local center = UI.rightStick.base.AbsolutePosition + UI.rightStick.base.AbsoluteSize*0.5
                                if not pointInGui(UI.rightStick.holder, pos) then
                                        local cx = clamp(pos.X, UI.rightStick.radius + 10, vp.X - UI.rightStick.radius - 10)
                                        local cy = clamp(pos.Y, UI.rightStick.radius + 10, vp.Y - UI.rightStick.radius - 10)
                                        center = Vector2.new(cx, cy)
                                        UI.rightStick.holder.Position = UDim2.fromOffset(center.X, center.Y)
                                end
                                aimTouchCenter = center
                                aimTouchRadius = UI.rightStick.radius
                                setAimFromPosition(pos)
                                return
                        end
                end
        end
end)

UserInputService.InputChanged:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Touch then
                if moveTouch.id == input then
                        updateMoveTouch(Vector2.new(input.Position.X, input.Position.Y))
                end
                if pl.touchAim and pl.touchId == input then
                        setAimFromPosition(Vector2.new(input.Position.X, input.Position.Y))
                end
        elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
                if input.KeyCode == Enum.KeyCode.Thumbstick1 then
                        gamepadMove = Vector2.new(input.Position.X, -input.Position.Y)
                end
        end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then moveKeys.W = false end
                if input.KeyCode == Enum.KeyCode.A then moveKeys.A = false end
                if input.KeyCode == Enum.KeyCode.S then moveKeys.S = false end
                if input.KeyCode == Enum.KeyCode.D then moveKeys.D = false end
                if input.KeyCode == Enum.KeyCode.Up then moveKeys.Up = false end
                if input.KeyCode == Enum.KeyCode.Down then moveKeys.Down = false end
                if input.KeyCode == Enum.KeyCode.Left then moveKeys.Left = false end
                if input.KeyCode == Enum.KeyCode.Right then moveKeys.Right = false end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                pl.fireHeld = false
        end
        if input.UserInputType == Enum.UserInputType.Touch then
                if moveTouch.id == input then resetMoveTouch() end
                if pl.touchId == input then resetTouchAim() end
        elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
                if input.KeyCode == Enum.KeyCode.Thumbstick1 then
                        gamepadMove = Vector2.new(0,0)
                end
        end
end)

resetGame()
setState(STATE_TITLE)

RunService.Heartbeat:Connect(function(dt)
	updateVHS()
	updateScale()
	updateReticle()

	if shakeT > 0 then shakeT -= dt end
	if pl.root then forceStayOnFloor() end

	updateCamera2D()
	updateGridAndBorder()

	local shakeOffX, shakeOffY = 0,0
	if shakeT > 0 then
		local a = shakeAmp * (shakeT * 12.0)
		shakeOffX = (math.random()*2-1) * a
		shakeOffY = (math.random()*2-1) * a
	end

	for i=#parts,1,-1 do
		local p = parts[i]
		p.t += dt
		p.x += p.vx*dt
		p.y += p.vy*dt
		p.vx *= (0.001^(dt))
		p.vy *= (0.001^(dt))
		local a = 1.0 - (p.t / p.life)
		a = clamp(a, 0, 1)
		if p.ui then
			local cx = (p.x - camX) + BASE_W*0.5 + shakeOffX
			local cy = (p.y - camY) + BASE_H*0.5 + shakeOffY
			p.ui.Position = UDim2.fromOffset(math.floor(cx+0.5), math.floor(cy+0.5))
			p.ui.BackgroundTransparency = 1 - a
		end
		if p.t >= p.life then
			if p.ui then p.ui:Destroy() end
			table.remove(parts,i)
		end
	end

	if state ~= STATE_PLAY then
		updateSprites(shakeOffX, shakeOffY)
		updateHUD()
		return
	end

	if not pl.root or not pl.hum then
		updateHUD()
		return
	end

	local px, py = getPlayerXY()

	local dirx, diry = computeAimDir()
	if math.abs(dirx) + math.abs(diry) > 0 then
		pl.lastAimX = dirx
		pl.lastAimY = diry
	end

	pl.fireCD = math.max(0, pl.fireCD - dt)
	pl.dashCD = math.max(0, pl.dashCD - dt)
	pl.invulnT = math.max(0, pl.invulnT - dt)
	pl.invuln = (pl.invulnT > 0)

        local mx, my = getMoveVector()
        pl.hum:Move(Vector3.new(mx, 0, my), true)
        local sp = 46
        local nx = px + mx*sp*dt
        local ny = py + my*sp*dt

	local vx = (nx - px) / math.max(1e-6, dt)
	local vy = (ny - py) / math.max(1e-6, dt)

        if dashQueued and pl.dashCD <= 0 then
                dashQueued = false
                local dx, dy = mx, my
                local m = math.sqrt(dx*dx+dy*dy)
                if m < 0.15 then dx, dy = pl.lastAimX, pl.lastAimY m = math.sqrt(dx*dx+dy*dy) end
                if m < 1e-6 then dx, dy = 1,0 m=1 end
                dx/=m dy/=m

                local dashDistance = 120
                vx += dx * (dashDistance / math.max(dt, 1e-4))
                vy += dy * (dashDistance / math.max(dt, 1e-4))
                nx += dx * dashDistance
                ny += dy * dashDistance

                pl.dashCD = pl.dashBaseCD
                pl.invulnT = 0.22
                popFX(px, py, 10)
                shake(0.08, 2.2)
        else
                dashQueued = false
        end

	nx, ny, vx, vy = resolveObstacles(nx, ny, 5.0, vx, vy)
	setPlayerXY(nx, ny)
	px, py = nx, ny

	if pl.fireHeld and pl.fireCD <= 0 then
		pl.fireCD = pl.fireRate
		shoot(pl.lastAimX, pl.lastAimY)
	end

	local diff = 1 + score*0.02 + pl.level*0.55
	spawnInterval = math.max(0.25, 1.05 - diff*0.04)

	spawnTimer -= dt
	if spawnTimer <= 0 then
		spawnTimer = spawnInterval
		spawnEnemy()
	end

	if pl.auraR > 0 and pl.auraDps > 0 then
		pl.auraAcc += dt * pl.auraDps
		local ticks = math.floor(pl.auraAcc)
		if ticks > 0 then
			pl.auraAcc -= ticks
			for _=1,ticks do
				for i=#enemies,1,-1 do
					local e = enemies[i]
					if dist(e.x,e.y, px,py) < (pl.auraR + e.r) then
						e.hp -= 1
						if e.hp <= 0 then
							killEnemy(e)
							table.remove(enemies,i)
						end
					end
				end
			end
		end
	end

	for i=#picks,1,-1 do
		local p = picks[i]
		p.t += dt
		local d = dist(p.x,p.y, px, py)
		if d < pl.pickupR then
			local dx = px - p.x
			local dy = py - p.y
			local m = math.sqrt(dx*dx+dy*dy)
			if m > 1e-6 then
				local ux, uy = dx/m, dy/m
				local spd = (1 - (d/pl.pickupR))*110 + 40
				p.vx = lerp(p.vx, ux*spd, 0.25)
				p.vy = lerp(p.vy, uy*spd, 0.25)
			end
		end
		p.x += p.vx*dt
		p.y += p.vy*dt
		p.vx *= 0.94^(dt*60)
		p.vy *= 0.94^(dt*60)

		if d < 5 then
			if p.kind==0 then pl.hp = math.min(pl.maxHp, pl.hp+1)
			elseif p.kind==1 then gainXP(6)
			elseif p.kind==2 then pl.invulnT = math.max(pl.invulnT, 0.9)
			end
			popFX(p.x, p.y, 10)
			if p.ui then p.ui:Destroy() end
			table.remove(picks,i)
			shake(0.05, 1.4)
		elseif p.t > 18 then
			if p.ui then p.ui:Destroy() end
			table.remove(picks,i)
		end
	end

	for i=#xps,1,-1 do
		local o = xps[i]
		o.t += dt
		local d = dist(o.x,o.y, px, py)
		local pullR = pl.pickupR + 18
		if d < pullR then
			local dx = px - o.x
			local dy = py - o.y
			local m = math.sqrt(dx*dx+dy*dy)
			if m > 1e-6 then
				local ux, uy = dx/m, dy/m
				local spd = (1 - (d/pullR))*160 + 30
				o.vx = lerp(o.vx, ux*spd, 0.18)
				o.vy = lerp(o.vy, uy*spd, 0.18)
			end
		end
		o.x += o.vx*dt
		o.y += o.vy*dt
		o.vx *= 0.98^(dt*60)
		o.vy *= 0.98^(dt*60)

		if d < 4.2 then
			gainXP(o.val)
			for k=1,3 do spawnParticle(o.x, o.y, (math.random()*2-1)*25, (math.random()*2-1)*25, 0.08 + math.random()*0.08, 2) end
			if o.ui then o.ui:Destroy() end
			table.remove(xps,i)
			shake(0.02, 0.9)
		elseif o.t > 25 then
			if o.ui then o.ui:Destroy() end
			table.remove(xps,i)
		end
	end

	for i=#bullets,1,-1 do
		local b = bullets[i]
		b.life += dt
		b.x += b.vx*dt
		b.y += b.vy*dt
		if b.x < -80 or b.x > WORLD_W+80 or b.y < -80 or b.y > WORLD_H+80 or b.life > 2.6 then
			if b.ui then b.ui:Destroy() end
			table.remove(bullets,i)
		else
			for j=#enemies,1,-1 do
				local e = enemies[j]
				if dist(b.x,b.y, e.x,e.y) < (e.r + b.r) then
					e.hp -= b.dmg
					hitSpark(b.x, b.y)
					shake(0.03, 1.1)
					if b.pierce > 0 then
						b.pierce -= 1
					else
						if b.ui then b.ui:Destroy() end
						table.remove(bullets,i)
					end
					if e.hp <= 0 then
						killEnemy(e)
						table.remove(enemies,j)
					end
					break
				end
			end
		end
	end

	for i=#enemies,1,-1 do
		local e = enemies[i]
		e.t += dt
		local dx = px - e.x
		local dy = py - e.y
		local d = math.sqrt(dx*dx + dy*dy)
		local ux, uy = 1, 0
		if d > 1e-6 then ux, uy = dx/d, dy/d end

		local sx = ux*e.sp
		local sy = uy*e.sp
		if e.typ==1 then
			local wig = math.sin(e.t*6.0)*0.9
			sx += (-uy) * wig * e.sp * 0.75
			sy += ( ux) * wig * e.sp * 0.75
		elseif e.typ==2 then
			sx *= 0.55
			sy *= 0.55
		end

		e.vx = lerp(e.vx, sx, 0.08)
		e.vy = lerp(e.vy, sy, 0.08)
		e.x += e.vx*dt
		e.y += e.vy*dt
		e.x, e.y, e.vx, e.vy = resolveObstacles(e.x, e.y, e.r*0.9, e.vx, e.vy)

		if not pl.invuln and dist(e.x,e.y, px,py) < (e.r + 4.6) then
			if pl.invulnT <= 0 then
				pl.hp -= 1
				pl.invulnT = 0.60
				popFX(px, py, 16)
				shake(0.10, 2.8)
			end
			local kx, ky = e.x - px, e.y - py
			local km = math.sqrt(kx*kx + ky*ky)
			if km < 1e-6 then km=1 kx,ky=1,0 end
			kx, ky = (kx/km)*14, (ky/km)*14
			e.vx += kx
			e.vy += ky
		end
	end

	if pl.hp <= 0 then
		bestScore = math.max(bestScore, score)
		setState(STATE_OVER)
	end

	if pl.wantLevelUp then
		pl.wantLevelUp = false
		showLevelUp()
	end

	if pl.auraHost then
		if pl.auraR > 0 then
			local rad = math.floor(pl.auraR + 0.5)
			if rad ~= pl.auraRadLast then
				pl.auraRadLast = rad
				clearChildren(pl.auraHost)
				pl.auraRing = mkPixelRing(pl.auraHost, rad, Color3.fromRGB(90,220,255), 0.55)
				pl.auraRing.Visible = true
			end
			pl.auraHost.Visible = true
		else
			pl.auraHost.Visible = false
		end
	end

	for _,e in ipairs(enemies) do
		if e.shieldHost and e.shieldRing then
			local show = (e.typ==2) or (e.hp >= 5)
			if show then
				local rad = (e.typ==2) and 9 or 7
				if rad ~= e.shieldRadLast then
					e.shieldRadLast = rad
					clearChildren(e.shieldHost)
					e.shieldRing = mkPixelRing(e.shieldHost, rad, Color3.fromRGB(255,255,255), 0.70)
					e.shieldRing.Visible = true
				end
				e.shieldHost.Visible = true
			else
				e.shieldHost.Visible = false
			end
		end
	end

	updateSprites(shakeOffX, shakeOffY)
	updateHUD()
end)
