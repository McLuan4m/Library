--[[
    Components/App.lua

    Componente raiz que monta o layout completo em três áreas:

        +------------------------------------------+
        |                Topbar                    |
        +---------+--------------------------------+
        | Sidebar |          Content               |
        |  (nav)  |     (página ativa aqui)        |
        +---------+--------------------------------+

    API (encadeada):
        local app = Library:CreateApp({ Name = "Minha UI", Logo = "rbxassetid://..." })
        local page = app:AddPage({ Title = "Aim", Icon = "rbxassetid://..." })
        local sec  = page:AddSection({ Title = "Aimbot" })
        sec:AddToggle({ Text = "Ativar", ... })
        app:Build()   -- finaliza: popula a sidebar e ativa a 1ª página
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local EventManager = Library.Core.EventManager
    local Services = Library.Services

    local App = setmetatable({}, { __index = Widget })
    App.__index = App

    function App.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local L = theme.Layout

        local playerGui = Services.GetPlayerGui()

        local screenGui = RenderEngine:Create("ScreenGui", {
            Name = "LibraryApp",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
            Parent = playerGui,
        })

        -- janela raiz
        local self = Widget.new("Frame", {
            Name = "AppWindow",
            Size = config.Size or UDim2.fromOffset(720, 460),
            Position = config.Position or UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.AppColors.ContentBackground,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = screenGui,
        })
        setmetatable(self, App)

        self._screenGui = screenGui
        self.Maid:Add(screenGui)
        self._pages = {}

        if theme.Shadow.Enabled then
            RenderEngine:ApplyShadow(self.Instance)
        end
        RenderEngine:ApplyCorner(self.Instance, theme.CornerRadius)
        RenderEngine:ApplyStroke(self.Instance, theme.Colors.WindowBorder)

        -- ===== TOPBAR =====
        self.Topbar = Library.Components.Topbar.new({
            Parent = self.Instance,
            Name = config.Name,
            Logo = config.Logo,
        })
        EventManager:MakeDraggable(self.Topbar.Instance, self.Instance, self.Maid)
        self.Maid:Add(self.Topbar.CloseButton.MouseButton1Click:Connect(function()
            self:Destroy()
        end))

        -- ===== CORPO (sidebar + content) =====
        self.Body = RenderEngine:Create("Frame", {
            Name = "Body",
            Size = UDim2.new(1, 0, 1, -L.TopbarHeight),
            Position = UDim2.fromOffset(0, L.TopbarHeight),
            BackgroundTransparency = 1,
            Parent = self.Instance,
        })

        -- ===== SIDEBAR =====
        self.Sidebar = Library.Components.Sidebar.new({ Parent = self.Body })

        -- ===== CONTENT =====
        self.Content = RenderEngine:Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -L.SidebarWidth, 1, 0),
            Position = UDim2.fromOffset(L.SidebarWidth, 0),
            BackgroundColor3 = theme.AppColors.ContentBackground,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = self.Body,
        })

        -- animação de entrada
        local finalSize = config.Size or UDim2.fromOffset(720, 460)
        self.Instance.Size = UDim2.fromOffset(finalSize.X.Offset * 0.97, finalSize.Y.Offset * 0.97)
        RenderEngine:Animate(self.Instance, { Size = finalSize })

        return self
    end

    -- Cria uma página, cujo conteúdo vive dentro de self.Content
    function App:AddPage(config)
        config = config or {}
        config.Parent = self.Content
        local page = Library.Components.Page.new(config)
        table.insert(self._pages, page)
        return page
    end

    -- Finaliza a montagem: popula a sidebar e ativa a primeira página
    function App:Build()
        for _, page in ipairs(self._pages) do
            self.Sidebar:AddPage(page)
        end
        self.Sidebar:SelectFirst()
        return self
    end

    function App:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.AppColors.ContentBackground })
        RenderEngine:Update(self.Content, { BackgroundColor3 = theme.AppColors.ContentBackground })
    end

    return App
end
