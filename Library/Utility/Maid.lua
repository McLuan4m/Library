--[[
    Utility/Maid.lua

    Gerencia o ciclo de vida de recursos (Instances, Connections,
    Signals, funções de limpeza) para evitar vazamento de memória
    quando um Componente/Widget é destruído.

    Uso:
        local maid = Maid.new()
        maid:Add(someInstance)
        maid:Add(someConnection)
        maid:Add(function() print("limpou") end)
        maid:Destroy()
]]

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(task_)
    table.insert(self._tasks, task_)
    return task_
end

local function cleanupTask(task_)
    local t = typeof(task_)
    if t == "function" then
        task_()
    elseif t == "RBXScriptConnection" then
        task_:Disconnect()
    elseif t == "Instance" then
        task_:Destroy()
    elseif t == "table" and task_.Disconnect then
        task_:Disconnect()
    elseif t == "table" and task_.Destroy then
        task_:Destroy()
    end
end

function Maid:Destroy()
    for i = #self._tasks, 1, -1 do
        local ok, err = pcall(cleanupTask, self._tasks[i])
        if not ok then
            warn("[Maid] Erro ao limpar tarefa: " .. tostring(err))
        end
        self._tasks[i] = nil
    end
end

return Maid
