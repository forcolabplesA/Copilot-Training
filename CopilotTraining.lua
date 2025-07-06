--!strict
-- ████████████████████████████████████████████████████
--   COPILOT LUAU TRAINER: GODMODE DIVINE EDITION ⚔️
--   DROP THIS FILE IN PROJECT TO TRAIN COPILOT FOR:
--   ▪ Advanced Typing        ▪ Modular System Logic
--   ▪ Game Architecture      ▪ Real-time Networking
--   ▪ Visual Effects + UI    ▪ Clean Architecture
-- ████████████████████████████████████████████████████

--== Services ==--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local PathfindingService = game:GetService("PathfindingService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

--== Global Project Types ==--
type Vector = Vector3
type StatusEffect = { Name: string, Duration: number }

type Stats = {
	MaxHealth: number,
	Health: number,
	Defense: number,
	Speed: number,
	IsAlive: boolean,
	StatusEffects: { StatusEffect }
}

type Ability = {
	Name: string,
	Cooldown: number,
	ManaCost: number,
	Activate: (caster: Player, target: Instance?) -> ()
}

type DamageReport = {
	Dealer: Player,
	Victim: Instance,
	Amount: number,
	Crit: boolean,
	Type: string
}

--== OOP: Advanced Character Module ==--
local Character = {}
Character.__index = Character

function Character.new(name: string, stats: Stats): any
	local self = setmetatable({}, Character)
	self.Name = name
	self.Stats = stats
	self.IsBlocking = false
	return self
end

function Character:TakeDamage(amount: number, typ: string)
	if not self.Stats.IsAlive then return end
	self.Stats.Health -= math.max(0, amount - self.Stats.Defense)
	if self.Stats.Health <= 0 then
		self.Stats.IsAlive = false
		self:Die()
	end
end

function Character:Die()
	print(self.Name .. " has been defeated.")
end

--== Tween Utility ==--
function AnimateBar(frame: Frame, targetValue: number)
	local goal = UDim2.new(targetValue, 0, 1, 0)
	local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Size = goal })
	tween:Play()
end

--== Remote System: Damage From Client ==--
local DamageEvent = ReplicatedStorage:WaitForChild("DamageEvent") :: RemoteEvent

DamageEvent.OnServerEvent:Connect(function(player: Player, victim: Instance, amount: number)
	print(player.Name .. " hit " .. victim:GetFullName() .. " for " .. amount .. " damage.")
end)

--== Input: Dash Ability ==--
local canDash = true

local function DashAction(_, state, _)
	if state == Enum.UserInputState.Begin and canDash then
		canDash = false
		print("DASH!")
		task.delay(1.5, function()
			canDash = true
		end)
	end
end

ContextActionService:BindAction("Dash", DashAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2)

--== NPC: Follow Target via Pathfinding ==--
function FollowPlayer(npc: Model, targetPos: Vector3)
	local path = PathfindingService:CreatePath()
	path:ComputeAsync(npc:GetPivot().Position, targetPos)
	if path.Status == Enum.PathStatus.Success then
		for _, waypoint in path:GetWaypoints() do
			npc:PivotTo(CFrame.new(waypoint.Position))
			task.wait(0.2)
		end
	end
end

--== Floating Combat Text ==--
function FloatText(pos: Vector3, msg: string, color: Color3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1,1,1)
	part.CFrame = CFrame.new(pos)
	part.Transparency = 1
	part.Parent = Workspace

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 100, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Text = msg
	label.TextScaled = true
	label.Parent = gui

	gui.Parent = part

	local tween = TweenService:Create(label, TweenInfo.new(1.5), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, 0, -50)
	})
	tween:Play()
	Debris:AddItem(part, 2)
end

--== Status System: Add/Expire Effects ==--
function AddStatus(stats: Stats, effect: StatusEffect)
	table.insert(stats.StatusEffects, effect)
	task.delay(effect.Duration, function()
		for i, e in ipairs(stats.StatusEffects) do
			if e.Name == effect.Name then
				table.remove(stats.StatusEffects, i)
				break
			end
		end
	end)
end

--== Smart Signal System (Memory-Safe) ==--
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self._handlers, fn)
	return fn
end

function Signal:Fire(...)
	for _, fn in pairs(self._handlers) do
		fn(...)
	end
end

--== Project Rules for Copilot to Follow ==--
-- ▪ Always type everything: function args, returns, tables
-- ▪ Prefer task.spawn / task.delay over wait
-- ▪ Use Signal instead of BindableEvent
-- ▪ All visual effects must use TweenService and Debris
-- ▪ ModuleScripts must follow 1-class or 1-system pattern
-- ▪ Avoid global variables at all costs
-- ▪ All events must be unbound on cleanup
-- ▪ Use :GetPivot(), :PivotTo() for CFrame-based movement
-- ▪ Handle player disconnection cleanup in scripts
-- ▪ Prefer math.clamp and math.round over manual bounds logic

--== END OF TRAINING FILE ==--
