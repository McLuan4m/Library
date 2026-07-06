--[[
    Theme/ThemeManager.lua

    Responsável por:
    - Manter o tema ativo
    - Registrar widgets que precisam ser retemados dinamicamente
    - Notificar (via Signal) quando o tema muda, permitindo que os
      componentes atualizem suas propriedades sem acoplamento direto.
]]

return function(Library)
    local Signal = Library.Utility.Signal
    local DefaultTheme = require and nil -- placeholder (não usado em runtime remoto)

    local ThemeManager = {}
    ThemeManager.__index = ThemeManager

    local instance = setmetatable({}, ThemeManager)
    instance.Current = Library._modulesRaw.DefaultTheme
    instance.Changed = Signal.new()
    instance._registered = {} -- lista de widgets inscritos

    function instance:Get()
        return self.Current
    end

    function instance:SetTheme(themeTable)
        assert(type(themeTable) == "table", "SetTheme espera uma tabela de tema")
        self.Current = themeTable
        self.Changed:Fire(themeTable)

        -- aplica imediatamente em todos os widgets registrados
        for _, widget in ipairs(self._registered) do
            if widget.ApplyTheme then
                widget:ApplyTheme(themeTable)
            end
        end
    end

    -- Todo Widget que quiser reagir a troca de tema deve se registrar aqui
    function instance:Register(widget)
        table.insert(self._registered, widget)
        if widget.ApplyTheme then
            widget:ApplyTheme(self.Current)
        end
    end

    function instance:Unregister(widget)
        for i, w in ipairs(self._registered) do
            if w == widget then
                table.remove(self._registered, i)
                break
            end
        end
    end

    return instance
end
