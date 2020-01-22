-- String
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string:upperFirst()
    return (self:gsub('^%l', string.upper))
end

function string:trim()
    return (self:gsub("^%s*(.-)%s*$", "%1"))
end

function string:toPascalCase(delimiter)
    local tab = {}
    self:gsub( '([^'.. delimiter..']+)', function(c)
        table.insert(tab, c:upperFirst())
    end)
    return table.concat(tab)
end

-- @TODO: Check if this is working correctly
function string.camelCaseToUnderscore(str)
    local tab = {}
    str:gsub('%u?%l+', function (c)
        table.insert(tab, c:lower())
    end)
    return table.concat(tab, '_')
end

-- @TODO: Check if this is working correctly
function string.underscoreToPascalCase(str)
    local tab = {}
    str:gsub('([^_]+)', function (c)
        table.insert(tab, c:upperFirst())
    end)
    return table.concat(tab)
end
 
-- Math
function math.round(num,base)
	if base == nil then
		return math.floor(num+0.5)
	else
        if base > 0 then
            base = math.pow(10,base)
        end
		return math.floor((num*base)+0.5)/base
	end
end

function math.lerp(a, b, t)
	return a + (b - a) * t
end

function math.average(...)
    local sum = 0
    local i = 0
    while (i < #arg) do
        i = i + 1
        sum = sum + arg[i]
    end
    return sum/#arg
end

-- Table
function table.contains(tab, value)
    for _, v in pairs(tab) do
        if (v == value) then
            return true
        end
    end

    return false
end

function table.removeDuplicates(tbl)
	local hash = {}
	local res = {}

	for _, v in ipairs(tbl) do
	   if (not hash[v]) then
	       res[#res+1] = v -- you could print here instead of saving to result table if you wanted
	       hash[v] = true
	   end
	end

	return res
end

function table.merge(tbl, tbl2, override)
    for k, v in pairs(tbl2) do 
        if override then
            tbl[k] = v
        else
            tbl[k] = tbl[k] or v
        end
    end
end

function table.isEmpty(tab)
    return next(tab) == nil
end

-- IO
function io.exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
end

function io.toTable(file, tbl)
    if not tbl then
        return
    end
    
    local file = io.open(file, "r");
    
    for line in file:lines() do
        table.insert(tbl, line);
    end
end

-- Misc
function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end