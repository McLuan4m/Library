--[[
    init.lua

    Ponto de entrada único da Library. Responsável por:

    1. Buscar todos os submódulos internos via HttpGet (raw.githubusercontent.com)
    2. Montar a tabela `Library` com Utility, Services, Theme, Core e Components
    3. Expor uma API pública simples: Library:CreateWindow({...})

    Uso pelo usuário final:

        local Library = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Library/init.lua"
        ))()

        local Window = Library:CreateWindow({ Title = "Professional UI" })
        Window:AddButton({ Text = "Clique aqui", Callback = function() print("clicado") end })

    IMPORTANTE: ajuste BASE_URL abaixo para apontar para o seu repositório
    e branch reais antes de publicar.
]]

local HttpService = game:GetService("HttpService")

-- =========================================================================
-- CONFIGURAÇÃO DO LOADER
-- =========================================================================

local BASE_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Library/"

-- Cache simples para evitar buscar o mesmo módulo duas vezes na mesma sessão
local _cache = {}

local function fetch(relativePath)
    if _cache[relativePath] then
        return _cache[relativePath]
    end

    local url = BASE_URL .. relativePath
    local ok, source = pcall(game.HttpGet, game, url)
    if not ok then
        error(("[Library] Falha ao baixar módulo '%s': %s"):format(relativePath, tostring(source)))
    end

    local chunk, compileErr = loadstring(source, "=" .. relativePath)
    if not chunk then
        error(("[Library] Falha ao compilar módulo '%s': %s"):format(relativePath, tostring(compileErr)))
    end

    _cache[relativePath] = chunk
    return chunk
end

-- Executa um módulo remoto passando `Library` como argumento (padrão usado
-- por Core/Components/Theme, que retornam function(Library) ... end)
local function importInjected(relativePath, ...)
    local chunk = fetch(relativePath)
    return chunk(...)
end

-- Executa um módulo remoto "puro" (sem receber Library), usado por Utility
-- e por tabelas estáticas de dados como o DefaultTheme
local function importPlain(relativePath)
    local chunk = fetch(relativePath)
    return chunk()
end

-- =========================================================================
-- MONTAGEM DA LIBRARY
-- =========================================================================

local Library = {}
Library._modulesRaw = {} -- guarda dados brutos (ex: tema padrão) antes de virar ThemeManager
Library.Utility = {}
Library.Services = nil
Library.Theme = nil
Library.Core = {}
Library.Components = {}

-- 1) Utility (sem dependências)
Library.Utility.Signal = importPlain("Utility/Signal.lua")
Library.Utility.Maid   = importPlain("Utility/Maid.lua")

-- 2) Services (sem dependências)
Library.Services = importPlain("Services/Services.lua")

-- 3) Theme (DefaultTheme é dado puro; ThemeManager depende de Library.Utility)
Library._modulesRaw.DefaultTheme = importPlain("Theme/DefaultTheme.lua")
Library.Theme = importInjected("Theme/ThemeManager.lua", Library)

-- 4) Core (ordem importa: RenderEngine -> Widget -> EventManager)
Library.Core.RenderEngine = importInjected("Core/RenderEngine.lua", Library)
Library.Core.Widget       = importInjected("Core/Widget.lua", Library)
Library.Core.EventManager = importInjected("Core/EventManager.lua", Library)

-- 5) Components (dependem de Core, Theme, Services, Utility já prontos)
Library.Components.Label    = importInjected("Components/Label.lua", Library)
Library.Components.Button   = importInjected("Components/Button.lua", Library)
Library.Components.Toggle   = importInjected("Components/Toggle.lua", Library)
Library.Components.Slider   = importInjected("Components/Slider.lua", Library)
Library.Components.Dropdown = importInjected("Components/Dropdown.lua", Library)
Library.Components.Window   = importInjected("Components/Window.lua", Library)

-- =========================================================================
-- API PÚBLICA
-- =========================================================================

-- Ponto de entrada usado pelo usuário final da Library
function Library:CreateWindow(config)
    return self.Components.Window.new(config)
end

-- Permite trocar o tema em runtime: Library:SetTheme(customThemeTable)
function Library:SetTheme(themeTable)
    self.Theme:SetTheme(themeTable)
end

function Library:GetTheme()
    return self.Theme:Get()
end

return Library
