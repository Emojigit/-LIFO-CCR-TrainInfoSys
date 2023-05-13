-- LIFO-CCR-TrainInfoSys/rail_arrived.lua
local stn = "Exp" -- Station ID
local plat = 1 -- Platform int
local match_RCs = {"EXP1","EXP2"}

if event.train and atc_arrow then
    local rc = F.get_rc_safe()
    for _,y in ipairs(match_RCs) do
        if F.has_rc(y, rc) then
            F.TIS.train_arrived(stn,plat)
            break
        end
    end
end
