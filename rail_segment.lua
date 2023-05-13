-- LIFO-CCR-TrainInfoSys/rail_segment.lua
local routes = {
    EXP1 = { -- Key: Route ID
        dest = "Exp2", -- stn ID
        dest_plat = 1, -- Platform int
        dest_dist = 30, -- Distance in meter
        speed = 15, -- running speed in m/s, i.e. Subway is 15 m/s
        expect_delay = 0, -- expected delay in second
        towards = "Exp3", -- destination stn ID
    }
}

if event.train and atc_arrow then
    local rc = F.get_rc_safe()
    for x,y in pairs(routes) do
        if F.has_rc(x, rc) then
            F.TIS.train_started(y.speed,y.dest,y.dest_plat,y.dest_dist,x,y.expect_delay,y.towards)
            break
        end
    end
end
