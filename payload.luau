--[[
    payload.luau - script phu, duoc main.luau tai ve qua game:HttpGet.

    Muc dich la de phep do co that: main.luau tai file nay tu GitHub, bien dich
    no, roi chay no. Neu file nay chay duoc thi ca ba giai doan deu thong.

    No co tinh lam mot viec do duoc va co the kiem chung, thay vi chi in ra
    chuoi: no dem so vong lap trong mot khoang thoi gian ngan, roi ghi ket qua
    vao bang chung cua getgenv() de main.luau doc lai.
]]

local t0 = os.clock()
local n = 0

-- Vong lap ngan, co gioi han thoi gian de khong phu thuoc toc do may.
while os.clock() - t0 < 0.05 do
    n = n + 1
end

local dt = os.clock() - t0

-- Ghi ket qua vao getgenv() de main.luau kiem chung duoc rang payload that su
-- da chay, chu khong chi duoc bien dich.
local g = getgenv()
g.__gh_test_payload = {
    ran = true,
    loops = n,
    seconds = dt,
    loops_per_sec = n / dt,
}

return "payload ok: " .. n .. " vong lap trong " .. string.format("%.4f", dt) .. " s"
