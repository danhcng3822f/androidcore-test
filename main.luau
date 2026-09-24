--[[
    main.luau - do toan bo duong di khi mot script duoc nap tu GitHub.

    Muc dich: do xem "load script cham" nam o dau. Script nay tu do chinh no,
    tach ra ba giai doan rieng biet:

        1. TAI     - game:HttpGet tu raw.githubusercontent.com
        2. BIEN DICH - loadstring tren source vua tai ve
        3. CHAY    - goi ham vua bien dich

    Cong them mot phep do thu tu: tai lai chinh script nay lan thu hai. Neu lan
    dau cham va lan sau nhanh thi chi phi nam o phia mang (DNS, TLS, cache
    cua CDN); neu ca hai deu cham nhu nhau thi chi phi nam trong executor.

    Ket qua ghi ra file va in ra logcat voi tien to ACMAIN, de doc duoc ca khi
    writefile hong.
]]

local REPO = "https://raw.githubusercontent.com/danhcng3822f/androidcore-test/main"
local OUT = "__gh_test.txt"
local lines = {}

local function log(s)
    lines[#lines + 1] = s
    pcall(writefile, OUT, table.concat(lines, "\n") .. "\n")
    pcall(print, "ACMAIN " .. s)
end

local function us(t0, t1)
    return (t1 - t0) * 1e6
end

log("01 start  os.clock=" .. string.format("%.4f", os.clock()))

-- ---------------------------------------------------------------- 1. TAI
-- Hai lan tai cung mot URL de tach chi phi mang khoi chi phi xu ly.
local t0 = os.clock()
local ok1, body1 = pcall(function() return game:HttpGet(REPO .. "/payload.luau") end)
local t1 = os.clock()

if not ok1 then
    log("02 TAI lan 1 THAT BAI: " .. tostring(body1))
    log("   -> kiem tra URL con truy cap duoc khong, va executor co cho phep")
    log("      raw.githubusercontent.com khong")
else
    log(string.format("02 TAI lan 1  ok  %9.1f us  %d byte", us(t0, t1), #body1))
end

local t2 = os.clock()
local ok2, body2 = pcall(function() return game:HttpGet(REPO .. "/payload.luau") end)
local t3 = os.clock()

if ok2 then
    log(string.format("03 TAI lan 2  ok  %9.1f us  %d byte  (lan 2 / lan 1 = %.2f)",
        us(t2, t3), #body2, us(t2, t3) / math.max(us(t0, t1), 1)))
end

-- ---------------------------------------------------------------- 2. BIEN DICH
if ok1 then
    local t4 = os.clock()
    local okc, chunk = pcall(loadstring, body1)
    local t5 = os.clock()

    if not okc then
        log("04 BIEN DICH THAT BAI: " .. tostring(chunk))
    else
        log(string.format("04 BIEN DICH   ok  %9.1f us  cho %d byte (%.3f us/byte)",
            us(t4, t5), #body1, us(t4, t5) / math.max(#body1, 1)))

        -- ------------------------------------------------------------ 3. CHAY
        local t6 = os.clock()
        local okr, err = pcall(chunk)
        local t7 = os.clock()

        if okr then
            log(string.format("05 CHAY        ok  %9.1f us", us(t6, t7)))
        else
            log(string.format("05 CHAY        LOI %9.1f us : %s", us(t6, t7), tostring(err)))
        end
    end
end

-- ---------------------------------------------------------------- 4. SO SANH
-- loadstring tren source lon do executor tu sinh, de tach chi phi bo quet
-- rewrite_game_httpget khoi chi phi cua Luau compiler.
local big = {}
for i = 1, 3000 do
    big[i] = "local v" .. i .. " = " .. i
end
local bigsrc = table.concat(big, "\n")

local t8 = os.clock()
local okb = pcall(loadstring, bigsrc)
local t9 = os.clock()

log(string.format("06 loadstring %d byte (tu sinh)  %9.1f us  (%.4f us/byte)",
    #bigsrc, us(t8, t9), us(t8, t9) / #bigsrc))

-- Cung kich thuoc nhung chua chuoi "game" de kich hoat bo quet nhieu hon.
local big2 = {}
for i = 1, 1500 do
    big2[i] = "local g" .. i .. " = game"
end
local big2src = table.concat(big2, "\n")

local t10 = os.clock()
local okb2 = pcall(loadstring, big2src)
local t11 = os.clock()

log(string.format("07 loadstring %d byte (co 'game')  %9.1f us  (%.4f us/byte)",
    #big2src, us(t10, t11), us(t10, t11) / #big2src))

log("08 xong  os.clock=" .. string.format("%.4f", os.clock()))

return {
    ok = ok1 and true or false,
    bytes = ok1 and #body1 or 0,
    fetch_us = us(t0, t1),
}
