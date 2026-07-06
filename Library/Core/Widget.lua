--[[
    Core/Widget.lua

    Classe-base de todo Componente visual da Library (Window, Button,
    Slider, Toggle, Dropdown, Label...). Fornece:

    - Instância raiz gerenciada pelo RenderEngine
    - Maid próprio para limpeza de eventos/conexões
    - Registro automático no ThemeManager
    - API padrão: SetVisible, Destroy, ApplyTheme (sobrescrita pelos filhos)

    Todo Componente concreto deve fazer:
        local MyWidget = setmetatable({}, { __index = Widget })
        MyWidget.__index = MyWidget
]]

return function(Library)
    local Maid = Library.Utility.Maid
    local RenderEngine = Library.Core.RenderEngine

    local Widget = {}
    Widget.__index = Widget

    function Widget.new(className, props)
        local self = setmetatable({}, Widget)

        self.Maid = Maid.new()
        self.Instance = RenderEngine:Create(className, props)
        self._visible = true

        Library.Theme:Register(self)

        return self
    end

    function Widget:SetVisible(visible)
        self._visible = visible
        if self.Instance and self.Instance:IsA("GuiObject") then
            self.Instance.Visible = visible
        end
    end

    -- Sobrescrito pelos componentes concretos para reagir a troca de tema
    function Widget:ApplyTheme(_theme)
        -- no-op por padrão
    end

    function Widget:Destroy()
        Library.Theme:Unregister(self)
        self.Maid:Destroy()
        if self.Instance then
            RenderEngine:Destroy(self.Instance)
            self.Instance = nil
        end
    end

    return Widget
end
