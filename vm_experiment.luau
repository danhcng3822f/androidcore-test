-- scripts/run_vm_experiment.lua
--
-- Tim cho VM Luraph khong thoat ra.
--
-- CACH LAM
-- --------
-- VM cua Luraph da duoc giai nen ra Lua doc duoc (252.807 byte) va da duoc chen
-- mot bo dem vao vong lap chinh: no ghi lai N (trang thai) moi 200.000 vong va
-- tu ngat sau 5 trieu vong thay vi treo vo han.
--
-- Script nay tai VM do ve, roi lam dung nhung gi doan R cua script goc lam:
--
--     vm_fn = loadstring(vm_src)     -- nap VM
--     f     = vm_fn()                -- chay no, lay bang co metatable
--     ok, r = pcall(f)               -- goi qua __call
--     runner = r                     -- ham/table de thuc thi bytecode
--     runner(C, nil, nil)            -- CHAY BYTECODE  <-- cho treo cu
--
-- Khac biet duy nhat so voi ban goc: VM co bo dem, nen thay vi treo no se
-- bao cao no dang ket o trang thai nao.

local VM_URL  = "https://raw.githubusercontent.com/danhcng3822f/androidcore-test/main/luraph_vm_instrumented.luau"
local SRC_URL = "https://raw.githubusercontent.com/duczsitink/DUCKHUB/refs/heads/main/main.lua"

local OUT = "__vm_exp.txt"
local lines = {}

local function log(s)
    lines[#lines + 1] = s
    pcall(writefile, OUT, table.concat(lines, "\n") .. "\n")
    pcall(print, "ACEXP " .. s)
end

log("01 bat dau  os.clock=" .. string.format("%.3f", os.clock()))

-- ---------------------------------------------------------------- tai VM
local t0 = os.clock()
local ok1, vm_src = pcall(function() return game:HttpGet(VM_URL) end)
log(string.format("02 tai VM   ok=%s  %.0f ms  %s byte", tostring(ok1),
    (os.clock() - t0) * 1000, ok1 and #vm_src or tostring(vm_src)))
if not ok1 then return end

-- ---------------------------------------------------------------- tai script goc
local t1 = os.clock()
local ok2, src = pcall(function() return game:HttpGet(SRC_URL) end)
log(string.format("03 tai script goc ok=%s  %.0f ms  %s byte", tostring(ok2),
    (os.clock() - t1) * 1000, ok2 and #src or tostring(src)))
if not ok2 then return end

-- ---------------------------------------------------------------- lay truong C
-- Truong C la blob bytecode ma VM se thuc thi.
local C = string.match(src, 'C="([0-9a-fA-F]*)"')
log("04 truong C: " .. (C and (#C .. " ky tu hex") or "KHONG TIM THAY"))
if not C then return end

local vmSize = tonumber(string.match(src, "vm_size%s*=%s*(%d+)")) or 0
local codeSize = tonumber(string.match(src, "code_size%s*=%s*(%d+)")) or 0
log(string.format("05 vm_size=%d  code_size=%d", vmSize, codeSize))

-- ---------------------------------------------------------------- nap VM
local t2 = os.clock()
local ok3, vm_fn = pcall(loadstring, vm_src)
log(string.format("06 loadstring VM ok=%s  %.0f ms", tostring(ok3), (os.clock() - t2) * 1000))
if not ok3 then
    log("   loi: " .. tostring(vm_fn))
    return
end

local t3 = os.clock()
local ok4, f = pcall(vm_fn)
log(string.format("07 vm_fn() ok=%s  %.0f ms  -> %s", tostring(ok4), (os.clock() - t3) * 1000, tostring(f)))
if not ok4 then return end

local t4 = os.clock()
local ok5, r = pcall(f)
log(string.format("08 pcall(f) ok=%s  %.0f ms  -> %s", tostring(ok5), (os.clock() - t4) * 1000, tostring(r)))

local runner = (ok5 and (type(r) == "function" or (type(r) == "table" and getmetatable(r)))) and r or f
log("09 runner = " .. type(runner))

-- ---------------------------------------------------------------- CHAY
-- Cho treo cu nam o day. VM co bo dem nen no se tu ngat va ghi __vm_trace.txt.
log("10 CHAY BYTECODE (cho tung treo)...")
local t5 = os.clock()
local ok6, err = pcall(runner, C, nil, nil)
local dt = (os.clock() - t5) * 1000
log(string.format("11 runner xong ok=%s  %.0f ms", tostring(ok6), dt))
if not ok6 then
    log("   loi/ngat: " .. tostring(err))
end
log("12 xong")
