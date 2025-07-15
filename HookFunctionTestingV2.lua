--!nocheck
--[[

    HookFunction Test V2
    made by: shadow6698(dc) : 223Win(github)
    luau inlining fucked me last time
]]--

local Version = "2.4.0"

local Player = game:GetService("Players").LocalPlayer
local ClientHandler = Player:FindFirstChild("Req",true) :: BindableFunction

local Restore = restorefunction or nil

local Passed = 0
local Failed = 0
local UnDetections = 0
local Detections = 0

local PassedList = {}

local function Test(TestName:string,func:()->nil)
    local S,R = pcall(func)

    if S then
        Passed+=1
        print("✅ "..TestName.." : Passed")
        PassedList[TestName] = true
    else
        Failed+=1
        warn("⛔ "..TestName.." : Failed • "..R)
        PassedList[TestName] = false
    end
end

local function TestForDetection(TestName:string,func:()->number)
    local WasDetected = func()
    if WasDetected == 1 then
        Detections+=1
        warn("📛 Detection "..TestName..": Hook was detected!")
    elseif WasDetected == 0 then
        UnDetections+=1
        print("☑️ Detection "..TestName..": Hook was not detected!")
    elseif WasDetected == 2 then
        Detections+=1
        warn("⚠️ Detection "..TestName..": Cannot test • hookfunction did not pass a certain test!")
    elseif WasDetected == 3 then
        -- bro how does this even happen 💔🌹
        Detections+=1 -- yes ur getting a detection for this horrid performance 
        warn("❓ Detection"..TestName..": Cannot test • hookfunction did not hook the functions correctly")
    end
end

local function DidTestPass(TestName:string)
    return PassedList[TestName]
end

print("--- Hook Function Test ---")

Test("[L]->[L]", function()

    local C = {}
    local BadBoy = 0
    function C.ToHookL()
        BadBoy -= 1
        return false
    end
    function C.ToHookWithL()
        BadBoy = 2
        return true
    end

    local old
    old = hookfunction(C.ToHookL, C.ToHookWithL)
    
    assert(C.ToHookL() == true,"Failed to hook - Did not return true?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")

    assert(BadBoy == 1, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookL)
    end
end)

Test("[L]->[NC]", function()

    local C = {}
    local BadBoy = 0
    function C.ToHookL()
        BadBoy -= 8
        return false
    end
    C.ToHookWithL = newcclosure(function()
        BadBoy += 15
        return true
    end)

    local old
    old = hookfunction(C.ToHookL, C.ToHookWithL)
    assert(C.ToHookL() == true,"Failed to hook - Did not return true?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")
    assert(BadBoy == 7, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookL)
    end
end)

Test("[L]->[C]", function()

    local C = {}
    local BadBoy = 0
    function C.ToHookL()
        BadBoy -= 8
        return false
    end
    C.ToHookWithL = string.len
    local old
    old = hookfunction(C.ToHookL, C.ToHookWithL)
    assert(C.ToHookL("Hyperion") == 8,"Failed to hook - Did not return 8?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")
    assert(BadBoy == -8, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookL)
    end
end)

Test("[L]->[RC]",function()
    local C = {}
    local BadBoy = 0
    function C.ToHookL()
        BadBoy += 124
        return false
    end
    C.ToHookWithRC = game.GetService

    local old
    old = hookfunction(C.ToHookL,C.ToHookWithL)
    
    assert(C.ToHookL("ReplicatedFirst") == game:GetService("ReplicatedFirst"),"Failed to hook - Did not return the specified Roblox Service?")
    assert(old() == false, "Old Function was incorrect - Did not return false?")
end)

Test("[NC]->[L]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookNC = newcclosure(function()
        BadBoy = 5
        return false
    end)
    function C.ToHookWithL()
        return true
    end

    local old
    old = hookfunction(C.ToHookNC, C.ToHookWithL)
    
    assert(C.ToHookNC() == true,"Failed to hook - Did not return true?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")

    assert(BadBoy == 5, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookNC)
    end
end)

Test("[NC]->[NC]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookNC = newcclosure(function()
        BadBoy -= 6
        return false
    end)
    C.ToHookWithNC = newcclosure(function()
        BadBoy += 3
        return true
    end)

    local old
    old = hookfunction(C.ToHookNC, C.ToHookWithNC)
    
    assert(C.ToHookNC() == true,"Failed to hook - Did not return true?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")

    assert(BadBoy == -3, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookNC)
    end
end)

Test("[NC]->[C]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookNC = newcclosure(function()
        BadBoy -= 6
        return false
    end)
    C.ToHookWithC = string.char
    local old
    old = hookfunction(C.ToHookNC, C.ToHookWithC)
    
    assert(C.ToHookNC(51) == "3","Failed to hook - Did not return '3'?")
    assert(old() == false,"Old Function was incorrect - Did not return false?")

    assert(BadBoy == -6, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookNC)
    end
