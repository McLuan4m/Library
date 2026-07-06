--[[
    Example.lua

    Exemplo com a nova estrutura de App (Topbar + Sidebar + Content).
    Rode no executor. A API é encadeada: App -> Page -> Section -> controles.
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/McLuan4m/Library/main/Library/init.lua"
))()

local App = Library:CreateApp({
    Name = "Professional UI",
    Size = UDim2.fromOffset(740, 470),
    -- Logo = "rbxassetid://SEU_ID",   -- opcional
})

-- ===== Página 1 =====
local player = App:AddPage({ Title = "Player" })

local movimento = player:AddSection({ Title = "Movimento" })
movimento:AddToggle({ Text = "Velocidade extra", Default = false, Callback = function(v)
    print("Speed:", v)
end })
movimento:AddSlider({ Text = "Velocidade", Min = 16, Max = 200, Default = 16, Suffix = "", Callback = function(v)
    print("WalkSpeed:", v)
end })
movimento:AddSlider({ Text = "Altura do pulo", Min = 50, Max = 300, Default = 50, Callback = function(v)
    print("JumpPower:", v)
end })

local acoes = player:AddSection({ Title = "Ações", Columns = 2 })
acoes:AddButton({ Text = "Curar", Primary = true, Callback = function() print("Curar") end })
acoes:AddButton({ Text = "Resetar", Callback = function() print("Resetar") end })

-- ===== Página 2 =====
local visual = App:AddPage({ Title = "Visual" })

local geral = visual:AddSection({ Title = "Geral" })
geral:AddToggle({ Text = "Modo escuro", Default = true })
geral:AddDropdown({ Text = "Qualidade", Options = { "Baixa", "Média", "Alta" }, Default = "Alta", Callback = function(v)
    print("Qualidade:", v)
end })

local cores = visual:AddSection({ Title = "Cores" })
cores:AddLabel({ Text = "Ajuste as cores da interface", Variant = "default" })
cores:AddSlider({ Text = "Brilho", Min = 0, Max = 100, Default = 80, Suffix = "%" })

-- ===== Página 3 =====
local config = App:AddPage({ Title = "Configurações" })
local sobre = config:AddSection({ Title = "Sobre" })
sobre:AddLabel({ Text = "Professional UI", Variant = "title" })
sobre:AddLabel({ Text = "Versão 2.0", Variant = "default" })

-- IMPORTANTE: finaliza a montagem (popula a sidebar e ativa a 1ª página)
App:Build()
