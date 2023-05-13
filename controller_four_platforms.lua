local stn = "Exp2" -- Station ID
local align_disp = "l" -- Align left display
local stop_time = 10 -- Stop time in seconds
local platforms = {nil,2,3,{"U1",1}} -- Platforms of every rows (str or {str,disp_int})), nil to disable that row

local default_lines = {"COC1", "COC2", "COC3", "COC4"} -- Default lines for each platform
local default_towards = {"Rh", "Rh", "Rh", "Rh"} -- Default towards for each platform

--[[ Display Example
12345678901234567890123456 (not actual line)
# Line   Destination  Time (if the first line is nil)
1 E16  > M. Grassland  10s (10 sec before train arrive)
2 COL3 > P. Valley     5s  (5 sec before train arrive)
3 COL2 > CANDC Farm   D5s  (Door 5 sec left)
4 COC1 > R. Hotel      N/A (NO DATA)
]]
-- Thank ChatGPT for producing the code so I just have to do small improvements

local function format_time(seconds)
    if seconds < 0 then
        return "N/A"
    elseif seconds < 60 then
        return string.format("%ds", seconds)
    else
        local minutes = math.floor(seconds / 60)
        local seconds_remain = seconds % 60
        return string.format("%d:%02d", minutes, seconds_remain)
    end
end

local function get_platform_data(plat)
    local coming_id, coming_data = F.TIS.get_coming_train(stn, plat)
    if not coming_data then
        return default_lines[plat], default_towards[plat], nil, nil
    elseif coming_data.dist == 0 then
        return coming_data.line, coming_data.towards, coming_data.speed, stop_time - os.time() + coming_data.time
    else
        local time_used = os.time() - coming_data.time
        local metre_remained = coming_data.dist - (time_used * coming_data.speed)
        local seconds_wait = metre_remained / coming_data.speed
        return coming_data.line, coming_data.towards, coming_data.speed, seconds_wait
    end
end

local function format_platform_data(plat,disp)
    local line, towards, speed, time = get_platform_data(plat)
    if not line then
        return ""
    end
    local s = string.format("%d %-4s > %s %s", disp or plat, line, F.get_stn_name(towards, true), format_time(time))
    if speed then
        s = s .. string.format("  (%.1fm/s)", speed)
    end
    return s
end

local function update_display()
    local data = {}
    for n,y in ipairs(platforms) do
        if y == nil then
            if n == 1 then
                table.insert(data,"# Line   Destination  Time")
            else
                table.insert(data,"")
            end
        elseif type(y) == "number" then
            table.insert(data,format_platform_data(y))
        else
            table.insert(data,format_platform_data(y[1],y[2]))
        end
    end
    digiline_send(align_disp, table.concat(data, "\n"))
end

if event.punch then
    interrupt_safe(2)
elseif event.interrupt then
    update_display()
    interrupt_safe(2)
end