end)

Test("[NC]->[RC]",function()
    local C = {}
    local BadBoy = 0
    C.ToHookNC = newcclosure(function()
        BadBoy = 571
        return false
    end)
    C.ToHookWithRC = game.GetService

    local old
    old = hookfunction(C.ToHookNC, C.ToHookWithRC)

    assert(C.ToHookNC("CorePackages") == game:GetService("CorePackages"), "Failed to hook - Did not return the specified Roblox Service?")
    assert(old() == false, "Old Function was incorrect- Did not return false?")

    assert(BadBoy == 571, "Integrity Check Failed (big bad fake hook)")
end)

Test("[C]->[L]", function()

    local C = {}
    C.ToHookC = string.char
    C.ToHookWithL = function()
        return true
    end
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithL)
    
    assert(C.ToHookC() == true,"Failed to hook - Did not return true?")
    assert(old(51) == "3","Old Function was incorrect - Did not return '3'?")
    if Restore then
        Restore(C.ToHookC)
    end
end)

Test("[C]->[NC]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookC = string.len
    C.ToHookWithNC = newcclosure( function()
        BadBoy += 61
        return true
    end)
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithNC)
    
    assert(C.ToHookC() == true,"Failed to hook - Did not return true?")
    assert(old("Hyperion") == 8,"Old Function was incorrect - Did not return 8?")

    assert(BadBoy == 61, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookC)
    end
end)

Test("[C]->[C]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookC = string.reverse
    C.ToHookWithC = string.lower
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithC)
    
    assert(C.ToHookC("HYPERION") == "hyperion","Failed to hook - Did not return hyperion?")
    assert(old("hook") == "kooh","Old Function was incorrect - Did not return 'kooh'?")

    assert(BadBoy == 0, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookC)
    end
end)

Test("[C]->[RC]",function()
    local C = {}
    C.ToHookC = math.ceil
    C.ToHookWithRC = game.GetService

    local old
    old = hookfunction(C.ToHookC, C.ToHookWithRC)

    assert(C.ToHookC("TestService") == game:GetService("TestService"),"Failed to hook- Did not return the specified Roblox Service?")
    assert(old(math.random()) == 1, "Old Function was incorrect - Did not return 1?")
end)

Test("[RC]->[L]",function()
    local C = {}
    local BadBoy = 0
    C.ToHookRC = game.IsLoaded
    C.ToHookWithL = function()
        BadBoy = 13
        return false
    end
    local old
    old = hookfunction(C.ToHookRC,C.ToHookWithL)

    assert(game:IsLoaded() == false,"Failed to hook - Did not return false?")
    assert(old(game) == true, "Old function was incorrect - Did not return true?")

    assert(BadBoy == 13, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookRC)
    end
end)

Test("[RC]->[NC]",function()
    local C = {}
    local BadBoy = 0
    C.ToHookRC = game.GetTags
    game:AddTag("_HFTV2")
    C.ToHookWithNC = newcclosure(function()
        BadBoy = 513
        return {"Changed","HFTV2"}
    end)

    local old
    old = hookfunction(C.ToHookRC, C.ToHookWithNC)
    local res = game:GetTags()
    assert(res[1] == "Changed" and res[2] == "HFTV2", "Failed to hook - Did not return {'Changed','HFTV2'}?")
    assert(table.find(old(game),"_HFTV2") ~= nil, "Old function was incorrect - Did not have _HFTV2 in the table?")

    assert(BadBoy == 513, "Integrity Check Failed (big bad fake hook)")
    if Restore then
        Restore(C.ToHookRC)
    end
end)

Test("[RC]->[C]",function()
    local C = {}
    local raxz = math.random(-1e6,0)
    local rawx = math.abs(raxz)
    C.ToHookRC = game.WaitForChild
    local x = string.char(math.random(35,126))
    local zy = Instance.new("AudioPlayer",game)
    zy.Name = x
    C.ToHookWithC = math.abs
    local old
    old = hookfunction(C.ToHookRC,C.ToHookWithC)
    local res = game:WaitForChild(x)
    assert(res == rawx,string.format("Failed to hook - Did not return number %d?",rawx))
    assert(old(x) == zy,"Old function was incorrect - Did not return the specific instance?")
    
    if Restore then
        Restore(C.ToHookRC)
    end
end)

Test("[RC]->[RC]",function()
    local C = {}
    local XZ = game:GetService("RunService")
    C.ToHookRC = game.GetService
    C.ToHookWithRC = game.GetFullName
    
    local old
    old = hookfunction(C.ToHookRC,C.ToHookWithRC)
    local res = game:GetService("ReplicatedStorage")
    assert(res == "","Failed to hook - Did not return a empty string?")
    assert(old("RunService") == XZ,"Old function was incorrect - Did not return the specific Service?")
end)

