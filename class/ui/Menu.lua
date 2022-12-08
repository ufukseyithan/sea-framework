local Menu = class()

function Menu:constructor(name, mode)
    self.name = name
    self.mode = mode
    self.buttons = {}
end

function Menu:addButton(name, func, description)
    table.insert(self.buttons, {
        name = name,
        func = func,
        description = description
    })
end

function Menu:addGap()
    table.insert(self.buttons, false)
end

function Menu:show(player, page)
    page = page or 1

    self.totalPage = math.ceil(table.count(self.buttons) / 9)

    local buttons = {}
    for i = 1, 9 do
        local button = self.buttons[((page - 1) * 9) + i]

        local name, description = "", ""

        if button then
            local disabled = button.func == nil

            if button.name then
                name = type(button.name) == "function" and button.name(player) or button.name
            end

            if button.description then
                description = type(button.description) == "function" and button.description(player) or button.description
            end

            if disabled then
                name, description = "("..name, description..")"
            end
        end

        table.insert(buttons, name.."|"..description)
    end

    local mode = ""
    if self.mode == "big" then
        mode = "@b"
    elseif self.mode == "invisible" then
        mode = "@i"
    end

    local pageLabel = ""
    if self.totalPage > 1 then
        pageLabel = " ("..page.." of "..self.totalPage..")"
    end

    menu(player.id, self.name..pageLabel..mode..","..table.concat(buttons, ","))
end

function Menu:interact(player, index)
    if index == 0 then
        player.currentMenu = {}
        return
    end

    local button = self.buttons[((player.currentMenu[2] - 1) * 9) + index]
    
    if button then
        if type(button.func) == "table" then
            player:displayMenu(button.func)
        else
            local result = button.func(player)

            if result == true then
                player:displayMenu(player.currentMenu[1])
            elseif type(result) == "table" then
                player:displayMenu(result)
            end
        end
    end
end

-------------------------
--        CONST        --
-------------------------

function Menu.construct(structure, parent, player) 
    local menu = Menu.new(structure.name, "big")

    for _, button in ipairs(type(structure.content) == "function" and structure.content(player) or structure.content) do
        local func = button.func
        local description = button.description
        
        if button.structure then
            func = function(player)
                if button.func then
                    button.func(player)
                end
                
                if button.structure then
                    return Menu.construct(button.structure, menu, player)
                end
            end

            if description == nil then
                description = ">"
            end
        end

        menu:addButton(button.name, func, description)
    end

    if parent then
        menu.name = parent.name.." / "..menu.name

        menu:addButton("Back", function(player)
            player:displayMenu(parent) 
        end, "<")
    end

    return menu
end

-------------------------
--        INIT         --
-------------------------

return Menu