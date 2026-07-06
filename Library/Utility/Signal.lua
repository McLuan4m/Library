--[[
    Utility/Signal.lua

    Implementação leve de um sistema de eventos (Signal),
    usado internamente pela Library para comunicação
    desacoplada entre Componentes, Core e Theme.

    Uso:
        local signal = Signal.new()
        local conn = signal:Connect(function(a, b) print(a, b) end)
        signal:Fire(1, 2)
        conn:Disconnect()
]]

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
    local self = setmetatable({}, Connection)
    self._signal = signal
    self._fn = fn
    self.Connected = true
    return self
end

function Connection:Disconnect()
    if not self.Connected then return end
    self.Connected = false
    local list = self._signal._listeners
    for i = #list, 1, -1 do
        if list[i] == self then
            table.remove(list, i)
            break
        end
    end
end

function Signal.new()
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return self
end

function Signal:Connect(fn)
    assert(type(fn) == "function", "Signal:Connect espera uma função")
    local conn = Connection.new(self, fn)
    table.insert(self._listeners, conn)
    return conn
end

function Signal:Fire(...)
    -- copia para permitir Disconnect durante a iteração
    local listeners = table.clone(self._listeners)
    for _, conn in ipairs(listeners) do
        if conn.Connected then
            task.spawn(conn._fn, ...)
        end
    end
end

function Signal:DisconnectAll()
    self._listeners = {}
end

return Signal
