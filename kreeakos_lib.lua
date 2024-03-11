util.require_natives("3095a")

-- if you would like me to add something to this, feel free to reach out to my on discord.

int32_max = 2147483647
neg_int32_max = -2147483648

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Ped Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Ped Functions

ped = {}

---For getting the vehicle a ped is in.
---@param ped integer --- Give a ped handle.
---@param include_last_vehicle boolean --- If you want to include the last vehicle the ped was in.
---@return integer --- Returns a vehicle handle or -1 if one could not be found.
function ped.get_vehicle(ped, include_last_vehicle)
    if include_last_vehicle or PED.IS_PED_IN_ANY_VEHICLE(ped) then
        return PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    return -1
end

--#endregion Ped Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Ped Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Command Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Command Functions

command = {}

---For getting if a fed command is a string or a reference.
---@param cmd string | userdata -- Feed a path or reference.
---@return string -- Returns a string of the command type, "path", "ref", or "invalid" if it was fed neither.
function command.get_type(cmd)
    if type(cmd) == "string" then
        return "path"
    elseif type(cmd) == "userdata" then
        return "ref"
    else
        return "invalid"
    end
end

---For checking if a command is valid.
---@param cmd string | userdata -- Feed a path or reference.
---@return boolean -- Returns a boolean indicating if the command is valid.
function command.check_valid(cmd)
    local cmd_type = command.get_type(cmd)
    if cmd_type == "path" then
        if menu.is_ref_valid(menu.ref_by_path(cmd)) then
            return true
        end
    elseif cmd_type == "ref" then
        if menu.is_ref_valid(cmd) then
            return true
        end
    elseif cmd_type == "invalid" then
        util.log("Not a valid command path or ref!")
        return false
    end
    return false
end

---For getting a command ref from another reference or a path.
---@param cmd string | userdata -- Feed a path or reference.
---@return any -- Returns a command reference from a path or another reference.
function command.get_ref(cmd)
    local cmd_type = command.get_type(cmd)
    if command.check_valid(cmd) then
        if cmd_type == "path" then
            return menu.ref_by_path(cmd)
        else
            return cmd
        end
    end
end

---Triggers a command from a reference or a path.
---@param cmd string | userdata -- Feed a path or reference.
---@param ... any -- Feed optional argument to meny.trigger_command.
function command.trigger(cmd, ...)
    local command = command.get_ref(cmd)
    menu.trigger_command(command, ...)
end

--#endregion Command Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Command Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Utility Functions

utils = {}

---Modify the first letter of a string to make it uppercase.
---@param str string -- The string you want to modify.
---@return string -- Returns new string with first letter uppercase.
function utils.first_to_upper(str)
    return (str:gsub("^%l", string.upper))
end

---To format a number with commas, example: 1000000 gets changed to 1,000,000
---@param number integer -- The number you wish to format.
---@return string -- Returns your number as a string formatted with commas.
function utils.format_integer(number) -- stackoverflow to the rescue https://stackoverflow.com/a/10992898
    local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

---To convert an int32 to a hexidecimal.
---https://stackoverflow.com/a/37797380
---@param number integer -- The int32 you would like to convert.
---@return string -- Returns converted hexidecimal as a string.
function utils.int32_to_hex(number)
    return string.format("%x", tostring(number * 255))
end

---For coverting various things into a boolean.
---@param to_convert any -- The data you would like to convert to a boolean.
---@return boolean | nil -- Returns your data converted to a boolean, or nil if it could not be converted (i.e. if you gave it anything other than a boolean/number/string).
function utils.toboolean(to_convert)
    local data_type = type(to_convert)

    if data_type == "boolean" then
        return to_convert
    elseif data_type == "number" then
        if to_convert ~= 0 then
            return true
        end
    elseif data_type == "string" then
        to_convert = to_convert:lower()
        if to_convert == "true" then
            return true
        end

        if to_convert == "false" then
            return false
        end
    elseif (data_type == "nil") or data_type == ("table" or data_type == "function") or (data_type == "thread") or (data_type == "userdata") then
        error("toboolean could not convert " .. data_type .. " :?", 2)
        return nil
    end
    return false
end

---Used for setting bits.
---@param int integer --The integer to modify.
---@param ... any --The bits to modify.
---@return integer --Returns new int with modified bits.
function utils.set_bits(int, ...)
    local bits = {...}
    for ind, bit in ipairs(bits) do
        int = int | (1 << bit)
    end
    return int
end

function utils.bit_test(operand1, operand2)
    return operand1 & 1 << operand2 ~= 0
end

function utils.is_bit_set(var, bit)
    return (var >> bit) and 1
