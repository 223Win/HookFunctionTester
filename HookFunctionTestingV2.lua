--!nocheck
--!optimize 0
--[[

    HookFunction Test V2
    made by: shadow6698(dc) : 223Win(github)
    luau inlining fucked me last time
]]--

local Version = "2.6.3"

local Player = game:GetService("Players").LocalPlayer
local ClientHandler = Player:FindFirstChild("Req",true) :: BindableFunction

local Restore = restorefunction or nil

local Passed = 0
local Failed = 0
local UnDetections = 0
local Detections = 0

local PassedList = {}

local function Test(TestName:string,func:()->(number,string?))
    local PcallResult = {pcall(func)}
    local ErrorCode = if PcallResult[1] then PcallResult[2] else 0
    local Result = if PcallResult[1] then PcallResult[3] else PcallResult[2]

    if ErrorCode == 1 then
        Passed+=1
        print("✅ "..TestName.." : Passed")
        PassedList[TestName] = true
    elseif ErrorCode == 0 then
        Failed+=1
        warn("⛔ "..TestName.." : Failed • "..Result)
        PassedList[TestName] = false
    elseif ErrorCode == 2 then
        -- warning from test (potental problem)
        Failed+=1
        warn("⚠️ "..TestName.." : "..Result)
    end
end

local function TestForDetection(TestName:string,func:()->number)
    local Pcallresult = {pcall(func)}
    local WasDetected = if Pcallresult[1] then Pcallresult[2] else 5
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
        warn("❓ Detection "..TestName..": Cannot test • hookfunction did not hook the functions correctly")
    elseif WasDetected == 5 then
        Detections+=1
        warn("❓ Detection "..TestName..": Cannot test • ",Pcallresult[2])
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
    if C.ToHookL() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= 1 then
        return 0,"Integrity Check Failed (big bad fake hook)"
    end

    if Restore then
        Restore(C.ToHookL)
    end

    return 1
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
    if C.ToHookL() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= 7 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookL)
    end

    return 1
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
    if C.ToHookL("Hyperion") ~= 8 then
        return 0, "Failed to hook - Did not return 8?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= -8 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookL)
    end

    return 1
end)

Test("[L]->[RC]",function()
    local C = {}
    local BadBoy = 0
    local function ToHookL()
        BadBoy += 124
        return false
    end
    C.ToHookWithRC = game.GetService

    local old
    old = hookfunction(ToHookL,C.ToHookWithRC)
    
    if ToHookL(game,"ReplicatedFirst") ~= game:GetService("ReplicatedFirst") then
        print(ToHookL(game,"ReplicatedFirst"))
        return 0, "Failed to hook - Did not return the specified Roblox Service?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end

    return 1
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
    
    if C.ToHookNC() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= 5 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookNC)
    end

    return 1
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
    
    if C.ToHookNC() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= -3 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookNC)
    end

    return 1
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
    
    if C.ToHookNC(51) ~= "3" then
        return 0, "Failed to hook - Did not return '3'?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= -6 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookNC)
    end

    return 1
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

    if C.ToHookNC("CorePackages") ~= game:GetService("CorePackages") then
        return 0, "Failed to hook - Did not return the specified Roblox Service?"
    end
    if old() ~= false then
        return 0, "Old Function was incorrect - Did not return false?"
    end
    if BadBoy ~= 571 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end

    return 1
end)

Test("[C]->[L]", function()

    local C = {}
    C.ToHookC = string.char
    C.ToHookWithL = function()
        return true
    end
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithL)
    
    if C.ToHookC() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old(51) ~= "3" then
        return 0, "Old Function was incorrect - Did not return '3'?"
    end
    if Restore then
        Restore(C.ToHookC)
    end

    return 1
end)

Test("[C]->[NC]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookC = string.len
    C.ToHookWithNC = newcclosure(function()
        BadBoy += 61
        return true
    end)
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithNC)
    
    if C.ToHookC() ~= true then
        return 0, "Failed to hook - Did not return true?"
    end
    if old("Hyperion") ~= 8 then
        return 0, "Old Function was incorrect - Did not return 8?"
    end
    if BadBoy ~= 61 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookC)
    end

    return 1
end)

Test("[C]->[C]", function()

    local C = {}
    local BadBoy = 0
    C.ToHookC = string.reverse
    C.ToHookWithC = string.lower
    local old
    old = hookfunction(C.ToHookC, C.ToHookWithC)
    
    if C.ToHookC("HYPERION") ~= "hyperion" then
        return 0, "Failed to hook - Did not return hyperion?"
    end
    if old("hook") ~= "kooh" then
        return 0, "Old Function was incorrect - Did not return 'kooh'?"
    end
    if BadBoy ~= 0 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookC)
    end

    return 1
end)

Test("[C]->[RC]",function()
    local C = {}
    C.ToHookC = math.ceil
    C.ToHookWithRC = game.GetService

    local old
    old = hookfunction(C.ToHookC, C.ToHookWithRC)

    if C.ToHookC("TestService") ~= game:GetService("TestService") then
        return 0,"Failed to hook- Did not return the specified Roblox Service?"
    end
    if old(math.random()) ~= 1 then
        return 0,"Old Function was incorrect - Did not return 1?"
    end

    if Restore then
        Restore(C.ToHookC)
    end

    return 1
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

    if game:IsLoaded() ~= false then
        return 0, "Failed to hook - Did not return false?"
    end
    if old(game) ~= true then
        return 0, "Old function was incorrect - Did not return true?"
    end
    if BadBoy ~= 13 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookRC)
    end

    return 1
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
    if res[1] ~= "Changed" or res[2] ~= "HFTV2" then
        return 0, "Failed to hook - Did not return {'Changed','HFTV2'}?"
    end
    if table.find(old(game),"_HFTV2") == nil then
        return 0, "Old function was incorrect - Did not have _HFTV2 in the table?"
    end
    if BadBoy ~= 513 then
        return 0, "Integrity Check Failed (big bad fake hook)"
    end
    if Restore then
        Restore(C.ToHookRC)
    end

    return 1
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
    local res = C.ToHookRC(raxz)
    if res ~= rawx then
        return 0, string.format("Failed to hook - Did not return number %d?",rawx)
    end
    if old(game,x) ~= zy then
        return 0, "Old function was incorrect - Did not return the specific instance?"
    end
    
    if Restore then
        Restore(C.ToHookRC)
    end

    return 1
end)

Test("[RC]->[RC]",function()
    local C = {}
    local XZ = game:GetService("RunService")
    C.ToHookRC = game.GetService
    C.ToHookWithRC = game.GetFullName
    
    local old
    old = hookfunction(C.ToHookRC,C.ToHookWithRC)
    local res = C.ToHookRC(game)
    if res ~= "Ugc" then
        return 0, "Failed to hook - Did not return Ugc?"
    end
    if old(game,"RunService") ~= XZ then
        return 0, "Old function was incorrect - Did not return the specific Service?"
    end

    if Restore then
        Restore(C.ToHookRC)
    end

    return 1
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
print("Credits: ")
print("\t Shadow(Discord: shadow6698)")
print("\t Arman(Discord: armandukx)")
print("----------------------------------------------")