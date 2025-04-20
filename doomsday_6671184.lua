-- Конфиг-система в стиле Neverlose (оптимизированная)
-- Повышена читаемость, переиспользуемость и расширяемость логики

local clipboard = require("neverlose/clipboard")

local HSP = "\u{200A}"


local function pad(text, count)
    return text .. string.rep(HSP, count)
end

--- animations.lua
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

    nl.antiaim = {
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

    local function extrapolate(origin, velocity, ticks)
        return origin + velocity * (ticks * globals.tickinterval)
    end

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


local angles_frontend do
    local settings = {}
    settings.states = {
        condition.STANDING,
        condition.MOVING,
        condition.SLOW_WALK,
        condition.CROUCH_STAND,
        condition.CROUCH_MOVE,
        condition.IN_AIR,
        condition.AIR_CROUCH
    }

    local tabs_angles = tabs.angles
    local state_selector = config.push(ui.create(tabs_angles, " ##state_selector", 2):combo("State", unpack(settings.states)))
    local builder_tab = ui.create(tabs_angles, "angle_builder", 2)
    local mode_selector = config.push(ui.create(tabs_angles, " ##Mode selector", 1):list("##Mode", "Builder", "Hotkeys", "Features"))

    local state_groups = {}

    local function update_yaw_visibility(ctx)
        local mode = ctx.yaw_mode:get()
        ctx.yaw_offset:visibility(mode == "Offset")
        local side_based = (mode == "Side Based")
        ctx.yaw_left:visibility(side_based)
        ctx.yaw_right:visibility(side_based)
        ctx.yaw_random:visibility(side_based)
    end

    local function update_side_visibility(ctx)
        local mode = ctx.side_mode:get()
        ctx.side_invert:visibility(mode == "Static")
        local jitter = (mode == "Jitter")
        ctx.side_chance:visibility(jitter)
        ctx.side_delay_type:visibility(jitter)
        local delay_type = ctx.side_delay_type:get()
        ctx.side_delay_static:visibility(jitter and delay_type == "Static")
        local randomizing = (delay_type == "Random")
        ctx.side_delay_min:visibility(jitter and randomizing)
        ctx.side_delay_max:visibility(jitter and randomizing)
    end

    local function update_body_visibility(ctx)
        local mode = ctx.body_limit_mode:get()
        local body_yaw = ctx.body_yaw_enabled:get() == false
        ctx.body_limit_mode:disabled(body_yaw)
        ctx.body_static_limit:visibility(mode == "Static")
        ctx.body_sway_from:visibility(mode == "Sway")
        ctx.body_sway_to:visibility(mode == "Sway")
        local randomizing = (mode == "Random")
        ctx.body_random_min:visibility(randomizing)
        ctx.body_random_max:visibility(randomizing)
    end

    local function build_angle_controls(tab, ctx)
        ctx.yaw_mode = config.push(tab:combo("Yaw", "Offset", "Side Based"))
        local yaw_tab = ctx.yaw_mode:create("YawSettings")
        ctx.yaw_offset = config.push(yaw_tab:slider("Offset##yaw", -180, 180, 0, 1))
        ctx.yaw_left   = config.push(yaw_tab:slider("Left##yaw",   -180, 180, 0, 1))
        ctx.yaw_right  = config.push(yaw_tab:slider("Right##yaw",  -180, 180, 0, 1))
        ctx.yaw_random = config.push(yaw_tab:slider("Random##yaw",   0,   100, 0, 1))
        ctx.yaw_mode:set_callback(function() update_yaw_visibility(ctx) end)
        update_yaw_visibility(ctx)

        ctx.side_mode       = config.push(tab:combo("Side", "Static", "Jitter"))
        local side_tab      = ctx.side_mode:create("SideSettings")
        ctx.side_invert     = config.push(side_tab:switch("Invert##side"))
        ctx.side_chance     = config.push(side_tab:slider("##side", 0, 100, 100, 1, "%"))
        ctx.side_delay_type = config.push(side_tab:combo("Delay Type##side", "Static", "Random"))
        ctx.side_delay_static= config.push(side_tab:slider("Value##side", 1, 16, 1, 1))
        ctx.side_delay_min   = config.push(side_tab:slider("Min ##side", 1, 16, 1, 1))
        ctx.side_delay_max   = config.push(side_tab:slider("Max ##side", 1, 16, 1, 1))
        ctx.side_mode:set_callback(function() update_side_visibility(ctx) end)
        ctx.side_delay_type:set_callback(function() update_side_visibility(ctx) end)
        update_side_visibility(ctx)

        ctx.mod_mode  = config.push(tab:combo("Modifier", {
            "Disabled", "LeftAdd", "RightAdd", "Center", "ThreeWay", "Random"
        }))
        local mod_tab = ctx.mod_mode:create("ModifierSettings")
        ctx.mod_value = config.push(mod_tab:slider("Value##mod", -180, 180, 0, 1))
    end

    local function build_body_controls(tab, ctx)
        ctx.body_yaw_enabled = config.push(tab:switch("Body"))
        ctx.body_limit_mode  = config.push(tab:combo("Limit", "Static", "Sway", "Random"))
        local body_tab       = ctx.body_limit_mode:create("BodySettings")
        ctx.body_static_limit= config.push(body_tab:slider("Value##body", 0, 60, 60, 1))
        ctx.body_sway_from   = config.push(body_tab:slider("From##body", 0, 60, 60, 1))
        ctx.body_sway_to     = config.push(body_tab:slider("To##body",   0, 60, 60, 1))
        ctx.body_random_min  = config.push(body_tab:slider("Min##body",   0, 60, 60, 1))
        ctx.body_random_max  = config.push(body_tab:slider("Max##body",   0, 60, 60, 1))
        ctx.body_yaw_enabled:set_callback(function() update_body_visibility(ctx) end)
        ctx.body_limit_mode:set_callback(function() update_body_visibility(ctx) end)
        update_body_visibility(ctx)
    end

    local function build_exploit_controls(tab, ctx)
        ctx.exploit_options = config.push(tab:selectable("Exploit", "Double Tap", "Hide Shots"))
    end

    local function build_state_group(state)
        local prefix = "##" .. state
        local ctx = {}
        local angle_tab   = ui.create(tabs_angles, prefix .. "_angles", 2)
        local body_tab    = ui.create(tabs_angles, prefix .. "_body",   2)
        local exploit_tab = ui.create(tabs_angles, prefix .. "_exploit",1)
        state_groups[state] = {angle_tab, body_tab, exploit_tab}
        build_angle_controls(angle_tab, ctx)
        build_body_controls(body_tab, ctx)
        build_exploit_controls(exploit_tab, ctx)
    end

    for _, state in ipairs(settings.states) do
        build_state_group(state)
    end

    local function update_state_visibility()
        local current = state_selector:get()
        for state, tabs in pairs(state_groups) do
            local visible = (state == current)
            tabs[1]:visibility(visible)
            tabs[2]:visibility(visible)
            tabs[3]:visibility(visible)
        end
    end

    local function update_builder_visibility()
        local show = mode_selector:get(1) == 1
        builder_tab:visibility(show)
        state_selector:visibility(show)
        for _, tabs in pairs(state_groups) do
            tabs[1]:visibility(false)
            tabs[2]:visibility(false)
            tabs[3]:visibility(false)
        end
        if show then update_state_visibility() end
    end

    state_selector:set_callback(update_state_visibility, true)
    mode_selector:set_callback(update_builder_visibility, true)
end


local angles_backend do
    local function compute_state()
        if localplayer.is_onground then
            if nl.antiaim.misc.slow_walk:get() then
                return condition.SLOW_WALK
            end
    
            if not localplayer.is_moving then
                if localplayer.is_crouched then
                    return condition.CROUCH_STAND
                end
                return condition.STANDING
            end
    
            if localplayer.is_crouched then
                return condition.CROUCH_MOVE
            end
            return condition.MOVING
        end
    
        return localplayer.is_crouched and condition.AIR_CROUCH or condition.IN_AIR
    end
end


local misc_frontend do
    misc = { }

    misc.tab = ui.create(tabs.misc, "Pook")

    misc.test = config.push(misc.tab:switch("Switch"))

end