end

---For retrieving filename.
---@return string --Returns filename.
function utils.get_filename() --Shameless paste from stackoverflow https://stackoverflow.com/a/48469960/22447005
    local str = debug.getinfo(2, "S").source
    return str:match("^.*/(.*).lua$") or str
end

---For creating a notification in the chat locally.
---@param text any
function utils.notify(text)
    util.BEGIN_TEXT_COMMAND_THEFEED_POST(text)
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
end

--#endregion Utility Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Entity Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Entity Functions

ent = {}

---Teleports given entity to given postion.
---@param entity integer --- Feed entity handle you wish to teleport.
---@param position table | userdata --- The coordinates, in table or vector3 format you wish to teleport entity to.
function ent.teleport(entity, position)
    ENTITY.SET_ENTITY_COORDS(entity, position[1] or position.x, position[2] or position.y, position[3] or position.z, true, false, false, false)
end

---For loading the model of a given model name or hash.
---@param model string | integer --The model you wish to load, as a string or a hash.
---@return boolean --If the model was succefully retrieved, returns true.
---@return integer | nil --Returns the hash of the given model or nil if was not a valid model.
function ent.request_model(model)
    if type(model) == "number" then
        hash = model
    elseif type(model) == "string" then
        hash = util.joaat(model)
    end

    if STREAMING.IS_MODEL_VALID(hash) then
        util.request_model(hash, 2000)
        return true, hash
    end

    util.log("request_model received invalid model: " .. model)
    return false, nil
end

---For spawning a ped.
---@param ped_type integer
---@param model string | integer
---@param position userdata | table
---@param heading integer
---@return integer | nil
function ent.new_ped(ped_type, model, position, heading)
    local model_valid, hash = ent.request_model(model)
    if model_valid then
        local ped = entities.create_ped(ped_type, hash, position, heading)

        if ped == 0 then
            util.log("ent.new_ped had an oopsie, ped was not created :?")
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        entities.set_can_migrate(ped, false)
        return ped
    else
        util.log("ent.new_ped received invalid model: " .. model)
        return nil
    end
end

--#endregion Entity Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Entity Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Self Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Self Functions

self = {}

---Teleports you, the local player or your vehicle to the given position.
---@param position table | userdata
function self.teleport(position)
    local tp_entity = client.player_ped
    if client.player_vehicle ~= -1 then
        tp_entity = client.player_vehicle
    end
    ent.teleport(tp_entity, position)
end

--#endregion Entity Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Entity Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Transaction Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Transaction Functions

transaction = {}

---Transfers all wallet cash to bank.
function transaction.deposit_wallet()
    if not online.in_session() then return end
    local wallet_balance = MONEY.NETWORK_GET_VC_WALLET_BALANCE(client.char_slot)
    while wallet_balance ~= 0 do
        if not transaction.is_active() then
            if NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK_GET_STATUS() ~= 1 then
                NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(client.char_slot, wallet_balance)
                wallet_balance = MONEY.NETWORK_GET_VC_WALLET_BALANCE(client.char_slot)
            end
        end
        util.yield()
    end
end

---To check if a transaction is active, to avoid transaction errors.
---@return boolean -- If transaction is active.
function transaction.is_active()
    return NETSHOPPING.NET_GAMESERVER_TRANSACTION_IN_PROGRESS()
end

---Get a price from a transaction hash.
---@param hash integer -- The hash to check.
---@param category integer -- The category to check.
---@return number? -- The returned price.
function transaction.get_price(hash, category)
    return tonumber(NETSHOPPING.NET_GAMESERVER_GET_PRICE(hash, category, true))
end

--#endregion Transaction Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Transaction Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Online Functions

online = {}

---For checking if in a session.
---@return boolean -- If in session.
function online.in_session()
    if util.is_session_started() and not util.is_session_transition_active() then
        return true
    end
    return false
end

local char_slot_ptr = memory.alloc(4)
---For getting your character slot.
---@return number? -- Character slot
function online.get_char_slot()
    local _ = STATS.STAT_GET_INT(util.joaat("MPPLY_LAST_MP_CHAR"), char_slot_ptr, 1)
    return memory.read_int(char_slot_ptr);
end

---For getting a gamer handle from a player ID.
---@param player_id integer -- The player ID for the player you want to get the gamer handle to.
---@return boolean | userdata | nil -- The status of the handle, the handle itself, or nil if it couldn't be gotten.
function online.get_gamer_handle(player_id) -- Sapphire gave this to me, thankies
    local handle = memory.alloc(13 * 8) -- 13 scrValues
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(player_id, handle, 13)
    return NETWORK.NETWORK_IS_HANDLE_VALID(handle, 13) and handle or nil
