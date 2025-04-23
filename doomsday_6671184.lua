
local clipboard = require("neverlose/clipboard")

local HSP = "\u{200A}"


local function pad(text, count)
    return text .. string.rep(HSP, count)
end


local animations do
    animations = {}
    local anim = color()
    local min_v, max_v, period = 0.4, 1, 3


    local function utf8_chars(str)
        local chars = {}
        for uchar in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
            chars[#chars + 1] = uchar
        end
        return chars
    end

    function animations.wave(text, col)
        local h, s = col:to_hsv()
        local chars = utf8_chars(text)
        local len   = #chars
        local parts = {}
        local t     = globals.curtime
        local base_phase = (t / period) * 2 * math.pi

        for i = 1, len do
            local phase = base_phase + (i - 1) / len * math.pi
            local f     = (math.sin(phase) + 1) * 0.5
            local v = min_v + (max_v - min_v) * f
            anim:as_hsv(h, s, v, 1.0)
            parts[i] = "\a" .. anim:to_hex() .. chars[i]
        end

        return table.concat(parts)
    end

    
end


local sidebar do
    local name     = "doomsday" 
    local iconChar = ui.get_icon("gem")

    local function on_render()
        if ui.get_alpha() <= 0 then
            return
        end

        local style = ui.get_style()
        local waved = animations.wave(
            name,
            style["Link Active"]
        )

        ui.sidebar(waved, iconChar)
    end

    events.render:set(on_render)
end

local watermark do
    local name = "DOOMSDAY IS OUT"
    local iconChar = ui.get_icon("gem")

    local function on_render()
        local screen = render.screen_size()
        local x = screen.x / 2
        local y = screen.y - 20

        local style = ui.get_style()
        local base_color = style["Link Active"]

        local waved = animations.wave(name, base_color)
        render.text(1, vector(x, y), color(255, 255, 255, 255), "c", waved)
    end

    events.render:set(on_render)
end


local icons do
    icons = {}

    local lookup = {} -- Hair Space

    function icons.get(name, left, right, color)
        local icon = lookup[name]
        if icon == nil then
            icon = ui.get_icon(name)
            lookup[name] = icon
        end
    
        left = left or 0
        right = right or 0
    
        -- Определяем префикс цвета
        local prefix = ""
        if color then
            -- Если пользователь уже указал \a, не добавляем повторно
            if color:sub(1, 2) == "\a{" or color:sub(1, 2) == "\aF" or color:sub(1, 2) == "\aC" then
                prefix = color
            else
                prefix = "\a" .. color
            end
        end
    
        return prefix .. string.rep(HSP, left) .. icon .. string.rep(HSP, right) .. "\aDEFAULT"
    end
end


local tabs = {
    main = icons.get("house-blank", 0, 0, "{Link Active}"),
    angles = icons.get("shield", 0,0,"{Link Active}"),
    misc = icons.get("tag", 0, 0, "{Link Active}")
}

    

local sounds do
    local play = cvar.playvol
    sounds = {
        error = "ui/panorama/lobby_error_01.wav",
        success = "ui/menu_accept.wav",
        press = "ui/panorama/submenu_dropdown_select_01.wav",
        scroll = "ui/panorama/submenu_scroll_01.wav"
    }

    function sounds.play(path)
        play:call(path, 1)
    end
end





local prints do
    prints = {}
    local color_error = "\aCE4848FF"
    local color_success = "\aA0CE48FF"

    function prints.error(msg)
        print(color_error .. msg)
        print_dev(color_error .. msg)
        sounds.play(sounds.error)
    end

    function prints.success(msg)
        print(color_success .. msg)
        print_dev(color_success .. msg)
        sounds.play(sounds.success)
    end
end


local nl do
    nl = { }

    nl.rage = {
        main = {
            dormant_aimbot = ui.find('Aimbot', 'Ragebot', 'Main', 'Enabled', 'Dormant Aimbot'),

            hide_shots = ui.find('Aimbot', 'Ragebot', 'Main', 'Hide Shots'),
            hide_shots_options = ui.find('Aimbot', 'Ragebot', 'Main', 'Hide Shots', 'Options'),

            double_tap = ui.find('Aimbot', 'Ragebot', 'Main', 'Double Tap'),
            double_tap_lag_options = ui.find('Aimbot', 'Ragebot', 'Main', 'Double Tap', 'Lag Options'),

            peek_assist = {
                ui.find('Aimbot', 'Ragebot', 'Main', 'Peek Assist'),
                { ui.find('Aimbot', 'Ragebot', 'Main', 'Peek Assist', 'Style') },
                ui.find('Aimbot', 'Ragebot', 'Main', 'Peek Assist', 'Auto Stop'),
                ui.find('Aimbot', 'Ragebot', 'Main', 'Peek Assist', 'Retreat Mode')
            }
        },

        selection = {
            hit_chance = ui.find('Aimbot', 'Ragebot', 'Selection', 'Hit Chance'),
            minimum_damage = ui.find('Aimbot', 'Ragebot', 'Selection', 'Min. Damage')
        },

        safety = {
            body_aim = ui.find('Aimbot', 'Ragebot', 'Safety', 'Body Aim')
        }
    }

    nl.aa = {
        angles = {
            enabled = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Enabled'),
            pitch = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Pitch'),

            yaw = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw'),
            yaw_base = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw', 'Base'),
            yaw_add = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw', 'Offset'),
            avoid_backstab = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw', 'Avoid Backstab'),
            hidden = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw', 'Hidden'),

            yaw_modifier = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw Modifier'),
            modifier_offset = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Yaw Modifier', 'Offset'),

            body_yaw = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw'),
            inverter = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw', 'Inverter'),
            left_limit = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw', 'Left Limit'),
            right_limit = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw', 'Right Limit'),
            options = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw', 'Options'),
            body_yaw_freestanding_desync = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Body Yaw', 'Freestanding'),

            freestanding = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Freestanding'),
            disable_yaw_modifiers = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Freestanding', 'Disable Yaw Modifiers'),
            body_freestanding = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Freestanding', 'Body Freestanding'),

            extended_angles = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Extended Angles'),
            extended_pitch = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Extended Angles', 'Extended Pitch'),
            extended_roll = ui.find('Aimbot', 'Anti Aim', 'Angles', 'Extended Angles', 'Extended Roll')
        },

        fake_lag = {
            enabled = ui.find('Aimbot', 'Anti Aim', 'Fake Lag', 'Enabled'),
            limit = ui.find('Aimbot', 'Anti Aim', 'Fake Lag', 'Limit')
        },

        misc = {
            fake_duck = ui.find('Aimbot', 'Anti Aim', 'Misc', 'Fake Duck'),
            slow_walk = ui.find('Aimbot', 'Anti Aim', 'Misc', 'Slow Walk'),
            leg_movement = ui.find('Aimbot', 'Anti Aim', 'Misc', 'Leg Movement')
        }
    }

    nl.visuals = {
        world = {
            other = {
                world_marker = ui.find('Visuals', 'World', 'Other', 'Hit Marker', '3D Marker'),
                damage_marker = ui.find('Visuals', 'World', 'Other', 'Hit Marker', 'Damage Marker'),

                grenade_prediction = {
                    color = ui.find('Visuals', 'World', 'Other', 'Grenade Prediction', 'Color'),
                    color_hit = { ui.find('Visuals', 'World', 'Other', 'Grenade Prediction', 'Color Hit') }
                }
            }
        }
    }

    nl.misc = {
        main = {
            movement = {
                air_strafe = ui.find('Miscellaneous', 'Main', 'Movement', 'Air Strafe'),
                strafe_assist = ui.find('Miscellaneous', 'Main', 'Movement', 'Strafe Assist'),
                air_duck = ui.find("Miscellaneous", "Main", "Movement", "Air Duck"),
                quick_stop = ui.find("Miscellaneous", "Main", "Movement", "Quick Stop"),
            },

            in_game = {
                clan_tag = ui.find('Miscellaneous', 'Main', 'In-Game', 'Clan Tag')
            },

            other = {
                windows = ui.find('Miscellaneous', 'Main', 'Other', 'Windows'),
                log_events = ui.find('Miscellaneous', 'Main', 'Other', 'Log Events'),
                weapon_actions = ui.find('Miscellaneous', 'Main', 'Other', 'Weapon Actions')
            }
        }
    }
end



local localplayer do
    localplayer = { }

    local pre_flags = 0
    local post_flags = 0

    localplayer.is_onground = false

    localplayer.is_moving = false
    localplayer.is_crouched = false

    localplayer.is_peeking = false
    localplayer.is_vulnerable = false

    localplayer.velocity2d = 0
    localplayer.duck_amount = 0

    localplayer.eye_position = vector()

    localplayer.velocity = vector()
    localplayer.move_dir = vector()

    localplayer.team_num = 0
    localplayer.sent_packets = 0


    local function on_createmove(cmd)
        local me = entity.get_local_player()

        if me == nil then
            return
        end

        local velocity = me.m_vecVelocity



        pre_flags = me.m_fFlags

        localplayer.velocity = velocity:clone()
        localplayer.velocity2d = velocity:length2d()

        if cmd.choked_commands == 0 then
            localplayer.duck_amount = me.m_flDuckAmount
            localplayer.eye_position = me:get_eye_position()

            localplayer.sent_packets = localplayer.sent_packets + 1
        end

        localplayer.is_moving = localplayer.velocity2d > 1.1 * 3.3
        localplayer.is_crouched = localplayer.duck_amount > 0

        localplayer.team_num = me.m_iTeamNum

        localplayer.move_dir = vector(
            cmd.forwardmove, cmd.sidemove, 0
        )
    end

    local function on_createmove_run(e)
        local me = entity.get_local_player()

        if me == nil then
            return
        end

        post_flags = me.m_fFlags

        localplayer.is_onground = bit.band(pre_flags, 1) == 1
            and bit.band(post_flags, 1) == 1
    end

    events.createmove(on_createmove)
    events.createmove_run(on_createmove_run)
end




local config do
    config = { _items = {} }


    local function get_color_value(item)
        local result = {}
        local modes = item:list()
        if #modes == 0 then
            local col = item:get()
            result["default"] = {{ r = col.r, g = col.g, b = col.b, a = col.a }}
        else
            for _, mode in ipairs(modes) do
                local ok, colors = pcall(item.get, item, mode)
                if ok then
                    result[mode] = {}
                    for i, c in ipairs(colors) do
                        result[mode][i] = { r = c.r, g = c.g, b = c.b, a = c.a }
                    end
                end
            end
        end
        return result
    end

    local function set_color_value(item, value)
        if type(value) ~= "table" then return end
        for mode, list in pairs(value) do
            local conv = {}
            for i, col in ipairs(list) do
                conv[i] = color(col.r, col.g, col.b, col.a)
            end
            item:set(mode, conv)
        end
    end

    local handlers = {
        color_picker = {
            get = get_color_value,
            set = set_color_value
        },
        default = {
            get = function(item) return item:get() end,
            set = function(item, val) item:set(val) end
        }
    }

    local function serialize()
        local data = {}
        for _, i in ipairs(config._items) do
            data[i.id] = i.get()
        end
        return data
    end

    local function contains(list, name)
        for _, v in ipairs(list) do
            if v == name then return true end
        end
        return false
    end

    local function ensure_list()
        local raw = db.config_list or {}
        local result = {}
        for _, name in ipairs(raw) do
            if type(db[name]) == "table" then
                table.insert(result, name)
            end
        end
        return result
    end

    local function ensure_meta()
        local meta = db.config_meta
        if type(meta) ~= "table" then
            meta = {}
            db.config_meta = meta
        end
        return meta
    end

    local function save_meta(name)
        local meta = ensure_meta()
        meta[name] = {
            created_ts = common.get_unixtime()
        }
        db.config_meta = meta
    end

    local function set_current_config(name)
        config_name:set(name)
        for i, v in ipairs(config_list:list()) do
            if v == name then
                config_list:set(i)
                break
            end
        end
    end

    function config.push(item)
        local last = item:get()
        local t = item:type()
        local strat = handlers[t] or handlers.default
        local snd = (t == "slider") and sounds.scroll or sounds.press

        item:set_callback(function()
            local cur = item:get()
            if cur ~= last then
                last = cur
                sounds.play(snd)
            end
        end)

        table.insert(config._items, {
            id = tostring(item:id()),
            get = function() return strat.get(item) end,
            set = function(val) strat.set(item, val) end
        })

        return item
    end

    function config.save(name)
        name = tostring(name or "")
        if name == "" then
            return prints.error("Config name cannot be empty!")
        end


        db[name] = serialize()
        save_meta(name)

        local list = ensure_list()
        if not contains(list, name) then
            table.insert(list, name)
        end
        db.config_list = list

        config.update()
        set_current_config(name)
        prints.success("Saved: " .. name)
    end

    function config.load(name)
        if not name or not db[name] then
            return prints.error("Config not found: " .. tostring(name))
        end
        config.apply(db[name])
        prints.success("Loaded config: " .. name)
    end

    function config.remove(name)

        if not db[name] then
            return prints.error("Config not found: " .. name)
        end

        db[name] = nil
        local meta = ensure_meta()
        meta[name] = nil
        db.config_meta = meta

        local list, fallback = ensure_list(), nil
        for i, v in ipairs(list) do
            if v == name then
                table.remove(list, i)
                fallback = list[i - 1] or list[1]
                break
            end
        end
        db.config_list = list

        config.update()
        set_current_config(fallback or (list[1] or ""))
        prints.success("Removed config: " .. name)
    end

    function config.update()
        local list = ensure_list()
        db.config_list = list
    end

    function config.apply(data)
        if type(data) ~= "table" then return end
        for _, i in ipairs(config._items) do
            local v = data[i.id]
            if v then i.set(v) end
        end
    end

    function config.export()
        clipboard.set(json.stringify(serialize()))
        prints.success("Copied config to clipboard")
    end

    function config.import()
        local raw = clipboard.get()
        local clean = raw:gsub("^%s+", ""):gsub("^\239\187\191", "")
        local ok, data = pcall(json.parse, clean)
        if not ok or type(data) ~= "table" then
            return prints.error("Invalid or empty clipboard data")
        end
        config.apply(data)
        prints.success("Config loaded from clipboard")
    end

    function config.import_from_git(name)
        if not name or db[name] == nil then
            return prints.error("Create or select a config first!")
        end
        local url = "https://raw.githubusercontent.com/h3xcolor/aesthetic/refs/heads/main/config.txt"
        network.get(url, nil, function(res)
            if type(res) ~= "string" then
                return prints.error("Failed to import from GitHub")
            end
            local clean = res:gsub("^\239\187\191", "")
            local ok, data = pcall(json.parse, clean)
            if not ok or type(data) ~= "table" then
                return prints.error("Invalid format in GitHub config")
            end
            config.apply(data)
            prints.success("Imported from Git: " .. name)
        end)
    end
end



local config_ui do
    local tab = ui.create(tabs.main, "preset", 1)
    config_list = tab:list("", {})
    config_name = tab:input("", "")
    local meta_group = ui.create(tabs.main, "", 1)
    local date_label = meta_group:label("")
    local pending_action = nil
    local all_buttons = {}
    local confirm_btn, cancel_btn, remove_btn
    local last_click = 0

    local function config_exists(name)
        for _, v in ipairs(config_list:list()) do
            if v == name then return true end
        end
        return false
    end

    local function format_elapsed(sec)
        if sec < 60 then
            return sec .. " Seconds"
        elseif sec < 3600 then
            return math.floor(sec / 60) .. " Minutes"
        elseif sec < 86400 then
            return math.floor(sec / 3600) .. " Hours"
        else
            return math.floor(sec / 86400) .. " Days"
        end
    end

    local function update_meta(name)
        local meta = db.config_meta and db.config_meta[name]
        if meta then
            local elapsed = common.get_unixtime() - meta.created_ts
            date_label:name(icons.get("clock", 0, 6, "{Link Active}") .. format_elapsed(elapsed) .. " ago")
            meta_group:visibility(true)
        else
            meta_group:visibility(false)
        end
    end

    local function refresh_list()
        local list = db.config_list or {}
        if #list == 0 then
            config_list:update({ icons.get("eye-slash", 0, 4, "{Link Active}") .. "I don't see any presets(" })
            config_list:set(1)
            config_list:disabled(true)
            config_name:set("")
            update_meta("")
            remove_btn:disabled(true)
            confirm_btn:disabled(true)
            cancel_btn:disabled(true)
        else
            config_list:update(list)
            local current = config_name:get()
            local found = false
            for i, v in ipairs(list) do
                if v == current then
                    config_list:set(i)
                    found = true
                    break
                end
            end
            if not found then
                config_list:set(1)
                config_name:set(list[1])
            end
            config_list:disabled(false)
            remove_btn:disabled(false)
            confirm_btn:disabled(false)
            cancel_btn:disabled(false)
            update_meta(config_name:get())
        end
    end

    local function start_action(action)
        pending_action = action
        for _, b in ipairs(all_buttons) do b:disabled(true) end
        confirm_btn:visibility(true)
        cancel_btn:visibility(true)
    end

    local function cancel_action()
        pending_action = nil
        for _, b in ipairs(all_buttons) do b:disabled(false) end
        confirm_btn:visibility(false)
        cancel_btn:visibility(false)
        refresh_list()
    end

    config_list:set_callback(function()
        if config_list:disabled() then return end
        local idx = config_list:get()
        local name = config_list:list()[idx]
        if not name then return end
        config_name:set(name)
        sounds.play(sounds.press)
        local now = globals.realtime
        if now - last_click < 0.3 then
            config.load(name)
            refresh_list()
        end
        last_click = now
    end)
    

    local save_btn = tab:button(icons.get("floppy-disk",2,3,"{Link Active}").."Save ",function()
        local name = config_name:get()
        if name == "" then return prints.error("Config name cannot be empty!") end
        if config_exists(name) then
            start_action("save")
        else
            config.save(name)
            refresh_list()
        end
    end,true):tooltip("Saves or creates a preset")

    local export_btn = tab:button(icons.get("copy",2,2,"{Link Active}"),config.export,true):tooltip("Copies the settings to the clipboard")

    local import_btn = tab:button(icons.get("download",2,2,"{Link Active}"),config.import,true):tooltip("Load settings from the clipboard")

    local import_git_btn = tab:button(icons.get("github",2,2,"{Link Active}"),function()
        local name = config_name:get()

        if name == "" then 
            return prints.error("Enter config name first") 
        end
        if not config_exists(name) then 
            return prints.error("Create or select a config first!") 
        end

        config.import_from_git(name)

    end,true):tooltip("Loads default values from github")


    remove_btn = tab:button(icons.get("trash-xmark",2,3,"FF6B6BFF").."Remove ",function()
        local name = config_name:get()

        if not config_exists(name) then 
            return prints.error("Config not found: "..name) 
        end

        start_action("remove")

    end,true):tooltip("Deletes the selected config")

    cancel_btn = tab:button(icons.get("xmark", 13, 5, "FF6B6BFF") .. "Cancel" .. pad(HSP, 13) ,cancel_action,true)


    confirm_btn = tab:button(icons.get("check", 13, 5, "{Link Active}") .. "Confirm" .. pad(HSP, 13),function()
        local name = config_name:get()
        if pending_action == "save" then
            config.save(name)
            refresh_list()
            cancel_action()
        elseif pending_action == "remove" then
            config.remove(name)
            cancel_action()
            refresh_list()
        end
    end,true)

    confirm_btn:visibility(false)
    cancel_btn:visibility(false)

    all_buttons = { save_btn, export_btn, import_btn, import_git_btn, remove_btn }

    refresh_list()

    local last_update = 0

    events.render:set(function()
        local now = globals.realtime
        if now - last_update >= 1 then
            update_meta(config_name:get())
            last_update = now
        end
    end)
    
end



local sub_ui do
    local sub = { }

    sub.tab = ui.create(tabs.main, "Sub", 2)

    sub.switch = config.push(sub.tab:switch("This is Switch"))
end


local condition = {
    STANDING       = "Stand",
    MOVING         = "Move",
    SLOW_WALK      = "Slow",
    CROUCH_STAND   = "Crouch",
    CROUCH_MOVE    = "Crouch Move",
    IN_AIR         = "Air",
    AIR_CROUCH     = "Air Crouch",
}


    builder = {}
    builder.selection_tab = ui.create(tabs.angles, "Selection", 1)
    builder.selection = config.push(builder.selection_tab:list("", "Builder", "Hotkeys", "Features"))
    
    local angles_frontend do

    builder.conditions = {
        condition.STANDING,
        condition.MOVING,
        condition.SLOW_WALK,
        condition.CROUCH_STAND,
        condition.CROUCH_MOVE,
        condition.IN_AIR,
        condition.AIR_CROUCH,
    }


    builder.main = ui.create(tabs.angles, "Builder", 2)

    builder.condition_selector = config.push(builder.main:combo("", builder.conditions))


    local function update_visibility_yaw(ctx)
        local m = ctx.yaw:get()
        ctx.yaw_off:visibility(m == "Offset")
        local show = (m == "Side Based")
        ctx.yaw_l:visibility(show)
        ctx.yaw_r:visibility(show)
        --ctx.yaw_rand:visibility(show)
    end

    local function update_visibility_side(ctx)
        local m = ctx.side:get()
        ctx.side_inv:visibility(m == "Static")
        local j = (m == "Jitter")
        ctx.side_ch:visibility(j)
        ctx.side_mode:visibility(j)
        ctx.side_s:visibility(j and ctx.side_mode:get() == "Static")
        local r = (ctx.side_mode:get() == "Randomize")
        ctx.side_min:visibility(j and r)
        ctx.side_max:visibility(j and r)
    end

    local function update_visibility_body(ctx)
        local mode = ctx.by_mode:get()
        ctx.by_mode:visibility(true)
        ctx.by_stat:visibility(mode == "Static")
        ctx.by_sw1:visibility(mode == "Sway")
        ctx.by_sw2:visibility(mode == "Sway")
        ctx.by_r1:visibility(mode == "Randomize")
        ctx.by_r2:visibility(mode == "Randomize")
    end

    local function generate_angles(tab, ctx)
        ctx.yaw = config.push(tab:combo("Yaw", "Offset", "Side Based"))
        local yaw = ctx.yaw:create("Yaw Settings")
        ctx.yaw_off  = config.push(yaw:slider("Offset##yaw_off", -180, 180, 0, 1))
        ctx.yaw_l    = config.push(yaw:slider("Left##yaw_side",  -180, 180, 0, 1))
        ctx.yaw_r    = config.push(yaw:slider("Right##yaw_side", -180, 180, 0, 1))
        ctx.yaw_rand = config.push(yaw:slider("Rand##yaw_side",     0, 100, 0, 1))
        ctx.yaw:set_callback(function() update_visibility_yaw(ctx) end)
        update_visibility_yaw(ctx)

        ctx.side = config.push(tab:combo("Side", "Static", "Jitter"))
        local side = ctx.side:create("Side Settings")
        ctx.side_inv  = config.push(side:switch("Inv##side_static"))
        ctx.side_ch   = config.push(side:slider("##side_jitter", 0, 100, 100, 1, "%"))
        ctx.side_mode = config.push(side:combo("Delay##side_jitter", "Static", "Randomize"))
        ctx.side_s    = config.push(side:slider("Val##side_delay_static",  1, 16, 1, 1))
        ctx.side_min  = config.push(side:slider("Min##side_delay_random",  1, 16, 1, 1))
        ctx.side_max  = config.push(side:slider("Max##side_delay_random",  1, 16, 1, 1))
        ctx.side:set_callback(function() update_visibility_side(ctx) end)
        ctx.side_mode:set_callback(function() update_visibility_side(ctx) end)
        update_visibility_side(ctx)

        ctx.mod = config.push(tab:combo("Modify", {"Disabled", "Center", "3-Way", "Random"}))
        local mod = ctx.mod:create("Mod Settings")
        ctx.mod_val = config.push(mod:slider("Val##mod_val", -180, 180, 0, 1))
    end

    local function generate_body(tab, ctx)
        ctx.by = config.push(tab:switch("Body Yaw"))
        ctx.by_mode = config.push(tab:combo("Limit##limit_mode", {"Static", "Sway", "Randomize"}))
        ctx.by_fs = config.push(tab:combo("Freestand", {"Off", "Peek Real", "Peek Fake"}))
        local bod = ctx.by_mode:create("Body Yaw Settings")
        ctx.by_stat = config.push(bod:slider("Val##limit_static",  0, 60, 60, 1))
        ctx.by_sw1  = config.push(bod:slider("From##limit_sway",   0, 60, 60, 1))
        ctx.by_sw2  = config.push(bod:slider("To##limit_sway",     0, 60, 60, 1))
        ctx.by_r1   = config.push(bod:slider("Min##limit_random",  0, 60, 60, 1))
        ctx.by_r2   = config.push(bod:slider("Max##limit_random",  0, 60, 60, 1))

        ctx.by_mode:set_callback(function() update_visibility_body(ctx) end)
        update_visibility_body(ctx)
    end

    local function generate_lc(tab, ctx)
        ctx.exploit = config.push(tab:selectable("Exploit", "Double Tap", "Hide Shots"))
    end

    builder.groups = {}

    local function build_for_condition(cond, ctx)
        local id = "##" .. cond
        local a = ui.create(tabs.angles, id .. "_angles", 2)
        local b = ui.create(tabs.angles, id .. "_body",   2)
        local l = ui.create(tabs.angles, id .. "_lc",     1)
        builder.groups[cond] = {a, b, l}
        generate_angles(a, ctx)
        generate_body(b, ctx)
        generate_lc(l, ctx)
    end

    local function create_condition_settings()
        local result = {}
        for _, cond in ipairs(builder.conditions) do
            result[cond] = {}
            build_for_condition(cond, result[cond])
        end
        return result
    end

    builder.groups_data = create_condition_settings()

    local function update_visibility_for_condition()
        local sel = builder.condition_selector:get()
        if builder.selection:get(1) ~= 1 then return end
        for cond, tabs in pairs(builder.groups) do
            local vis = (cond == sel)
            tabs[1]:visibility(vis)
            tabs[2]:visibility(vis)
            tabs[3]:visibility(vis)
        end
    end

    local function update_visibility_for_builder()
        local show = builder.selection:get(1) == 1
        builder.main:visibility(show)
        builder.condition_selector:visibility(show)

        for _, tabs in pairs(builder.groups) do
            tabs[1]:visibility(show)
            tabs[2]:visibility(show)
            tabs[3]:visibility(show)
        end

        if show then update_visibility_for_condition() end
    end

    builder.condition_selector:set_callback(update_visibility_for_condition, true)
    builder.selection:set_callback(update_visibility_for_builder, true)
end


local angles_hotkeys do
    hotkeys = { }

    hotkeys.main = ui.create(tabs.angles, " ##Main", 2)

    hotkeys.freestanding = config.push(hotkeys.main:switch("Freestanding"))
    hotkeys.manuals = config.push(hotkeys.main:slider("Rotation", -180, 180, 0, 1))


    local function update_visibility_for_hotkeys()
        local show = builder.selection:get(2) == 2

        hotkeys.main:visibility(show)
    end

    builder.selection:set_callback(update_visibility_for_hotkeys, true)

end

local angles_backend do

    local current_delay = 0
    local tick_counter = 0
    local chance_tick_counter = 0
    local need_reset = false

    local function compute_state()
        if localplayer.is_onground then
            if nl.aa.misc.slow_walk:get() then
                return condition.SLOW_WALK
            end
            if not localplayer.is_moving then
                return localplayer.is_crouched and condition.CROUCH_STAND or condition.STANDING
            end
            return localplayer.is_crouched and condition.CROUCH_MOVE or condition.MOVING
        end
        return localplayer.is_crouched and condition.AIR_CROUCH or condition.IN_AIR
    end

    local function get_current_settings()
        local state = compute_state()
        local ctx = builder.groups_data[state]
        if not ctx then return {} end

        return {
            yaw = {
                mode   = ctx.yaw:get(),
                offset = ctx.yaw_off:get(),
                left   = ctx.yaw_l:get(),
                right  = ctx.yaw_r:get(),
                random = ctx.yaw_rand:get()
            },
            side = {
                mode    = ctx.side:get(),
                invert  = ctx.side_inv:get(),
                chance  = ctx.side_ch:get(),
                delay   = ctx.side_mode:get(),
                static  = ctx.side_s:get(),
                minimum = ctx.side_min:get(),
                maximum = ctx.side_max:get()
            },
            body = {
                enabled    = ctx.by:get(),
                mode       = ctx.by_mode:get(),
                static_val = ctx.by_stat:get(),
                sway_from  = ctx.by_sw1:get(),
                sway_to    = ctx.by_sw2:get(),
                rand_min   = ctx.by_r1:get(),
                rand_max   = ctx.by_r2:get(),
                fs         = ctx.by_fs:get()
            },
            mod = {
                mode  = ctx.mod:get(),
                value = ctx.mod_val:get()
            },
            exploit = ctx.exploit:get()
        }
    end

    local function should_switch_side(tick_interval)
        chance_tick_counter = chance_tick_counter + 1

        if chance_tick_counter >= tick_interval then
            chance_tick_counter = 0
            local settings = get_current_settings()
            return utils.random_int(0, 100) <= settings.side.chance
        end

        return false
    end

    local function calculate_delay()
        local settings = get_current_settings()
        local mode = settings.side.delay

        if mode == "Static" then
            return settings.side.static
        elseif mode == "Randomize" then
            tick_counter = tick_counter + 1
            if tick_counter >= current_delay then
                current_delay = utils.random_int(settings.side.minimum, settings.side.maximum)
                tick_counter = 0
            end
            return current_delay
        end

        return 0
    end

    local function get_inverter()
        local settings = get_current_settings()
        local mode = settings.side.mode

        if mode == "Jitter" then
            local delay = calculate_delay()
            if globals.choked_commands == 0 and should_switch_side(delay) then
                local packet = localplayer.sent_packets % (delay * 2)
                return packet < delay
            end
            return rage.antiaim:inverter()
        else
            return settings.side.invert
        end
    end

    local function apply_modifier(base, side, value, mode, left, right)
        if mode == "Disabled" then return base end

        if mode == "Center" then
            local offset = value * 0.5
            return side and (left - offset) or (right + offset)
        end

        if mode == "3-Way" then
            local pattern = { -1.0, 0.0, 1.0 }
            local index = sent_packets % #pattern
            return base + pattern[index + 1] * value
        end

        if mode == "Random" then
            return base + utils.random_int(-value, value)
        end

        return base + (side and value or -value)
    end

    local function lerp(a, b, t)
        return a + t * (b - a)
    end

    local function update_yaw(e)
        local settings = get_current_settings()

        local ctx = {
            mode     = settings.yaw.mode,
            offset   = settings.yaw.offset,
            left     = settings.yaw.left,
            right    = settings.yaw.right,
            random   = settings.yaw.random,
            delay    = calculate_delay(),
            side     = get_inverter(),
            inverter = false,
            options  = {},
            mod_mode = settings.mod.mode,
            mod_val  = settings.mod.value,
        }

        ctx.random_offset = utils.random_int(0, ctx.random)
        rage.antiaim:inverter(ctx.side)
        ctx.inverter = ctx.side

        if ctx.mode == "Offset" then
            ctx.left = ctx.offset
            ctx.right = ctx.offset
        end

        local base = ctx.side and ctx.left - ctx.random_offset or ctx.right + ctx.random_offset
        local final_yaw = apply_modifier(base, ctx.side, ctx.mod_val, ctx.mod_mode, ctx.left, ctx.right)

        nl.aa.angles.yaw_modifier:override("Disabled")
        nl.aa.angles.yaw_add:override(final_yaw)
        nl.aa.angles.inverter:override(ctx.inverter)
        nl.aa.angles.options:override(ctx.options)
    end

    local function override_exploit(e)
        local settings = get_current_settings()

        if need_reset then
            nl.rage.main.double_tap_lag_options:override()
            nl.rage.main.hide_shots_options:override()
        end

        local ctx = {
            dt = "",
            hs = ""
        }

        if settings.exploit[1] == "Double Tap" then
            ctx.dt = "Always On"
            need_reset = true
        end

        if settings.exploit[2] == "Hide Shots" then
            ctx.hs = "Break LC"
            need_reset = true
        end

        local me = entity.get_local_player()
        local weapon = me:get_player_weapon()

        if not me then return end
        if not weapon then return end

        if weapon.m_bPinPulled then
            ctx.dt = "Disabled"
            ctx.hs = "Favor Fire Rate"
            need_reset = true
        end

        nl.rage.main.double_tap_lag_options:override(ctx.dt)
        nl.rage.main.hide_shots_options:override(ctx.hs)
    end

    local function calculate_body_yaw()
        local settings = get_current_settings()
        local mode = settings.body.mode

        if mode == "Static" then
            return settings.body.static_val
        elseif mode == "Sway" then
            return lerp(settings.body.sway_from, settings.body.sway_to, globals.curtime * 0.5 % 1)
        elseif mode == "Randomize" then
            return utils.random_int(settings.body.rand_min, settings.body.rand_max)
        end

        return 0
    end

    local function override_body_yaw(e)
        local settings = get_current_settings()
        local value = calculate_body_yaw()

        nl.aa.angles.body_yaw:override(settings.body.enabled)
        nl.aa.angles.body_yaw_freestanding_desync:override(settings.body.fs)
        nl.aa.angles.left_limit:override(value)
        nl.aa.angles.right_limit:override(value)
    end

    local function on_createmove(e)
        update_yaw(e)
        override_exploit(e)
        override_body_yaw(e)
    end

    events.createmove(on_createmove)
end

local misc_frontend do
    misc = { }

    misc.tab = ui.create(tabs.misc, "Pook")

    misc.test = config.push(misc.tab:slider("", 0, 100, 50,1))

    local group = misc.test:create()


end
