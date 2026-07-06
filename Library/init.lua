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

local BASE_URL = "https://raw.githubusercontent.com/McLuan4m/Library/main/Library/"

-- Cache simples para evitar buscar o mesmo módulo duas vezes na mesma sessão
local _cache = {}

local function fetch(relativePath)
    if _cache[relativePath] then
        return _cache[relativePath]
    end

    local url = BASE_URL .. relativePath .. "?v=" .. tostring(math.random(1, 1e9))
    local ok, source = pcall(game.HttpGet, game, url)
    if not ok then
        error(("[Library] Falha ao baixar módulo '%s'\nURL: %s\nErro: %s"):format(relativePath, url, tostring(source)))
    end

    -- HttpGet não lança erro em 404 (a menos que a Instance esteja configurada
    -- assim), então detectamos manualmente uma resposta de erro do GitHub.
    if source:match("^%s*404:") or source:match("^%s*<!DOCTYPE html>") then
        error(("[Library] Módulo '%s' não encontrado (404).\nURL testada: %s\nVerifique BASE_URL, o nome do branch e a estrutura de pastas do repositório."):format(relativePath, url))
    end

    local chunk, compileErr = loadstring(source, "=" .. relativePath)
    if not chunk then
        error(("[Library] Falha ao compilar módulo '%s': %s"):format(relativePath, tostring(compileErr)))
    end

    _cache[relativePath] = chunk
    return chunk
end

-- Executa um módulo remoto passando `Library` como argumento (padrão usado
-- por Core/Components/Theme, que retornam function(Library) ... end).
--
-- IMPORTANTE: o chunk compilado, quando executado (chunk()), roda o código
-- de nível superior do arquivo — que apenas RETORNA a função interna
-- `function(Library) ... end`. É preciso chamar essa função retornada
-- separadamente, passando Library, para de fato construir o módulo.
local function importInjected(relativePath, ...)
    local chunk = fetch(relativePath)
    local moduleFactory = chunk()
    return moduleFactory(...)
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

-- 4) Core (ordem importa: RenderEngine -> Widget -> Layout -> EventManager)
Library.Core.RenderEngine = importInjected("Core/RenderEngine.lua", Library)
Library.Core.Widget       = importInjected("Core/Widget.lua", Library)
Library.Core.Layout       = importInjected("Core/Layout.lua", Library)
Library.Core.EventManager = importInjected("Core/EventManager.lua", Library)

-- 5) Components de controle (folhas: dependem só de Core/Theme/Utility)
Library.Components.Label    = importInjected("Components/Label.lua", Library)
Library.Components.Button   = importInjected("Components/Button.lua", Library)
Library.Components.Toggle   = importInjected("Components/Toggle.lua", Library)
Library.Components.Slider   = importInjected("Components/Slider.lua", Library)
Library.Components.Dropdown = importInjected("Components/Dropdown.lua", Library)
Library.Components.Window   = importInjected("Components/Window.lua", Library)

-- 6) Components de estrutura (dependem dos controles acima)
--    Ordem: Section -> Page -> Sidebar/Topbar -> App
Library.Components.Section  = importInjected("Components/Section.lua", Library)
Library.Components.Page     = importInjected("Components/Page.lua", Library)
Library.Components.Sidebar  = importInjected("Components/Sidebar.lua", Library)
Library.Components.Topbar   = importInjected("Components/Topbar.lua", Library)
Library.Components.App      = importInjected("Components/App.lua", Library)

-- =========================================================================
-- API PÚBLICA
-- =========================================================================

-- Cria a interface completa em app (Topbar + Sidebar + Content)
function Library:CreateApp(config)
    return self.Components.App.new(config)
end

-- Ponto de entrada legado: janela flutuante simples (ainda suportado)
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
