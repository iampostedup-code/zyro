local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local SETTINGS = {
    KEYBIND = Enum.KeyCode.G,
    MAX_DISTANCE = 150,
    SMOOTHNESS = 0.2
}

local target = nil
local isLocked = false

local function getClosestPlayer()
    local closestPart = nil
    local shortestDistance = SETTINGS.MAX_DISTANCE

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local head = otherPlayer.Character:FindFirstChild("Head")
            local hum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")

            if head and hum and root and hum.Health > 0 then
                local _, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPart = head
                    end
                end
            end
        end
    end
    return closestPart
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == SETTINGS.KEYBIND then
        isLocked = not isLocked
        if isLocked then
            target = getClosestPlayer()
            if not target then 
                isLocked = false 
            end
        else
            target = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocked and target and target.Parent and player.Character then
        local hum = target.Parent:FindFirstChildOfClass("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not hum or hum.Health <= 0 or not root then
            isLocked = false
            target = nil
            return
        end

        local dist = (root.Position - target.Position).Magnitude
        if dist > SETTINGS.MAX_DISTANCE then
            isLocked = false
            target = nil
            return
        end

        local targetLook = CFrame.lookAt(camera.CFrame.Position, target.Position)
        camera.CFrame = camera.CFrame:Lerp(targetLook, SETTINGS.SMOOTHNESS)
    else
        if isLocked then
            isLocked = false
            target = nil
        end
    end
end)
