--[[
    Services/Services.lua

    Centraliza o acesso aos serviços do Roblox usados pela Library.
    Evita chamadas repetidas de game:GetService espalhadas pelo código
    e facilita mocks/testes.
]]

local Services = {
    TweenService     = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService       = game:GetService("RunService"),
    Players          = game:GetService("Players"),
    CoreGui          = game:GetService("CoreGui"),
    GuiService       = game:GetService("GuiService"),
}

function Services.GetPlayerGui()
    local player = Services.Players.LocalPlayer
    return player and player:WaitForChild("PlayerGui")
end

return Services
