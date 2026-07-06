--[[
    Components/Window.lua

    Janela principal da interface. Contém título arrastável e um
    container de conteúdo onde outros componentes (botões, sliders,
    toggles etc.) são adicionados via métodos AddXxx.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local EventManager = Library.Core.EventManager
    local Services = Library.Services

    local Window = setmetatable({}, { __index = Widget })
    Window.__index = Window

    function Window.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        local playerGui = Services.GetPlayerGui()

        -- ScreenGui raiz (uma por janela, simples e suficiente aqui)
        local screenGui = RenderEngine:Create("ScreenGui", {
            Name = "LibraryWindow_" .. (config.Title or "Window"),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = playerGui,
        })

        local self = Widget.new("Frame", {
            Name = "Window",
            Size = config.Size or UDim2.fromOffset(480, 320),
            Position = config.Position or UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Colors.WindowBackground,
            BorderSizePixel = 0,
            Parent = screenGui,
        })
        setmetatable(self, Window)

        self._screenGui = screenGui
        self.Maid:Add(screenGui)

        RenderEngine:ApplyCorner(self.Instance)
        RenderEngine:ApplyStroke(self.Instance, theme.Colors.WindowBorder)

        -- Barra de título
        self.TitleBar = RenderEngine:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = theme.Colors.TitleBarBackground,
            BorderSizePixel = 0,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.TitleBar)

        self.TitleLabel = RenderEngine:Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Text = config.Title or "Window",
            Font = theme.FontBold,
            TextSize = theme.TitleTextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.TitleBar,
        })

        -- Container de conteúdo (onde ficam os componentes filhos)
        self.Content = RenderEngine:Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -16, 1, -46),
            Position = UDim2.fromOffset(8, 42),
            BackgroundTransparency = 1,
            Parent = self.Instance,
        })

        self.Layout = RenderEngine:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Content,
        })

        -- Torna a janela arrastável pela barra de título
        EventManager:MakeDraggable(self.TitleBar, self.Instance, self.Maid)

        return self
    end

    function Window:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.Colors.WindowBackground })
        RenderEngine:Update(self.TitleBar, { BackgroundColor3 = theme.Colors.TitleBarBackground })
        RenderEngine:Update(self.TitleLabel, {
            TextColor3 = theme.Colors.Text,
            Font = theme.FontBold,
        })
    end

    -- Métodos de conveniência para criar componentes já parentados a esta janela
    function Window:AddButton(config)
        config = config or {}
        config.Parent = self.Content
        return Library.Components.Button.new(config)
    end

    function Window:AddToggle(config)
        config = config or {}
        config.Parent = self.Content
        return Library.Components.Toggle.new(config)
    end

    function Window:AddSlider(config)
        config = config or {}
        config.Parent = self.Content
        return Library.Components.Slider.new(config)
    end

    function Window:AddDropdown(config)
        config = config or {}
        config.Parent = self.Content
        return Library.Components.Dropdown.new(config)
    end

    function Window:AddLabel(config)
        config = config or {}
        config.Parent = self.Content
        return Library.Components.Label.new(config)
    end

    return Window
end
