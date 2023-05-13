-- LIFO-CCR-TrainInfoSys/controller_four_platforms.lua
local stn = "Sg" -- Station ID
local align_disp = "l" -- display
local stop_time = 12 -- Stop time in seconds
local platforms = {nil,1,2,nil} -- Platforms of every rows (str or {str,disp_int})), nil to disable that row

local default_lines = {nil, "COL1", "COL1", nil} -- Default lines for each platform
local default_towards = {nil, "Sg", "Sg",nil} -- Default towards for each platform

--[[ Display Example
12345678901234567890123456 (not actual line)
# Line   Destination  Time (if the first line is nil)
1 E16  > M. Grassland  10s (10 sec before train arrive)
2 COL3 > P. Valley     5s  (5 sec before train arrive)
3 COL2 > CANDC Farm   D5s  (Door 5 sec left)
4 COC1 > R. Hotel      N/A (NO DATA)
]]
-- Thank ChatGPT for producing the code so I just have to do small improvements

local function format_time(seconds,arrived)
    if not seconds or seconds < 0 then
        return "N/A"
    elseif arrived then
        return string.format("D%d", seconds)
    elseif seconds < 60 then
        return string.format("%ds", seconds)
    else
        local minutes = math.floor(seconds / 60)
        local seconds_remain = seconds % 60
        return string.format("%d:%02d", minutes, seconds_remain)
    end
end

local function get_platform_data(i,plat)
    local coming_id, coming_data = F.TIS.get_coming_train(stn, plat)
    if not coming_data then
        return default_lines[i], default_towards[i], nil, nil
    elseif coming_data.dist == 0 then
        return coming_data.line, coming_data.towards, coming_data.speed, stop_time - os.time() + coming_data.time, true
    else
        local time_used = os.time() - coming_data.time
        local metre_remained = coming_data.dist - (time_used * coming_data.speed)
        local seconds_wait = metre_remained / coming_data.speed
        return coming_data.line, coming_data.towards, coming_data.speed, (seconds_wait + 4), false
    end
end

local function format_platform_data(i,plat,disp)
    local line, towards, speed, time, arrived = get_platform_data(i,plat)
    if not line then
        return ""
    end
    local s = string.format("%d %-4s > %-12s %s", disp or plat, line, F.get_stn_name(towards, true), format_time(time,arrived))
    return s
end

local function update_display()
    local data = {}
    for i=1, 4 do
        y = platforms[i]
        if y == nil then
            if i == 1 then
                table.insert(data,"# Line   Destination  Time")
            else
                table.insert(data," ")
            end
        elseif type(y) == "table" then
            table.insert(data,format_platform_data(i,y[1],y[2]))
        else
            table.insert(data,format_platform_data(i,y))
        end
    end
    digiline_send(align_disp, table.concat(data, "\n") .. " ")
end

if event.punch then
    digiline_send(align_disp, "INIT")
    interrupt_safe(2)
elseif event.int then
    update_display()
    interrupt_safe(2)
end

