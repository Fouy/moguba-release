local _M = {}

local mt = { __index = _M }

function _M:new(total, page, rows)
    local temp = {}
    setmetatable(temp, mt)
    temp.total = total
    temp.page = page
    temp.rows = rows
    return temp
end

return _M