local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/main/Neverlose/source.lua"))()

local Window = Library:Window({
    text = "xooz main dahood script"
})

local TabSection = Window:TabSection({
    text = "xooz lock"
})

local Tab = TabSection:Tab({
    text = "Main",
    icon = "rbxassetid://7999345313",
})

local Section = Tab:Section({
    text = "Aimbot"
})

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local SelectedPart = "Head"

local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Radius = 50
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if AimbotEnabled and FovCircle.Visible then
        local target = nil
        local shortestDistance = FovCircle.Radius
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(SelectedPart) then
                local screenPoint = Camera:WorldToViewportPoint(player.Character[SelectedPart].Position)
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                
                if dist < shortestDistance then
                    target = player.Character[SelectedPart]
                    shortestDistance = dist
                end
            end
        end
        
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

Section:Toggle({
    text = "Aimbot",
    state = false,
    callback = function(v)
        AimbotEnabled = v
    end
})

Section:Toggle({
    text = "Fov",
    state = false,
    callback = function(v)
        FovCircle.Visible = v
    end
})

Section:Slider({
    text = "Fov Size",
    min = 10,
    max = 500,
    default = 50,
    callback = function(v)
        FovCircle.Radius = v
    end
})

Section:Dropdown({
    text = "Aim Part",
    list = {"Head", "Torso", "HumanoidRootPart"},
    default = "Head",
    callback = function(v)
        SelectedPart = v
    end
})

Section:Textbox({
    text = "Note",
    value = "Default",
    callback = function(v)
        print(v)
    end
})

Section:Colorpicker({
    text = "Fov Color",
    color = Color3.new(1,1,1),
    callback = function(c)
        FovCircle.Color = c
    end
})

Section:Keybind({
    text = "Keybind",
    default = Enum.KeyCode.Q,
    callback = function()
        AimbotEnabled = not AimbotEnabled
    end
})
getgenv().AimbotEnabled = false
getgenv().ShowFOV = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local SmallestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < SmallestDistance then
                    SmallestDistance = distance
                    ClosestPlayer = player
                end
            end
        end
    end
    return ClosestPlayer
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if getgenv().AimbotEnabled and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
        local target = GetClosestPlayer()
        if target then
            args[1] = Ray.new(Camera.CFrame.Position, (target.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

local Section = Tab:Section({
    text = "Silent Aim"
})

Section:Toggle({
    text = "Silent Aim",
    state = getgenv().AimbotEnabled,
    callback = function(v)
        getgenv().AimbotEnabled = v
    end
})


Section:Toggle({
    text = "Silent Aim FOV",
    state = getgenv().ShowFOV,
    callback = function(v)
        getgenv().ShowFOV = v
    end
})
local Section = Tab:Section({
    text = "Hitbox Expander"
})
getgenv().HitboxEnabled = false
getgenv().BotSupport = false
getgenv().HitboxSize = 5
getgenv().HitboxColor = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if not getgenv().HitboxEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isBot = player:FindFirstChild("IsBot") or player.Name == "Bot"
            if not getgenv().BotSupport and isBot then continue end
            
            local hrp = player.Character.HumanoidRootPart
            
            -- Apply Size
            local newSize = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
            if hrp.Size ~= newSize then
                hrp.Size = newSize
            end
            
            -- Apply Visuals
            hrp.Transparency = 0.5
            hrp.Color = getgenv().HitboxColor
            hrp.Material = Enum.Material.Neon
            hrp.CanCollide = false
        end
    end
end)

-- Reset loop
RunService.RenderStepped:Connect(function()
    if getgenv().HitboxEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp.Size.X > 2 then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

local Section = Tab:Section({ text = "Hitbox Expander" })

Section:Toggle({
    text = "Hitbox Expander",
    state = getgenv().HitboxEnabled,
    callback = function(v)
        getgenv().HitboxEnabled = v
    end
})

Section:Toggle({
    text = "Bot Support",
    state = getgenv().BotSupport,
    callback = function(v)
        getgenv().BotSupport = v
    end
})

Section:Colorpicker({
    text = "Hitbox Color",
    color = getgenv().HitboxColor,
    callback = function(c)
        getgenv().HitboxColor = c
    end
})

Section:Slider({
    text = "Hitbox Size",
    min = 2,
    max = 20,
    default = 5,
    callback = function(v)
        getgenv().HitboxSize = v
    end
})


local VisualsTab = TabSection:Tab({
    text = "Visuals",
    icon = "rbxassetid://7999345313",
})

local VisualsSection = VisualsTab:Section({
    text = "ESP"
})

local ESPEnabled = {Box = false, Name = false, Distance = false}

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Enabled = false
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Info"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = head

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled = true
end

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then createESP(player) end
    player.CharacterAdded:Connect(function() createESP(player) end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() createESP(player) end)
end)

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            local head = player.Character:FindFirstChild("Head")
            local billboard = head and head:FindFirstChild("ESP_Info")
            
            if highlight then highlight.Enabled = ESPEnabled.Box end
            if billboard then
                billboard.Enabled = ESPEnabled.Name or ESPEnabled.Distance
                local name = ESPEnabled.Name and player.Name or ""
                local dist = ESPEnabled.Distance and math.floor((LocalPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude) .. " studs" or ""
                billboard.TextLabel.Text = name .. " " .. dist
            end
        end
    end
end)

VisualsSection:Toggle({
    text = "Box ESP",
    state = false,
    callback = function(v) ESPEnabled.Box = v end
})

VisualsSection:Toggle({
    text = "Name ESP",
    state = false,
    callback = function(v) ESPEnabled.Name = v end
})

VisualsSection:Toggle({
    text = "Distance ESP",
    state = false,
    callback = function(v) ESPEnabled.Distance = v end
})
