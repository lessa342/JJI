local Target = ""
local Mission = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Server = Remotes:WaitForChild("Server")
local Client = Remotes:WaitForChild("Client")
local Data = Server:WaitForChild("Data")
local AcceptQuest = Data:WaitForChild("AcceptQuest")
local Missions = ReplicatedStorage:WaitForChild("Missions")
local Objects = workspace:WaitForChild("Objects")
local Mobs = Objects:WaitForChild("Mobs")
local Drops = Objects:WaitForChild("Drops")
local CollectChest = Client:WaitForChild("CollectChest")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or (Player.CharacterAdded:Wait() and Player.Character)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function(Char)
    Character = Char 
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

local Grades = {
    ["Non Sorcerer"] = 1,
    ["Grade 4"] = 2,
    ["Grade 3"] = 3,
    ["Grade 2"] = 4,
    ["Grade 1"] = 5,
    ["Special Grade"] = 6,
    ["Special Grade 4"] = 6
}

local ReplicatedData = Player:WaitForChild("ReplicatedData")
local PGrade = Grades[ReplicatedData:WaitForChild("grade").Value] or 10

local UpdateStatus
UpdateStatus = function() task.wait()
    local CMission, CGrade = nil, 0 
    for i,v in next, Missions:GetChildren() do 
        local Grade = v:FindFirstChild("Grade")
        local Type = v:FindFirstChild("Type")
        if Grade and Type then 
            Grade, Type = Grades[Grade.Value], Type.Value 
            if Type == "Kill" and type(Grade) == "number" and Grade > CGrade and PGrade >= Grade then 
                CMission = v 
                CGrade = Grade	
            end 
        end 
    end 
    if not CMission then UpdateStatus() end 
    local Mob = CMission:FindFirstChild("Mob")
    if Mob then
        Mob = Mob.Value 
        if type(Mob) == "string" then  
            Mission = CMission 
            Target = Mob 
        else 
            UpdateStatus()
        end 
    else 
        UpdateStatus()
    end 
end 

local FindFirstChest = function()
    local Chest 
    for i,v in next, Drops:GetChildren() do 
        if v.Name:lower():match("chest") then 
            Chest = v 
            break 
        end 
    end 
    return Chest 
end 

CollectChest.OnClientInvoke = function() return 0 end 

while true do 
    if not pcall(function() AcceptQuest:InvokeServer(Mission) end) then UpdateStatus() end
	local Mob = Mobs:FindFirstChild(Target)
	if Mob then 
		local Humanoid = Mob:FindFirstChild("Humanoid")
		if Humanoid and Humanoid.Health > 0 then
			HumanoidRootPart.CFrame = Mob:GetPivot()
			task.wait(1)
			local Head = Mob:FindFirstChild("Head")
			if Head then 
				Head:Destroy()
			end 
			repeat task.wait() until Humanoid.Health <= 0 
			Mob:Destroy()
			repeat task.wait() until FindFirstChest()
			repeat 
				local Chest = FindFirstChest()
				local ProximityPrompt = Chest and Chest:FindFirstChild("Collect")
				if ProximityPrompt then 
					HumanoidRootPart.CFrame = Chest:GetPivot()
					fireproximityprompt(ProximityPrompt)
				elseif Chest then 
					Chest:Destroy()
				end 
				task.wait()
			until not FindFirstChest()
		end 
	end 
	task.wait()
end 
