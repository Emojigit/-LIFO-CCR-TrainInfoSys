F.STN_ID = { -- string, or table{long,short}
    -- Cat-o-land Local Lines Stations
    CcF = "CANDC Farm", -- Digilines have problem showing "&"
    Tb = "Tile Bridge",
    Sg = "Sakura Gaps",
    BkN = "Baka North",
    Cay = "Annoying Yard",
    Dh = "Dungeon Head",
    Bb = "Bamboo Bush",
    Tb = "Tile Bridge",
    OgS = {"Overground Spawner","O. Spawner"},
    Btw = "By The Way"
    Mg = {"Mushroom Grassland","M. Grassland"},
    Di = "Diagonal Island",
    Mp = "Mushroom Pier",
    Pv = {"Pineapple Valley","P. Valley"},
    -- LinuxForks Stations
    Sh = "Sheep Hills",
    LF_Yj = {"Yarrak Junction","Yarrak J."},
    LF_Kv_Ms = "Kangasvarkaa",
    LF_Spn21 = "Spawn 21",
    -- Cat-o-City Subway
    CcFF = "The Factory",
    Rh = {"Rukkhashava Hotel","R. Hotel"},
}

F.get_stn_name(stn,short) -- short: bool
    local stn = F.STN_ID[stn]
    if not stn the return "?" end
    if type(stn) == "string" then return stn end
    if short then return stn[2] end
    return stn[1]
end

F.LINE_ID = {
    COL1  = "Cat-o-land Local 1",
    COL1a = "Cat-o-land Local 1a",
    COL2  = "Cat-o-land Local 2",
    COL3  = "Cat-o-land Local 3",

    COC1  = "Cat-o-City Subway 1",

    E16   = "LF Express 16",
}

F.TIS = { -- Train Information System
    Tbl = {}, -- Nested table, station -> platform -> atc_id
    train_started = function(speed,dest,dest_plat,dest_dist,line,delay,towards) -- to be called when a train going towards a stn
        if not atc_arrow then return end
        if not F.TRS.Tbl[dest] then F.TRS.Tbl[dest] = {} end
        if not F.TRS.Tbl[dest][dest_plat] then F.TRS.Tbl[dest][dest_plat] = {} end
        F.TRS.Tbl[dest][dest_plat][atc_id] = {
            time = os.time(),
            dist = dest_dist,
            speed = speed,
            line = line,
            towards = towards,
            delay = delay,
        }
    end,
    train_arrived = function(stn,stn_plat) -- to be called when a train arrived a station
        if not atc_arrow then return end
        if F.TRS.Tbl[stn] and F.TRS.Tbl[stn][stn_plat] and F.TRS.Tbl[stn][stn_plat][atc_id] then
            F.TRS.Tbl[stn][stn_plat][atc_id].time = os.time()
            F.TRS.Tbl[stn][stn_plat][atc_id].dist = 0
        end
    end,
    train_leaved = function(stn,stn_plat) -- to be called when a train leaves a station
        if not atc_arrow then return end
        if F.TRS.Tbl[stn] and F.TRS.Tbl[stn][stn_plat] then
            F.TRS.Tbl[stn][stn_plat][atc_id] = nil
        end
    end,
    get_coming_train = function(stn,stn_plat) -- to be called by the displays
        if not(F.TRS.Tbl[stn] and F.TRS.Tbl[stn][stn_plat]) then return false end
        local now = os.time()
        local selected = nil
        local sid = nil
        for id,t in pairs(F.TRS.Tbl[stn][stn_plat]) do
            if t.dist == 0 then
                if now - t.time > 20 then
                    F.TRS.Tbl[stn][stn_plat][id] = nil
                else
                    if selected.time < t.time then
                        selected = t
                        sid = id
                    end
                end
            else
                if now - t.time > 120 then
                    F.TRS.Tbl[stn][stn_plat][id] = nil
                else
                    if selected.dist > t.dist and select.time > t.time then
                        selected = t
                        sid = id
                    end
                end
            end
        end
        if not selected then return false end
        return sid, selected
    end,
}
