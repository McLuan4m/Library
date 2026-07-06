--[[
    Example.lua

    Exemplo de uso da Library com os novos recursos visuais.
    Rode este script no executor (não faz parte do loader).
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/McLuan4m/Library/main/Library/init.lua"
))()

local Window = Library:CreateWindow({
    Title = "Professional UI",
    Subtitle = "Painel de configurações",
    Size = UDim2.fromOffset(520, 380),
})

-- Título de seção (caixa alta, esmaecido)
Window:AddLabel({ Text = "Geral", Variant = "section" })

Window:AddButton({
    Text = "Ação principal",
    Primary = true,               -- botão preenchido na cor de acento
    Callback = function()
        print("Botão primário clicado!")
    end,
})

Window:AddButton({
    Text = "Ação secundária",
    Callback = function()
        print("Botão secundário clicado!")
    end,
})

Window:AddToggle({
    Text = "Ativar recurso",
    Default = true,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Window:AddLabel({ Text = "Ajustes", Variant = "section" })

Window:AddSlider({
    Text = "Velocidade",
    Min = 0, Max = 100, Default = 50, Step = 1,
    Suffix = "%",                 -- sufixo mostrado na pill de valor
    Callback = function(value)
        print("Slider:", value)
    end,
})

Window:AddSlider({
    Text = "Distância",
    Min = 0, Max = 500, Default = 250, Step = 5,
    Suffix = "m",
    Callback = function(value)
        print("Distância:", value)
    end,
})

Window:AddDropdown({
    Text = "Modo",
    Options = { "Fácil", "Normal", "Difícil" },
    Default = "Normal",
    Callback = function(value)
        print("Modo:", value)
    end,
})