end

--#endregion Online Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DirectX Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region DirectX Functions

dx = {}

---Draws text with a drop shadow and optional background.
---@param text string -- Text to draw.
---@param x number -- Pixel screen position x.
---@param y number -- Pixel screen position y.
---@param padding number -- Pixel padding for the box around the text.
---@param scale number -- 1-100 text size.
---@param add_drop_shadow boolean -- Specify if you want your text to have a drop shaddow.
function dx.draw_text(text, x, y, padding, alignment, scale, add_drop_shadow, ...) -- Has optional argument, for setting background color and text color using tables.
    local text_width, text_height = directx.get_text_size(text, scale / 10)
    if ... == nil then
        background_color = { r = 0, g = 0, b = 0, a = 0 }
        text_color = { r = 1, g = 1, b = 1, a = 1 }
    else
        background_color, text_color = ...
    end

    directx.draw_rect(x / client.screen_width - (padding / client.screen_width), y / client.screen_height - (padding / client.screen_height), text_width + (((padding * 2) + 8) / client.screen_width), text_height + ((padding * 2) / client.screen_height), background_color)

    if add_drop_shadow then
        directx.draw_text((x / client.screen_width) + (1 / client.screen_width), (y / client.screen_height) + (1 / client.screen_height), text, alignment, scale / 10, { r = 0, g = 0, b = 0, a = 1 }, false)
    end

    directx.draw_text(x / client.screen_width, y / client.screen_height, text, alignment, scale / 10, text_color, false)
end

--#endregion DirectX Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DirectX Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stat Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Stat Functions

stat = {}

---Gets an integer from a stat.
---@param stat_name string -- The stat name.
---@return integer -- Returns integer from stat.
function stat.read_int(stat_name)
    local ptr = memory.alloc(4)
	STATS.STAT_GET_INT(util.joaat(stat_name), ptr, -1)
	return memory.read_int(ptr)
end

---Sets a boolean stat.
---@param stat_name string -- The stat name.
---@param status boolean -- The value you want to set the stat to.
function stat.write_bool(stat_name, status)
	STATS.STAT_SET_BOOL(util.joaat(stat_name), status, true)
end

---Gets a boolean stat.
---@param stat_name string -- The stat name.
function stat.read_bool(stat_name)
    local ptr = memory.alloc(4)
	STATS.STAT_GET_BOOL(util.joaat(stat_name), ptr, -1)
    return memory.read_int(ptr)
end

---Gets a packed boolean stat.
---@param packed_stat_bool integer -- The stat to read.
---@param character_slot integer -- The character slot to read the stat from.
---@return boolean -- The stat value.
function stat.read_packed_bool(packed_stat_bool, character_slot)
    return STATS.GET_PACKED_STAT_BOOL_CODE(packed_stat_bool, character_slot)
end

---Sets a packed boolean stat.
---@param packed_stat_bool integer -- The stat to write to.
---@param bool boolean -- The value to set the stat to.
---@param character_slot integer -- The character slot to write the stat to.
function stat.write_packed_bool(packed_stat_bool, bool, character_slot)
    STATS.SET_PACKED_STAT_BOOL_CODE(packed_stat_bool, bool, character_slot)
end

---Sets a packed stat integer.
---@param packed_stat_int integer -- The stat to set.
---@param value integer -- The value to set the stat to.
---@param character_slot integer -- The character slot to change the stat on.
function stat.write_packed_int(packed_stat_int, value, character_slot)
    STATS.SET_PACKED_STAT_INT_CODE(packed_stat_int, value, character_slot)
end

---Gets a packed stat integer.
---@param packed_stat_int integer -- The stat to read.
---@param character_slot integer -- The character slot to read the stat from.
---@return integer -- The value of the stat.
function stat.read_packed_int(packed_stat_int, character_slot)
    return STATS.GET_PACKED_STAT_INT_CODE(packed_stat_int, character_slot)
end

--#endregion Stat Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stat Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Global Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Update Global Variables

client = {}

util.create_tick_handler(function()
    client.screen_width, client.screen_height = directx.get_client_size()
    client.player_ped = players.user_ped()
    client.player = players.user()
    client.session_host = players.get_host()
    client.player_position = ENTITY.GET_ENTITY_COORDS(client.player_ped, false)
    client.player_vehicle = ped.get_vehicle(client.player_ped, false)
    client.player_vehicle_position = ENTITY.GET_ENTITY_COORDS(ped.get_vehicle(client.player_ped, true), false)
    client.char_slot = online.get_char_slot()
end)

--#endregion Update Global Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Global Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------