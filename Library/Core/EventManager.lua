--[[
    Core/EventManager.lua

    Utilitários de input reutilizáveis por vários componentes
    (ex: arrastar janelas, arrastar sliders). Mantém a lógica de
    input centralizada e desacoplada dos componentes visuais.
]]

return function(Library)
    local Services = Library.Services
    local UserInputService = Services.UserInputService

    local EventManager = {}

    -- Torna `dragHandle` capaz de arrastar `target` (ex: barra de título arrasta a janela)
    function EventManager:MakeDraggable(dragHandle, target, maid)
        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end

        maid:Add(dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = target.Position

                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        conn:Disconnect()
                    end
                end)
            end
        end))

        maid:Add(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end))
    end

    return EventManager
end
