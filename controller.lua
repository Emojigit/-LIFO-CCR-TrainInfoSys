-- LIFO-CCR-TrainInfoSys/controller.lua
local stn = "Sg" -- Station ID
local plat = 1 -- Platform int
local align_l_disp = "l"
local align_r_disp = "r"
local stop_time = 12

local default_line = "COL1"
local default_to = "Sg"
local default_via = nil

--[[ Display Example:
Platform 1
Cat-o-land Local 3
To Pineapple Valley
(either one of the following lines)
via Sakura Gaps
Arrive in 10 sec
Leave in 5 sec
]]

if event.punch then
    interrupt_safe(2)
    digiline_send(align_l_disp,"INIT L")
    digiline_send(align_l_disp,"INIT R")
elseif event.int then
    local coming_id, coming_data = F.TIS.get_coming_train(stn,plat)
    local rtn = {}
    if not coming_data then
        rtn = {
            "Platform " .. plat,
            F.LINE_ID[default_line],
            "To " .. F.get_stn_name(default_to,true),
            default_via and ("Via " .. F.get_stn_name(default_via,true)) or ""
        }
    else
        local now = os.time()
        local time_used = now - coming_data.time
        if coming_data.dist == 0 then
            local seconds_wait = stop_time - now + coming_data.time
            if seconds_wait < 0 then
                seconds_wait = "?"
            end
            rtn = {
                "Platform " .. plat,
                F.LINE_ID[coming_data.line],
                "To " .. F.get_stn_name(coming_data.towards,true),
                "Leave in " .. seconds_wait .. " sec"
            }
        else
            local metre_remained = coming_data.dist - (time_used * coming_data.speed)
            local seconds_wait = (metre_remained / coming_data.speed) + 4
            if seconds_wait < 0 then
                seconds_wait = "?"
            end
            rtn = {
                "Platform " .. plat,
                F.LINE_ID[coming_data.line],
                "To " .. F.get_stn_name(coming_data.towards,true),
                "Arrive in " .. seconds_wait .. " sec"
            }
        end
    end
    digiline_send(align_l_disp,table.concat(rtn,"\n"))
    local rcont = {}
    for x,y in ipairs(rtn) do
        table.insert(rcont,string.format("%26s",y))
    end
    digiline_send(align_r_disp,table.concat(rcont,"\n"))
    interrupt_safe(2)
end
