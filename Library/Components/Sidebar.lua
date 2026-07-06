--[[
    Components/Sidebar.lua

    Barra lateral de navegação. Para cada Page cria um item (ícone + texto);
    ao clicar, ativa a página e expande/colapsa a lista de seções abaixo
    (estilo árvore). Clicar numa seção rola o conteúdo até ela.

    Efeitos: hover suave, barra de acento animada no item ativo,
    seta que rotaciona ao expandir, expand/collapse animado.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local Signal = Library.Utility.Signal

    local Sidebar = setmetatable({}, { __index = Widget })
    Sidebar.__index = Sidebar

    function Sidebar.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local L = theme.Layout

        local self = Widget.new("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, L.SidebarWidth, 1, 0),
            BackgroundColor3 = theme.AppColors.SidebarBackground,
            BorderSizePixel = 0,
            Parent = config.Parent,
        })
        setmetatable(self, Sidebar)

        self.PageSelected = Signal.new()
        self._entries = {}     -- { page = ..., button = ..., subContainer = ..., arrow = ..., accent = ..., expanded = bool }
        self._activePage = nil

        -- divisor vertical à direita
        RenderEngine:Create("Frame", {
            Name = "RightBorder",
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = theme.Colors.Divider,
            BorderSizePixel = 0,
            Parent = self.Instance,
        })

        -- scroll caso haja muitas páginas
        self.List = RenderEngine:Create("ScrollingFrame", {
            Name = "NavList",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = self.Instance,
        })
        RenderEngine:ApplyPadding(self.List, { Top = theme.Spacing.SM, Bottom = theme.Spacing.SM,
            Left = theme.Spacing.SM, Right = theme.Spacing.SM })
        RenderEngine:Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.List,
        })

        return self
    end

    -- Cria o item de navegação de uma página e seus sub-itens (seções)
    function Sidebar:AddPage(page)
        local theme = Library.Theme:Get()
        local L = theme.Layout

        -- wrapper que segura o item + o sub-container das seções
        local wrapper = RenderEngine:Create("Frame", {
            Name = "NavEntry",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = self.List,
        })
        RenderEngine:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = wrapper,
        })

        -- botão principal (página)
        local button = RenderEngine:Create("TextButton", {
            Name = "PageItem",
            Size = UDim2.new(1, 0, 0, L.SidebarItemHeight),
            BackgroundColor3 = theme.AppColors.NavItemActive,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = 0,
            Parent = wrapper,
        })
        RenderEngine:ApplyCorner(button, theme.ElementCornerRadius)

        -- barra de acento (esquerda) que aparece quando ativo
        local accent = RenderEngine:Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = theme.AppColors.NavActiveBar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = button,
        })
        RenderEngine:ApplyCorner(accent, UDim.new(1, 0))

        -- ícone
        local iconLabel
        local hasIcon = page.Icon ~= nil
        if hasIcon then
            iconLabel = RenderEngine:Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, theme.Spacing.MD, 0.5, -8),
                BackgroundTransparency = 1,
                Image = page.Icon,
                ImageColor3 = theme.Colors.TextMuted,
                Parent = button,
            })
        end

        local textX = hasIcon and (theme.Spacing.MD + 16 + theme.Spacing.SM) or theme.Spacing.MD

        local label = RenderEngine:Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -textX - 24, 1, 0),
            Position = UDim2.fromOffset(textX, 0),
            BackgroundTransparency = 1,
            Text = page.Title,
            Font = theme.FontMedium,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button,
        })

        -- seta de expandir (só se a página tiver seções)
        local arrow
        if #page.Sections > 0 then
            arrow = RenderEngine:Create("TextLabel", {
                Name = "Arrow",
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(1, -20, 0.5, -8),
                BackgroundTransparency = 1,
                Text = "▸",
                Font = theme.Font,
                TextSize = 10,
                TextColor3 = theme.Colors.TextDim,
                Parent = button,
            })
        end

        -- sub-container das seções (colapsável)
        local subContainer = RenderEngine:Create("Frame", {
            Name = "Sections",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
            LayoutOrder = 1,
            Parent = wrapper,
        })
        RenderEngine:Create("UIListLayout", {
            Padding = UDim.new(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = subContainer,
        })
        RenderEngine:ApplyPadding(subContainer, { Top = 2, Bottom = theme.Spacing.XS })

        -- sub-itens (seções)
        for _, section in ipairs(page.Sections) do
            local subBtn = RenderEngine:Create("TextButton", {
                Name = "SectionItem",
                Size = UDim2.new(1, 0, 0, L.SidebarSubItemHeight),
                BackgroundColor3 = theme.AppColors.NavItemHover,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                Parent = subContainer,
            })
            RenderEngine:ApplyCorner(subBtn, theme.ElementCornerRadius)

            -- "guia" de árvore (linha vertical + traço)
            RenderEngine:Create("Frame", {
                Name = "TreeGuide",
                Size = UDim2.new(0, 1, 1, -8),
                Position = UDim2.new(0, L.SidebarIndent - 6, 0, 4),
                BackgroundColor3 = theme.Colors.Divider,
                BorderSizePixel = 0,
                Parent = subBtn,
            })

            RenderEngine:Create("TextLabel", {
                Size = UDim2.new(1, -L.SidebarIndent - 6, 1, 0),
                Position = UDim2.fromOffset(L.SidebarIndent, 0),
                BackgroundTransparency = 1,
                Text = section.Title,
                Font = theme.Font,
                TextSize = 12,
                TextColor3 = theme.Colors.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = subBtn,
            })

            self.Maid:Add(subBtn.MouseEnter:Connect(function()
                RenderEngine:Animate(subBtn, { BackgroundTransparency = 0,
                    BackgroundColor3 = Library.Theme:Get().AppColors.NavItemHover },
                    TweenInfo.new(theme.AnimationSpeedFast))
            end))
            self.Maid:Add(subBtn.MouseLeave:Connect(function()
                RenderEngine:Animate(subBtn, { BackgroundTransparency = 1 },
                    TweenInfo.new(theme.AnimationSpeedFast))
            end))
            self.Maid:Add(subBtn.MouseButton1Click:Connect(function()
                -- ativa a página e rola até a seção
                self:_activate(page)
                task.wait()
                local content = page.Instance
                local sectionPos = section.Instance.AbsolutePosition.Y - content.AbsolutePosition.Y
                content.CanvasPosition = Vector2.new(0, math.max(0, content.CanvasPosition.Y + sectionPos - 8))
            end))
        end

        local entry = {
            page = page, button = button, subContainer = subContainer,
            arrow = arrow, accent = accent, label = label, icon = iconLabel,
            expanded = false, wrapper = wrapper,
        }
        table.insert(self._entries, entry)

        -- hover no item da página
        self.Maid:Add(button.MouseEnter:Connect(function()
            if self._activePage ~= page then
                RenderEngine:Animate(button, { BackgroundTransparency = 0,
                    BackgroundColor3 = Library.Theme:Get().AppColors.NavItemHover },
                    TweenInfo.new(theme.AnimationSpeedFast))
                RenderEngine:Animate(label, { TextColor3 = Library.Theme:Get().Colors.Text })
            end
        end))
        self.Maid:Add(button.MouseLeave:Connect(function()
            if self._activePage ~= page then
                RenderEngine:Animate(button, { BackgroundTransparency = 1 })
                RenderEngine:Animate(label, { TextColor3 = Library.Theme:Get().Colors.TextMuted })
            end
        end))
        self.Maid:Add(button.MouseButton1Click:Connect(function()
            self:_activate(page)
            self:_toggleExpand(entry)
        end))

        return entry
    end

    function Sidebar:_toggleExpand(entry)
        if not entry.arrow then return end
        entry.expanded = not entry.expanded
        local theme = Library.Theme:Get()

        RenderEngine:Animate(entry.arrow, { Rotation = entry.expanded and 90 or 0 })

        if entry.expanded then
            entry.subContainer.Visible = true
            -- pequeno stagger nos sub-itens ao expandir
            for i, child in ipairs(entry.subContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    local scale = child:FindFirstChildOfClass("UIScale")
                    if not scale then
                        scale = RenderEngine:Create("UIScale", { Scale = 1, Parent = child })
                    end
                    scale.Scale = 0.9
                    task.delay((i - 1) * 0.03, function()
                        if scale and scale.Parent then
                            RenderEngine:Animate(scale, { Scale = 1 },
                                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
                        end
                    end)
                end
            end
        else
            entry.subContainer.Visible = false
        end
    end

    function Sidebar:_activate(page)
        local theme = Library.Theme:Get()
        if self._activePage == page then return end
        self._activePage = page

        for _, entry in ipairs(self._entries) do
            local isActive = entry.page == page
            entry.page:SetActive(isActive)

            RenderEngine:Animate(entry.button, {
                BackgroundTransparency = isActive and 0 or 1,
                BackgroundColor3 = theme.AppColors.NavItemActive,
            })
            RenderEngine:Animate(entry.label, {
                TextColor3 = isActive and theme.Colors.Text or theme.Colors.TextMuted,
            })
            -- barra de acento: aparece e "cresce" verticalmente quando ativa
            RenderEngine:Animate(entry.accent, {
                BackgroundTransparency = isActive and 0 or 1,
                Size = isActive and UDim2.new(0, 3, 0.6, 0) or UDim2.new(0, 3, 0, 0),
                Position = isActive and UDim2.new(0, 0, 0.2, 0) or UDim2.new(0, 0, 0.5, 0),
            }, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
            -- ícone acende na cor de acento quando ativo
            if entry.icon then
                RenderEngine:Animate(entry.icon, {
                    ImageColor3 = isActive and theme.Colors.Accent or theme.Colors.TextMuted,
                })
            end
        end

        self.PageSelected:Fire(page)
    end

    -- Ativa a primeira página (chamado pelo App após montar tudo)
    function Sidebar:SelectFirst()
        if self._entries[1] then
            self:_activate(self._entries[1].page)
            self:_toggleExpand(self._entries[1])
        end
    end

    function Sidebar:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.AppColors.SidebarBackground })
    end

    return Sidebar
end
