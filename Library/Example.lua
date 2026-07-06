--[[
    Example.lua

    Exemplo de uso da Library depois de publicada no GitHub.
    Este arquivo NÃO faz parte do loader (não é importado pelo init.lua) —
    é só uma referência de como o usuário final consome a API pública.
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Library/init.lua"
))()

local Window = Library:CreateWindow({
    Title = "Professional UI",
    Size = UDim2.fromOffset(480, 320),
})

Window:AddLabel({ Text = "Configurações Gerais" })

Window:AddButton({
    Text = "Executar ação",
    Callback = function()
        print("Botão clicado!")
    end,
})

Window:AddToggle({
    Text = "Ativar recurso",
    Default = false,
    Callback = function(value)
        print("Toggle mudou para:", value)
    end,
})

Window:AddSlider({
    Text = "Velocidade",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Callback = function(value)
        print("Slider mudou para:", value)
    end,
})

Window:AddDropdown({
    Text = "Modo",
    Options = { "Fácil", "Normal", "Difícil" },
    Default = "Normal",
    Callback = function(value)
        print("Modo selecionado:", value)
    end,
})
