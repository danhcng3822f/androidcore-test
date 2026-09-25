--[[
    executor_test.luau - kiem tra executor bang mot menu va mot nut toggle
    TU CHUA, khong dung Fluent hay thu vien UI nao.

    VI SAO TU CHUA
    --------------
    Khi menu khong hien, khong the biet loi o executor hay o thu vien UI ben
    thu ba. Script nay tu dung moi thu, nen ket qua chi noi ve executor.

    No cung tranh dung VirtualInputManager de gui phim gia. Ban test truoc cho
    thay kieu do khong dang tin: su kien phim toi duoc UserInputService nhung
    handler cua thu vien khong chay. O day nut toggle goi thang ham doi trang
    thai, khong qua trung gian nao.

    CACH CHAY
    ---------
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/danhcng3822ac/androidcore-test/main/executor_test.luau"
        ))()

    Hoac day file len may va chay truc tiep.

    NO KIEM TRA GI
    --------------
      1. gethui() va game.CoreGui tra ve container nao
      2. Instance.new + gan Parent + ghi thuoc tinh
      3. Su kien click chuot co ban (MouseButton1Click) - khong phai phim gia
      4. writefile / isfile / readfile
      5. game:HttpGet
      6. getgenv / task.spawn / os.clock
      7. Su kien doi trang thai cua nut toggle va menu

    Ket qua ghi ra file VA in ra logcat voi tien to ACEXEC, de doc duoc ca khi
    writefile hong.
]]

local OUT = "__exec_test.txt"
local lines = {}

local function log(s)
    lines[#lines + 1] = s
    pcall(writefile, OUT, table.concat(lines, "\n") .. "\n")
    pcall(print, "ACEXEC " .. s)
end

log("01 start  os.clock=" .. string.format("%.3f", os.clock()))

-- =====================================================================
-- 1. Container
-- =====================================================================
local container = nil
local container_src = "?"

local ok1, hui = pcall(gethui)
if ok1 and hui then
    container = hui
    container_src = "gethui()"
end

if not container then
    local ok2, cg = pcall(function() return game.CoreGui end)
    if ok2 and cg then
        container = cg
        container_src = "game.CoreGui"
    end
end

if not container then
    local ok3, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok3 and cg then
        container = cg
        container_src = "GetService('CoreGui')"
    end
end

log("02 container: " .. tostring(container) .. "  (nguon: " .. container_src .. ")")
if not container then
    log("   KHONG CO CONTAINER NAO - khong the dung UI. Dung lai.")
    return
end
log("   ClassName=" .. tostring(container.ClassName) .. "  Name=" .. tostring(container.Name))

-- =====================================================================
-- 2. Dung UI
-- =====================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ExecutorTestGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = container

log("03 ScreenGui.Parent dat xong, kiem tra lai: " .. tostring(gui.Parent == container))
if gui.Parent ~= container then
    log("   GAN THAT BAI - container tu choi. Day la loi cua executor.")
    return
end

-- ---- nut toggle ----
local toggle = Instance.new("TextButton")
toggle.Name = "ToggleButton"
toggle.Size = UDim2.fromOffset(120, 44)
toggle.Position = UDim2.fromOffset(20, 80)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Text = "MENU"
toggle.TextSize = 16
toggle.Font = Enum.Font.GothamBold
toggle.AutoButtonColor = true
toggle.ZIndex = 10
toggle.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = toggle

-- ---- menu (bat dau an) ----
local menu = Instance.new("Frame")
menu.Name = "MenuFrame"
menu.Size = UDim2.fromOffset(260, 300)
menu.Position = UDim2.fromOffset(20, 134)
menu.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
menu.BorderSizePixel = 0
menu.Visible = false
menu.ZIndex = 9
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menu

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Executor Test Menu"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = menu

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Size = UDim2.new(1, -20, 1, -60)
body.Position = UDim2.fromOffset(10, 48)
body.BackgroundTransparency = 1
body.TextColor3 = Color3.fromRGB(190, 190, 200)
body.Text = "Neu ban doc duoc dong nay thi:\n\n"
    .. "- ScreenGui da duoc gan vao container\n"
    .. "- Frame, TextLabel, TextButton tao duoc\n"
    .. "- UICorner hoat dong\n\n"
    .. "Bam nut MENU o tren de an/hien."
body.TextSize = 14
body.Font = Enum.Font.Gotham
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.Parent = menu

log("04 UI tao xong: toggle=" .. tostring(toggle) .. " menu=" .. tostring(menu))
log("   menu.Visible ban dau = " .. tostring(menu.Visible))

-- =====================================================================
-- 3. Su kien click - goi thang, khong qua phim gia
-- =====================================================================
local clicks = 0

toggle.MouseButton1Click:Connect(function()
    clicks = clicks + 1
    menu.Visible = not menu.Visible
    toggle.Text = menu.Visible and "DONG" or "MENU"

    log(string.format("05 CLICK #%d  menu.Visible=%s  toggle.Text=%s",
        clicks, tostring(menu.Visible), toggle.Text))
end)

log("06 da ket noi MouseButton1Click - bam nut MENU de kiem tra")

-- =====================================================================
-- 4. Cac ham khac cua executor
-- =====================================================================
log("07 kiem tra cac ham khac:")

log("   type(gethui)      = " .. type(gethui))
log("   type(getgenv)     = " .. type(getgenv))
log("   type(writefile)   = " .. type(writefile))
log("   type(readfile)    = " .. type(readfile))
log("   type(isfile)      = " .. type(isfile))
log("   type(loadstring)  = " .. type(loadstring))
log("   type(getrawmetatable) = " .. type(getrawmetatable))

local ok_w, err_w = pcall(writefile, "__exec_probe.txt", "hello from executor test")
log("   writefile        : ok=" .. tostring(ok_w) .. " err=" .. tostring(err_w))

local ok_f, isf = pcall(isfile, "__exec_probe.txt")
log("   isfile           : ok=" .. tostring(ok_f) .. " -> " .. tostring(isf))

if ok_f and isf then
    local ok_r, content = pcall(readfile, "__exec_probe.txt")
    log("   readfile         : ok=" .. tostring(ok_r) .. " -> " .. tostring(content))
end

-- task
local task_ok, task_err = pcall(function()
    local done = false
    task.spawn(function() done = true end)
    task.wait(0.1)
    return done
end)
log("   task.spawn/wait  : ok=" .. tostring(task_ok) .. " -> " .. tostring(task_err))

-- HttpGet
local t0 = os.clock()
local ok_h, body = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/danhcng3822f/androidcore-test/main/payload.luau")
end)
local dt = (os.clock() - t0) * 1e6
if ok_h then
    log(string.format("   game:HttpGet    : ok  %.0f us  %d byte", dt, #body))
else
    log(string.format("   game:HttpGet    : LOI sau %.0f us -> %s", dt, tostring(body)))
end

-- =====================================================================
-- 5. Tu kiem tra sau 3 giay
-- =====================================================================
task.spawn(function()
    task.wait(3)
    log("08 tu kiem tra sau 3s:")
    log("   gui.Parent == container : " .. tostring(gui.Parent == container))
    log("   gui:FindFirstChild('ToggleButton') = " .. tostring(gui:FindFirstChild("ToggleButton")))
    log("   so lan click            : " .. clicks)
    log("   menu.Visible            : " .. tostring(menu.Visible))
    if clicks == 0 then
        log("   -> CHUA BAM NUT. Bam nut MENU roi xem lai file nay.")
    else
        log("   -> Nut da hoat dong.")
    end
end)

log("09 script chay xong - UI dang hien, cho ban bam nut")