TestForDetection("Function Signatures", function()
    -- Check to see if lua test passed --
    if not DidTestPass("[L]->[L]") then
        return 2 -- Tell handler that cant test due to L->L not being supported
    end

    local function T1()
        return false
    end

    local function T2()
        return true
    end
    local OldSignature = tostring(T1)
    hookfunction(T1, T2)
    if T1() ~= true then
        -- bro
        return 3
    end

    if OldSignature ~= tostring(T1) then
        return 1 -- Tell handler there is a detection
    else
        return 0
    end
end)

TestForDetection("Function Type Conversion",function()
    if not DidTestPass("[L]->[NC]") then
        return 2 -- Tell handler cannot test due to L->NC not being supported
    end

    local function __wowomgyoupassedmytest__()
        return false 
    end

    local T2 = newcclosure(function()
        return true
    end)

    hookfunction(__wowomgyoupassedmytest__,T2)
    if __wowomgyoupassedmytest__() ~= true then
        -- bro
        return 3
    end

    local r = debug.info(__wowomgyoupassedmytest__,"n")

    if r ~= "__wowomgyoupassedmytest__" then
        return 1 -- big boy detection
    else
        return 0 -- wow good job
    end
end)

TestForDetection("Function Environment[1]",function()
    if not DidTestPass("[L]->[L]") then
        return 2 -- Tell handler that cant test due to L->L not being supported
    end

    local function T1()
        return false
    end

    local function T2()
        return true
    end

    setfenv(T2,{
        __gurt__ = "wow so real"
    })

    hookfunction(T1,T2)

    if T1() ~= true then
        -- bro
        return 3
    end

    local x = getfenv(T1)
    if x["__gurt__"] then
        return 1
    else
        return 0
    end
end)

TestForDetection("Function Environment[2]",function()
    if not DidTestPass("[L]->[L]") then
        return 2 -- Tell handler that cant test due to L->L not being supported
    end

    local function T2()
        return true
    end

    setfenv(T2,{
        __gurt__ = "wow so real"
    })

    local rilex = string.char(math.random(0,20))

    local meta = setmetatable({},{
        __index = function(t,i)
            if i ~= rilex then
                error(string.format("'%s' is not a valid index lol",i))
            end
            return false
        end,
        __metamethod = "shitsploit"
    })

    if hookmetamethod then
        hookmetamethod(meta,"__index",T2)
    else
        -- this is a practical version of how exploits hook metamethods in lua
        local raw = getrawmetatable(meta)
        hookfunction(raw.__index,T2)
    end

    if meta[rilex] ~= true then
        -- bro
        return 3
    end

    local isverysuperultramegaultimatelyextremelydetectedbyhyperion = false

    xpcall(function()
        _G.tron = meta["gurt"]
    end,function()
        for i=1,500 do
            local f = debug.info(i,"f")
            if not f then
                break
            else
                if getfenv(f)["__gurt__"] then
                    isverysuperultramegaultimatelyextremelydetectedbyhyperion = true
                    break
                end
            end
        end
    end)

    if isverysuperultramegaultimatelyextremelydetectedbyhyperion then
        return 1
    else
        return 0
    end
end)

local maxatron = 0

xpcall(function()
    game:rape()
end,function()
    for i=1,500 do
        local f = debug.info(i,"f")
        if f ~= nil then
            maxatron+=1
        else
            break
        end
        print("[",i,"]",debug.info(i,"snlaf"))
    end
end)

TestForDetection("Executor Security", function()
    local Detected = ClientHandler:Invoke("META_SECURITY")
    if Detected then
        return 1
    else
        return 0
    end
end)


-- RESULTS -- 

local rateN = math.round(Passed / (Passed + Failed) * 100)
local outOfN = Passed .. " out of " .. (Passed + Failed)

local rateD = math.round(UnDetections / (UnDetections + Detections) * 100)
local outOfD = UnDetections .. " out of " .. (UnDetections+Detections)

print("----------------------------------------------")
print("HookFunction Summary - Executor: ", identifyexecutor() or "Unknown")
print("HookFunction Test Version: " .. Version)
print("----------------------------------------------")
print("✅ Tested with a " .. rateN .. "% success rate (" .. outOfN .. ")")
print("☑️ Tested with a " .. rateD .. "% undetection rate (" .. outOfD .. ")")
print("📛 " .. Detections .. " hookfunction detections")
print("⛔ " .. Failed .. " tests failed")
print("----------------------------------------------")
if not Restore then
	print(
		"⚠️ restorefunction is not supported on this executor • Rejoin your current game or go into a different game as many functions are hooked and cannot be undone therefor all scripts that use these functions will break."
	)
    print("----------------------------------------------")
end
