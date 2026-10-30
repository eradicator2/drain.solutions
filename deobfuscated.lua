local Source = {}

Source.GetCachedFrameValue = function(Bindings)
	local TimeSlot = Bindings[1]
	local ValueSlot = Bindings[2]
	local UpdateValue = Bindings[3]
	return function()
		local Now = os.clock()
		if Now - TimeSlot[4][TimeSlot[6]] < 1 / 240 then
			return ValueSlot[4][ValueSlot[6]]
		end
		local Value = UpdateValue()
		ValueSlot[4][ValueSlot[6]] = Value
		TimeSlot[4][TimeSlot[6]] = Now
		return Value
	end
end

Source.HandleFallDamageRemote = function(Bindings)
	local FallRemote = Bindings[1]
	local Settings = Bindings[2]
	local OriginalNamecall = Bindings[3]
	return function(Remote, ...)
		if getnamecallmethod() == "FireServer" and Remote == FallRemote then
			if Settings.NoFallDamage and Settings.NoFallDamageMethod == "Block Remote" then
				local FirstArgument = select(1, ...)
				if FirstArgument == "FlllD" or FirstArgument == "FllH" then
					return
				end
			end
		end
		return OriginalNamecall[4][OriginalNamecall[6]](Remote, ...)
	end
end

Source.SelectTarget = function(Bindings, I, I)
	local I = Bindings[1]
	local U = Bindings[2]
	local M = Bindings[3]
	local x = Bindings[4]
	local V = Bindings[5]
	local K = Bindings[6]
	local m = Bindings[7]
	local D = Bindings[8]
	local n = Bindings[9]
	local e = Bindings[10]
	return function()
		local u, F = {}
		local F = I
		local I = F()
		local a
		F = U
		local a, L = F.priority_Only, U
		local Q, B = L.fov_Limit, U
		local T, G = B.target_Selection
		F = M
		B = F()
		local M
		L = x
		F = L.Character
		L = F and (F:FindFirstChild("HumanoidRootPart"))
		if not L then
			return u
		end
		F = U
		local M, x = F.locked_Target
		if I then
			if M then
				F = M.Parent
				if F then
					local x = V
					local G = x(M) ~= "Enemy"
					if G then
						x = U
						x.locked_Target = nil
						M = nil
					else
						local x
						local x = K
						local K = x(M)
						if K then
						else
							x = U
							x.locked_Target = nil
							M = nil
						end
					end
				else
					local x = U
					x.locked_Target = nil
					M = nil
				end
			else
			end
		else
			local x = U
			x.locked_Target = nil
			M = nil
		end
		local x, K = ipairs
		F = m
		local K = y[58](F:GetPlayers())
		for m, G in x(y:t5(K)) do
			F = V
			m = F(G)
			if a then
				if m ~= "Enemy" then
					continue
				end
			end
			local y
			local y = D
			local x, V = y(G)
			if x then
				if V then
					local D, F = x:FindFirstChild("Head") or V
					local F, a = n[4][n[6]]:WorldToViewportPoint(D.Position)
					local n, c, C =
						a and (Vector2.new(F.X, F.Y) - B).Magnitude or math.huge,
						(V.Position - L.Position).Magnitude,
						x:FindFirstChildOfClass("Humanoid")
					y, D = C and C.Health or math.huge, U
					if c > D.max_Distance then
						continue
					end
					F = if T == "Distance" then c else if T == "Lowest HP" then y else n
					if Q then
						if not a then
							continue
						end
						C = U
						if n > C.fov_Radius then
							continue
						end
					end
					u[#u + 1] = {
						Player = G,
						Character = x,
						Root = V,
						Distance = F,
						SelectionValue = F,
						ScreenDistance = n,
						WorldDistance = c,
						Health = y,
						OnScreen = a,
						Priority = m == "Enemy" and 0 or 1,
						Locked = G == M,
					}
				end
			end
		end
		table.sort(u, function(y, M)
			if y.Priority ~= M.Priority then
				return y.Priority < M.Priority
			end
			if y.SelectionValue ~= M.SelectionValue then
				return y.SelectionValue < M.SelectionValue
			end
			if y.Locked ~= M.Locked then
				return y.Locked
			end
			if y.WorldDistance ~= M.WorldDistance then
				return y.WorldDistance < M.WorldDistance
			end
			if y.ScreenDistance ~= M.ScreenDistance then
				return y.ScreenDistance < M.ScreenDistance
			end
			return y.Player.UserId < M.Player.UserId
		end)
		local y
		L = e
		L:ApplyStickiness(u)
		if I then
			B = U
			B.locked_Target = nil
			K = ipairs
			for y, y in K(u) do
				Q = y.Priority == 0
				if Q then
					T = U
					T.locked_Target = y.Player
					break
				end
			end
		end
		return u
	end
end

Source.GetPlayerPriority = function(Bindings)
	local PlayerListSlot = Bindings[1]
	return function(Player)
		local Panel = PlayerListSlot[4][PlayerListSlot[6]]
		local Entry = Panel and Panel.Players and Panel.Players[Player.Name]
		if Entry and Entry.Priority then
			return Entry.Priority.Text
		end
		return "Neutral"
	end
end

Source.IsTargetValid = function(Bindings)
	local LocalPlayer = Bindings[1]
	local GetPriority = Bindings[2]
	local Settings = Bindings[3]
	local IsDowned = Bindings[4]
	return function(Player)
		if not Player or Player == LocalPlayer then
			return false
		end
		local Priority = GetPriority(Player)
		if Priority == "Friendly" or Settings.priority_Only and Priority ~= "Enemy" then
			return false
		end
		local Character = Player.Character
		if not Character then
			return false
		end
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if not Humanoid or not RootPart then
			return false
		end
		if Settings.check_Dead and Humanoid.Health <= 0 then
			return false
		end
		if Settings.check_ForceField and Character:FindFirstChildOfClass("ForceField") then
			return false
		end
		if Settings.check_Downed and IsDowned(Player) then
			return false
		end
		if Settings.check_Team and LocalPlayer.Team ~= nil and Player.Team == LocalPlayer.Team then
			return false
		end
		return true
	end
end

Source.UpdateVisualEffects = function(Bindings)
	local State = Bindings[1]
	local ClearEffects = Bindings[2]
	local RemoveEffect = Bindings[3]
	local FadeCurve = Bindings[4]
	return function()
		if not State.Enabled then
			ClearEffects()
			return
		end
		local Now = os.clock()
		local Duration = math.max(State.Duration, 0.05)
		for Index = #State.Effects, 1, -1 do
			local Effect = State.Effects[Index]
			local Elapsed = Now - Effect.CreatedAt
			if Elapsed >= Duration then
				RemoveEffect(Effect)
				table.remove(State.Effects, Index)
			else
				local Transparency = State.Transparency
				if State.Fade and Elapsed >= State.FadeDelay then
					local FadeDuration = math.max(Duration - State.FadeDelay, 0.01)
					local FadeAmount = FadeCurve((Elapsed - State.FadeDelay) / FadeDuration)
					Transparency = State.Transparency + (1 - State.Transparency) * FadeAmount
				end
				for _, Adornment in ipairs(Effect.Adornments) do
					if Adornment.Parent then
						Adornment.Color3 = State.Color
						Adornment.Transparency = math.clamp(Transparency, 0, 1)
					end
				end
			end
		end
	end
end

Source.CreateSensoryESP = function(Bindings)
	local I = Bindings[1]
	local U = Bindings[2]
	local M = Bindings[3]
	return function()
		local u = game:GetService("UserInputService")
		local x = game:GetService("RunService")
		local V = game:GetService("Players")
		local K = game:GetService("CoreGui")
		local m = game:GetService("Workspace")
		local D = game:GetService("ReplicatedStorage")
		local n = game:GetService("HttpService")
		local e = V.LocalPlayer
		local F = m.CurrentCamera
		local a, L, Q, B, T, G, c, C, b, E = gethui and gethui() or K, V, {}
		local t, N, _ = {}, false, false
		local v = n:GenerateGUID(false)
		if getgenv().SensoryESP_Unload then
			pcall(getgenv().SensoryESP_Unload)
		end
		local r = a:FindFirstChild("SensoryESP_Chams") or m:FindFirstChild("SensoryESP_Chams")
		if r then
			pcall(function()
				r:Destroy()
			end)
		end
		local r = m:FindFirstChild("SensoryESP_MeshChams")
		if r then
			pcall(function()
				r:Destroy()
			end)
		end
		local function r(d)
			if not d then
				return false
			end
			if d:GetAttribute("SensoryESP_MeshCham") == true then
				return true
			end
			if d:IsA("Model") then
				if d.Name == "ChamShells" then
					return true
				end
			end
			if d:IsA("BasePart") then
				if d.Name:match("^ChamShell_") then
					return true
				end
			end
			if d:IsA("Highlight") then
				if d.Name == "ChamShellHighlight" then
					return true
				end
			end
			return false
		end
		local function d(p)
			if not p then
				return
			end
			for O, O in ipairs(p:GetDescendants()) do
				if r(O) then
					pcall(function()
						O:Destroy()
					end)
				end
			end
		end
		local function p(O)
			if not O then
				return
			end
			for q, q in ipairs(O:GetChildren()) do
				if r(q) then
					pcall(function()
						q:Destroy()
					end)
				end
			end
		end
		d(m)
		for r, r in ipairs(L:GetPlayers()) do
			p(r.Character)
		end
		local function r()
			local O = if B then not B.Parent else not B
			if O then
				B = Instance.new("Folder")
				B.Name = "SensoryESP_Chams"
				local q
				local q, h = B, I
				q.Parent = I.IsMobile and m or a
			end
			O = if T then not T.Parent else not T
			if O then
				T = Instance.new("Folder")
				T.Name = "SensoryESP_MeshChams"
				T.Parent = m
			end
			O = if G then not G.Parent else not G
			if O then
				G = Instance.new("ScreenGui")
				G.Name = "SensoryESP"
				G.ResetOnSpawn = false
				G.IgnoreGuiInset = true
				local a = G
				a.ZIndexBehavior = Enum.ZIndexBehavior.Global
				getgenv().SensoryESP_UI = G
				a = pcall(function()
					G.Parent = K
				end)
				if not a then
					local K = e:FindFirstChildOfClass("PlayerGui") or e:WaitForChild("PlayerGui", 10)
					if K then
						pcall(function()
							G.Parent = K
						end)
					end
				end
			end
		end
		local K, a = setmetatable, { __mode = "k" }
		local O, q, h, W, g, S, l, J, o, R, Y, P = K({}, a), 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
		local H, X, z, A, i, j, f = -1, 0, 0, 1, 0, 0, 0
		local function Z(s)
			local k = s.CFrame
			local w = k.Position
			local yq, uq, Iq = w.X, w.Y, w.Z
			q, h, W = yq, uq, Iq
			Iq = k.RightVector
			yq, w, uq = Iq.X, Iq.Y, Iq.Z
			g, S, l = yq, w, uq
			w = k.UpVector
			yq, uq, Iq = w.X, w.Y, w.Z
			J, o, R = yq, uq, Iq
			Iq = k.LookVector
			yq, uq, w = Iq.X, Iq.Y, Iq.Z
			Y, P, H = yq, uq, w
			yq = s.ViewportSize
			k, Iq = yq.X, yq.Y
			i, j = k, Iq
			uq, w = yq.X * 0.5, yq.Y * 0.5
			X, z = uq, w
			k = z
			A = k / math.tan(math.rad(s.FieldOfView) * 0.5)
		end
		local function s(k)
			local w, yq, uq = k.X - q, k.Y - h, k.Z - W
			k = w * Y + yq * P + uq * H
			if k <= 0.05 then
				return 0, 0, k
			end
			local q, h = A / k, X
			local W, Y, P = h + (w * g + yq * S + uq * l) * q, z, (w * J + yq * o + uq * R) * q
			return W, Y - P, k
		end
		local function q(h)
			local W, g, S = s(h)
			h = S > 0 and W >= 0 and W <= i and g >= 0 and g <= j
			return W, g, h
		end
		local function h(W, g, S)
			if W then
				if W[g] ~= S then
					W[g] = S
				end
			end
		end
		local function W(g, S, l)
			local J = O[g] or g:FindFirstChildOfClass("UIStroke")
			if not J then
				return
			end
			g = S ~= "None"
			h(J, "Enabled", g)
			if g then
				h(J, "Thickness", 1)
				h(J, "Color", l or Color3.fromRGB(0, 0, 0))
			end
		end
		local function g(S, l, J, o, R, Y)
			local P = S.StyleCache[l]
			if P then
			else
				P = {}
				S.StyleCache[l] = P
			end
			if P.Color1 ~= o or P.Color2 ~= R or P.Color3 ~= Y then
				J.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, o),
					ColorSequenceKeypoint.new(0.5, R),
					ColorSequenceKeypoint.new(1, Y),
				})
				P.Color1 = o
				P.Color2 = R
				P.Color3 = Y
			end
		end
		local function S(l, J, o, R, Y)
			l.Position = UDim2.new(0, J, 0, o)
			l.Size = UDim2.new(0, R, 0, Y)
		end
		local function l(J, o, R, Y, P, H, A, i, j, k, w, yq, uq)
			local Iq = J.FlagLabels[o]
			if not Iq then
				return
			end
			h(Iq, "Visible", true)
			h(Iq, "Text", R)
			h(Iq, "TextColor3", Y)
			h(Iq, "Font", P)
			if H then
				h(Iq, "FontFace", H)
			end
			h(Iq, "TextSize", A)
			h(Iq, "TextXAlignment", i and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right)
			Iq.Position = UDim2.new(0, j, 0, k + (o - 1) * (A + w))
			W(Iq, yq, uq)
		end
		local J = {
			Enabled = false,
			Keybind = { Enabled = false, Key = Enum.KeyCode.Insert },
			Players = false,
			OnlyEnemies = false,
			LocalPlayer = false,
			LimitFPS = 0,
			MaxDistance = 0,
			DynamicBoxes = true,
			DynamicBoxesCheap = true,
			DynamicBoxesIncludeAll = false,
			Boxes = false,
			BoxType = "Normal",
			BoxColor = Color3.fromRGB(255, 255, 255),
			BoxThickness = 1,
			Outlines = { Style = "Full", Color = Color3.fromRGB(0, 0, 0), Thickness = 1 },
			BoxFill = {
				Enabled = false,
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.9,
				Gradient = {
					Enabled = false,
					Color1 = Color3.fromRGB(180, 255, 255),
					Color2 = Color3.fromRGB(0, 255, 255),
					Color3 = Color3.fromRGB(0, 120, 255),
					Rotation = 0,
					Animated = false,
					Speed = 64,
					Direction = "Right",
				},
			},
			HealthBar = {
				Enabled = false,
				Position = "Left",
				SideGap = 2,
				Width = 2,
				ShowText = false,
				TextFollowBar = false,
				HideWhenFullHP = false,
				FollowGradientColorText = false,
				Font = "Smallest Pixel-7",
				TextSize = 9,
				Outline = { Style = "Full", Color = Color3.fromRGB(0, 0, 0) },
				Gradient = {
					Enabled = false,
					Color1 = Color3.fromRGB(0, 255, 0),
					Color2 = Color3.fromRGB(255, 255, 0),
					Color3 = Color3.fromRGB(255, 0, 0),
				},
			},
			ArmorBar = {
				Enabled = false,
				Position = "Right",
				SideGap = 2,
				Width = 2,
				ShowText = false,
				TextFollowBar = false,
				HideWhenFullArmor = false,
				FollowGradientColorText = false,
				Font = "Smallest Pixel-7",
				TextSize = 9,
				Outline = { Style = "Full", Color = Color3.fromRGB(0, 0, 0) },
				Gradient = {
					Enabled = false,
					Color1 = Color3.fromRGB(90, 190, 255),
					Color2 = Color3.fromRGB(45, 125, 235),
					Color3 = Color3.fromRGB(20, 65, 160),
				},
			},
			DrawingMode = false,
			Names = false,
			TextSize = 12,
			TextColor = Color3.fromRGB(255, 255, 255),
			TextOutline = false,
			TextOutlineStyle = "Full",
			TextGap = 3,
			Font = "Proggy Clean",
			PlayerStatusColors = { Target = Color3.fromRGB(255, 220, 0), Friendly = Color3.fromRGB(0, 255, 0) },
			TeamIndicator = {
				Enabled = false,
				Position = "Right",
				UseTeamColor = false,
				Color = Color3.fromRGB(255, 255, 255),
				Compact = false,
				TextSize = 10,
			},
			FriendlyIndicator = {
				Enabled = false,
				Position = "Right",
				CheckTeam = false,
				CheckFriends = false,
				Text = "[F]",
				Color = Color3.fromRGB(0, 255, 0),
			},
			Weapon = {
				Enabled = false,
				Gap = 1,
				OutlineStyle = "Full",
				Font = "Proggy Clean",
				TextSize = 12,
				Color = Color3.fromRGB(255, 255, 255),
				InventoryPath = "ReplicatedStorage.Players.%NAME%.Inventory",
				UseToolFallback = false,
			},
			Flags = {
				Enabled = false,
				Position = "Right",
				Gap = 2,
				SideGap = 4,
				TextGap = 2,
				OutlineStyle = "Full",
				Font = "Smallest Pixel-7",
				TextSize = 9,
				Options = {
					Idle = false,
					Moving = false,
					Jumping = false,
					Swimming = false,
					ForceField = false,
					Downed = false,
					Exploiting = false,
				},
				Colors = {
					Idle = Color3.fromRGB(255, 255, 255),
					Moving = Color3.fromRGB(255, 255, 255),
					Jumping = Color3.fromRGB(255, 255, 255),
					Swimming = Color3.fromRGB(65, 65, 255),
					ForceField = Color3.fromRGB(0, 140, 255),
					Downed = Color3.fromRGB(255, 80, 80),
					Exploiting = Color3.fromRGB(255, 45, 45),
				},
			},
			Skeleton = {
				Enabled = false,
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1.5,
				Joints = true,
				JointScale = 1,
				Outline = false,
				OutlineColor = Color3.fromRGB(0, 0, 0),
				Gradient = {
					Enabled = false,
					Color1 = Color3.fromRGB(255, 255, 255),
					Color2 = Color3.fromRGB(100, 200, 255),
				},
			},
			OffScreenArrows = {
				Enabled = false,
				Size = 14,
				Color = Color3.fromRGB(255, 255, 255),
				OrbitRadius = 100,
				ArrowMode = "Camera",
				Outline = false,
				OutlineColor = Color3.fromRGB(0, 0, 0),
				Names = {
					Enabled = false,
					Font = "Smallest Pixel-7",
					TextSize = 9,
					Color = Color3.fromRGB(255, 255, 255),
					Outline = true,
					OutlineColor = Color3.fromRGB(0, 0, 0),
					Side = "Bottom",
					Gap = 4,
				},
				Distance = {
					Enabled = false,
					Font = "Smallest Pixel-7",
					TextSize = 9,
					Color = Color3.fromRGB(255, 255, 255),
					Outline = false,
					OutlineColor = Color3.fromRGB(0, 0, 0),
					Side = "Bottom",
					Gap = 2,
				},
			},
			Distance = {
				Enabled = false,
				Unit = "Meters",
				StudsPerMeter = 3,
				Ending = "m",
				Gap = 3,
				OutlineStyle = "Full",
				Font = "Proggy Clean",
				TextSize = 12,
				Color = Color3.fromRGB(255, 255, 255),
			},
			Chams = {
				Enabled = false,
				Type = "Highlight",
				RefreshRate = 0.1,
				Highlight = {
					FillColor = Color3.fromRGB(255, 255, 255),
					FillTransparency = 1,
					OutlineColor = Color3.fromRGB(255, 255, 255),
					OutlineTransparency = 0,
					VisibleCheck = false,
				},
				Adornment = {
					VisibleSize = 0.1,
					RoundHead = false,
					R6HeadScale = 0.86,
					Glow = {
						Enabled = false,
						Color = Color3.fromRGB(59, 144, 204),
						Intensity = 5,
						Size = 0.03,
						FallbackTransparency = 0.72,
					},
					Invisible = {
						Color = Color3.fromRGB(59, 144, 204),
						Transparency = 0.7,
						Highlight = {
							Enabled = false,
							FillColor = Color3.fromRGB(59, 144, 204),
							FillTransparency = 1,
							OutlineColor = Color3.fromRGB(59, 144, 204),
							OutlineTransparency = 0,
						},
					},
					Visible = {
						Enabled = true,
						Color = Color3.fromRGB(59, 204, 90),
						Transparency = 0.35,
						Highlight = {
							Enabled = false,
							FillColor = Color3.fromRGB(59, 204, 90),
							FillTransparency = 1,
							OutlineColor = Color3.fromRGB(59, 204, 90),
							OutlineTransparency = 0,
						},
					},
				},
				CharacterClone = {
					Color = Color3.fromRGB(190, 195, 205),
					Transparency = 0.55,
					Material = "SmoothPlastic",
					KeepTextures = false,
					IncludeAccessories = true,
					SizeScale = 1.015,
					Highlight = {
						Enabled = true,
						FillColor = Color3.fromRGB(190, 195, 205),
						FillTransparency = 0.75,
						OutlineColor = Color3.fromRGB(255, 255, 255),
						OutlineTransparency = 0.25,
						VisibleCheck = false,
					},
				},
				MeshChams = {
					FillColor = Color3.fromRGB(59, 144, 204),
					FillTransparency = 0.6,
					OutlineColor = Color3.fromRGB(255, 255, 255),
					OutlineTransparency = 0,
					VisibleCheck = false,
				},
			},
			Directories = {},
		}
		local function o(R)
			if type(R) ~= "table" then
				return R
			end
			local Y = {}
			for P, H in pairs(R) do
				Y[P] = o(H)
			end
			return Y
		end
		local function R(Y, P)
			if type(P) ~= "table" then
				return Y
			end
			for H, A in pairs(P) do
				if type(A) == "table" then
					if type(Y[H]) == "table" then
						R(Y[H], A)
					else
						Y[H] = A
					end
				else
					Y[H] = A
				end
			end
			return Y
		end
		local Y, P, H, A, i = o(J), {}, {}, 0, {}
		local function j()
			A += 1
			table.clear(i)
		end
		local k
		K = U
		K.DrainESPConfigDirty = j
		local function K(k)
			local w = P[k]
			if w then
			else
				w = string.split(k, ".")
				P[k] = w
			end
			return w
		end
		local function P(k, w)
			local yq, uq, Iq = K(w), k, true
			for K, K in ipairs(yq) do
				if type(uq) == "table" and uq[K] ~= nil then
					uq = uq[K]
				else
					Iq = false
					break
				end
			end
			if Iq then
				return uq
			end
			k = i[w]
			if k ~= nil then
				if k == H then
					return nil
				end
				return k
			end
			uq = J
			for K, K in ipairs(yq) do
				uq = uq[K]
			end
			i[w] = uq == nil and H or uq
			return uq
		end
		local function K(i, k, w, yq, uq)
			if P(i, "Names") then
				return true
			end
			if k then
				return false
			end
			if P(i, "Boxes") then
				return true
			elseif P(i, "Distance.Enabled") then
				return true
			elseif P(i, "Weapon.Enabled") then
				return true
			end
			k = w:IsA("Model") and (uq and uq.Humanoid or w:FindFirstChild("Humanoid")) ~= nil
			if k then
				if P(i, "HealthBar.Enabled") then
					return true
				elseif P(i, "ArmorBar.Enabled") then
					return true
				end
			end
			if k then
				if not yq then
					if P(i, "Flags.Enabled") then
						return P(i, "Flags.Options.Idle")
							or P(i, "Flags.Options.Moving")
							or P(i, "Flags.Options.Jumping")
							or P(i, "Flags.Options.Swimming")
							or P(i, "Flags.Options.ForceField")
							or P(i, "Flags.Options.Downed")
							or P(i, "Flags.Options.Exploiting")
					end
				end
			end
			return false
		end
		local function i(k, w)
			return w and P(k, "Names")
				or P(k, "Distance.Enabled")
				or P(k, "OffScreenArrows.Enabled") and P(k, "OffScreenArrows.Distance.Enabled")
		end
		local k = {}
		local function w(yq)
			if type(yq) ~= "string" then
				return ""
			elseif yq == "" then
				return ""
			end
			local uq = k[yq]
			if uq then
				return uq
			end
			local Iq = {}
			for Uq in yq:gmatch("[^%s%-_]+") do
				if Uq ~= "" then
					table.insert(Iq, Uq)
				end
			end
			if #Iq == 0 then
				return yq
			end
			if #Iq == 1 then
				local Uq = Iq[1]
				if #Uq <= 4 then
					uq = Uq:upper()
					k[yq] = uq
					return uq
				end
				uq = Uq:sub(1, 1):upper()
				k[yq] = uq
				return uq
			end
			local Uq = {}
			for Mq, Mq in ipairs(Iq) do
				table.insert(Uq, Mq:sub(1, 1):upper())
			end
			uq = table.concat(Uq)
			k[yq] = uq
			return uq
		end
		local function k(yq)
			local uq, Iq, Uq =
				math.clamp(math.floor(yq.R * 255 + 0.5), 0, 255),
				math.clamp(math.floor(yq.G * 255 + 0.5), 0, 255),
				math.clamp(math.floor(yq.B * 255 + 0.5), 0, 255)
			return string.format("#%02X%02X%02X", uq, Iq, Uq)
		end
		local yq, uq, Iq, Uq, Mq =
			{
				["Proggy Clean"] = Enum.Font.SourceSans,
				["Smallest Pixel-7"] = Enum.Font.SourceSans,
				Tahoma = Enum.Font.SourceSans,
				Minecraftia = Enum.Font.SourceSans,
				["Tahoma Modern Bold"] = Enum.Font.SourceSansBold,
			}, {
				Tahoma = { TTF = "https://github.com/LuckyHub1/LuckyHub/raw/main/zekton_rg.ttf" },
				Minecraftia = { TTF = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Minecraftia.ttf" },
				["Smallest Pixel-7"] = {
					TTF = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/smallest_pixel-7.ttf",
				},
				["Proggy Clean"] = { TTF = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf" },
				["Tahoma Modern Bold"] = {
					TTF = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Tahoma-Modern-Bold.ttf",
				},
			}, { Loaded = {} }, true, U
		Mq.DrainESPFontFaces = Iq.Loaded
		a = U
		a.DrainESPFontMap = yq
		local U, Mq =
			{
				{ "Head", "Neck" },
				{ "Neck", "LeftShoulder" },
				{ "LeftShoulder", "LeftElbow" },
				{ "LeftElbow", "LeftHand" },
				{ "Neck", "RightShoulder" },
				{ "RightShoulder", "RightElbow" },
				{ "RightElbow", "RightHand" },
				{ "Neck", "Chest" },
				{ "Chest", "Pelvis" },
				{ "Pelvis", "LeftHip" },
				{ "LeftHip", "LeftKnee" },
				{ "LeftKnee", "LeftFoot" },
				{ "Pelvis", "RightHip" },
				{ "RightHip", "RightKnee" },
				{ "RightKnee", "RightFoot" },
			}, {
				"Neck",
				"LeftShoulder",
				"LeftElbow",
				"RightShoulder",
				"RightElbow",
				"Chest",
				"Pelvis",
				"LeftHip",
				"LeftKnee",
				"RightHip",
				"RightKnee",
			}
		local function xq(Vq, ...)
			for Kq = 1, select("#", ...), 1 do
				local mq = Vq:FindFirstChild((select(Kq, ...)))
				if mq then
					if mq:IsA("BasePart") then
						return mq
					end
				end
			end
			return nil
		end
		local function Vq(Kq, ...)
			if not Kq then
				return nil
			end
			for mq = 1, select("#", ...), 1 do
				local Dq = Kq:FindFirstChild((select(mq, ...)))
				if Dq then
					if Dq:IsA("Attachment") then
						return Dq.WorldPosition
					end
				end
			end
			return nil
		end
		local function Kq(mq, Dq)
			if not mq then
				return nil
			end
			return (mq.CFrame * CFrame.new(0, mq.Size.Y * 0.5 * Dq, 0)).Position
		end
		local function mq(Dq)
			if Dq then
				if not Dq.Parent then
					return nil
				end
			else
				return nil
			end
			local nq = Dq:FindFirstChildOfClass("Humanoid")
			if not nq then
				return nil
			end
			if nq.RigType == Enum.HumanoidRigType.R6 then
				local eq, Fq, aq, Lq, Qq, Bq =
					xq(Dq, "Torso", "UpperTorso", "LowerTorso"),
					xq(Dq, "Head"),
					xq(Dq, "Left Arm", "LeftArm"),
					xq(Dq, "Right Arm", "RightArm"),
					xq(Dq, "Left Leg", "LeftLeg"),
					xq(Dq, "Right Leg", "RightLeg")
				if not eq then
					return nil
				end
				local Tq, Gq =
					Kq(aq, 1) or (eq.CFrame * CFrame.new(-eq.Size.X * 0.5, eq.Size.Y * 0.25, 0)).Position,
					Kq(Lq, 1) or (eq.CFrame * CFrame.new(eq.Size.X * 0.5, eq.Size.Y * 0.25, 0)).Position
				local cq, Cq = Kq(aq, -1) or Tq, Kq(Lq, -1) or Gq
				local bq, Eq, tq, Nq, _q, vq =
					aq and aq.Position or (Tq + cq) * 0.5,
					Lq and Lq.Position or (Gq + Cq) * 0.5,
					Kq(Qq, 1) or (eq.CFrame * CFrame.new(-eq.Size.X * 0.25, -eq.Size.Y * 0.5, 0)).Position,
					Kq(Bq, 1) or (eq.CFrame * CFrame.new(eq.Size.X * 0.25, -eq.Size.Y * 0.5, 0)).Position,
					Kq(Qq, -1) or (eq.CFrame * CFrame.new(-0.5, -eq.Size.Y * 1.5, 0)).Position,
					Kq(Bq, -1) or (eq.CFrame * CFrame.new(0.5, -eq.Size.Y * 1.5, 0)).Position
				local aq, Lq, rq, dq =
					Qq and Qq.Position or (tq + _q) * 0.5,
					Bq and Bq.Position or (Nq + vq) * 0.5,
					(tq + Nq) * 0.5,
					Vq(eq, "NeckAttachment", "NeckRigAttachment")
						or (eq.CFrame * CFrame.new(0, eq.Size.Y * 0.5, 0)).Position
				return {
					Head = Fq and Fq.Position or dq + eq.CFrame.UpVector * 0.65,
					Neck = dq,
					LeftShoulder = Tq,
					RightShoulder = Gq,
					LeftElbow = bq,
					RightElbow = Eq,
					LeftHand = cq,
					RightHand = Cq,
					Chest = (dq + rq) * 0.5,
					Pelvis = rq,
					LeftHip = tq,
					RightHip = Nq,
					LeftKnee = aq,
					RightKnee = Lq,
					LeftFoot = _q,
					RightFoot = vq,
				}
			end
			local eq, Fq, aq, Lq, Qq, Bq, Tq, Gq, cq, Cq, bq, Eq, tq, Nq, _q =
				xq(Dq, "Head"),
				xq(Dq, "UpperTorso", "Torso"),
				xq(Dq, "LowerTorso", "Torso", "HumanoidRootPart"),
				xq(Dq, "LeftUpperArm", "Left Arm", "LeftArm"),
				xq(Dq, "RightUpperArm", "Right Arm", "RightArm"),
				xq(Dq, "LeftLowerArm", "LeftUpperArm", "Left Arm", "LeftArm"),
				xq(Dq, "RightLowerArm", "RightUpperArm", "Right Arm", "RightArm"),
				xq(Dq, "LeftHand"),
				xq(Dq, "RightHand"),
				xq(Dq, "LeftUpperLeg", "Left Leg", "LeftLeg"),
				xq(Dq, "RightUpperLeg", "Right Leg", "RightLeg"),
				xq(Dq, "LeftLowerLeg", "LeftUpperLeg", "Left Leg", "LeftLeg"),
				xq(Dq, "RightLowerLeg", "RightUpperLeg", "Right Leg", "RightLeg"),
				xq(Dq, "LeftFoot"),
				xq(Dq, "RightFoot")
			if Fq then
				if not aq then
					return nil
				end
			else
				return nil
			end
			local xq, vq, rq, dq =
				Vq(Fq, "LeftShoulderRigAttachment") or Vq(Lq, "LeftShoulderRigAttachment") or Lq and Kq(Lq, 1) or (
					Fq.CFrame * CFrame.new(-Fq.Size.X * 0.5, Fq.Size.Y * 0.2, 0)
				).Position,
				Vq(Fq, "RightShoulderRigAttachment") or Vq(Qq, "RightShoulderRigAttachment") or Qq and Kq(Qq, 1) or (
					Fq.CFrame * CFrame.new(Fq.Size.X * 0.5, Fq.Size.Y * 0.2, 0)
				).Position,
				Vq(aq, "LeftHipRigAttachment") or Vq(Cq, "LeftHipRigAttachment") or Cq and Kq(Cq, 1) or (
					aq.CFrame * CFrame.new(-aq.Size.X * 0.25, -aq.Size.Y * 0.35, 0)
				).Position,
				Vq(aq, "RightHipRigAttachment") or Vq(bq, "RightHipRigAttachment") or bq and Kq(bq, 1) or (
					aq.CFrame * CFrame.new(aq.Size.X * 0.25, -aq.Size.Y * 0.35, 0)
				).Position
			Dq, nq =
				(rq + dq) * 0.5,
				Vq(Fq, "NeckRigAttachment", "NeckAttachment") or Vq(eq, "NeckRigAttachment", "NeckAttachment") or (
					Fq.CFrame * CFrame.new(0, Fq.Size.Y * 0.5, 0)
				).Position
			local pq, Oq, qq =
				eq and eq.Position or nq + Fq.CFrame.UpVector * 0.6,
				Gq and Gq.Position or Kq(Bq, -1) or Kq(Lq, -1) or xq,
				cq and cq.Position or Kq(Tq, -1) or Kq(Qq, -1) or vq
			eq, Gq, aq, cq =
				Vq(Lq, "LeftElbowRigAttachment") or Vq(Bq, "LeftElbowRigAttachment") or Kq(Lq, -1) or (xq + Oq) * 0.5,
				Vq(Qq, "RightElbowRigAttachment") or Vq(Tq, "RightElbowRigAttachment") or Kq(Qq, -1) or (vq + qq) * 0.5,
				Nq and Nq.Position or Kq(Eq, -1) or Kq(Cq, -1) or rq,
				_q and _q.Position or Kq(tq, -1) or Kq(bq, -1) or dq
			Lq, Qq =
				Vq(Cq, "LeftKneeRigAttachment") or Vq(Eq, "LeftKneeRigAttachment") or Kq(Cq, -1) or (rq + aq) * 0.5,
				Vq(bq, "RightKneeRigAttachment") or Vq(tq, "RightKneeRigAttachment") or Kq(bq, -1) or (dq + cq) * 0.5
			return {
				Head = pq,
				Neck = nq,
				LeftShoulder = xq,
				RightShoulder = vq,
				LeftElbow = eq,
				RightElbow = Gq,
				LeftHand = Oq,
				RightHand = qq,
				Chest = Fq.Position,
				Pelvis = Dq,
				LeftHip = rq,
				RightHip = dq,
				LeftKnee = Lq,
				RightKnee = Qq,
				LeftFoot = aq,
				RightFoot = cq,
			}
		end
		local function xq(Vq)
			if Vq.Skeleton3DSegments then
				for Kq, Kq in ipairs(Vq.Skeleton3DSegments) do
					if Kq.Part then
						pcall(function()
							Kq.Part:Destroy()
						end)
					end
				end
			end
			if Vq.Skeleton3DJoints then
				for Kq, Kq in ipairs(Vq.Skeleton3DJoints) do
					if Kq.Part then
						pcall(function()
							Kq.Part:Destroy()
						end)
					end
				end
			end
			if Vq.Skeleton3DFolder then
				pcall(function()
					Vq.Skeleton3DFolder:Destroy()
				end)
			end
			Vq.Skeleton3DSegments = nil
			Vq.Skeleton3DJoints = nil
			Vq.Skeleton3DFolder = nil
			Vq.Skeleton3DRoot = nil
		end
		local function Vq(Kq, Dq)
			if Dq then
				if not Dq.Parent then
					xq(Kq)
					return nil
				end
			else
				xq(Kq)
				return nil
			end
			if
				Kq.Skeleton3DRoot ~= Dq
				or not Kq.Skeleton3DFolder
				or not Kq.Skeleton3DFolder.Parent
				or not Kq.Skeleton3DSegments
				or #Kq.Skeleton3DSegments ~= #U
				or not Kq.Skeleton3DJoints
				or #Kq.Skeleton3DJoints ~= #Mq
			then
				xq(Kq)
				local nq = Instance.new("Folder")
				nq.Name = "SensorySkeleton3D"
				nq.Parent = workspace
				local eq = {}
				for Fq = 1, #U, 1 do
					local aq = Instance.new("Part")
					aq.Name = "SensorySkeletonSegment"
					aq.Anchored = true
					aq.CanCollide = false
					aq.CanTouch = false
					aq.CanQuery = false
					aq.CastShadow = false
					aq.Transparency = 1
					aq.Size = Vector3.new(0.05, 0.05, 0.05)
					aq.CFrame = CFrame.new(Dq.Position)
					aq.Parent = nq
					local Lq = Instance.new("BoxHandleAdornment")
					Lq.Name = "SensorySkeletonOutline"
					Lq.Adornee = aq
					Lq.CFrame = CFrame.identity
					Lq.AlwaysOnTop = true
					Lq.ZIndex = 7
					Lq.Transparency = 0
					Lq.Visible = false
					Lq.Parent = aq
					local Qq = Instance.new("BoxHandleAdornment")
					Qq.Name = "SensorySkeleton"
					Qq.Adornee = aq
					Qq.CFrame = CFrame.identity
					Qq.AlwaysOnTop = true
					Qq.ZIndex = 8
					Qq.Transparency = 0
					Qq.Visible = false
					Qq.Parent = aq
					eq[Fq] = { Part = aq, Main = Qq, Outline = Lq }
				end
				local Fq = {}
				for aq = 1, #Mq, 1 do
					local Lq = Instance.new("Part")
					Lq.Name = "SensorySkeletonJoint"
					Lq.Anchored = true
					Lq.CanCollide = false
					Lq.CanTouch = false
					Lq.CanQuery = false
					Lq.CastShadow = false
					Lq.Transparency = 1
					Lq.Size = Vector3.new(0.03, 0.03, 0.03)
					Lq.CFrame = CFrame.new(Dq.Position)
					Lq.Parent = nq
					local Qq = Instance.new("SphereHandleAdornment")
					Qq.Name = "SensorySkeletonJointOutline"
					Qq.Adornee = Lq
					Qq.CFrame = CFrame.identity
					Qq.AlwaysOnTop = true
					Qq.ZIndex = 7
					Qq.Transparency = 0
					Qq.Radius = 0.03
					Qq.Visible = false
					Qq.Parent = Lq
					local Bq = Instance.new("SphereHandleAdornment")
					Bq.Name = "SensorySkeletonJoint"
					Bq.Adornee = Lq
					Bq.CFrame = CFrame.identity
					Bq.AlwaysOnTop = true
					Bq.ZIndex = 9
					Bq.Transparency = 0
					Bq.Radius = 0.02
					Bq.Visible = false
					Bq.Parent = Lq
					Fq[aq] = { Key = Mq[aq], Part = Lq, Main = Bq, Outline = Qq }
				end
				Kq.Skeleton3DFolder = nq
				Kq.Skeleton3DSegments = eq
				Kq.Skeleton3DJoints = Fq
				Kq.Skeleton3DRoot = Dq
			end
			return Kq.Skeleton3DSegments, Kq.Skeleton3DJoints
		end
		local function Mq(Kq, Dq)
			local nq = F
			if nq then
				if not Kq then
					return 0.045, 0.02
				end
			else
				return 0.045, 0.02
			end
			local eq, Fq = math.max((nq.CFrame.Position - Kq).Magnitude, 0.1), math.max(nq.ViewportSize.Y, 1)
			Kq = 2 * eq * math.tan(math.rad(nq.FieldOfView) * 0.5) / Fq
			return math.clamp(Kq * math.clamp(tonumber(Dq) or 1.5, 0.5, 5), 0.018, 0.22), Kq
		end
		local function Kq(Dq, nq, eq, Fq, aq, Lq, Qq, Bq)
			if Dq then
				if Dq.Part then
					if nq then
						if not eq then
							return
						end
					else
						return
					end
				else
					return
				end
			else
				return
			end
			local Tq = (eq - nq).Magnitude
			if Tq <= 0.001 then
				h(Dq.Main, "Visible", false)
				h(Dq.Outline, "Visible", false)
				return
			end
			local Gq = (nq + eq) * 0.5
			h(Dq.Part, "CFrame", CFrame.lookAt(Gq, eq))
			h(Dq.Part, "Size", Vector3.new(0.03, 0.03, math.max(Tq, 0.03)))
			h(Dq.Main, "Size", Vector3.new(Qq, Qq, Tq + Qq * 0.35))
			h(Dq.Main, "Color3", Fq)
			h(Dq.Main, "Transparency", 0)
			h(Dq.Main, "AlwaysOnTop", true)
			h(Dq.Main, "Visible", true)
			h(Dq.Outline, "Size", Vector3.new(Bq, Bq, Tq + Bq * 0.45))
			h(Dq.Outline, "Color3", Lq)
			h(Dq.Outline, "Transparency", 0)
			h(Dq.Outline, "AlwaysOnTop", true)
			h(Dq.Outline, "Visible", aq)
		end
		local function Dq(nq, eq, Fq, aq, Lq, Qq, Bq, Tq, Gq)
			if nq then
				if nq.Part then
					if not eq then
						return
					end
				else
					return
				end
			else
				return
			end
			if not aq then
				h(nq.Main, "Visible", false)
				h(nq.Outline, "Visible", false)
				return
			end
			aq = math.clamp(tonumber(Gq) or 1, 0.5, 2)
			h(nq.Part, "CFrame", CFrame.new(eq))
			h(nq.Main, "Radius", Bq * 0.72 * aq)
			h(nq.Main, "Color3", Fq)
			h(nq.Main, "Transparency", 0)
			h(nq.Main, "AlwaysOnTop", true)
			h(nq.Main, "Visible", true)
			h(nq.Outline, "Radius", Tq * 0.72 * aq)
			h(nq.Outline, "Color3", Qq)
			h(nq.Outline, "Transparency", 0)
			h(nq.Outline, "AlwaysOnTop", true)
			h(nq.Outline, "Visible", Lq)
		end
		local nq = writefile and isfile and getcustomasset
		local function eq(Fq, aq, Lq)
			local Qq = aq .. ".ttf"
			local Bq = aq .. ".ttf.json"
			local Tq, Gq = pcall(isfile, Qq)
			if Tq then
				if not Gq then
					return false
				end
			else
				return false
			end
			Gq, Tq = pcall(isfile, Bq)
			if Lq or not Gq or not Tq then
				if
					not (
						pcall(function()
							local Tq = {
								name = aq,
								faces = {
									{ name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(Qq) },
								},
							}
							writefile(Bq, n:JSONEncode(Tq))
						end)
					)
				then
					return false
				end
			end
			Lq, Gq = pcall(Font.new, getcustomasset(Bq), Enum.FontWeight.Regular)
			if Lq then
				if Gq then
					Iq.Loaded[Fq] = Gq
					return true
				end
			end
			return false
		end
		local function Fq(aq, Lq)
			if not nq then
				return false
			end
			local Qq = aq:gsub("%s+", "")
			if eq(aq, Qq, false) then
				return true
			elseif eq(aq, Qq, true) then
				return true
			end
			local Bq, Tq = pcall(function()
				return game:HttpGet(Lq)
			end)
			if Bq then
				if Tq then
					if Tq == "" then
						return false
					end
				else
					return false
				end
			else
				return false
			end
			if not (pcall(writefile, Qq .. ".ttf", Tq)) then
				return false
			end
			return eq(aq, Qq, true)
		end
		local function eq()
			if not nq then
				Uq = false
				return
			end
			for nq, aq in pairs(uq) do
				if not Iq.Loaded[nq] then
					task.spawn(Fq, nq, aq.TTF)
				end
			end
			Uq = false
		end
		task.spawn(function()
			task.wait(1)
			local uq = Uq
			if uq then
				eq()
			end
		end)
		local uq = {}
		local function Uq(nq, eq)
			local Fq = {
				Instance = nq,
				Player = eq and eq.Player or nil,
				Humanoid = nil,
				RootPart = nil,
				Tool = nil,
				Holding = nil,
				PlayerStats = nil,
				Connections = {},
			}
			local function aq(Lq)
				Fq.Connections[#Fq.Connections + 1] = Lq
				return Lq
			end
			local function Lq()
				local Qq, Bq = Fq.Player, D:FindFirstChild("CharStats")
				Fq.PlayerStats = Qq and Bq and Bq:FindFirstChild(Qq.Name) or nil
			end
			local function Qq(Bq)
				if Fq.Player then
					if Bq then
						if Bq.Name ~= "CharStats" then
							return
						end
					else
						return
					end
				else
					return
				end
				Lq()
				aq(Bq.ChildAdded:Connect(function(Tq)
					if Tq.Name == Fq.Player.Name then
						Fq.PlayerStats = Tq
					end
				end))
				aq(Bq.ChildRemoved:Connect(function(Bq)
					if Bq == Fq.PlayerStats then
						Fq.PlayerStats = nil
					end
				end))
			end
			local function Bq(Tq)
				if not Tq then
					return
				end
				if Tq:IsA("Humanoid") then
					Fq.Humanoid = Tq
				elseif Tq:IsA("Tool") then
					Fq.Tool = Tq
				elseif Tq:IsA("BasePart") then
					if Tq.Name == "HumanoidRootPart" then
						Fq.RootPart = Tq
					elseif not Fq.RootPart then
						if Tq.Name == "Torso" then
							Fq.RootPart = Tq
						elseif Tq.Name == "UpperTorso" then
							Fq.RootPart = Tq
						end
					end
				elseif Tq.Name == "Holding" then
					Fq.Holding = Tq
				end
			end
			local function Tq()
				if nq.Parent then
					if not (nq:IsA("Model")) then
						return
					end
				else
					return
				end
				Fq.RootPart = nq.PrimaryPart
					or nq:FindFirstChild("HumanoidRootPart")
					or nq:FindFirstChild("Torso")
					or nq:FindFirstChild("UpperTorso")
					or nq:FindFirstChildWhichIsA("BasePart")
				Fq.Humanoid = nq:FindFirstChildOfClass("Humanoid")
				Fq.Tool = nq:FindFirstChildWhichIsA("Tool")
				Fq.Holding = nq:FindFirstChild("Holding")
			end
			if nq:IsA("Model") then
				if not Fq.Player then
					Fq.Player = V:GetPlayerFromCharacter(nq)
				end
				for Gq, Gq in ipairs(nq:GetChildren()) do
					Bq(Gq)
				end
				Tq()
				aq(nq.ChildAdded:Connect(function(Gq)
					Bq(Gq)
					if Gq:IsA("BasePart") then
						if eq then
							if eq.espObj then
								eq.espObj.BoundingPartsDirty = true
							end
						end
					end
				end))
				aq(nq.ChildRemoved:Connect(function(Bq)
					local Gq = false
					if Bq == Fq.Humanoid then
						Fq.Humanoid = nil
						Gq = true
					else
					end
					if Bq == Fq.RootPart then
						Fq.RootPart = nil
						Gq = true
					else
					end
					if Bq == Fq.Tool then
						Fq.Tool = nil
						Gq = true
					else
					end
					if Bq == Fq.Holding then
						Fq.Holding = nil
						Gq = true
					else
					end
					if Bq:IsA("BasePart") then
						if eq then
							if eq.espObj then
								eq.espObj.BoundingPartsDirty = true
							end
						end
					end
					if Gq then
						task.defer(Tq)
					end
				end))
				aq(nq:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
					Fq.RootPart = nq.PrimaryPart or Fq.RootPart
				end))
			elseif nq:IsA("BasePart") then
				Fq.RootPart = nq
			end
			if Fq.Player then
				Lq()
				local nq = D:FindFirstChild("CharStats")
				if nq then
					Qq(nq)
				end
				aq(D.ChildAdded:Connect(function(nq)
					if nq.Name == "CharStats" then
						Qq(nq)
					end
				end))
				aq(D.ChildRemoved:Connect(function(nq)
					if nq.Name == "CharStats" then
						Fq.PlayerStats = nil
					end
				end))
			end
			return Fq
		end
		local function nq(eq)
			local Fq = eq and eq.Runtime
			if not Fq then
				return
			end
			for aq = #Fq.Connections, 1, -1 do
				local Lq = Fq.Connections[aq]
				Fq.Connections[aq] = nil
				pcall(function()
					Lq:Disconnect()
				end)
			end
			eq.Runtime = nil
		end
		local function eq(Fq)
			local aq = game
			for Lq, Qq in ipairs((string.split(Fq, "."))) do
				if aq == game and (Qq == "Workspace" or Qq == "workspace") then
					aq = m
				else
					if aq == game and Qq == "Players" then
						aq = V
					else
						Lq = aq:FindFirstChild(Qq)
						if not Lq then
							return nil
						end
						aq = Lq
					end
				end
			end
			return aq ~= game and aq or nil
		end
		local function Fq(aq)
			local Lq = Instance.new("Frame")
			Lq.BorderSizePixel = 0
			Lq.BackgroundColor3 = J.BoxColor
			Lq.Parent = aq
			aq = Instance.new("Frame")
			aq.BorderSizePixel = 0
			aq.BackgroundColor3 = J.Outlines.Color
			aq.ZIndex = 0
			aq.Parent = Lq
			return Lq, aq
		end
		local function aq(Lq, Qq)
			if not Lq then
				return
			end
			local Bq = Lq[Qq]
			if Bq then
				Bq:Destroy()
				Lq[Qq] = nil
			end
			Lq[Qq .. "Color"] = nil
			Lq[Qq .. "Transparency"] = nil
			Lq[Qq .. "PartSize"] = nil
			Lq[Qq .. "SizeIncrease"] = nil
			Lq[Qq .. "HeadScale"] = nil
			Lq[Qq .. "Visible"] = nil
			Lq[Qq .. "Intensity"] = nil
			Lq[Qq .. "XRay"] = nil
		end
		local function Lq(Qq)
			if typeof(Qq) == "Instance" then
				Qq:Destroy()
				return
			end
			if not Qq then
				return
			end
			aq(Qq, "Invisible")
			aq(Qq, "Visible")
			aq(Qq, "Glow")
		end
		local function Qq(Bq)
			for Tq, Gq in pairs(Bq.Adornments or {}) do
				Lq(Gq)
				Bq.Adornments[Tq] = nil
			end
		end
		local function Bq(Tq, Gq)
			for cq, cq in pairs(Tq.Adornments or {}) do
				if typeof(cq) == "Instance" then
					cq.Visible = Gq
				else
					if cq.Invisible then
						if cq.InvisibleVisible ~= Gq then
							cq.Invisible.Visible = Gq
							cq.InvisibleVisible = Gq
						end
					end
					if cq.Visible then
						if cq.VisibleVisible ~= Gq then
							cq.Visible.Visible = Gq
							cq.VisibleVisible = Gq
						end
					end
					if cq.Glow then
						if cq.GlowVisible ~= Gq then
							cq.Glow.Visible = Gq
							cq.GlowVisible = Gq
						end
					end
				end
			end
		end
		local function Tq(Gq)
			if Gq then
				if Gq.Proxy then
					Gq.Proxy:Destroy()
				end
			end
		end
		local function Gq(cq, Cq)
			local bq = cq.AdornmentProxyLayers and cq.AdornmentProxyLayers[Cq]
			if not bq then
				return
			end
			if bq.Model then
				bq.Model:Destroy()
			end
			cq.AdornmentProxyLayers[Cq] = nil
		end
		local function cq(Cq)
			for bq in pairs(Cq.AdornmentProxyLayers or {}) do
				Gq(Cq, bq)
			end
		end
		local function Cq(bq)
			local Eq = Instance.new("Humanoid")
			Eq.Name = "ChamProxyRasterizer"
			Eq.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			Eq.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			Eq.NameDisplayDistance = 0
			Eq.HealthDisplayDistance = 0
			Eq.BreakJointsOnDeath = false
			Eq.RequiresNeck = false
			Eq.AutoRotate = false
			Eq.PlatformStand = true
			pcall(function()
				Eq.EvaluateStateMachine = false
			end)
			Eq.Parent = bq
			return Eq
		end
		local function bq(Eq, tq)
			local Nq = Eq.AdornmentProxyLayers[tq]
			if Nq then
				if Nq.Model then
					if Nq.Model.Parent then
						return Nq
					else
						Gq(Eq, tq)
					end
				else
					Gq(Eq, tq)
				end
			end
			local _q = Instance.new("Model")
			_q.Name = "Cham" .. tq .. "Proxy"
			_q:SetAttribute("SensoryESP_MeshCham", true)
			_q:SetAttribute("SensoryESP_RunId", v)
			local vq, rq = Cq(_q), Instance.new("Highlight")
			rq.Name = "ChamProxyHighlight"
			rq:SetAttribute("SensoryESP_MeshCham", true)
			rq:SetAttribute("SensoryESP_RunId", v)
			rq.Adornee = _q
			rq.Parent = _q
			_q.Parent = T
			Nq = { Model = _q, Highlight = rq, Rasterizer = vq, Parts = {} }
			Eq.AdornmentProxyLayers[tq] = Nq
			return Nq
		end
		local function Eq(tq, Nq, _q)
			_q = math.clamp(tonumber(_q) or 1, 0.5, 1.25)
			return math.max(tq.X, tq.Z) * 0.5 * _q + Nq * 0.5, tq.Y + Nq
		end
		local function tq(Nq, _q, vq, rq)
			local dq, pq = Nq.Parts[_q], vq.IsCylinder
			if dq then
				if dq.IsCylinder ~= pq then
					Tq(dq)
					dq = nil
				else
					if dq.Proxy then
						if dq.Proxy.Parent then
						else
							Tq(dq)
							dq = nil
						end
					else
						Tq(dq)
						dq = nil
					end
				end
			else
			end
			if dq then
			else
				local Oq = Instance.new("Part")
				Oq.Name = "ChamProxy_" .. _q.Name
				Oq:SetAttribute("SensoryESP_MeshCham", true)
				Oq:SetAttribute("SensoryESP_RunId", v)
				Oq.Shape = pq and Enum.PartType.Cylinder or Enum.PartType.Block
				Oq.Transparency = 0.99
				Oq.CastShadow = false
				Oq.CanCollide = false
				Oq.CanQuery = false
				Oq.CanTouch = false
				Oq.Anchored = false
				Oq.Massless = true
				Oq.RootPriority = -127
				Oq.CFrame = pq and _q.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) or _q.CFrame
				Oq.Parent = Nq.Model
				local qq = Instance.new("WeldConstraint")
				qq.Part0 = Oq
				qq.Part1 = _q
				qq.Parent = Oq
				dq = { Proxy = Oq, IsCylinder = pq }
				Nq.Parts[_q] = dq
			end
			_q = nil
			if pq then
				local Nq, pq = Eq(vq.PartSize, rq, vq.HeadScale)
				_q = Vector3.new(pq, Nq * 2, Nq * 2)
			else
				_q = vq.PartSize + Vector3.new(rq, rq, rq)
			end
			if dq.Size ~= _q then
				dq.Proxy.Size = _q
				dq.Size = _q
			end
		end
		local function Nq(_q, vq, rq, dq, pq)
			local Oq = Instance.new(vq and "CylinderHandleAdornment" or "BoxHandleAdornment")
			Oq.Name = rq
			Oq.Adornee = _q
			Oq.CFrame = vq and CFrame.Angles(1.5707963267948966, 0, 0) or CFrame.identity
			Oq.AlwaysOnTop = dq
			Oq.ZIndex = pq
			Oq.Parent = B
			return Oq
		end
		local _q
		pcall(function()
			_q = Enum.AdornShading.XRayShaded
		end)
		local function vq(rq, dq)
			local pq = Nq(rq, dq, "ChamGlow", true, 7)
			rq = if _q
				then pcall(function()
					pq.Shading = _q
					pq.Transparency = -1
				end)
				else false
			return pq, rq
		end
		local function _q(rq, dq, pq, Oq, qq, hq, Wq)
			local gq = rq.Glow
			if not gq then
				return
			end
			qq, hq = math.clamp(tonumber(qq) or 5, 1, 10), math.clamp(tonumber(hq) or 0.72, 0, 1)
			local Sq = rq.GlowXRay == true
			local lq = Sq and Color3.new(Oq.R * qq, Oq.G * qq, Oq.B * qq) or Oq
			if rq.GlowColor ~= lq then
				gq.Color3 = lq
				rq.GlowColor = lq
			end
			if rq.GlowIntensity ~= qq then
				rq.GlowIntensity = qq
			end
			local qq = Sq and -1 or hq
			if rq.GlowTransparency ~= qq then
				lq = pcall(function()
					gq.Transparency = qq
				end)
				if if lq then not lq else Sq then
					rq.GlowXRay = false
					gq.Color3 = Oq
					rq.GlowColor = Oq
					qq = hq
					gq.Transparency = qq
				else
				end
				rq.GlowTransparency = qq
			else
			end
			pq = math.max(tonumber(pq) or 0.03, 0)
			if rq.GlowPartSize ~= dq or rq.GlowSizeIncrease ~= pq or rq.GlowHeadScale ~= Wq then
				if rq.IsCylinder then
					Sq, Oq = Eq(dq, pq, Wq)
					gq.Radius = Sq
					gq.Height = Oq
				else
					gq.Size = dq + Vector3.new(pq, pq, pq)
				end
				rq.GlowPartSize = dq
				rq.GlowSizeIncrease = pq
				rq.GlowHeadScale = Wq
			end
			if rq.GlowVisible ~= true then
				gq.Visible = true
				rq.GlowVisible = true
			end
		end
		local function rq(dq, pq, Oq, qq, hq, Wq, gq)
			local Sq = dq[pq]
			if not Sq then
				return
			end
			if dq[pq .. "Color"] ~= hq then
				Sq.Color3 = hq
				dq[pq .. "Color"] = hq
			end
			Wq = math.clamp(tonumber(Wq) or 0, 0, 1)
			if dq[pq .. "Transparency"] ~= Wq then
				Sq.Transparency = Wq
				dq[pq .. "Transparency"] = Wq
			end
			qq = math.max(tonumber(qq) or 0, 0)
			if dq[pq .. "PartSize"] ~= Oq or dq[pq .. "SizeIncrease"] ~= qq or dq[pq .. "HeadScale"] ~= gq then
				if dq.IsCylinder then
					local hq, Wq = Eq(Oq, qq, gq)
					Sq.Radius = hq
					Sq.Height = Wq
				else
					Sq.Size = Oq + Vector3.new(qq, qq, qq)
				end
				dq[pq .. "PartSize"] = Oq
				dq[pq .. "SizeIncrease"] = qq
				dq[pq .. "HeadScale"] = gq
			end
			if dq[pq .. "Visible"] ~= true then
				Sq.Visible = true
				dq[pq .. "Visible"] = true
			end
		end
		local Eq = {
			{
				Key = "Invisible",
				EnabledPath = "Chams.Adornment.Invisible.Highlight.Enabled",
				FillColorPath = "Chams.Adornment.Invisible.Highlight.FillColor",
				FillTransparencyPath = "Chams.Adornment.Invisible.Highlight.FillTransparency",
				OutlineColorPath = "Chams.Adornment.Invisible.Highlight.OutlineColor",
				OutlineTransparencyPath = "Chams.Adornment.Invisible.Highlight.OutlineTransparency",
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			},
			{
				Key = "Visible",
				EnabledPath = "Chams.Adornment.Visible.Highlight.Enabled",
				FillColorPath = "Chams.Adornment.Visible.Highlight.FillColor",
				FillTransparencyPath = "Chams.Adornment.Visible.Highlight.FillTransparency",
				OutlineColorPath = "Chams.Adornment.Visible.Highlight.OutlineColor",
				OutlineTransparencyPath = "Chams.Adornment.Visible.Highlight.OutlineTransparency",
				DepthMode = Enum.HighlightDepthMode.Occluded,
			},
		}
		local dq = {
			SmoothPlastic = Enum.Material.SmoothPlastic,
			ForceField = Enum.Material.ForceField,
			Neon = Enum.Material.Neon,
			Glass = Enum.Material.Glass,
		}
		local function pq(Oq)
			if Oq then
				if Oq.Proxy then
					Oq.Proxy:Destroy()
				end
			end
		end
		local function Oq(qq)
			for hq, Wq in pairs(qq and qq.Parts or {}) do
				pq(Wq)
				qq.Parts[hq] = nil
			end
		end
		local function qq(hq)
			local Wq = hq.CharacterClone
			if not Wq then
				return
			end
			if Wq.AddedConnection then
				Wq.AddedConnection:Disconnect()
			end
			if Wq.RemovingConnection then
				Wq.RemovingConnection:Disconnect()
			end
			if Wq.Model then
				Wq.Model:Destroy()
			end
			hq.CharacterClone = nil
		end
		local function hq(Wq, gq, Sq)
			if gq:IsA("BasePart") then
				if gq.Name == "HumanoidRootPart" then
					return false
				elseif gq:GetAttribute("SensoryESP_MeshCham") == true then
					return false
				end
			else
				return false
			end
			if gq.Parent == Wq then
				return true
			end
			if not Sq then
				return false
			end
			Sq = gq.Parent
			while Sq and Sq ~= Wq do
				if Sq:IsA("Accessory") then
					return true
				end
				Sq = Sq.Parent
			end
			return false
		end
		local function Wq(gq, Sq, lq)
			local Jq
			local oq = gq.Archivable
			if not oq then
				pcall(function()
					gq.Archivable = true
				end)
			end
			pcall(function()
				Jq = gq:Clone()
			end)
			if not oq then
				pcall(function()
					gq.Archivable = false
				end)
			end
			oq = not Jq
			if oq then
				Jq = Instance.new(gq:IsA("MeshPart") and "MeshPart" or "Part")
				local Rq = gq:IsA("Part")
				if Rq then
					Jq.Shape = gq.Shape
				else
					local Rq = gq:IsA("MeshPart")
					if Rq then
						pcall(function()
							local Rq = Jq
							Rq.MeshId = gq.MeshId
						end)
						pcall(function()
							local Rq = Jq
							Rq.TextureID = gq.TextureID
						end)
					end
				end
			else
			end
			local Rq, Yq = ipairs, y[58](Jq:GetChildren())
			for Pq, Pq in Rq(y:t5(Yq)) do
				if
					Pq:IsA("DataModelMesh")
					or lq.KeepTextures and (Pq:IsA("Decal") or Pq:IsA("Texture") or Pq:IsA("SurfaceAppearance"))
				then
					if Pq:IsA("SpecialMesh") then
						if not lq.KeepTextures then
							Pq.TextureId = ""
						end
					end
				else
					Pq:Destroy()
				end
			end
			oq = Jq:IsA("MeshPart")
			if oq then
				Yq = lq.KeepTextures
				if not Yq then
					pcall(function()
						Jq.TextureID = ""
					end)
				end
			end
			Jq.Name = "ChamClone_" .. gq.Name
			Jq:SetAttribute("SensoryESP_MeshCham", true)
			Jq:SetAttribute("SensoryESP_RunId", v)
			Jq.CastShadow = false
			Jq.CanCollide = false
			Jq.CanQuery = false
			Jq.CanTouch = false
			Jq.Anchored = false
			Jq.Massless = true
			Jq.RootPriority = -127
			Jq.LocalTransparencyModifier = 0
			Jq.CFrame = gq.CFrame
			Jq.Parent = Sq.Model
			Yq = Instance.new("WeldConstraint")
			Yq.Name = "ChamCloneWeld"
			Yq.Part0 = Jq
			Yq.Part1 = gq
			Yq.Parent = Jq
			lq = { Proxy = Jq, Weld = Yq }
			Sq.Parts[gq] = lq
			return lq
		end
		local function gq(Sq, lq, Jq)
			local oq = lq.Proxy
			if oq then
				if not oq.Parent then
					return false
				end
			else
				return false
			end
			local Rq = Sq.Size * Jq.SizeScale
			if lq.Size ~= Rq then
				oq.Size = Rq
				lq.Size = Rq
			end
			if lq.Color ~= Jq.Color then
				oq.Color = Jq.Color
				lq.Color = Jq.Color
			end
			if lq.Material ~= Jq.Material then
				oq.Material = Jq.Material
				lq.Material = Jq.Material
			end
			Rq = Jq.Transparency
			Rq = if Jq.HighlightEnabled then math.min(Rq, 0.99) else Rq
			if lq.Transparency ~= Rq then
				oq.Transparency = Rq
				lq.Transparency = Rq
			end
			return true
		end
		local function Sq(lq, Jq, oq)
			local Rq = lq.KeepTextures ~= oq.KeepTextures or lq.IncludeAccessories ~= oq.IncludeAccessories
			if lq.RebuildAll or Rq then
				Oq(lq)
			else
				for Oq in pairs(lq.PendingSources) do
					local Rq = lq.Parts[Oq]
					if Rq then
						pq(Rq)
						lq.Parts[Oq] = nil
					end
				end
			end
			lq.KeepTextures = oq.KeepTextures
			lq.IncludeAccessories = oq.IncludeAccessories
			lq.RebuildAll = false
			for Oq in pairs(lq.PendingSources) do
				lq.PendingSources[Oq] = nil
			end
			lq.ScanRevision = (lq.ScanRevision or 0) + 1
			local Oq = lq.ScanRevision
			for Rq, Yq in ipairs(Jq:GetDescendants()) do
				if hq(Jq, Yq, oq.IncludeAccessories) then
					Rq = lq.Parts[Yq]
					if (if Rq then not Rq.Proxy else not Rq) or not Rq.Proxy.Parent then
						if Rq then
							pq(Rq)
						end
						Rq = (Wq(Yq, lq, oq))
					else
					end
					Rq.ScanRevision = Oq
				end
			end
			for hq, Wq in pairs(lq.Parts) do
				if Wq.ScanRevision ~= Oq or not hq.Parent then
					pq(Wq)
					lq.Parts[hq] = nil
				end
			end
			lq.Dirty = false
		end
		local function Oq(hq, Wq)
			local lq = Wq
			while lq and lq ~= hq do
				if lq:IsA("BasePart") then
					return lq
				end
				lq = lq.Parent
			end
			return nil
		end
		local function hq(Wq, lq)
			local Jq = Wq.CharacterClone
			if Jq then
				if Jq.Source ~= lq then
					qq(Wq)
				elseif Jq.Model then
					if Jq.Model.Parent then
						return Jq
					else
						qq(Wq)
					end
				else
					qq(Wq)
				end
			end
			local Jq = Instance.new("Model")
			Jq.Name = "ChamCharacterClone"
			Jq:SetAttribute("SensoryESP_MeshCham", true)
			Jq:SetAttribute("SensoryESP_RunId", v)
			Jq.Parent = T
			local oq
			oq = {
				Source = lq,
				Model = Jq,
				Parts = {},
				PendingSources = {},
				Dirty = true,
				RebuildAll = true,
				AddedConnection = lq.DescendantAdded:Connect(function(Jq)
					local Rq = Oq(lq, Jq)
					if Rq then
						oq.PendingSources[Rq] = true
					end
					oq.Dirty = true
				end),
				RemovingConnection = lq.DescendantRemoving:Connect(function(Jq)
					local Rq = Oq(lq, Jq)
					if Rq then
						oq.PendingSources[Rq] = true
					end
					oq.Dirty = true
				end),
			}
			Wq.CharacterClone = oq
			return oq
		end
		local function Oq(Wq, lq)
			if not lq.HighlightEnabled then
				if Wq.Highlight then
					Wq.Highlight:Destroy()
					Wq.Highlight = nil
				end
				if Wq.Rasterizer then
					Wq.Rasterizer:Destroy()
					Wq.Rasterizer = nil
				end
				return
			end
			local Jq = Wq.Rasterizer
			if if Jq then not Wq.Rasterizer.Parent else not Jq then
				Wq.Rasterizer = Cq(Wq.Model)
			end
			Jq = Wq.Highlight
			local Cq = if Jq then not Wq.Highlight.Parent else not Jq
			if Cq then
				Jq = Instance.new("Highlight")
				Jq.Name = "ChamCharacterHighlight"
				Jq:SetAttribute("SensoryESP_MeshCham", true)
				Jq:SetAttribute("SensoryESP_RunId", v)
				Jq.Adornee = Wq.Model
				Jq.Parent = Wq.Model
				Wq.Highlight = Jq
			end
			Cq = Wq.Highlight
			h(Cq, "FillColor", lq.HighlightFillColor)
			h(Cq, "FillTransparency", lq.HighlightFillTransparency)
			h(Cq, "OutlineColor", lq.HighlightOutlineColor)
			h(Cq, "OutlineTransparency", lq.HighlightOutlineTransparency)
			h(
				Cq,
				"DepthMode",
				lq.HighlightVisibleCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
			)
			h(Cq, "Enabled", true)
		end
		local function Cq(Wq, lq, Jq, oq)
			local Rq = hq(Wq, lq)
			Wq = Rq.KeepTextures ~= Jq.KeepTextures or Rq.IncludeAccessories ~= Jq.IncludeAccessories
			if oq then
				Sq(Rq, lq, Jq)
			elseif Rq.Dirty then
				Sq(Rq, lq, Jq)
			elseif Wq then
				Sq(Rq, lq, Jq)
			end
			for hq, Wq in pairs(Rq.Parts) do
				lq = hq.Parent
				if if lq then not gq(hq, Wq, Jq) else not lq then
					pq(Wq)
					Rq.Parts[hq] = nil
					Rq.Dirty = true
				end
			end
			Oq(Rq, Jq)
		end
		local pq
		local Oq = 0
		local function hq(Wq)
			Oq += 1
			local gq = {
				RefreshPhase = Oq % 16 / 16,
				Visible = false,
				Lines = {},
				Outlines = {},
				CornerLines = {},
				CornerOutlines = {},
				StyleCache = {},
				FrameConfigCache = {},
				ConfigRevisionRef = -1,
				BoundingParts = {},
				BoundingPartsDirty = true,
				BoundingSource = nil,
				BoundingAddedConnection = nil,
				BoundingRemovedConnection = nil,
				CharacterCloneStyle = {},
				ActiveAdornmentParts = {},
				AdornmentPartInfo = {},
				FlagLabels = {},
			}
			local Oq = Instance.new("Frame")
			Oq.BackgroundTransparency = 1
			Oq.Name = "ESPObj"
			Oq.Parent = G
			gq.Container = Oq
			local Sq = Instance.new("Frame")
			Sq.BorderSizePixel = 0
			Sq.ZIndex = 0
			Sq.Visible = false
			Sq.Parent = Oq
			gq.BoxFill = Sq
			local lq = Instance.new("UIGradient")
			lq.Parent = Sq
			gq.BoxFillGradient = lq
			for Jq = 1, 4, 1 do
				lq, Sq = Fq(Oq)
				gq.Lines[Jq] = lq
				gq.Outlines[Jq] = Sq
			end
			for Jq = 1, 8, 1 do
				lq, Sq = Fq(Oq)
				lq.Visible = false
				Sq.Visible = false
				gq.CornerLines[Jq] = lq
				gq.CornerOutlines[Jq] = Sq
			end
			local function Fq(Jq)
				Jq.BackgroundTransparency = 1
				Jq.Size = UDim2.new(0, 100, 0, J.TextSize)
				Jq.Font = yq[J.Font] or Enum.Font.Code
				local oq = Iq.Loaded[J.Font]
				if oq then
					Jq.FontFace = Iq.Loaded[J.Font]
				end
				Jq.TextSize = J.TextSize
				Jq.TextColor3 = J.TextColor
				Jq.TextStrokeTransparency = 1
				Jq.ZIndex = 2
				Jq.Parent = Oq
				oq = Instance.new("UIStroke")
				oq.Thickness = 1
				oq.Color = J.TextOutlineColor or J.Outlines.Color
				oq.LineJoinMode = Enum.LineJoinMode.Miter
				oq.Enabled = J.TextOutline
				oq.Parent = Jq
				O[Jq] = oq
			end
			lq = Instance.new("TextLabel")
			Fq(lq)
			lq.TextYAlignment = Enum.TextYAlignment.Bottom
			lq.RichText = true
			lq.Text = Wq
			lq.Visible = J.Names
			gq.Text = lq
			gq.TeamText = nil
			gq.TeamTextStroke = nil
			gq.FriendlyText = nil
			gq.FriendlyTextStroke = nil
			lq = Instance.new("TextLabel")
			Fq(lq)
			lq.TextYAlignment = Enum.TextYAlignment.Top
			lq.Visible = false
			gq.DistanceText = lq
			Sq = Instance.new("TextLabel")
			Fq(Sq)
			Sq.TextYAlignment = Enum.TextYAlignment.Top
			Sq.Visible = false
			gq.WeaponText = Sq
			Sq = Instance.new("Frame")
			Sq.BackgroundColor3 = J.Outlines.Color
			Sq.BorderSizePixel = 0
			Sq.Visible = false
			Sq.ZIndex = 1
			Sq.Parent = Oq
			gq.HealthBarOutline = Sq
			lq = Instance.new("Frame")
			lq.BackgroundTransparency = 1
			lq.ClipsDescendants = true
			lq.BorderSizePixel = 0
			lq.ZIndex = 2
			lq.Parent = Sq
			gq.HealthBarContainer = lq
			Wq = Instance.new("Frame")
			Wq.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Wq.BorderSizePixel = 0
			Wq.ZIndex = 2
			Wq.Parent = lq
			gq.HealthBar = Wq
			Sq = Instance.new("UIGradient")
			Sq.Enabled = J.HealthBar.Gradient.Enabled
			local Jq, oq, Rq, Yq, Pq, Hq =
				ColorSequence.new,
				{},
				ColorSequenceKeypoint.new(0, J.HealthBar.Gradient.Color1),
				ColorSequenceKeypoint.new(0.5, J.HealthBar.Gradient.Color2),
				ColorSequenceKeypoint.new,
				J.HealthBar
			y:w5(oq, 0, Rq, Yq, Pq(1, Hq.Gradient.Color3))
			Sq.Color = Jq(oq)
			Sq.Parent = Wq
			gq.HealthGradient = Sq
			Jq = Instance.new("TextLabel")
			Fq(Jq)
			Jq.TextYAlignment = Enum.TextYAlignment.Center
			Jq.ZIndex = 3
			Jq.Visible = false
			gq.HealthText = Jq
			lq = Instance.new("Frame")
			lq.BackgroundColor3 = J.Outlines.Color
			lq.BorderSizePixel = 0
			lq.Visible = false
			lq.ZIndex = 1
			lq.Parent = Oq
			gq.ArmorBarOutline = lq
			oq = Instance.new("Frame")
			oq.BackgroundTransparency = 1
			oq.ClipsDescendants = true
			oq.BorderSizePixel = 0
			oq.ZIndex = 2
			oq.Parent = lq
			gq.ArmorBarContainer = oq
			Jq = Instance.new("Frame")
			Jq.BackgroundColor3 = Color3.fromRGB(90, 190, 255)
			Jq.BorderSizePixel = 0
			Jq.ZIndex = 2
			Jq.Parent = oq
			gq.ArmorBar = Jq
			lq = Instance.new("UIGradient")
			lq.Enabled = J.ArmorBar.Gradient.Enabled
			Sq, Hq, Wq, Yq, oq, Rq =
				ColorSequence.new,
				{},
				ColorSequenceKeypoint.new(0, J.ArmorBar.Gradient.Color1),
				ColorSequenceKeypoint.new(0.5, J.ArmorBar.Gradient.Color2),
				ColorSequenceKeypoint.new,
				J.ArmorBar
			y:w5(Hq, 0, Wq, Yq, oq(1, Rq.Gradient.Color3))
			lq.Color = Sq(Hq)
			lq.Parent = Jq
			gq.ArmorGradient = lq
			Sq = Instance.new("TextLabel")
			Fq(Sq)
			Sq.TextYAlignment = Enum.TextYAlignment.Center
			Sq.ZIndex = 3
			Sq.Visible = false
			gq.ArmorText = Sq
			for Sq = 1, 5, 1 do
				Wq = Instance.new("TextLabel")
				Fq(Wq)
				Wq.TextSize = J.Flags.TextSize
				Wq.Font = yq[J.Flags.Font] or Enum.Font.Code
				Pq = Iq.Loaded[J.Flags.Font]
				if Pq then
					Wq.FontFace = Iq.Loaded[J.Flags.Font]
				end
				Wq.Visible = false
				gq.FlagLabels[Sq] = Wq
			end
			gq.Skeleton3DSegments = nil
			gq.Skeleton3DJoints = nil
			gq.Skeleton3DFolder = nil
			gq.Skeleton3DRoot = nil
			oq = Instance.new("TextLabel")
			oq.BackgroundTransparency = 1
			oq.Text = "\226\150\178"
			oq.TextColor3 = J.OffScreenArrows.Color
			oq.TextSize = J.OffScreenArrows.Size
			oq.Font = Enum.Font.SourceSans
			oq.Size = UDim2.new(0, J.OffScreenArrows.Size * 2, 0, J.OffScreenArrows.Size * 2)
			oq.ZIndex = 100
			oq.Visible = false
			oq.Parent = G
			gq.ArrowInner = oq
			Fq = Instance.new("TextLabel")
			Fq.BackgroundTransparency = 1
			Fq.Text = "\226\150\178"
			Fq.TextColor3 = J.OffScreenArrows.OutlineColor
			Fq.TextSize = J.OffScreenArrows.Size + 2
			Fq.Font = Enum.Font.SourceSans
			Fq.Size = UDim2.new(0, (J.OffScreenArrows.Size + 2) * 2, 0, (J.OffScreenArrows.Size + 2) * 2)
			Fq.ZIndex = 99
			Fq.Visible = false
			Fq.Parent = G
			gq.ArrowOutline = Fq
			local function Fq()
				local Wq = Instance.new("TextLabel")
				Wq.BackgroundTransparency = 1
				Wq.Size = UDim2.new(0, 150, 0, 12)
				Wq.TextStrokeTransparency = 1
				Wq.ZIndex = 110
				Wq.TextColor3 = Color3.fromRGB(255, 255, 255)
				Wq.Visible = false
				Wq.Parent = G
				local Sq = Instance.new("UIStroke")
				Sq.Parent = Wq
				O[Wq] = Sq
				return Wq
			end
			gq.ArrowName = Fq()
			gq.ArrowDist = Fq()
			gq.Adornments = {}
			gq.AdornmentProxyLayers = {}
			gq.CharacterClone = nil
			gq.Highlight = nil
			gq.Destroy = function()
				xq(gq)
				pq(gq)
				if gq.BoundingAddedConnection then
					gq.BoundingAddedConnection:Disconnect()
					gq.BoundingAddedConnection = nil
				end
				if gq.BoundingRemovedConnection then
					gq.BoundingRemovedConnection:Disconnect()
					gq.BoundingRemovedConnection = nil
				end
				Oq:Destroy()
				if gq.Highlight then
					gq.Highlight:Destroy()
				end
				if gq.MeshShell then
					gq.MeshShell:Destroy()
				end
				Qq(gq)
				cq(gq)
				qq(gq)
				if gq.ArrowInner then
					gq.ArrowInner:Destroy()
				end
				if gq.ArrowOutline then
					gq.ArrowOutline:Destroy()
				end
				if gq.ArrowName then
					gq.ArrowName:Destroy()
				end
				if gq.ArrowDist then
					gq.ArrowDist:Destroy()
				end
			end
			return gq
		end
		local O, Fq =
			{ "Armor", "Armour", "ArmorValue", "ArmourValue" }, { "MaxArmor", "MaxArmour", "ArmorMax", "ArmourMax" }
		local function Qq(Oq, Wq)
			if not Oq then
				return nil
			end
			for gq, Sq in ipairs(Wq) do
				if type((Oq:GetAttribute(Sq))) == "number" then
					return { Kind = "Attribute", Root = Oq, Name = Sq }
				end
				gq = Oq:FindFirstChild(Sq)
				if gq then
					if gq:IsA("ValueBase") then
						return { Kind = "Value", Object = gq }
					end
				end
			end
			return nil
		end
		local function Oq(Wq)
			if not Wq then
				return nil
			end
			if Wq.Kind == "Attribute" then
				local gq = Wq.Root
				if gq then
					if not gq.Parent then
						return nil
					end
				else
					return nil
				end
				local Sq = gq:GetAttribute(Wq.Name)
				return type(Sq) == "number" and Sq or nil
			end
			local gq = Wq.Object
			if gq then
				if not gq.Parent then
					return nil
				end
			else
				return nil
			end
			Wq = gq.Value
			if type(Wq) == "number" then
				return Wq
			elseif type(Wq) == "boolean" then
				return Wq and 100 or 0
			end
			return nil
		end
		local function Wq(gq, Sq, lq)
			if not Sq then
				return nil
			end
			local Jq = Sq.ArmorCache
			lq = lq or tick()
			local oq = Jq
				and (
					Jq.ArmorSource and Oq(Jq.ArmorSource) == nil
					or Jq.MaxSource and Oq(Jq.MaxSource) == nil
					or Jq.Kevlar and not Jq.Kevlar.Parent
				)
			if Jq then
				if not oq then
					if lq < (Jq.NextResolve or 0) then
						return Jq
					end
				end
			end
			local oq, Rq = Sq.Player, Sq.PlayerStats
			if oq and (if Rq then not Rq.Parent else not Rq) then
				local Yq = D:FindFirstChild("CharStats")
				Rq = Yq and Yq:FindFirstChild(oq.Name) or nil
				Sq.PlayerStats = Rq
			else
			end
			Jq = Jq or {}
			Jq.ArmorSource = Qq(gq, O) or Qq(oq, O) or Qq(Rq, O)
			Jq.MaxSource = Qq(gq, Fq) or Qq(oq, Fq) or Qq(Rq, Fq)
			Jq.Kevlar = nil
			if not Jq.ArmorSource then
				Jq.Kevlar = gq:FindFirstChild("Kevlar", true)
					or oq and oq:FindFirstChild("Kevlar", true)
					or Rq and (Rq:FindFirstChild("Kevlar", true))
			end
			Jq.NextResolve = lq + 0.5
			Sq.ArmorCache = Jq
			return Jq
		end
		local function gq(Sq, lq)
			if lq then
				local Jq = Wq(Sq, lq)
				local Wq, oq = Jq and Oq(Jq.ArmorSource) or nil, tonumber(Jq and Oq(Jq.MaxSource) or nil) or 100
				if Wq == nil then
					local Rq = Jq and Jq.Kevlar
					if Rq then
						local Jq = Rq:IsA("ValueBase") and Rq.Value or nil
						Wq = if type(Jq) == "number" then Jq else if type(Jq) == "boolean" then Jq and oq or 0 else oq
					else
						Wq = 0
					end
				else
				end
				oq = math.max(oq, 1)
				Wq = math.clamp(tonumber(Wq) or 0, 0, oq)
				return Wq, oq, Wq / oq
			end
			local Wq, Jq = V:GetPlayerFromCharacter(Sq), D:FindFirstChild("CharStats")
			lq = Wq and Jq and Jq:FindFirstChild(Wq.Name)
			local Jq, oq = Qq(Sq, O) or Qq(Wq, O) or Qq(lq, O), Qq(Sq, Fq) or Qq(Wq, Fq) or Qq(lq, Fq)
			local O, Fq = Oq(Jq), Oq(oq) or 100
			if O == nil then
				oq = Sq:FindFirstChild("Kevlar", true)
					or Wq and Wq:FindFirstChild("Kevlar", true)
					or lq and (lq:FindFirstChild("Kevlar", true))
				if oq then
					Jq = oq:IsA("ValueBase") and oq.Value or nil
					O = type(Jq) == "number" and Jq or (type(Jq) == "boolean" and (Jq and Fq or 0) or Fq)
				else
					O = 0
				end
			else
			end
			Fq = math.max(tonumber(Fq) or 100, 1)
			O = math.clamp(tonumber(O) or 0, 0, Fq)
			return O, Fq, O / Fq
		end
		local function O(Fq, Qq)
			if not Fq then
				return false
			end
			local Oq = tick()
			if Qq then
				local Wq = Qq.DownedValue
				if Wq then
					if Wq.Parent then
						return Wq.Value == true
					end
				end
				if Oq < (Qq.NextDownedResolve or 0) then
					return false
				end
				Qq.NextDownedResolve = Oq + 0.5
				Wq = Qq.PlayerStats
				if if Wq then not Wq.Parent else not Wq then
					local Sq = D:FindFirstChild("CharStats")
					Wq = Sq and Sq:FindFirstChild(Fq.Name) or nil
					Qq.PlayerStats = Wq
				else
				end
				Qq.DownedValue = Wq and Wq:FindFirstChild("Downed") or nil
				return Qq.DownedValue ~= nil and Qq.DownedValue.Value == true
			end
			Qq = D:FindFirstChild("CharStats")
			Oq = Qq and Qq:FindFirstChild(Fq.Name)
			Fq = Oq and (Oq:FindFirstChild("Downed"))
			return Fq ~= nil and Fq.Value == true
		end
		local function D(Fq)
			if not Fq then
				return false
			end
			local Qq
			local Qq = I
			local Oq = Qq.ExploitFlags
			return Oq ~= nil and Oq[Fq.UserId] == true
		end
		local Fq = {}
		local function Qq(Oq)
			if not Oq then
				return false
			end
			local Wq = Oq.UserId
			Oq = Fq[Wq]
			if Oq ~= nil then
				return Oq
			end
			local Sq, lq = pcall(e.IsFriendsWith, e, Wq)
			Oq = Sq and lq == true
			Fq[Wq] = Oq
			return Oq
		end
		local function Oq(Wq, Sq, lq, Jq, oq, Rq, Yq)
			if not Wq then
				return Jq
			end
			Jq = math.clamp((oq - Yq) / Rq, 0, 1)
			return Sq:Lerp(lq, Jq)
		end
		local function Wq(Sq, lq, Jq, oq)
			if Jq("Skeleton.Enabled") then
				if not (lq:IsA("Model")) then
					xq(Sq)
					return
				end
			else
				xq(Sq)
				return
			end
			local Rq, Yq =
				oq and oq.Humanoid or lq:FindFirstChildOfClass("Humanoid"),
				oq and oq.RootPart
					or lq:FindFirstChild("HumanoidRootPart")
					or lq:FindFirstChild("Torso")
					or lq.PrimaryPart
					or lq:FindFirstChildWhichIsA("BasePart")
			oq = Rq and Yq and mq(lq)
			if oq then
				if not Yq then
					xq(Sq)
					return
				end
			else
				xq(Sq)
				return
			end
			Rq, lq = Vq(Sq, Yq)
			if not Rq then
				return
			end
			local Vq, mq, Pq, Hq, Xq, zq, Aq, iq, jq, fq, Zq =
				Jq("Skeleton.Outline"),
				Jq("Skeleton.Color"),
				Jq("Skeleton.OutlineColor"),
				Jq("Skeleton.Thickness") or 1.5,
				Jq("Skeleton.Joints") ~= false,
				Jq("Skeleton.JointScale") or 1,
				Jq("Skeleton.Gradient.Enabled"),
				Jq("Skeleton.Gradient.Color1"),
				Jq("Skeleton.Gradient.Color2"),
				-math.huge,
				math.huge
			for sq, sq in pairs(oq) do
				if typeof(sq) == "Vector3" then
					fq, Zq = (math.max(fq, sq.Y)), math.min(Zq, sq.Y)
				else
				end
			end
			local sq, kq, wq = math.max(fq - Zq, 0.001), Mq(Yq.Position, Hq)
			Jq = kq + wq * 1.5
			for Mq, Zq in ipairs(U) do
				Yq, wq, Sq = oq[Zq[1]], oq[Zq[2]], Rq[Mq]
				if Yq and wq and Sq then
					Kq(Sq, Yq, wq, Oq(Aq, iq, jq, mq, fq, sq, (Yq.Y + wq.Y) * 0.5), Vq, Pq, kq, Jq)
				elseif Sq then
					h(Sq.Main, "Visible", false)
					h(Sq.Outline, "Visible", false)
				end
			end
			for U, U in ipairs(lq or {}) do
				Hq = oq[U.Key]
				if Hq then
					Dq(U, Hq, Oq(Aq, iq, jq, mq, fq, sq, Hq.Y), Xq, Vq, Pq, kq, Jq, zq)
				else
					h(U.Main, "Visible", false)
					h(U.Outline, "Visible", false)
				end
			end
		end
		local U
		local function Mq(Vq, Kq, mq, Dq, Oq)
			local Sq = Vq[Kq]
			if Oq or not Sq then
				Sq = mq + Dq * (Vq.RefreshPhase or 0)
				Vq[Kq] = Sq
			else
			end
			if mq < Sq then
				return false
			end
			Vq[Kq] = mq + Dq
			return true
		end
		local Vq, Kq, mq = type(Drawing) == "table" or typeof(Drawing) == "table", 2
		if Vq then
			a = Drawing.Fonts
			if type(a) == "table" then
				Kq = a.Plex or a.Monospace or a.UI or a.System or 2
			else
			end
			mq = Kq
		else
			mq = Kq
		end
		local function a(Kq, Dq, Oq)
			pcall(function()
				Kq[Dq] = Oq
			end)
		end
		local function Kq(Dq, Oq, Sq)
			local lq = Drawing.new("Square")
			lq.Visible = false
			lq.Filled = Dq and true or false
			lq.Thickness = Oq or 1
			lq.Transparency = 1
			a(lq, "ZIndex", Sq or 1)
			return lq
		end
		local function Dq(Oq, Sq)
			local lq = Drawing.new("Line")
			lq.Visible = false
			lq.Thickness = Oq or 1
			lq.Transparency = 1
			a(lq, "ZIndex", Sq or 1)
			return lq
		end
		local function Oq(Sq, lq, Jq)
			local oq = Drawing.new("Text")
			oq.Visible = false
			oq.Transparency = 1
			oq.Size = Sq or 12
			a(oq, "Font", mq)
			a(oq, "Center", lq and true or false)
			a(oq, "Centered", lq and true or false)
			a(oq, "Outline", true)
			a(oq, "Outlined", true)
			a(oq, "OutlineColor", Color3.fromRGB(0, 0, 0))
			a(oq, "ZIndex", Jq or 5)
			return oq
		end
		local function a(mq)
			if mq.Draw then
				return mq.Draw
			end
			if not Vq then
				return nil
			end
			local Sq = {
				BoxOutline = Kq(false, 3, 1),
				Box = Kq(false, 1, 2),
				Fill = Kq(true, 1, 0),
				Corners = {},
				CornerOutlines = {},
				Name = Oq(12, true, 6),
				Dist = Oq(12, true, 6),
				Weapon = Oq(12, true, 6),
				HpBg = Kq(true, 1, 3),
				HpBar = Kq(true, 1, 4),
				HpText = Oq(9, true, 6),
				ArBg = Kq(true, 1, 3),
				ArBar = Kq(true, 1, 4),
				ArText = Oq(9, true, 6),
				Flags = {},
			}
			for Kq = 1, 8, 1 do
				Sq.CornerOutlines[Kq] = Dq(3, 1)
				Sq.Corners[Kq] = Dq(1, 2)
			end
			for Kq = 1, 5, 1 do
				Sq.Flags[Kq] = Oq(9, true, 6)
			end
			mq.Draw = Sq
			return Sq
		end
		local function Kq(mq)
			local Dq = mq and mq.Draw
			if not Dq then
				return
			end
			Dq.BoxOutline.Visible = false
			Dq.Box.Visible = false
			Dq.Fill.Visible = false
			Dq.Name.Visible = false
			Dq.Dist.Visible = false
			Dq.Weapon.Visible = false
			Dq.HpBg.Visible = false
			Dq.HpBar.Visible = false
			Dq.HpText.Visible = false
			Dq.ArBg.Visible = false
			Dq.ArBar.Visible = false
			Dq.ArText.Visible = false
			for mq = 1, 8, 1 do
				Dq.Corners[mq].Visible = false
				Dq.CornerOutlines[mq].Visible = false
			end
			for mq = 1, 5, 1 do
				Dq.Flags[mq].Visible = false
			end
		end
		pq = function(mq)
			local Dq = mq and mq.Draw
			if not Dq then
				return
			end
			local function pq(Oq)
				if Oq then
					pcall(function()
						Oq:Remove()
					end)
				end
			end
			pq(Dq.BoxOutline)
			pq(Dq.Box)
			pq(Dq.Fill)
			pq(Dq.Name)
			pq(Dq.Dist)
			pq(Dq.Weapon)
			pq(Dq.HpBg)
			pq(Dq.HpBar)
			pq(Dq.HpText)
			pq(Dq.ArBg)
			pq(Dq.ArBar)
			pq(Dq.ArText)
			for Oq = 1, 8, 1 do
				pq(Dq.Corners[Oq])
				pq(Dq.CornerOutlines[Oq])
			end
			for Oq = 1, 5, 1 do
				pq(Dq.Flags[Oq])
			end
			mq.Draw = nil
		end
		local function mq(Dq, pq)
			if Dq("Distance.Unit") == "Meters" then
				return math.floor(pq / (Dq("Distance.StudsPerMeter") or 3))
			end
			return math.floor(pq)
		end
		local function Dq(
			pq,
			Oq,
			Sq,
			lq,
			Jq,
			oq,
			Rq,
			Yq,
			Pq,
			Hq,
			Xq,
			zq,
			Aq,
			iq,
			jq,
			fq,
			Zq,
			sq,
			kq,
			wq,
			yp,
			up,
			Ip,
			Up,
			Mp,
			xp,
			Vp,
			Kp
		)
			local mp = a(pq)
			if not mp then
				return
			end
			Kq(pq)
			local a = Oq("Outlines.Color") or Color3.fromRGB(0, 0, 0)
			pq = Oq("Outlines.Style") ~= "None" and Oq("Outlines.Enabled") ~= false
			if Rq then
				if Oq("Names") then
					mp.Name.Text = Jq .. " " .. mq(Oq, oq) .. tostring(Oq("Distance.Ending") or "")
					mp.Name.Size = fq
					mp.Name.Color = Zq
					mp.Name.Position = Vector2.new(iq, jq - fq / 2)
					mp.Name.Visible = true
				end
				return
			end
			local Dp, np, ep = Oq("Boxes"), Oq("BoxThickness") or 1, (Oq("BoxType") or "Normal") == "Corner"
			if Dp and not ep then
				if pq then
					mp.BoxOutline.Position = Vector2.new(Hq - 1, Xq - 1)
					mp.BoxOutline.Size = Vector2.new(zq + 2, Aq + 2)
					mp.BoxOutline.Thickness = np + 2
					mp.BoxOutline.Color = a
					mp.BoxOutline.Visible = true
				end
				mp.Box.Position = Vector2.new(Hq, Xq)
				mp.Box.Size = Vector2.new(zq, Aq)
				mp.Box.Thickness = np
				mp.Box.Color = sq
				mp.Box.Visible = true
			elseif Dp and ep then
				Rq, jq = math.max(math.floor(zq * 0.25), np * 3), math.max(math.floor(Aq * 0.25), np * 3)
				local ep = {
					{ Hq, Xq, Hq + Rq, Xq },
					{ Hq, Xq, Hq, Xq + jq },
					{ Hq + zq - Rq, Xq, Hq + zq, Xq },
					{ Hq + zq, Xq, Hq + zq, Xq + jq },
					{ Hq, Xq + Aq, Hq + Rq, Xq + Aq },
					{ Hq, Xq + Aq - jq, Hq, Xq + Aq },
					{ Hq + zq - Rq, Xq + Aq, Hq + zq, Xq + Aq },
					{ Hq + zq, Xq + Aq - jq, Hq + zq, Xq + Aq },
				}
				for Fp = 1, 8, 1 do
					local ap = ep[Fp]
					local ep, Lp = Vector2.new(ap[1], ap[2]), Vector2.new(ap[3], ap[4])
					if pq then
						ap = mp.CornerOutlines[Fp]
						ap.From = ep
						ap.To = Lp
						ap.Thickness = np + 2
						ap.Color = a
						ap.Visible = true
					end
					local pq = mp.Corners[Fp]
					pq.From = ep
					pq.To = Lp
					pq.Thickness = np
					pq.Color = sq
					pq.Visible = true
				end
			end
			if Dp then
				if Oq("BoxFill.Enabled") then
					mp.Fill.Position = Vector2.new(Hq, Xq)
					mp.Fill.Size = Vector2.new(zq, Aq)
					mp.Fill.Color = Oq("BoxFill.Color")
					mp.Fill.Transparency = 1 - (tonumber(Oq("BoxFill.Transparency")) or 0.9)
					mp.Fill.Visible = true
				end
			end
			if Oq("Names") then
				mp.Name.Text = Jq
				mp.Name.Size = fq
				mp.Name.Color = Zq
				mp.Name.Position = Vector2.new(iq, Xq - fq - (Oq("TextGap") or 0) - Mp)
				mp.Name.Visible = true
			end
			sq = Xq + Aq + (Oq("Distance.Gap") or 0) + xp
			if Oq("Distance.Enabled") then
				jq = Oq("Distance.TextSize") or fq
				mp.Dist.Text = mq(Oq, oq) .. tostring(Oq("Distance.Ending") or "")
				mp.Dist.Size = jq
				mp.Dist.Color = Oq("Distance.Color")
				mp.Dist.Position = Vector2.new(iq, sq)
				mp.Dist.Visible = true
				sq = sq + jq + (Oq("Weapon.Gap") or 0)
			else
			end
			if Oq("Weapon.Enabled") then
				oq = Sq and Sq.Holding or lq:FindFirstChild("Holding")
				xp = if oq
					then if oq:IsA("ValueBase") then if oq.Value then tostring(oq.Value) else nil else oq.Name
					else nil
				if (if xp then xp == "" else not xp) or xp == "nil" then
					if Oq("Weapon.UseToolFallback") then
						Rq = Sq and Sq.Tool or lq:FindFirstChildWhichIsA("Tool")
						xp = if Rq then Rq.Name else xp
					else
					end
				else
				end
				if xp then
					if xp ~= "" then
						if xp ~= "nil" then
							mp.Weapon.Text = xp
							mp.Weapon.Size = Oq("Weapon.TextSize") or fq
							mp.Weapon.Color = Oq("Weapon.Color")
							mp.Weapon.Position = Vector2.new(iq, sq)
							mp.Weapon.Visible = true
						end
					end
				end
			end
			local function mq(pq, Jq, oq, iq, jq, fq, Mp, xp)
				local np, ep, Fp = Oq(iq .. ".Position"), Oq(iq .. ".Width") or 2, Oq(iq .. ".SideGap") or 2
				local ap, Lp, Qp, Bp, Tp, Gp = np == "Top" or np == "Bottom", Oq(iq .. ".Outline.Style") ~= "None"
				if ap then
					Qp = np == "Top" and Xq - Fp - ep or Xq + Aq + Fp
					Bp, Tp, Gp = Hq, zq, ep
				else
					Bp, Qp, Tp, Gp = np == "Left" and Hq - Fp - ep or Hq + zq + Fp, Xq, ep, Aq
				end
				if Lp then
					pq.Position = Vector2.new(Bp - 1, Qp - 1)
					pq.Size = Vector2.new(Tp + 2, Gp + 2)
					pq.Color = Oq(iq .. ".Outline.Color") or a
					pq.Visible = true
				end
				if ap then
					np = math.floor(Tp * Mp)
					Jq.Position = Vector2.new(Bp, Qp)
					Jq.Size = Vector2.new(np, Gp)
				else
					Fp = math.floor(Gp * Mp)
					Jq.Position = Vector2.new(Bp, Qp + Gp - Fp)
					Jq.Size = Vector2.new(Tp, Fp)
				end
				Jq.Color = xp
				Jq.Visible = true
				ep = Oq(iq .. ".ShowText")
				ep = ep and (if Oq(iq .. ".HideWhenFullHP") then if jq >= fq then false else ep else ep)
				if ep and (if Oq(iq .. ".HideWhenFullArmor") then if jq >= fq then false else ep else ep) then
					Lp = Oq(iq .. ".TextSize") or 9
					oq.Text = tostring(math.floor(jq))
					oq.Size = Lp
					oq.Color = Zq
					if ap then
						oq.Position = Vector2.new(Bp + Tp / 2, Qp - Lp - 1)
					else
						oq.Position = Vector2.new(Bp + Tp / 2, Qp - Lp - 1)
					end
					oq.Visible = true
				end
			end
			if Oq("HealthBar.Enabled") then
				if lq:IsA("Model") then
					if Pq then
						mq(mp.HpBg, mp.HpBar, mp.HpText, "HealthBar", kq, wq, yp, Color3.fromHSV(yp * 0.3, 1, 1))
					end
				end
			end
			if Oq("ArmorBar.Enabled") then
				if lq:IsA("Model") then
					if Pq then
						if up > 0 then
							mq(
								mp.ArBg,
								mp.ArBar,
								mp.ArText,
								"ArmorBar",
								up,
								Ip,
								Up,
								Oq("ArmorBar.Gradient.Color1") or Color3.fromRGB(90, 190, 255)
							)
						end
					end
				end
			end
			Rq = Oq("Flags.Enabled") and lq:IsA("Model") and Pq and not Yq
			if Rq then
				Dp, sq = Pq:GetState(), Pq.MoveDirection.Magnitude > 0
				local a, mq, pq =
					Dp == Enum.HumanoidStateType.Jumping
						or Dp == Enum.HumanoidStateType.FallingDown
						or Dp == Enum.HumanoidStateType.Freefall,
					Dp == Enum.HumanoidStateType.Swimming,
					Oq("Flags.TextSize") or 9
				local Jq, oq, Rq = Oq("Flags.Gap") or 2, Oq("Flags.SideGap") or 4, Oq("Flags.TextGap") or 2
				local Yq = Oq("Flags.Position") == "Right" and Hq + zq + oq + Kp or Hq - oq - Vp
				local oq, Pq = Xq - Jq, 0
				local function Jq(Hq, Xq)
					Pq += 1
					local zq = mp.Flags[Pq]
					if not zq then
						return
					end
					zq.Text = Hq
					zq.Size = pq
					zq.Color = Xq
					zq.Position = Vector2.new(Yq, oq + (Pq - 1) * (pq + Rq))
					zq.Visible = true
				end
				if sq and a and Oq("Flags.Options.Moving") and Oq("Flags.Options.Jumping") then
					Jq("Moving & Jumping", Oq("Flags.Colors.Moving"))
				elseif a and (Oq("Flags.Options.Jumping")) then
					Jq("Jumping", Oq("Flags.Colors.Jumping"))
				elseif sq and (Oq("Flags.Options.Moving")) then
					Jq("Moving", Oq("Flags.Colors.Moving"))
				elseif mq and (Oq("Flags.Options.Swimming")) then
					Jq("Swimming", Oq("Flags.Colors.Swimming"))
				elseif Oq("Flags.Options.Idle") then
					Jq("Idle", Oq("Flags.Colors.Idle"))
				end
				if Oq("Flags.Options.ForceField") then
					if lq:FindFirstChildOfClass("ForceField") then
						Jq("FF", Oq("Flags.Colors.ForceField"))
					end
				end
				if Oq("Flags.Options.Downed") then
					if O(Sq and Sq.Player or V:GetPlayerFromCharacter(lq), Sq) then
						Jq("Downed", Oq("Flags.Colors.Downed"))
					end
				end
				if Oq("Flags.Options.Exploiting") then
					if D(Sq and Sq.Player or V:GetPlayerFromCharacter(lq)) then
						Jq("exp", Oq("Flags.Colors.Exploiting"))
					end
				end
			end
		end
		local function a(mq, pq, Oq, Sq, lq, Jq, oq, Rq, Yq, Pq, Hq, Xq)
			local zq = mq.FrameConfigCache
			local Aq = mq.ConfigOverrideRef ~= Pq or mq.ConfigRevisionRef ~= A
			if Aq then
				mq.ConfigOverrideRef = Pq
				mq.ConfigRevisionRef = A
				table.clear(zq)
			end
			local iq = mq.GetCfgFn
			if if iq then mq.GetCfgOverrideRef ~= Pq else not iq then
				mq.GetCfgOverrideRef = Pq
				iq = function(jq)
					local fq = zq[jq]
					if fq ~= nil then
						if fq == H then
							return nil
						end
						return fq
					end
					fq = P(Pq, jq)
					zq[jq] = fq == nil and H or fq
					return fq
				end
				mq.GetCfgFn = iq
			else
			end
			Aq = not Rq
			local H, Pq =
				(if Rq then Aq else Xq and Xq.Humanoid or Jq:FindFirstChild("Humanoid")) or nil, iq("Chams.Enabled")
			local zq = Pq and not Hq
			if zq then
			elseif Pq then
				local jq = iq("Chams.Type")
				jq = if jq == "Adornment" then "BoxHandleAdornment" else jq
				local fq
				local fq = I
				jq = if fq.IsMobile
					then if jq == "CharacterClone" then "Highlight" else if jq == "MeshChams" then "Highlight" else jq
					else jq
				fq = mq.ActiveChamType ~= jq
				mq.ActiveChamType = jq
				local Zq = jq == "Highlight" and (Jq:IsA("Model") or Jq:IsA("BasePart"))
				if Zq then
					qq(mq)
					if mq.MeshShell then
						mq.MeshShell:Destroy()
						mq.MeshShell = nil
						mq.MeshHighlight = nil
					end
					Bq(mq, false)
					cq(mq)
					local Zq = mq.Highlight
					if if Zq then not mq.Highlight.Parent else not Zq then
						if mq.Highlight then
							mq.Highlight:Destroy()
						end
						mq.Highlight = Instance.new("Highlight")
					end
					Zq = mq.Highlight
					h(Zq, "Parent", B)
					h(Zq, "Adornee", Jq)
					h(Zq, "FillColor", iq("Chams.Highlight.FillColor"))
					h(Zq, "FillTransparency", iq("Chams.Highlight.FillTransparency"))
					h(Zq, "OutlineColor", iq("Chams.Highlight.OutlineColor"))
					h(Zq, "OutlineTransparency", iq("Chams.Highlight.OutlineTransparency"))
					h(
						Zq,
						"DepthMode",
						iq("Chams.Highlight.VisibleCheck") and Enum.HighlightDepthMode.Occluded
							or Enum.HighlightDepthMode.AlwaysOnTop
					)
					h(Zq, "Enabled", true)
				else
					local Zq = jq == "BoxHandleAdornment"
					if Zq then
						qq(mq)
						if mq.Highlight then
							h(mq.Highlight, "Enabled", false)
						end
						if mq.MeshShell then
							mq.MeshShell:Destroy()
							mq.MeshShell = nil
							mq.MeshHighlight = nil
						end
						local Zq = Mq(
							mq,
							"NextAdornmentRefresh",
							tick(),
							math.clamp(tonumber(iq("Chams.RefreshRate")) or 0.1, 0.05, 1),
							fq
						)
						if Zq then
							local Zq, sq = U(mq, Jq), mq.ActiveAdornmentParts
							table.clear(sq)
							local kq, wq, yp, up, Ip, Up =
								iq("Chams.Adornment.RoundHead"),
								H and H.RigType == Enum.HumanoidRigType.R6,
								math.clamp(tonumber(iq("Chams.Adornment.R6HeadScale")) or 0.86, 0.5, 1),
								math.max(tonumber(iq("Chams.Adornment.VisibleSize")) or 0, 0),
								iq("Chams.Adornment.Visible.Enabled"),
								I
							local I = Up.IsMobile
							local Mp, xp, Vp, Kp, mp, Dp, np, ep, Fp, ap =
								if I then not I else iq("Chams.Adornment.Glow.Enabled") == true,
								iq("Chams.Adornment.Glow.Color"),
								iq("Chams.Adornment.Glow.Intensity"),
								iq("Chams.Adornment.Glow.Size"),
								iq("Chams.Adornment.Glow.FallbackTransparency"),
								iq("Chams.Adornment.Invisible.Color"),
								iq("Chams.Adornment.Invisible.Transparency"),
								iq("Chams.Adornment.Visible.Color"),
								iq("Chams.Adornment.Visible.Transparency"),
								wq
							for Lp, Qp in ipairs(Zq) do
								if Qp.Parent then
									if Qp:IsA("BasePart") then
										if Qp.Name ~= "HumanoidRootPart" then
											I = kq and (Qp.Name == "Head" or Qp.Name == "FakeHead")
											Up, Lp = I and ap and yp or 1, mq.AdornmentPartInfo[Qp]
											if Lp then
											else
												Lp = {}
												mq.AdornmentPartInfo[Qp] = Lp
											end
											Lp.IsCylinder = I
											Lp.PartSize = Qp.Size
											Lp.HeadScale = Up
											sq[Qp] = Lp
											local Zq = mq.Adornments[Qp]
											if
												Zq
												and (
													typeof(Zq) == "Instance"
													or Zq.IsCylinder ~= I
													or not Zq.Invisible
													or not Zq.Invisible.Parent
													or Zq.Visible and not Zq.Visible.Parent
													or Zq.Glow and not Zq.Glow.Parent
												)
											then
												Lq(Zq)
												Zq = nil
											else
											end
											if Zq then
											else
												Zq = { IsCylinder = I, Invisible = Nq(Qp, I, "ChamInvisible", true, 8) }
												mq.Adornments[Qp] = Zq
											end
											if Ip and not Zq.Visible then
												Zq.Visible = Nq(Qp, I, "ChamVisible", false, 9)
											elseif Ip then
											elseif Zq.Visible then
												aq(Zq, "Visible")
											end
											if Mp and not Zq.Glow then
												local Nq, ap = vq(Qp, I)
												Zq.Glow = Nq
												Zq.GlowXRay = ap
											elseif Mp then
											elseif Zq.Glow then
												aq(Zq, "Glow")
											end
											if Mp then
												_q(Zq, Qp.Size, Kp, xp, Vp, mp, Up)
											end
											rq(Zq, "Invisible", Qp.Size, 0, Dp, np, Up)
											if Ip then
												rq(Zq, "Visible", Qp.Size, up, ep, Fp, Up)
											end
										end
									end
								end
							end
							for I, aq in pairs(mq.Adornments) do
								np = sq[I]
								if if np then not I.Parent else not np then
									Lq(aq)
									mq.Adornments[I] = nil
									mq.AdornmentPartInfo[I] = nil
								end
							end
							for I, I in ipairs(Eq) do
								mp = iq(I.EnabledPath)
								if if I.Key == "Visible" then mp and Ip else mp then
									yp = bq(mq, I.Key)
									wq, Dp = yp.Highlight, I.Key == "Visible" and up or 0
									for aq, Lq in pairs(sq) do
										tq(yp, aq, Lq, Dp)
									end
									for aq, Lq in pairs(yp.Parts) do
										kq = sq[aq]
										if if kq then not aq.Parent else not kq then
											Tq(Lq)
											yp.Parts[aq] = nil
										end
									end
									h(wq, "FillColor", iq(I.FillColorPath))
									h(wq, "FillTransparency", iq(I.FillTransparencyPath))
									h(wq, "OutlineColor", iq(I.OutlineColorPath))
									h(wq, "OutlineTransparency", iq(I.OutlineTransparencyPath))
									h(wq, "DepthMode", I.DepthMode)
									h(wq, "Enabled", true)
								else
									Gq(mq, I.Key)
								end
							end
						end
					else
						local I = jq == "CharacterClone"
						if I then
							if mq.Highlight then
								h(mq.Highlight, "Enabled", false)
							end
							Bq(mq, false)
							cq(mq)
							if mq.MeshShell then
								mq.MeshShell:Destroy()
								mq.MeshShell = nil
								mq.MeshHighlight = nil
							end
							if Jq:IsA("Model") then
								local I, aq, Lq =
									tick(),
									math.clamp(tonumber(iq("Chams.RefreshRate")) or 0.1, 0.05, 1),
									mq.CharacterClone
								if Mq(mq, "NextCharacterCloneRefresh", I, aq, fq) then
									local I, Mq = iq("Chams.CharacterClone.Material"), mq.CharacterCloneStyle
									Mq.Color = iq("Chams.CharacterClone.Color")
									Mq.Transparency =
										math.clamp(tonumber(iq("Chams.CharacterClone.Transparency")) or 0.55, 0, 1)
									Mq.Material = dq[I] or Enum.Material.SmoothPlastic
									Mq.KeepTextures = iq("Chams.CharacterClone.KeepTextures") == true
									Mq.IncludeAccessories = iq("Chams.CharacterClone.IncludeAccessories") ~= false
									Mq.SizeScale =
										math.clamp(tonumber(iq("Chams.CharacterClone.SizeScale")) or 1.015, 1, 1.1)
									Mq.HighlightEnabled = iq("Chams.CharacterClone.Highlight.Enabled") == true
									Mq.HighlightFillColor = iq("Chams.CharacterClone.Highlight.FillColor")
									Mq.HighlightFillTransparency = math.clamp(
										tonumber(iq("Chams.CharacterClone.Highlight.FillTransparency")) or 0.75,
										0,
										1
									)
									Mq.HighlightOutlineColor = iq("Chams.CharacterClone.Highlight.OutlineColor")
									Mq.HighlightOutlineTransparency = math.clamp(
										tonumber(iq("Chams.CharacterClone.Highlight.OutlineTransparency")) or 0.25,
										0,
										1
									)
									Mq.HighlightVisibleCheck = iq("Chams.CharacterClone.Highlight.VisibleCheck") == true
									Cq(mq, Jq, Mq, fq)
								end
							else
								qq(mq)
							end
						else
							local I = jq == "MeshChams"
							if I then
								qq(mq)
								if mq.Highlight then
									h(mq.Highlight, "Enabled", false)
								end
								Bq(mq, false)
								cq(mq)
								local I = V:GetPlayerFromCharacter(Jq)
								if I then
									local I = mq.MeshShell
									local Mq = if I then not mq.MeshShell.Parent else not I
									if Mq then
										if mq.MeshShell then
											mq.MeshShell:Destroy()
											mq.MeshShell = nil
											mq.MeshHighlight = nil
										end
										p(Jq)
										I = Jq:FindFirstChild("Humanoid")
										local aq, Lq =
											I and I.RigType == Enum.HumanoidRigType.R15 and {
												"Head",
												"UpperTorso",
												"LowerTorso",
												"LeftUpperArm",
												"LeftLowerArm",
												"LeftHand",
												"RightUpperArm",
												"RightLowerArm",
												"RightHand",
												"LeftUpperLeg",
												"LeftLowerLeg",
												"LeftFoot",
												"RightUpperLeg",
												"RightLowerLeg",
												"RightFoot",
											} or {
												"Head",
												"Torso",
												"Left Arm",
												"Right Arm",
												"Left Leg",
												"Right Leg",
											}, Instance.new("Model")
										Lq.Name = "ChamShells"
										Lq:SetAttribute("SensoryESP_MeshCham", true)
										Lq:SetAttribute("SensoryESP_RunId", v)
										Lq.Parent = Jq
										for I, Tq in ipairs(aq) do
											I = Jq:FindFirstChild(Tq)
											if I then
												local Gq = I:IsA("BasePart")
												if Gq then
													local Gq = Instance.new("Part")
													Gq.Name = "ChamShell_" .. Tq
													Gq:SetAttribute("SensoryESP_MeshCham", true)
													Gq:SetAttribute("SensoryESP_RunId", v)
													Gq.Size = I.Size * 1.015
													Gq.Transparency = 0.9999999
													Gq.CastShadow = false
													Gq.CanCollide = false
													Gq.CanQuery = false
													Gq.CanTouch = false
													Gq.Anchored = false
													Gq.Massless = true
													Gq.CFrame = I.CFrame
													Gq.Parent = Lq
													local Tq = Instance.new("Weld")
													Tq.Part0 = Gq
													Tq.Part1 = I
													Tq.C0 = CFrame.new()
													Tq.C1 = CFrame.new()
													Tq.Parent = Gq
												end
											end
										end
										aq = Instance.new("Highlight")
										aq.Name = "ChamShellHighlight"
										aq:SetAttribute("SensoryESP_MeshCham", true)
										aq:SetAttribute("SensoryESP_RunId", v)
										aq.Adornee = Lq
										aq.Parent = Lq
										mq.MeshShell = Lq
										mq.MeshHighlight = aq
									end
									if mq.MeshHighlight then
										Mq = mq.MeshHighlight
										h(Mq, "FillColor", iq("Chams.MeshChams.FillColor"))
										h(Mq, "FillTransparency", iq("Chams.MeshChams.FillTransparency"))
										h(Mq, "OutlineColor", iq("Chams.MeshChams.OutlineColor"))
										h(Mq, "OutlineTransparency", iq("Chams.MeshChams.OutlineTransparency"))
										h(
											Mq,
											"DepthMode",
											iq("Chams.MeshChams.VisibleCheck") and Enum.HighlightDepthMode.Occluded
												or Enum.HighlightDepthMode.AlwaysOnTop
										)
										h(Mq, "Enabled", true)
									end
								elseif mq.MeshShell then
									mq.MeshShell:Destroy()
									mq.MeshShell = nil
									mq.MeshHighlight = nil
								end
							else
								if mq.Highlight then
									h(mq.Highlight, "Enabled", false)
								end
								Bq(mq, false)
								cq(mq)
								qq(mq)
								if mq.MeshShell then
									mq.MeshShell:Destroy()
									mq.MeshShell = nil
									mq.MeshHighlight = nil
								end
							end
						end
					end
				end
			else
				mq.ActiveChamType = nil
				if mq.Highlight then
					h(mq.Highlight, "Enabled", false)
				end
				Bq(mq, false)
				cq(mq)
				qq(mq)
				if mq.MeshShell then
					mq.MeshShell:Destroy()
					mq.MeshShell = nil
					mq.MeshHighlight = nil
				end
			end
			Pq = mq.ArrowInner and iq("OffScreenArrows.Enabled") and Jq:IsA("Model")
			if Pq then
				zq = Xq and Xq.RootPart
					or Jq.PrimaryPart
					or Jq:FindFirstChild("HumanoidRootPart")
					or Jq:FindFirstChildWhichIsA("BasePart")
				if zq then
					local I, I, I = q(zq.Position)
					local Mq, aq = X, z
					if I then
						mq.ArrowInner.Visible = false
						mq.ArrowOutline.Visible = false
						mq.ArrowName.Visible = false
						mq.ArrowDist.Visible = false
					else
						local I, X, z, Lq, Tq =
							iq("OffScreenArrows.OrbitRadius"), iq("OffScreenArrows.ArrowMode") == "Compass"
						if X then
							local Gq = e.Character
								and (
									e.Character:FindFirstChild("HumanoidRootPart")
									or e.Character:FindFirstChild("Torso")
									or e.Character:FindFirstChildWhichIsA("BasePart")
								)
							local Cq = Gq and Gq.Position or F.CFrame.Position
							local bq = (Vector3.new(zq.Position.X, 0, zq.Position.Z) - Vector3.new(Cq.X, 0, Cq.Z)).Unit
							Cq = Gq and Gq.CFrame:VectorToObjectSpace(bq) or bq
							z, Lq, Tq = Cq.X, Cq.Z, math.deg(math.atan2(Cq.Z, Cq.X)) + 90
						else
							local Gq = (zq.Position - F.CFrame.Position).Unit
							local Cq = F.CFrame:VectorToObjectSpace(Gq)
							z, Lq, Tq = Cq.X, -Cq.Y, math.deg(math.atan2(-Cq.Y, Cq.X)) + 90
						end
						X = math.sqrt(z * z + Lq * Lq)
						if X > 0.001 then
							z, Lq = z / X, Lq / X
						else
							z, Lq = 0, -1
						end
						local Gq, Cq, bq, Eq =
							Mq + z * I, aq + Lq * I, iq("OffScreenArrows.Size"), iq("OffScreenArrows.Color")
						if iq("OffScreenArrows.Outline") then
							h(mq.ArrowOutline, "TextSize", bq + 2)
							h(mq.ArrowOutline, "TextColor3", iq("OffScreenArrows.OutlineColor"))
							mq.ArrowOutline.Position = UDim2.new(0, Gq - bq - 2, 0, Cq - bq - 2)
							mq.ArrowOutline.Rotation = Tq
							h(mq.ArrowOutline, "Visible", true)
						else
							h(mq.ArrowOutline, "Visible", false)
						end
						I = yq[iq("OffScreenArrows.Font")] or Enum.Font.SourceSans
						h(mq.ArrowInner, "Text", "\226\150\178")
						h(mq.ArrowInner, "Font", I)
						h(mq.ArrowInner, "TextSize", bq)
						h(mq.ArrowInner, "TextColor3", Eq)
						mq.ArrowInner.Position = UDim2.new(0, Gq - bq, 0, Cq - bq)
						mq.ArrowInner.Size = UDim2.new(0, bq * 2, 0, bq * 2)
						mq.ArrowInner.Rotation = Tq
						mq.ArrowInner.Visible = true
						I = Cq + bq + 4
						if iq("OffScreenArrows.Names.Enabled") and Sq then
							if Sq ~= "" then
								Eq, X = iq("OffScreenArrows.Names.Font"), iq("OffScreenArrows.Names.TextSize")
								local z, Mq, aq, Lq, Tq, tq, Nq =
									yq[Eq] or Enum.Font.Code,
									Iq.Loaded[Eq],
									iq("OffScreenArrows.Names.Side"),
									iq("OffScreenArrows.Names.Gap") or 4,
									iq("OffScreenArrows.Names.Color"),
									iq("OffScreenArrows.Names.Outline"),
									iq("OffScreenArrows.Names.OutlineColor")
								h(mq.ArrowName, "Font", z)
								if Mq then
									h(mq.ArrowName, "FontFace", Mq)
								end
								h(mq.ArrowName, "TextSize", X)
								h(mq.ArrowName, "TextColor3", Tq)
								h(mq.ArrowName, "Text", Sq)
								if aq == "Top" then
									mq.ArrowName.Position = UDim2.new(0, Gq - 75, 0, Cq - bq - Lq - X)
								else
									if aq == "Left" then
										mq.ArrowName.Position = UDim2.new(0, Gq - bq - Lq - 150, 0, Cq - 6)
									else
										if aq == "Right" then
											mq.ArrowName.Position = UDim2.new(0, Gq + bq + Lq, 0, Cq - 6)
										else
											mq.ArrowName.Position = UDim2.new(0, Gq - 75, 0, I)
											I = I + X + 1
										end
									end
								end
								W(mq.ArrowName, tq and "Full" or "None", Nq or Color3.fromRGB(0, 0, 0))
								mq.ArrowName.Visible = true
							else
								mq.ArrowName.Visible = false
							end
						else
							mq.ArrowName.Visible = false
						end
						if iq("OffScreenArrows.Distance.Enabled") then
							X, Eq = iq("OffScreenArrows.Distance.Font"), iq("OffScreenArrows.Distance.TextSize")
							local z, Mq, aq, Lq, Tq, tq, Nq, _q =
								yq[X] or Enum.Font.Code,
								Iq.Loaded[X],
								iq("OffScreenArrows.Distance.Side"),
								iq("OffScreenArrows.Distance.Gap") or 2,
								iq("OffScreenArrows.Distance.Color"),
								iq("OffScreenArrows.Distance.Outline"),
								iq("OffScreenArrows.Distance.OutlineColor"),
								if iq("Distance.Unit") == "Meters"
									then math.floor(lq / iq("Distance.StudsPerMeter"))
									else math.floor(lq)
							h(mq.ArrowDist, "Font", z)
							if Mq then
								h(mq.ArrowDist, "FontFace", Mq)
							end
							h(mq.ArrowDist, "TextSize", Eq)
							h(mq.ArrowDist, "TextColor3", Tq)
							mq.ArrowDist.Text = _q .. iq("Distance.Ending")
							if aq == "Top" then
								mq.ArrowDist.Position = UDim2.new(0, Gq - 75, 0, Cq - bq - Lq - Eq)
							elseif aq == "Left" then
								mq.ArrowDist.Position = UDim2.new(0, Gq - bq - Lq - 150, 0, Cq - 6)
							elseif aq == "Right" then
								mq.ArrowDist.Position = UDim2.new(0, Gq + bq + Lq, 0, Cq - 6)
							else
								mq.ArrowDist.Position = UDim2.new(0, Gq - 75, 0, I)
							end
							W(mq.ArrowDist, tq and "Full" or "None", Nq or Color3.fromRGB(0, 0, 0))
							mq.ArrowDist.Visible = true
						else
							mq.ArrowDist.Visible = false
						end
					end
				else
					mq.ArrowInner.Visible = false
					mq.ArrowOutline.Visible = false
					mq.ArrowName.Visible = false
					mq.ArrowDist.Visible = false
				end
			elseif mq.ArrowInner then
				mq.ArrowInner.Visible = false
				mq.ArrowOutline.Visible = false
				mq.ArrowName.Visible = false
				mq.ArrowDist.Visible = false
			end
			if iq("Skeleton.Enabled") then
				if Hq then
					if not oq then
						Wq(mq, Jq, iq, Xq)
					end
				end
			else
				xq(mq)
			end
			if (if Hq then not pq else not Hq) or not Oq then
				h(mq.Container, "Visible", false)
				Kq(mq)
				return
			end
			h(mq.Container, "Visible", true)
			h(mq.Container, "ZIndex", Rq and 1 or 10)
			if iq("Names") then
				h(mq.Text, "Text", Sq)
			end
			Pq = iq("TextOutlineStyle")
			Pq = if iq("TextOutline") == false then "None" else Pq
			local I, X, z, Mq, aq, Lq =
				iq("TextOutlineColor") or iq("Outlines.Color"),
				iq("BoxThickness"),
				iq("Outlines.Thickness"),
				iq("TextSize"),
				iq("TextColor"),
				(if Rq then Aq else Jq:IsA("Model")) and (Xq and Xq.Player or V:GetPlayerFromCharacter(Jq)) or nil
			if Lq then
				local Tq
				Rq = M
				Aq = Rq(Lq)
				aq = if Aq == "Enemy"
					then (iq("PlayerStatusColors.Target"))
					else if Aq == "Friendly" then (iq("PlayerStatusColors.Friendly")) else aq
			else
			end
			Hq = iq("Font")
			Aq, zq, Rq = yq[Hq] or Enum.Font.Code, Iq.Loaded[Hq], iq("BoxColor")
			h(mq.Text, "TextSize", Mq)
			h(mq.Text, "TextColor3", aq)
			h(mq.Text, "Font", Aq)
			if zq then
				h(mq.Text, "FontFace", zq)
			end
			W(mq.Text, Pq, I)
			Hq = iq("Distance.Font")
			zq = yq[Hq] or Enum.Font.Code
			h(mq.DistanceText, "TextSize", iq("Distance.TextSize") or Mq)
			h(mq.DistanceText, "TextColor3", iq("Distance.Color"))
			h(mq.DistanceText, "Font", zq)
			if Iq.Loaded[Hq] then
				h(mq.DistanceText, "FontFace", Iq.Loaded[Hq])
			end
			W(mq.DistanceText, iq("Distance.OutlineStyle") or Pq, I)
			Hq = iq("Weapon.Font")
			Aq = yq[Hq] or Enum.Font.Code
			h(mq.WeaponText, "TextSize", iq("Weapon.TextSize") or Mq)
			h(mq.WeaponText, "TextColor3", iq("Weapon.Color"))
			h(mq.WeaponText, "Font", Aq)
			if Iq.Loaded[Hq] then
				h(mq.WeaponText, "FontFace", Iq.Loaded[Hq])
			end
			W(mq.WeaponText, iq("Weapon.OutlineStyle") or Pq, I)
			local Tq, Gq, Cq, bq = math.floor(pq.X), math.floor(pq.Y), math.floor(Oq.X), math.floor(Oq.Y)
			pq, Hq, Aq, zq, Oq = math.floor(Tq - Cq / 2), math.floor(Gq - bq / 2), 100, 100, 1
			if H then
				Aq, zq = H.Health, H.MaxHealth
				Oq = math.clamp(Aq / zq, 0, 1)
			else
			end
			local Eq, tq, Nq = 0, 100, 0
			if iq("ArmorBar.Enabled") and H then
				if Jq:IsA("Model") then
					Eq, tq, Nq = gq(Jq, Xq)
				else
				end
			else
			end
			local _q, vq, rq, dq = 0, 0, 0, 0
			if iq("HealthBar.Enabled") and Jq:IsA("Model") and H then
				local Wq, gq, jq, jq =
					iq("HealthBar.Position"),
					iq("HealthBar.Width") + 2 + iq("HealthBar.SideGap"),
					iq("Flags.Position") == "Right",
					iq("HealthBar.ShowText") and Aq < zq and 20 or 0
				if Wq == "Top" then
					_q = gq
				else
					if Wq == "Bottom" then
						vq = gq
					else
						if Wq == "Left" then
							rq = gq + jq
						else
							dq = if Wq == "Right" then gq + jq else dq
						end
					end
				end
			else
			end
			if iq("ArmorBar.Enabled") and Jq:IsA("Model") and H and Eq > 0 then
				local Wq, gq, jq =
					iq("ArmorBar.Position"),
					iq("ArmorBar.Width") + 2 + iq("ArmorBar.SideGap"),
					iq("ArmorBar.ShowText") and Eq < tq and 20 or 0
				gq = if iq("HealthBar.Enabled")
					then if iq("HealthBar.Position") == Wq
						then gq + iq("HealthBar.Width") + 3 + iq("HealthBar.SideGap")
						else gq
					else gq
				if Wq == "Top" then
					_q = math.max(_q, gq)
				else
					if Wq == "Bottom" then
						vq = math.max(vq, gq)
					else
						if Wq == "Left" then
							rq = math.max(rq, gq + jq)
						else
							dq = if Wq == "Right" then math.max(dq, gq + jq) else dq
						end
					end
				end
			else
			end
			if iq("DrawingMode") then
				if Vq then
					h(mq.Container, "Visible", false)
					Dq(
						mq,
						iq,
						Xq,
						Jq,
						Sq,
						lq,
						oq,
						Yq,
						H,
						pq,
						Hq,
						Cq,
						bq,
						Tq,
						Gq,
						Mq,
						aq,
						Rq,
						Aq,
						zq,
						Oq,
						Eq,
						tq,
						Nq,
						_q,
						vq,
						rq,
						dq
					)
					return
				end
			end
			Kq(mq)
			if oq then
				for Vq = 1, 4, 1 do
					mq.Lines[Vq].Visible = false
					mq.Outlines[Vq].Visible = false
				end
				mq.HealthBarOutline.Visible = false
				mq.HealthText.Visible = false
				mq.ArmorBarOutline.Visible = false
				mq.ArmorText.Visible = false
				mq.WeaponText.Visible = false
				for Vq, Vq in ipairs(mq.FlagLabels) do
					Vq.Visible = false
				end
				local Vq = if iq("Distance.Unit") == "Meters"
					then math.floor(lq / iq("Distance.StudsPerMeter"))
					else math.floor(lq)
				h(mq.Text, "Text", Sq .. " " .. Vq .. iq("Distance.Ending"))
				mq.Text.Position = UDim2.new(0, Tq - 50, 0, Gq - Mq / 2)
				mq.Text.Visible = iq("Names")
				mq.DistanceText.Visible = false
				return
			end
			if mq.BoxGeoX ~= pq or mq.BoxGeoY ~= Hq or mq.BoxGeoSX ~= Cq or mq.BoxGeoSY ~= bq or mq.BoxGeoT ~= X then
				mq.BoxGeoX = pq
				mq.BoxGeoY = Hq
				mq.BoxGeoSX = Cq
				mq.BoxGeoSY = bq
				mq.BoxGeoT = X
				mq.Lines[1].Position = UDim2.new(0, pq, 0, Hq)
				mq.Lines[1].Size = UDim2.new(0, Cq, 0, X)
				mq.Lines[2].Position = UDim2.new(0, pq, 0, Hq + bq)
				mq.Lines[2].Size = UDim2.new(0, Cq + X, 0, X)
				mq.Lines[3].Position = UDim2.new(0, pq, 0, Hq)
				mq.Lines[3].Size = UDim2.new(0, X, 0, bq)
				mq.Lines[4].Position = UDim2.new(0, pq + Cq, 0, Hq)
				mq.Lines[4].Size = UDim2.new(0, X, 0, bq + X)
			end
			local Vq, Dq, aq, Wq, gq =
				iq("Boxes"),
				(iq("BoxType") or "Normal") == "Corner",
				iq("Outlines.Style"),
				iq("Outlines.Color"),
				iq("Outlines.Thickness")
			Gq = (if iq("Outlines.Enabled") == false then "None" else aq) ~= "None"
			if Dq then
				local aq, jq = math.max(math.floor(Cq * 0.25), X * 3), math.max(math.floor(bq * 0.25), X * 3)
				S(mq.CornerLines[1], pq, Hq, aq, X)
				S(mq.CornerLines[2], pq, Hq, X, jq)
				S(mq.CornerLines[3], pq + Cq - aq + X, Hq, aq, X)
				S(mq.CornerLines[4], pq + Cq, Hq, X, jq)
				S(mq.CornerLines[5], pq, Hq + bq, aq, X)
				S(mq.CornerLines[6], pq, Hq + bq - jq + X, X, jq)
				S(mq.CornerLines[7], pq + Cq - aq + X, Hq + bq, aq, X)
				S(mq.CornerLines[8], pq + Cq, Hq + bq - jq + X, X, jq)
			end
			X = mq.OutlineOffsetCache
			if mq.OutlineThicknessCache ~= gq or not X then
				mq.OutlineThicknessCache = gq
				X = { Position = UDim2.new(0, -gq, 0, -gq), Size = UDim2.new(1, gq * 2, 1, gq * 2) }
				mq.OutlineOffsetCache = X
			else
			end
			oq = Vq and not Dq
			gq = oq and Gq
			for S = 1, 4, 1 do
				h(mq.Lines[S], "Visible", oq)
				h(mq.Outlines[S], "Visible", gq)
				h(mq.Outlines[S], "Position", X.Position)
				h(mq.Outlines[S], "Size", X.Size)
				h(mq.Outlines[S], "BackgroundTransparency", 0)
				h(mq.Lines[S], "BackgroundColor3", Rq)
				h(mq.Outlines[S], "BackgroundColor3", Wq)
			end
			gq = Vq and Dq
			oq = gq and Gq
			if gq or mq.CornerWasVisible then
				mq.CornerWasVisible = gq
				for S = 1, 8, 1 do
					h(mq.CornerLines[S], "Visible", gq)
					h(mq.CornerOutlines[S], "Visible", oq)
					h(mq.CornerOutlines[S], "Position", X.Position)
					h(mq.CornerOutlines[S], "Size", X.Size)
					h(mq.CornerOutlines[S], "BackgroundTransparency", 0)
					h(mq.CornerLines[S], "BackgroundColor3", Rq)
					h(mq.CornerOutlines[S], "BackgroundColor3", Wq)
				end
			end
			Gq, gq = mq.BoxFill, mq.BoxFillGradient
			if iq("BoxFill.Enabled") and Vq then
				Gq.Visible = true
				Gq.Position = UDim2.new(0, pq, 0, Hq)
				Gq.Size = UDim2.new(0, Cq, 0, bq)
				h(Gq, "BackgroundTransparency", iq("BoxFill.Transparency"))
				if iq("BoxFill.Gradient.Enabled") then
					h(gq, "Enabled", true)
					g(
						mq,
						"BoxFillGradient",
						gq,
						iq("BoxFill.Gradient.Color1"),
						iq("BoxFill.Gradient.Color2"),
						(iq("BoxFill.Gradient.Color3"))
					)
					Wq = iq("BoxFill.Gradient.Rotation")
					if iq("BoxFill.Gradient.Animated") then
						X, Rq = iq("BoxFill.Gradient.Speed"), iq("BoxFill.Gradient.Direction") == "Left" and -1 or 1
						Wq = (Wq + _now * X * Rq) % 360
					else
					end
					gq.Rotation = Wq
					h(Gq, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
				else
					h(gq, "Enabled", false)
					h(Gq, "BackgroundColor3", iq("BoxFill.Color"))
				end
			else
				Gq.Visible = false
			end
			Dq, Rq, X = Hq - Mq - (iq("TextGap") or 0) - _q, "", ""
			if iq("TeamIndicator.Enabled") and Lq and Lq.Team then
				oq, Vq =
					iq("TeamIndicator.UseTeamColor") and Lq.TeamColor.Color or iq("TeamIndicator.Color"), Lq.Team.Name
				Wq = iq("TeamIndicator.Compact") and w(Vq) or Vq
				gq = string.format('<font color="%s">[%s]</font>', k(oq), Wq)
				if iq("TeamIndicator.Position") == "Left" then
					Rq = gq
				else
					X = gq
				end
			else
			end
			Vq = false
			if Lq then
				if iq("FriendlyIndicator.Enabled") then
					gq = if iq("FriendlyIndicator.CheckTeam") and e.Team ~= nil
						then if Lq.Team == e.Team then true else Vq
						else Vq
					Vq = gq or (if iq("FriendlyIndicator.CheckFriends") then (Qq(Lq)) else gq)
				else
				end
			else
			end
			if Vq then
				Wq = string.format(
					'<font color="%s">%s</font>',
					k(iq("FriendlyIndicator.Color")),
					tostring(iq("FriendlyIndicator.Text") or "[F]")
				)
				if iq("FriendlyIndicator.Position") == "Left" then
					Rq = Rq == "" and Wq or Rq .. " " .. Wq
				else
					X = X == "" and Wq or X .. " " .. Wq
				end
			else
			end
			Gq = if Rq ~= "" then Rq .. " " .. Sq else Sq
			Gq = if X ~= "" then Gq .. " " .. X else Gq
			if iq("Names") then
				h(mq.Text, "RichText", Rq ~= "" or X ~= "")
				h(mq.Text, "Text", Gq)
				mq.Text.Position = UDim2.new(0, Tq - 50, 0, Dq)
				mq.Text.Visible = true
			else
				mq.Text.Visible = false
			end
			Dq = iq("Distance.Gap") or 0
			X = Hq + bq + Dq + vq
			if iq("Distance.Enabled") then
				mq.DistanceText.Visible = true
				mq.DistanceText.Position = UDim2.new(0, Tq - 50, 0, X)
				oq = if iq("Distance.Unit") == "Meters"
					then math.floor(lq / iq("Distance.StudsPerMeter"))
					else math.floor(lq)
				mq.DistanceText.Text = oq .. iq("Distance.Ending")
				X = X + (iq("Distance.TextSize") or Mq) + (iq("Weapon.Gap") or 0)
			else
				mq.DistanceText.Visible = false
			end
			if iq("Weapon.Enabled") then
				oq = Xq and Xq.Holding or Jq:FindFirstChild("Holding")
				Vq = if oq
					then if oq:IsA("ValueBase") then if oq.Value then tostring(oq.Value) else nil else oq.Name
					else nil
				if (if Vq then Vq == "" else not Vq) or Vq == "nil" then
					if iq("Weapon.UseToolFallback") then
						Mq = Xq and Xq.Tool or Jq:FindFirstChildWhichIsA("Tool")
						Vq = if Mq then Mq.Name else Vq
					else
					end
				else
				end
				if Vq and Vq ~= "" then
					if Vq ~= "nil" then
						mq.WeaponText.Visible = true
						mq.WeaponText.Text = Vq
						mq.WeaponText.Position = UDim2.new(0, Tq - 50, 0, X)
					else
						mq.WeaponText.Visible = false
					end
				else
					mq.WeaponText.Visible = false
				end
			else
				mq.WeaponText.Visible = false
			end
			if iq("HealthBar.Enabled") and Jq:IsA("Model") and H then
				X = iq("HealthBar.Position")
				Vq, Wq, Gq, oq, Dq =
					X == "Top" or X == "Bottom",
					iq("HealthBar.Width"),
					iq("HealthBar.SideGap"),
					iq("HealthBar.TextFollowBar"),
					iq("HealthBar.Outline.Style")
				Dq = if iq("HealthBar.Outline.Enabled") == false then "None" else Dq
				mq.HealthBarOutline.Visible = Dq ~= "None"
				h(mq.HealthBarOutline, "BackgroundTransparency", 0)
				h(mq.HealthBarOutline, "BackgroundColor3", iq("HealthBar.Outline.Color"))
				if Vq then
					Mq = math.floor((Cq + 1) * Oq)
					mq.HealthBarOutline.Size = UDim2.new(0, Cq + 3, 0, Wq + 2)
					if X == "Top" then
						mq.HealthBarOutline.Position = UDim2.new(0, pq - 1, 0, Hq - z - Gq - Wq - 1)
					else
						mq.HealthBarOutline.Position = UDim2.new(0, pq - 1, 0, Hq + bq + z + Gq)
					end
					mq.HealthBarContainer.Size = UDim2.new(0, Mq, 0, Wq)
					mq.HealthBarContainer.Position = UDim2.new(0, 1, 0, 1)
					mq.HealthBar.Size = UDim2.new(0, Cq + 1, 0, Wq)
					mq.HealthBar.Position = UDim2.new(0, 0, 0, 0)
				else
					Sq = math.floor((bq + 1) * Oq)
					mq.HealthBarOutline.Size = UDim2.new(0, Wq + 2, 0, bq + 3)
					if X == "Left" then
						mq.HealthBarOutline.Position = UDim2.new(0, pq - z - Gq - Wq - 1, 0, Hq - 1)
					else
						mq.HealthBarOutline.Position = UDim2.new(0, pq + Cq + z + Gq, 0, Hq - 1)
					end
					mq.HealthBarContainer.Size = UDim2.new(0, Wq, 0, Sq)
					mq.HealthBarContainer.Position = UDim2.new(0, 1, 0, bq + 1 - Sq + 1)
					mq.HealthBar.Size = UDim2.new(0, Wq, 0, bq + 1)
					mq.HealthBar.Position = UDim2.new(0, 0, 0, -(bq + 1 - Sq))
				end
				Tq = iq("HealthBar.Gradient.Enabled")
				h(mq.HealthGradient, "Enabled", Tq and not Vq)
				g(
					mq,
					"HealthGradient",
					mq.HealthGradient,
					iq("HealthBar.Gradient.Color1"),
					iq("HealthBar.Gradient.Color2"),
					iq("HealthBar.Gradient.Color3")
				)
				lq = iq("HealthBar.ShowText")
				lq = if iq("HealthBar.HideWhenFullHP") then if Aq >= zq then false else lq else lq
				gq, Rq = lq and (iq("HealthBar.FollowGradientColorText")), Color3.fromHSV(Oq * 0.3, 1, 1)
				if Tq and not Vq then
					h(mq.HealthGradient, "Rotation", 90)
					h(mq.HealthBar, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
					if gq then
						if Oq > 0.5 then
							local S = (1 - Oq) * 2
							Rq = iq("HealthBar.Gradient.Color1"):Lerp(iq("HealthBar.Gradient.Color2"), S)
						else
							local S = (0.5 - Oq) * 2
							Rq = iq("HealthBar.Gradient.Color2"):Lerp(iq("HealthBar.Gradient.Color3"), S)
						end
					else
					end
				else
					h(mq.HealthBar, "BackgroundColor3", Rq)
				end
				if lq then
					mq.HealthText.Visible = true
					mq.HealthText.Text = math.floor(Aq)
					h(mq.HealthText, "TextSize", iq("HealthBar.TextSize"))
					local S = iq("HealthBar.Font")
					local k = yq[S] or Enum.Font.Code
					h(mq.HealthText, "Font", k)
					if Iq.Loaded[S] then
						h(mq.HealthText, "FontFace", Iq.Loaded[S])
					end
					S = nil
					S, Rq = mq.HealthText, gq and Rq
					h(S, "TextColor3", Rq or iq("TextColor"))
					W(mq.HealthText, Dq, I)
					if Vq then
						S, k = pq + math.floor((Cq + 1) * Oq) - 1, mq.HealthBarOutline.Position.Y.Offset
						mq.HealthText.TextXAlignment = Enum.TextXAlignment.Center
						mq.HealthText.Size = UDim2.new(0, 0, 0, 0)
						if oq then
							mq.HealthText.Position = UDim2.new(0, S, 0, k + Wq / 2 + 1)
						else
							mq.HealthText.Position = UDim2.new(0, pq + Cq, 0, k + Wq / 2 + 1)
						end
					else
						local S, k = math.floor((bq + 1) * Oq), mq.HealthBarOutline.Position.X.Offset
						local w = Hq + (bq + 1) - S
						mq.HealthText.TextXAlignment = X == "Left" and Enum.TextXAlignment.Right
							or Enum.TextXAlignment.Left
						mq.HealthText.Size = UDim2.new(0, 0, 0, 0)
						local S, aq = X == "Left" and k - 2 or k + Wq + 4, oq and w or Hq
						mq.HealthText.Position = UDim2.new(0, S, 0, aq)
					end
				else
					mq.HealthText.Visible = false
				end
			else
				mq.HealthBarOutline.Visible = false
				mq.HealthText.Visible = false
			end
			if iq("ArmorBar.Enabled") and Jq:IsA("Model") and H and Eq > 0 then
				oq = iq("ArmorBar.Position")
				Wq, lq, Oq, Rq, Sq, Tq =
					oq == "Top" or oq == "Bottom",
					iq("ArmorBar.Width"),
					iq("ArmorBar.SideGap"),
					iq("ArmorBar.TextFollowBar"),
					iq("ArmorBar.Outline.Style"),
					iq("HealthBar.Enabled") and iq("HealthBar.Position") == oq
				Sq = if iq("ArmorBar.Outline.Enabled") == false then "None" else Sq
				mq.ArmorBarOutline.Visible = Sq ~= "None"
				h(mq.ArmorBarOutline, "BackgroundTransparency", 0)
				h(mq.ArmorBarOutline, "BackgroundColor3", iq("ArmorBar.Outline.Color"))
				gq = nil
				if Wq then
					gq = math.floor((Cq + 1) * Nq)
					mq.ArmorBarOutline.Size = UDim2.new(0, Cq + 3, 0, lq + 2)
					if Tq then
						Dq, Mq = mq.HealthBarOutline.Position.Y.Offset, iq("HealthBar.Width")
						if oq == "Top" then
							mq.ArmorBarOutline.Position = UDim2.new(0, pq - 1, 0, Dq - lq - Oq - 3)
						else
							mq.ArmorBarOutline.Position = UDim2.new(0, pq - 1, 0, Dq + Mq + Oq + 3)
						end
					elseif oq == "Top" then
						mq.ArmorBarOutline.Position = UDim2.new(0, pq - 1, 0, Hq - z - Oq - lq - 1)
					else
						mq.ArmorBarOutline.Position = UDim2.new(0, pq - 1, 0, Hq + bq + z + Oq)
					end
					mq.ArmorBarContainer.Size = UDim2.new(0, gq, 0, lq)
					mq.ArmorBarContainer.Position = UDim2.new(0, 1, 0, 1)
					mq.ArmorBar.Size = UDim2.new(0, Cq + 1, 0, lq)
					mq.ArmorBar.Position = UDim2.new(0, 0, 0, 0)
				else
					gq = math.floor((bq + 1) * Nq)
					mq.ArmorBarOutline.Size = UDim2.new(0, lq + 2, 0, bq + 3)
					if Tq then
						Vq, Gq, X =
							mq.HealthBarOutline.Position.X.Offset,
							iq("HealthBar.Width"),
							iq("HealthBar.ShowText") and Aq < zq and 20 or 0
						if oq == "Left" then
							mq.ArmorBarOutline.Position = UDim2.new(0, Vq - lq - Oq - X - 3, 0, Hq - 1)
						else
							mq.ArmorBarOutline.Position = UDim2.new(0, Vq + Gq + Oq + X + 3, 0, Hq - 1)
						end
					elseif oq == "Left" then
						mq.ArmorBarOutline.Position = UDim2.new(0, pq - z - Oq - lq - 1, 0, Hq - 1)
					else
						mq.ArmorBarOutline.Position = UDim2.new(0, pq + Cq + z + Oq, 0, Hq - 1)
					end
					mq.ArmorBarContainer.Size = UDim2.new(0, lq, 0, gq)
					mq.ArmorBarContainer.Position = UDim2.new(0, 1, 0, bq + 1 - gq + 1)
					mq.ArmorBar.Size = UDim2.new(0, lq, 0, bq + 1)
					mq.ArmorBar.Position = UDim2.new(0, 0, 0, -(bq + 1 - gq))
				end
				local S = iq("ArmorBar.Gradient.Enabled")
				h(mq.ArmorGradient, "Enabled", S and not Wq)
				g(
					mq,
					"ArmorGradient",
					mq.ArmorGradient,
					iq("ArmorBar.Gradient.Color1"),
					iq("ArmorBar.Gradient.Color2"),
					iq("ArmorBar.Gradient.Color3")
				)
				local g = iq("ArmorBar.ShowText")
				g = if iq("ArmorBar.HideWhenFullArmor") then if Eq >= tq then false else g else g
				local z, k = g and (iq("ArmorBar.FollowGradientColorText")), iq("ArmorBar.Gradient.Color1")
				if S and not Wq then
					h(mq.ArmorGradient, "Rotation", 90)
					h(mq.ArmorBar, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
					if z then
						if Nq > 0.5 then
							local w = (1 - Nq) * 2
							k = iq("ArmorBar.Gradient.Color1"):Lerp(iq("ArmorBar.Gradient.Color2"), w)
						else
							local w = (0.5 - Nq) * 2
							k = iq("ArmorBar.Gradient.Color2"):Lerp(iq("ArmorBar.Gradient.Color3"), w)
						end
					else
					end
				else
					if Nq > 0.5 then
						local w = (1 - Nq) * 2
						k = iq("ArmorBar.Gradient.Color1"):Lerp(iq("ArmorBar.Gradient.Color2"), w)
					else
						local w = (0.5 - Nq) * 2
						k = iq("ArmorBar.Gradient.Color2"):Lerp(iq("ArmorBar.Gradient.Color3"), w)
					end
					h(mq.ArmorBar, "BackgroundColor3", k)
				end
				if g then
					mq.ArmorText.Visible = true
					mq.ArmorText.Text = math.floor(Eq)
					h(mq.ArmorText, "TextSize", iq("ArmorBar.TextSize"))
					S = iq("ArmorBar.Font")
					h(mq.ArmorText, "Font", yq[S] or Enum.Font.Code)
					if Iq.Loaded[S] then
						h(mq.ArmorText, "FontFace", Iq.Loaded[S])
					end
					local g
					g, k = mq.ArmorText, z and k
					h(g, "TextColor3", k or iq("TextColor"))
					W(mq.ArmorText, Sq, I)
					mq.ArmorText.Size = UDim2.new(0, 0, 0, 0)
					if Wq then
						local W, S = pq + gq - 1, mq.ArmorBarOutline.Position.Y.Offset
						mq.ArmorText.TextXAlignment = Enum.TextXAlignment.Center
						mq.ArmorText.Position = UDim2.new(0, Rq and W or pq + Cq, 0, S + lq / 2 + 1)
					else
						local W, S = mq.ArmorBarOutline.Position.X.Offset, Hq + (bq + 1) - gq
						mq.ArmorText.TextXAlignment = oq == "Left" and Enum.TextXAlignment.Right
							or Enum.TextXAlignment.Left
						g = oq == "Left" and W - 2 or W + lq + 4
						mq.ArmorText.Position = UDim2.new(0, g, 0, Rq and S or Hq)
					end
				else
					mq.ArmorText.Visible = false
				end
			else
				mq.ArmorBarOutline.Visible = false
				mq.ArmorText.Visible = false
			end
			for W, W in ipairs(mq.FlagLabels) do
				W.Visible = false
			end
			if iq("Flags.Enabled") then
				if Jq:IsA("Model") then
					if Yq then
					elseif H then
						Mq, Gq = H:GetState(), H.MoveDirection.Magnitude > 0
						local W, g, S, H, z, k, w, Vq, aq, Qq, Eq, tq, Nq, _q, vq, Wq, Sq, lq, Yq, zq, jq =
							Mq == Enum.HumanoidStateType.Jumping
								or Mq == Enum.HumanoidStateType.FallingDown
								or Mq == Enum.HumanoidStateType.Freefall,
							Mq == Enum.HumanoidStateType.Swimming,
							iq("Flags.Options.Moving"),
							iq("Flags.Options.Jumping"),
							iq("Flags.Options.Swimming"),
							iq("Flags.Options.Idle"),
							iq("Flags.Options.ForceField"),
							iq("Flags.Options.Downed"),
							iq("Flags.Options.Exploiting"),
							iq("Flags.Colors.Moving"),
							iq("Flags.Colors.Jumping"),
							iq("Flags.Colors.Swimming"),
							iq("Flags.Colors.Idle"),
							iq("Flags.Colors.ForceField"),
							iq("Flags.Colors.Downed"),
							iq("Flags.Font"),
							iq("Flags.TextSize"),
							iq("Flags.TextGap"),
							iq("Flags.Gap") or 2,
							iq("Flags.SideGap"),
							iq("Flags.Position") == "Right"
						Aq, gq = jq and pq + Cq + zq + dq or pq - 100 - zq - rq, Hq - Yq
						gq = if Wq == "Smallest Pixel-7" then gq - 3 else gq
						Tq, zq, Rq, X, oq, Oq =
							yq[Wq] or Enum.Font.Code, Iq.Loaded[Wq], iq("Flags.OutlineStyle") or Pq, 0
						if Gq and W and S and H then
							oq, Oq = "Moving & Jumping", Qq
						else
							if W and H then
								oq, Oq = "Jumping", Eq
							else
								if Gq and S then
									oq, Oq = "Moving", Qq
								else
									if g then
										Dq = nil
										if z then
											Dq = "Swimming"
											oq, Oq = Dq, tq
										else
											if k then
												Dq = "Idle"
												oq, Oq = Dq, Nq
											else
											end
										end
									else
										if k then
											bq = "Idle"
											oq, Oq = bq, Nq
										else
										end
									end
								end
							end
						end
						if oq then
							X = 1
							l(mq, X, oq, Oq, Tq, zq, Sq, jq, Aq, gq, lq, Rq, I)
						else
						end
						if w then
							if Jq:FindFirstChildOfClass("ForceField") then
								z = X + 1
								l(mq, z, "FF", _q, Tq, zq, Sq, jq, Aq, gq, lq, Rq, I)
								X = z
							else
							end
						else
						end
						if Vq then
							if O(Lq or Xq and Xq.Player or (V:GetPlayerFromCharacter(Jq)), Xq) then
								g = X + 1
								l(mq, g, "Downed", vq, Tq, zq, Sq, jq, Aq, gq, lq, Rq, I)
								X = g
							else
							end
						else
						end
						if aq then
							if D(Lq or Xq and Xq.Player or (V:GetPlayerFromCharacter(Jq))) then
								l(mq, X + 1, "exp", iq("Flags.Colors.Exploiting"), Tq, zq, Sq, jq, Aq, gq, lq, Rq, I)
							end
						end
					end
				end
			end
		end
		local I = {
			Vector3.new(1, 1, 1),
			Vector3.new(-1, 1, 1),
			Vector3.new(1, -1, 1),
			Vector3.new(-1, -1, 1),
			Vector3.new(1, 1, -1),
			Vector3.new(-1, 1, -1),
			Vector3.new(1, -1, -1),
			Vector3.new(-1, -1, -1),
		}
		local function D(O, W, g, S, l, H)
			local X, z, k = W.X * 0.5, W.Y * 0.5, W.Z * 0.5
			for w, yq in ipairs(I) do
				w, W = s(O * Vector3.new(X * yq.X, z * yq.Y, k * yq.Z))
				g, l, S, H =
					if w < g then w else g, if w > l then w else l, if W < S then W else S, if W > H then W else H
			end
			return g, S, l, H
		end
		local function I(O, W, g, S, l)
			local H, X = O.CFrame, O.Size * 0.5
			local O, z = s(H * Vector3.new(X.X, X.Y, X.Z))
			local k, w = s(H * Vector3.new(-X.X, -X.Y, -X.Z))
			W, S, g, l = if O < W then O else W, if O > S then O else S, if z < g then z else g, if z > l then z else l
			W, S = if k < W then k else W, if k > S then k else S
			return W, if w < g then w else g, S, if w > l then w else l
		end
		U = function(O, W)
			if O.BoundingSource ~= W then
				if O.BoundingAddedConnection then
					O.BoundingAddedConnection:Disconnect()
				end
				if O.BoundingRemovedConnection then
					O.BoundingRemovedConnection:Disconnect()
				end
				O.BoundingAddedConnection = nil
				O.BoundingRemovedConnection = nil
				O.BoundingSource = W
				O.BoundingPartsDirty = true
				if W:IsA("Model") then
					O.BoundingAddedConnection = W.ChildAdded:Connect(function()
						O.BoundingPartsDirty = true
					end)
					O.BoundingRemovedConnection = W.ChildRemoved:Connect(function()
						O.BoundingPartsDirty = true
					end)
				end
			end
			if O.BoundingPartsDirty then
				table.clear(O.BoundingParts)
				if W:IsA("Model") then
					for g, g in ipairs(W:GetChildren()) do
						if g:IsA("BasePart") then
							O.BoundingParts[#O.BoundingParts + 1] = g
						end
					end
				elseif W:IsA("BasePart") then
					O.BoundingParts[1] = W
				end
				O.BoundingPartsDirty = false
			end
			return O.BoundingParts
		end
		local O = {
			Vector3.new(-1, -1, -1),
			Vector3.new(-1, -1, 1),
			Vector3.new(-1, 1, -1),
			Vector3.new(-1, 1, 1),
			Vector3.new(1, -1, -1),
			Vector3.new(1, -1, 1),
			Vector3.new(1, 1, -1),
			Vector3.new(1, 1, 1),
		}
		local function W(g, S, l)
			local H = S.LocalBounds
			if H then
				local X = S.BoundingPartsDirty
				if not X then
					local X = f
					local z = X - (S.LocalBoundsAt or 0) < 0.1
					if z then
						local X, z = S.LocalBoundsAll, J.DynamicBoxesIncludeAll
						if X == z then
							return H
						end
					end
				end
			end
			local X, z, k, w, yq, Iq, Mq, Vq, mq, Dq, aq =
				math.abs,
				math.min,
				math.max,
				math.huge,
				math.huge,
				math.huge,
				-math.huge,
				-math.huge,
				-math.huge,
				J.DynamicBoxesIncludeAll,
				0
			for Lq, Lq in ipairs(U(S, g)) do
				if Lq.Parent and (Dq or Lq.Name ~= "HumanoidRootPart" and Lq.Transparency ~= 1) then
					aq += 1
					local g, Qq = l:ToObjectSpace(Lq.CFrame), Lq.Size * 0.5
					local l, Lq, Tq, Gq, Cq, bq = Qq.X, Qq.Y, Qq.Z, g.RightVector, g.UpVector, g.LookVector
					local Qq, Eq, tq, Nq =
						X(Gq.X) * l + X(Cq.X) * Lq + X(bq.X) * Tq,
						X(Gq.Y) * l + X(Cq.Y) * Lq + X(bq.Y) * Tq,
						X(Gq.Z) * l + X(Cq.Z) * Lq + X(bq.Z) * Tq,
						g.Position
					Gq, g, Tq = Nq.X, Nq.Y, Nq.Z
					w, Mq, yq, Vq, Iq, mq =
						(z(w, Gq - Qq)),
						(k(Mq, Gq + Qq)),
						(z(yq, g - Eq)),
						(k(Vq, g + Eq)),
						(z(Iq, Tq - tq)),
						k(mq, Tq + tq)
				else
				end
			end
			if H then
			else
				H = {}
				S.LocalBounds = H
			end
			H.Count = aq
			if aq > 0 then
				H.CenterX, H.CenterY, H.CenterZ = (w + Mq) * 0.5, (yq + Vq) * 0.5, (Iq + mq) * 0.5
				H.HalfX, H.HalfY, H.HalfZ = (Mq - w) * 0.5, (Vq - yq) * 0.5, (mq - Iq) * 0.5
			end
			S.LocalBoundsAt = f
			S.LocalBoundsAll = Dq
			return H
		end
		local function g(S, l, H)
			if H then
				if not H.Parent then
					return false, nil, nil
				end
			else
				return false, nil, nil
			end
			local X = H.CFrame
			H = W(S, l, X)
			if H.Count == 0 then
				return false, nil, nil
			end
			local W, S, z, k, w, yq, Iq, Mq, Vq, mq, Dq =
				H.CenterX, H.CenterY, H.CenterZ, H.HalfX, H.HalfY, H.HalfZ, math.huge, math.huge, -math.huge
			mq, Dq = 0, -math.huge
			for aq, Lq in ipairs(O) do
				H = X:PointToWorldSpace(Vector3.new(W + k * Lq.X, S + w * Lq.Y, z + yq * Lq.Z))
				aq, Lq, l = s(H)
				if l > 0 then
					mq, Iq, Vq, Mq, Dq =
						mq + 1,
						if aq < Iq then aq else Iq,
						if aq > Vq then aq else Vq,
						if Lq < Mq then Lq else Mq,
						if Lq > Dq then Lq else Dq
				else
				end
			end
			if mq == 0 then
				return false, nil, nil
			end
			return true, Vector2.new((Iq + Vq) * 0.5, (Mq + Dq) * 0.5), Vector2.new(Vq - Iq, Dq - Mq)
		end
		local function O(W, S, l)
			local H = if W:IsA("Model")
				then l and l.RootPart
					or W:FindFirstChild("HumanoidRootPart")
					or W:FindFirstChild("Torso")
					or W.PrimaryPart
					or W:FindFirstChildWhichIsA("BasePart")
				else if W:IsA("BasePart") then W else nil
			if H then
				local X = F
				if not X then
					return false, nil, nil
				end
			else
				return false, nil, nil
			end
			local X = H.Position
			local z, k, k = q(X)
			if not k then
				return false, nil, nil
			end
			k = J
			if not k.DynamicBoxes then
				local w = W:IsA("Model") and (l and l.Humanoid or W:FindFirstChild("Humanoid"))
				if w then
					local yq = w.RigType == Enum.HumanoidRigType.R6
					local w, Iq = yq and 2.8 or 3, yq and 3 or 3.5
					local Mq, Mq = s(X + Vector3.new(0, w, 0))
					w, yq = s(X - Vector3.new(0, Iq, 0))
					Iq = math.abs(Mq - yq)
					return true, Vector2.new(z, (Mq + yq) / 2), Vector2.new(Iq * 0.65, Iq)
				end
				local s, w
				if W:IsA("Model") then
					s, w = W:GetBoundingBox()
				else
					s, w = W.CFrame, W.Size
				end
				local yq, Iq, Mq, Vq = D(s, w, math.huge, math.huge, -math.huge, -math.huge)
				return true, Vector2.new((yq + Mq) / 2, (Iq + Vq) / 2), Vector2.new(Mq - yq, Vq - Iq)
			end
			k = J
			if k.DynamicBoxesCheap then
				if W:IsA("Model") then
					return g(W, S, H)
				end
			end
			local g, H, s, w, yq, Iq, Mq =
				math.huge, math.huge, -math.huge, -math.huge, J.DynamicBoxesIncludeAll, 0, W:IsA("BasePart")
			if Mq then
				k = J
				if k.DynamicBoxesCheap then
					g, H, s, w = I(W, g, H, s, w)
				else
					g, H, s, w = D(W.CFrame, W.Size, g, H, s, w)
				end
			else
				l, X = ipairs, y[58](U(S, W))
				for U, W in l(y:t5(X)) do
					z = W.Parent and (yq or W.Name ~= "HumanoidRootPart" and W.Transparency ~= 1)
					if z then
						Iq += 1
						U = J
						if U.DynamicBoxesCheap then
							g, H, s, w = I(W, g, H, s, w)
						else
							g, H, s, w = D(W.CFrame, W.Size, g, H, s, w)
						end
					else
					end
				end
				if Iq == 0 then
					return false, nil, nil
				end
			end
			return true, Vector2.new((g + s) / 2, (H + w) / 2), Vector2.new(s - g, w - H)
		end
		local function I(U)
			if not U then
				return
			end
			h(U.Container, "Visible", false)
			h(U.ArrowInner, "Visible", false)
			h(U.ArrowOutline, "Visible", false)
			h(U.ArrowName, "Visible", false)
			h(U.ArrowDist, "Visible", false)
			Kq(U)
			U.ActiveChamType = nil
			if U.Highlight then
				h(U.Highlight, "Enabled", false)
			end
			Bq(U, false)
			cq(U)
			qq(U)
			if U.MeshShell then
				U.MeshShell:Destroy()
				U.MeshShell = nil
				U.MeshHighlight = nil
			end
			xq(U)
		end
		local function U(D, h)
			if type(h) ~= "table" then
				return true
			elseif #h == 0 then
				return true
			end
			if #h == 1 then
				if h[1] == "" then
					return true
				end
			end
			for W, g in ipairs(h) do
				W = false
				for h, h in ipairs(D:GetChildren()) do
					if h.Name == g then
						W = true
						break
					end
				end
				if not W then
					return false
				end
			end
			return true
		end
		local function D(h, W)
			if type(W) ~= "table" then
				return true
			elseif #W == 0 then
				return true
			end
			if #W == 1 then
				if W[1] == "" then
					return true
				end
			end
			for g, g in ipairs(W) do
				if h.Name == g then
					return true
				end
			end
			return false
		end
		local function h(W, g)
			if g then
				if #g == 0 then
					return false
				end
			else
				return false
			end
			local S = W
			while S and S ~= game do
				for W, W in ipairs(g) do
					if W ~= "" then
						if S.Name:find(W) then
							return true
						end
					end
				end
				S = S.Parent
			end
			return false
		end
		local function W(g)
			if g then
				if g == e then
					return false
				end
			else
				return false
			end
			local S
			local S = M
			return S(g) == "Enemy"
		end
		local function M()
			local g, S = {}, J.Players
			if S then
				local l, H = ipairs, y[58](V:GetPlayers())
				for X, z in l(y:t5(H)) do
					X = J
					if not X.LocalPlayer then
						if z == e then
							continue
						end
					end
					X = J
					if X.OnlyEnemies then
						if not (W(z)) then
							continue
						end
					end
					if z.Character then
						g[z.Character] = { name = z.Name, Cheap = false, Player = z }
					end
				end
			end
			S = J
			for y, l in pairs(S.Directories) do
				local H = if type(l) == "table"
						and l.DisplayName
						and l.DisplayName ~= ""
					then l.DisplayName
					else if type(y) == "string" then y else nil
				if type(l) == "string" then
					y = eq(l)
					if y then
						g[y] = { name = H or y.Name, Cheap = false }
					end
				elseif type(l) == "table" then
					local y = l.Path
					if not y then
						continue
					end
					local X = eq(y)
					if not X then
						continue
					end
					local z, s, k, w, yq =
						l.Cheap or false, l.NonHuman or false, l.NoStatus or false, l.Config or {}, l.Recursive or false
					if l.Multiple then
						for Iq, Mq in ipairs(yq and X:GetDescendants() or X:GetChildren()) do
							if Mq:IsA("Model") or Mq:IsA("BasePart") then
								y, Iq = Mq.Parent, false
								while y and y ~= X and y ~= game do
									if g[y] then
										Iq = true
										break
									end
									y = y.Parent
								end
								if not Iq then
									if D(Mq, l.Names) then
										if U(Mq, l.Contains) then
											if not (h(Mq, l.BlockNames)) then
												g[Mq] = {
													name = H and H ~= "" and H or Mq.Name,
													Cheap = z,
													NonHuman = s,
													NoStatus = k,
													Config = w,
												}
											end
										end
									end
								end
							end
						end
					elseif D(X, l.Names) then
						if U(X, l.Contains) then
							if not (h(X, l.BlockNames)) then
								g[X] = {
									name = H and H ~= "" and H or X.Name,
									Cheap = z,
									NonHuman = s,
									NoStatus = k,
									Config = w,
								}
							end
						end
					end
				end
			end
			for y, U in pairs(g) do
				S = uq[y]
				if S then
					uq[y].name = U.name
					uq[y].Cheap = U.Cheap
					uq[y].NonHuman = U.NonHuman
					uq[y].NoStatus = U.NoStatus
					uq[y].Config = U.Config
					uq[y].Player = U.Player
					if uq[y].Runtime then
						uq[y].Runtime.Player = U.Player or uq[y].Runtime.Player
					else
						uq[y].Runtime = Uq(y, uq[y])
					end
				else
					uq[y] = {
						espObj = hq(U.name),
						name = U.name,
						Cheap = U.Cheap,
						NonHuman = U.NonHuman,
						NoStatus = U.NoStatus,
						Config = U.Config,
						Player = U.Player,
					}
					uq[y].Runtime = Uq(y, uq[y])
					local U = J
					if not U.Enabled then
						I(uq[y].espObj)
					end
				end
			end
			for y, U in pairs(uq) do
				local D, h = U.Player and J.Players and (J.LocalPlayer or U.Player ~= e)
				if D then
					S = J.OnlyEnemies
					h = if S then W(U.Player) else not S
				else
					h = D
				end
				local D, e = h and U.Player.Parent and U.Player.Character == nil and y.Parent, g[y]
				if (if e then not e else not D) or not y.Parent then
					nq(U)
					U.espObj:Destroy()
					uq[y] = nil
				end
			end
		end
		local function y(U)
			local D = t[U]
			if not D then
				return
			end
			for e, e in pairs(D) do
				e:Disconnect()
			end
			t[U] = nil
		end
		local U
		local function D(e)
			if t[e] then
				return
			end
			t[e] = {
				Added = e.CharacterAdded:Connect(function()
					U()
				end),
				Removing = e.CharacterRemoving:Connect(function()
					U()
				end),
			}
		end
		local e, h, W, g = 0, 0, 0, false
		U = function()
			g = true
		end
		local function S()
			local l = N
			if not l then
				return
			end
			l = J.Enabled
			if not l then
				local H = _
				if H then
					for H, H in pairs(uq) do
						I(H.espObj)
					end
					_ = false
				end
				return
			end
			local H, X = tick(), _
			if not X then
				_, h, e = true, 0, 0
			end
			X = F
			if not X then
				return
			end
			l = J.LimitFPS
			if l then
				X = l > 0
				if X then
					local z = H - h
					if z < 1 / l then
						return
					end
					h = H
				end
			end
			X = g and H - e > 0.25
			if X then
				g, e = false, H
				M()
			else
				l = next(J.Directories) ~= nil
				if l then
					local g = H - e > 1
					if g then
						e = H
						M()
					end
				end
			end
			X = H - W > 1
			if X then
				W = H
				j()
			end
			f = H
			Z(F)
			X, l = F.CFrame.Position, J.MaxDistance or 0
			local W, g = l > 0 and l * l or 0
			for z, j in pairs(uq) do
				if if z then not z.Parent else not z then
					g = g or {}
					g[#g + 1] = z
					continue
				end
				H = j.Runtime
				if H then
				else
					H = Uq(z, j)
					j.Runtime = H
				end
				l = H.RootPart or z:IsA("BasePart") and z
				if l then
					local f = X - l.Position
					local X = f.X * f.X + f.Y * f.Y + f.Z * f.Z
					if W > 0 then
						if X > W then
							I(j.espObj)
							continue
						end
					end
					f = j.NeedsRev ~= A or j.NeedsHum ~= H.Humanoid
					if f then
						j.NeedsRev = A
						j.NeedsHum = H.Humanoid
						j.NeedsGeo = K(j.Config, j.Cheap, z, j.NoStatus, H)
						j.NeedsDist = i(j.Config, j.Cheap)
						local I = j.Cheap
						j.NeedsSkeleton = if I then not I else P(j.Config, "Skeleton.Enabled")
					end
					local I, K, P = false
					if j.NeedsGeo then
						I, K, P = O(z, j.espObj, H)
					else
						if j.NeedsSkeleton then
							local O, O, O = q(l.Position)
							I = O
						else
						end
					end
					f = if j.NeedsDist then math.sqrt(X) else 0
					a(j.espObj, K, P, j.name, f, z, j.Cheap, j.NonHuman, j.NoStatus, j.Config, I, H)
				else
					a(j.espObj, nil, nil, j.name, 0, z, j.Cheap, j.NonHuman, j.NoStatus, j.Config, false, H)
				end
			end
			if g then
				for I, I in ipairs(g) do
					W = uq[I]
					if W then
						nq(W)
						W.espObj:Destroy()
						uq[I] = nil
					end
				end
			end
		end
		Q.Unload = function(I)
			N, _ = false, false
			for K, a in pairs(uq) do
				nq(a)
				if a.espObj then
					a.espObj:Destroy()
				end
				uq[K] = nil
			end
			I = c
			if I then
				c:Disconnect()
				c = nil
			end
			I = C
			if I then
				C:Disconnect()
				C = nil
			end
			I = {}
			for K in pairs(t) do
				I[#I + 1] = K
			end
			for K, K in ipairs(I) do
				y(K)
			end
			I = b
			if I then
				b:Disconnect()
				b = nil
			end
			I = E
			if I then
				E:Disconnect()
				E = nil
			end
			if getgenv().SensoryESP_Loop then
				getgenv().SensoryESP_Loop:Disconnect()
				getgenv().SensoryESP_Loop = nil
			end
			I = G
			if I then
				G:Destroy()
				G = nil
			end
			I = B
			if I then
				B:Destroy()
				B = nil
			end
			I = T
			if I then
				T:Destroy()
				T = nil
			end
			d(m)
			for I, I in ipairs(L:GetPlayers()) do
				p(I.Character)
			end
			getgenv().SensoryESP_UI = nil
		end
		Q.Load = function(I, K)
			I:Unload()
			J = R(o(Y), K or {})
			r()
			N, _ = true, false
			v, e, h = n:GenerateGUID(false), 0, 0
			F = m.CurrentCamera
			table.clear(Fq)
			E = m:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				F = m.CurrentCamera
			end)
			c = V.PlayerRemoving:Connect(function(K)
				Fq[K.UserId] = nil
				y(K)
				for y, n in pairs(uq) do
					local e = n.Runtime and n.Runtime.Player or nil
					if n.Player == K or e == K or V:GetPlayerFromCharacter(y) == K then
						nq(n)
						n.espObj:Destroy()
						uq[y] = nil
					end
				end
			end)
			C = V.PlayerAdded:Connect(function(y)
				Fq[y.UserId] = nil
				D(y)
				U()
			end)
			for y, y in ipairs(V:GetPlayers()) do
				D(y)
			end
			b = u.InputBegan:Connect(function(y, u)
				if not u then
					local u = J.Keybind.Enabled
					if u then
						local u = y.KeyCode == J.Keybind.Key
						if u then
							local y = J
							y.Enabled = not y.Enabled
						end
					end
				end
			end)
			getgenv().SensoryESP_Loop = x.RenderStepped:Connect(S)
			M()
			return I
		end
		Q.Refresh = function(y)
			y = N
			if y then
				M()
			end
		end
		Q.ClearSkeletons = function(y)
			for y, y in pairs(uq) do
				if y then
					if y.espObj then
						xq(y.espObj)
					end
				end
			end
			for y, y in ipairs(m:GetChildren()) do
				if y:IsA("Folder") and y.Name == "SensorySkeleton3D" then
					pcall(function()
						y:Destroy()
					end)
				elseif
					y:IsA("BasePart")
					and (
						y.Name == "SensorySkeletonAnchor"
						or y.Name == "SensorySkeletonSegment"
						or y.Name == "SensorySkeletonJoint"
					)
				then
					pcall(function()
						y:Destroy()
					end)
				end
			end
		end
		Q.GetConfig = function(y)
			y = J
			return y
		end
		getgenv().SensoryESP_Unload = function()
			Q:Unload()
		end
		return Q
	end
end

Source.InterceptMovementRemote = function(Bindings)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	return function(y, ...)
		local x
		local x = u
		local u = x()
		local V, V
		if u then
			x = I
			V = y == x.MoveRemote
		else
			V = u
		end
		u = V and getnamecallmethod() == "FireServer"
		if u then
			x = { ... }
			local u = x[1]
			local K = type(u) == "table" and u[1] or nil
			V = type(K) == "table"
			if V then
				pcall(function()
					local m = I
					local D = m.Sprint ~= "off"
					if D then
						m = I
						u[2] = m.Sprint == "sprint"
					end
					D = I
					m = D.Stance ~= "off"
					if m then
						D = I
						u[3] = D.Stance == "crouch"
					end
					m = I
					D = m.SpoofSpeed
					if D then
						m = I
						u[4] = m.SpeedValue
					end
					m, D = K[2], I
					local u = D.HandsMode
					if u then
						D = typeof(m) == "Vector3"
						if D then
							local n = I
							local e, F = n.HandsMode == "handsup"
							if e then
								n = U
								K[1] = m + n
							else
								local n = I
								local e = n.HandsMode == "handsdown"
								if e then
									n = U
									K[1] = m - n
								else
									local U = I
									local n = U.HandsMode == "break"
									if n then
										K[1] = m
									else
										U = I
										if U.HandsMode == "frozen" then
											K[5] = false
										end
									end
								end
							end
						end
					end
					D = I
					m = D.HeadMode == "break"
					if m then
						local U
						u = M
						K[3] = u
					else
						D = I
						if D.HeadMode == "hide" then
							K[4] = false
						end
					end
				end)
				local u = I
				return u.OldNamecall(y, table.unpack(x))
			end
		end
		V = I
		return V.OldNamecall(y, ...)
	end
end

Source.InterceptRaycast = function(Bindings, u)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	local x = Bindings[5]
	return function(y, ...)
		local V, K = { ... }
		local K, m = getnamecallmethod() == "Raycast"
			and u[4][u[6]].Enabled
			and u[4][u[6]].Method == "Raycast"
			and y == workspace
			and V[1]
			and typeof(V[1]) == "Vector3"
			and math.random(1, 100) <= u[4][u[6]].HitChance
		if K then
			local u = true
			pcall(function()
				u = not checkcaller()
			end)
			if u then
				local u
				local u = I
				local I = u(true)
				if I then
					local K
					u = U
					local K, m = u.Character
					if K then
						local u = U
						m = u.Character:FindFirstChildOfClass("Tool")
					else
						m = K
					end
					local u
					K = M
					local u = K(V[1], I, m, true) - V[1]
					m = u.Magnitude > 0
					if m then
						K = typeof(V[2]) == "Vector3" and V[2].Magnitude or 0
						V[2] = u.Unit * math.max(K, u.Magnitude + 1)
						local u = x[4][x[6]]
						return u(y, table.unpack(V))
					end
				end
			end
		end
		V = x[4][x[6]]
		return V(y, ...)
	end
end

Source.GetAmmoIndicatorPosition = function(Bindings)
	local Settings = Bindings[1]
	local FindMagazinePart = Bindings[2]
	local CameraSlot = Bindings[3]
	return function(ViewportSize, Tool)
		local OffsetX = Settings.OffsetX
		local OffsetY = Settings.OffsetY
		local Anchor = Settings.Anchor
		if Anchor == "Magazine" and Tool then
			local MagazinePart, IsViewModel = FindMagazinePart(Tool)
			local Camera = workspace.CurrentCamera or CameraSlot[4][CameraSlot[6]]
			if MagazinePart and Camera and IsViewModel then
				local Point, Visible = Camera:WorldToViewportPoint(MagazinePart.Position)
				if
					Visible
					and Point.Z > 0
					and Point.X >= 0
					and Point.X <= ViewportSize.X
					and Point.Y >= 0
					and Point.Y <= ViewportSize.Y
				then
					return Point.X + OffsetX, Point.Y + OffsetY
				end
			end
			return ViewportSize.X * 0.5 + OffsetX, ViewportSize.Y * 0.5 + OffsetY
		end
		local Horizontal = ViewportSize.X * 0.5
		local Vertical = ViewportSize.Y * 0.5
		if Anchor == "Top Left" or Anchor == "Bottom Left" then
			Horizontal = 60
		elseif Anchor == "Top Right" or Anchor == "Bottom Right" then
			Horizontal = ViewportSize.X - 60
		end
		if Anchor == "Top Left" or Anchor == "Top Center" or Anchor == "Top Right" then
			Vertical = 60
		elseif Anchor == "Bottom Left" or Anchor == "Bottom Center" or Anchor == "Bottom Right" then
			Vertical = ViewportSize.Y - 60
		end
		return Horizontal + OffsetX, Vertical + OffsetY
	end
end

Source.InterceptAimDirections = function(Bindings)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	local x = Bindings[5]
	local V = Bindings[6]
	return function(y, ...)
		local K
		if y then
			local K = u[4][u[6]]
			return K(y, ...)
		end
		local K
		local K = I[4][I[6]].Enabled
		if K then
			local m = I[4][I[6]].Method ~= "Module"
			if m then
				local m = u[4][u[6]]
				return m(y, ...)
			end
		else
			local m = u[4][u[6]]
			return m(y, ...)
		end
		K = math.random(1, 100) > I[4][I[6]].HitChance
		if K then
			local I = u[4][u[6]]
			return I(y, ...)
		end
		local I, m, D = { ... }
		for n = 1, #I, 1 do
			K = I[n]
			if type(K) == "table" then
				if m then
				else
					local e, F = 0, true
					for a, a in pairs(K) do
						e += 1
						if e > 32 then
							break
						end
						if typeof(a) ~= "Vector3" then
							F = false
							break
						end
					end
					if F then
						if e > 0 then
							m, D = K, n
						else
						end
					else
					end
				end
			else
			end
		end
		K = nil
		if D then
			for n = D - 1, 1, -1 do
				if typeof(I[n]) == "Vector3" then
					K = I[n]
					break
				end
			end
		else
		end
		local D = m and K
		if not D then
			local n
			local n = U[4][U[6]]
			if not n then
				U[4][U[6]] = true
			end
			n = u[4][u[6]]
			return n(y, ...)
		end
		local U
		D = M
		local U = D(true)
		if not U then
			D = u[4][u[6]]
			return D(y, ...)
		end
		local M
		D = x
		local M, n = D.Character
		if M then
			D = x
			n = D.Character:FindFirstChildOfClass("Tool")
		else
			n = M
		end
		local x
		M = V
		D = M(K, U, n, true) - K
		K = D.Magnitude <= 0
		if K then
			U = u[4][u[6]]
			return U(y, ...)
		end
		D = D.Unit
		n = D:Cross(Vector3.new(0, 1, 0))
		n = (if n.Magnitude < 0.001 then D:Cross(Vector3.new(1, 0, 0)) else n).Unit
		K = n:Cross(D).Unit
		for U = 1, #m, 1 do
			if U == 1 then
				m[U] = D
			else
				m[U] = (D + n * ((math.random() * 2 - 1) * 0.004) + K * ((math.random() * 2 - 1) * 0.004)).Unit
			end
		end
		M = u[4][u[6]]
		return M(y, table.unpack(I))
	end
end

Source.InterceptCameraCFrame = function(Bindings)
	local Settings = Bindings[1]
	local CameraSlot = Bindings[2]
	return function(Target, Property, Value, ...)
		if type(checkcaller) == "function" and checkcaller() then
			return Settings.CFHook(Target, Property, Value)
		end
		local Camera = CameraSlot[4][CameraSlot[6]]
		if
			Settings.Enabled
			and Settings.Mode == "Remove Recoil & Spread"
			and Target == Camera
			and (Property == "CoordinateFrame" or Property == "coordinateFrame")
		then
			return Settings.CFHook(Target, Property, Camera.CFrame)
		end
		return Settings.CFHook(Target, Property, Value)
	end
end

Source.UpdateAmmoIndicator = function(Bindings, u, u, u)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	return function()
		local y
		local y = u
		local x = y.Bar
		if not x then
			return
		end
		y = u
		if not y.Enabled then
			if x.Visible then
				x.Visible = false
			end
			return
		end
		local V
		y = I
		local I = y.Character
		y = I and (I:FindFirstChildOfClass("Tool"))
		I = y and (y:FindFirstChild("Values"))
		local V, K =
			I and (I:FindFirstChild("Ammo") or I:FindFirstChild("SERVER_Ammo")),
			I and (I:FindFirstChild("StoredAmmo") or I:FindFirstChild("SERVER_StoredAmmo"))
		if not V then
			if x.Visible then
				x.Visible = false
			end
			return
		end
		local m, D = V.Value, V.MaxValue
		D = if if D then D <= 0 else not D then math.max(m, 1) else D
		I = math.clamp(m / D, 0, 1)
		local V
		local V = workspace.CurrentCamera or U[4][U[6]]
		local U, n = V and V.ViewportSize or Vector2.new(1920, 1080)
		V = M
		local M, n = V(U, y)
		x.Position = UDim2.fromOffset(math.floor(M + 0.5), math.floor(n + 0.5))
		U = u
		y = I ~= U.LastPercent
		if y then
			V = u
			V.LastPercent = I
			M = u
			M.Fill.Size = UDim2.new(I, 0, 1, 0)
			U = u
			n = U.Gradient
			if n then
				local e, F = u
				F, e.Grad.Parent = u, u.Fill
				F, e = u
				e, F.Grad.Rotation = u, u.GradientRotation
				local F, a, L = u
				a, L, F.Grad.Color = u, u, ColorSequence.new(u.LowColor, u.HighColor)
				e = u
				e.Fill.BackgroundColor3 = Color3.new(1, 1, 1)
			else
				local e = u
				e.Grad.Parent = nil
				local e, F, a = u
				F, a, e.Fill.BackgroundColor3 = u, u, u.LowColor:Lerp(u.HighColor, I)
			end
		end
		y = u
		n, I = y.Label, u
		M, y = I.ShowText
		if M then
			y = M
		else
			V = u
			y = V.ShowReserve
		end
		if y then
			I, V = K and K.Value or 0, u
			U, M = V.ShowText
			if U then
				local y = u
				M = y.ShowReserve
			else
				M = U
			end
			local y
			if M then
				y = string.format("%d/%d (%d)", m, D, I)
			else
				local U = u
				y = if U.ShowText then string.format("%d/%d", m, D) else string.format("(%d)", I)
			end
			local I = u
			local U = y ~= I.LastText
			if U then
				I = u
				I.LastText = y
				n.Text = y
			end
			if not n.Visible then
				n.Visible = true
			end
		elseif n.Visible then
			n.Visible = false
		end
		if not x.Visible then
			x.Visible = true
		end
	end
end

Source.SetupRaycastVisibility = function(Bindings, u)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	local x = Bindings[5]
	return function()
		local y, V = setmetatable, { __mode = "k" }
		local K, m, D = y({}, V), setmetatable, { __mode = "k" }
		local y, V, n = m({}, D), setmetatable, { __mode = "k" }
		local m, D, e = V({}, n), setmetatable, { __mode = "k" }
		local V = D({}, e)
		local n, e, F = { Left = 0, Time = -math.huge, Deadline = math.huge }, setmetatable, { __mode = "k" }
		n.Scans = e({}, F)
		n.Scan = nil
		n.Last = nil
		n.Base = {}
		n.ServerScratch = {}
		local e = 0
		local F, a, L = Vector3.zero, setmetatable, { __mode = "k" }
		local Q, B = a({}, L), 0
		local a = -math.huge
		local L = RaycastParams.new()
		L.FilterType = Enum.RaycastFilterType.Exclude
		L.IgnoreWater = true
		local T = RaycastParams.new()
		T.FilterType = Enum.RaycastFilterType.Exclude
		T.IgnoreWater = true
		local G = RaycastParams.new()
		G.FilterType = Enum.RaycastFilterType.Include
		G.IgnoreWater = true
		local c = RaycastParams.new()
		c.FilterType = Enum.RaycastFilterType.Exclude
		c.IgnoreWater = true
		local C, b, E, t = {}, { nil }, setmetatable, { __mode = "k" }
		local N = E({}, t)
		local E, t =
			workspace:FindFirstChild("Characters"),
			{
				Head = true,
				Torso = true,
				["Left Arm"] = true,
				["Right Arm"] = true,
				["Left Leg"] = true,
				["Right Leg"] = true,
			}
		local function _(v)
			local r = N[v]
			if r ~= nil then
				if r == 2 then
					return false
				end
				if r == 1 then
					return true
				end
			else
				if v:FindFirstChild("CanHitT") then
					N[v] = 2
					return false
				end
				if v:FindFirstChild("FilterV") then
					N[v] = 1
					return true
				elseif v:GetAttribute("RayHandlerIG") then
					N[v] = 1
					return true
				end
				if E then
					if v:IsDescendantOf(E) then
						if not t[v.Name] then
							N[v] = 1
							return true
						end
					end
				end
				N[v] = 0
			end
			return v.Transparency >= 1 and v.Name ~= "MainPart"
		end
		local function E(t, v)
			for r = 1, 16, 1 do
				r = workspace:Raycast(t, v, c)
				if not r then
					return nil
				end
				if not (_(r.Instance)) then
					return r.Position
				end
				n.Left = n.Left - 1
				local t = n.ServerScratch
				t[#t + 1] = r.Instance
				c.FilterDescendantsInstances = t
			end
			return nil
		end
		local t = { Thickness = 0, Walls = 0, Material = "Unknown", Name = "Unknown", Learned = false }
		local _ = {
			Vector3.new(1, 0, 0),
			Vector3.new(0, 0, 1),
			Vector3.new(0, 1, 0),
			-Vector3.new(1, 0, 0),
			-Vector3.new(0, 0, 1),
			-Vector3.new(0, 1, 0),
			Vector3.new(1, 1, 0) / 1.4142135623730951,
			Vector3.new(1, 0, 1) / 1.4142135623730951,
			Vector3.new(0, 1, 1) / 1.4142135623730951,
			Vector3.new(-1, 1, 0) / 1.4142135623730951,
			Vector3.new(-1, 0, 1) / 1.4142135623730951,
			-Vector3.new(1, 0, 1) / 1.4142135623730951,
			-Vector3.new(-1, 0, 1) / 1.4142135623730951,
			-Vector3.new(0, -1, 1) / 1.4142135623730951,
			Vector3.new(1, 1, 1) / 1.7320508075688772,
			Vector3.new(-1, 1, 1) / 1.7320508075688772,
			Vector3.new(1, 1, -1) / 1.7320508075688772,
			-Vector3.new(1, 1, 1) / 1.7320508075688772,
			-Vector3.new(1, -1, 1) / 1.7320508075688772,
			Vector3.new(1, 2, 0) / 2.23606797749979,
			Vector3.new(-1, 2, 0) / 2.23606797749979,
			Vector3.new(1, 0, 2) / 2.23606797749979,
			Vector3.new(-1, 0, 2) / 2.23606797749979,
			-Vector3.new(-1, 0, 2) / 2.23606797749979,
			-Vector3.new(1, 0, 2) / 2.23606797749979,
		}
		local v = {
			Vector3.new(0, 1, 0),
			Vector3.new(0, -1, 0),
			Vector3.new(0, 0, 1),
			Vector3.new(0, 0, -1),
			Vector3.new(1, 0, 0),
			Vector3.new(-1, 0, 0),
		}
		local r, d, p =
			{
				Vector3.new(1, 0, 0),
				Vector3.new(-1, 0, 0),
				Vector3.new(0, 1, 0),
				Vector3.new(0, -1, 0),
				Vector3.new(0, 0, 1),
				Vector3.new(0, 0, -1),
				Vector3.new(1, 1, 0).Unit,
				Vector3.new(-1, 1, 0).Unit,
			}, { "Fixed", "Hemi", "Bounce", "Femboy", "Random", "Cardinals", "Vector", "Hammersley", "Halo", "Cylinder", "Shell" }, { "Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
		local O, q =
			(function()
				local h = {}
				for W, g in ipairs(d) do
					h[g] = W
				end
				return h
			end)(), { Head = 4, Torso = 3, HumanoidRootPart = 2, ["Left Arm"] = 1, ["Right Arm"] = 1, ["Left Leg"] = 1, ["Right Leg"] = 1 }
		local function h()
			local W = n.Scan
			if W then
				if os.clock() > n.Deadline then
					if coroutine.running() == W.Thread then
						coroutine.yield()
					end
				end
			end
		end
		local function W()
			local g, S = math.clamp
			local S, S = u, tonumber(u.path_Target_Shift_Range) or 3
			return g(S, 0.1, 4)
		end
		local function g(S)
			local l
			local l = u
			local J = l.lead_Enabled and S and S:FindFirstChild("HumanoidRootPart")
			if not J then
				return Vector3.zero
			end
			l = os.clock()
			S = l - a >= 0.25
			if S then
				a = l
				local a, o = pcall(function()
					local R
					local R = I
					return R.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
				end)
				B = a and type(o) == "number" and math.clamp(o, 0, 1) or 0
			end
			S, l = J.AssemblyLinearVelocity, B
			if l <= 0 then
				return Vector3.zero
			elseif S.Magnitude <= 0.1 then
				return Vector3.zero
			end
			J, l = B, u
			local I = J * (u.lead_Scale / 100)
			return S * I
		end
		local function I(a, B, S)
			if not O[B] then
				return
			end
			local l = V[a]
			if l then
			else
				l = {}
				V[a] = l
			end
			a = l[B] or 0
			if S then
				l[B] = math.min(12, a + 3)
			else
				l[B] = math.max(-6, a - 1)
			end
		end
		local function a(B)
			local S
			local S, S = u, math.floor(tonumber(u.path_Max_Miss) or 0)
			if S <= 0 then
				return
			end
			local l = y[B]
			local J = l and l[1]
			if not J then
				return
			end
			J.Shots = (J.Shots or 0) + 1
			if J.Shots <= S then
				return
			end
			table.remove(l, 1)
			if #l == 0 then
				y[B] = nil
			end
			K[B] = nil
		end
		local function B(S, l)
			local J = y[S]
			if J then
			else
				J = {}
				y[S] = J
			end
			for S = #J, 1, -1 do
				if J[S].Method == l.Method then
					table.remove(J, S)
				end
			end
			table.insert(J, 1, l)
			for S = #J, 5, -1 do
				J[S] = nil
			end
		end
		local function S(l, J, o)
			local R = m[l]
			if not R then
				return 0
			end
			l = R[J]
			if l then
				if l < 0 then
					return 0
				elseif l >= o then
					return 0
				end
			else
				return 0
			end
			return l
		end
		local function l(J, o, R)
			local Y = m[J]
			if Y then
			else
				Y = {}
				m[J] = Y
			end
			Y[o] = R
		end
		local function J(o)
			local R, Y, P = {}, {}
			local P = u
			local H = P.hitbox_Parts
			for X, X in ipairs(p) do
				if H[X] then
					P = o:FindFirstChild(X)
					if P then
						R[#R + 1] = P
						Y[#Y + 1] = q[X] or 1
					end
				end
			end
			return R, Y
		end
		local function q(o, R, Y)
			local P = R - o
			if P.Magnitude <= 1.0E-4 then
				return true
			end
			local H
			local H, X = u
			if H.server_Ray_Rules then
				X = E(o, P)
				if not X then
					return true
				end
			else
				local E = workspace:Raycast(o, P, L)
				if not E then
					return true
				end
				X = E.Position
			end
			o = (R - X).Magnitude
			if Y then
				H = e
				if o < H then
					return true, o
				end
			end
			return false, o
		end
		local function E(o, R, Y)
			local P = R - o
			local H = P.Magnitude
			if H <= 1.0E-4 then
				return 0, 0, nil, nil
			end
			local X = P / H
			table.clear(C)
			for z, z in ipairs(n.Base) do
				C[#C + 1] = z
			end
			T.FilterDescendantsInstances = C
			local z, A, i, j = 0, 0
			P = 0
			while true do
				local f = H - z
				if f <= 1.0E-4 then
					break
				end
				local Z = workspace:Raycast(o + X * z, X * f, T)
				if not Z then
					break
				end
				A += 1
				if i then
				else
					i, j = Z.Material, Z.Instance and Z.Instance.Name or nil
				end
				if A > Y then
					return math.huge, A, i, j
				end
				b[1] = Z.Instance
				G.FilterDescendantsInstances = b
				local b, Y = workspace:Raycast(R, -X * H, G), (Z.Position - o).Magnitude
				f = b and (b.Position - o).Magnitude or H
				f = if f < Y then Y else f
				P += f - Y
				C[#C + 1] = Z.Instance
				T.FilterDescendantsInstances = C
				z = f + 0.05
			end
			return P, A, i, j
		end
		local function T()
			local G
			local G, G = u, math.clamp(tonumber(u.path_Scanning_Rate) or 50, 5, 100)
			return 1 / math.max(1, 60 * (G / 100))
		end
		local function G(C, b)
			local o, R = {}
			local R = u
			local Y = R.path_Scan_Types or {}
			for P, P in ipairs(d) do
				if Y[P] then
					o[#o + 1] = P
				end
			end
			local d = V[b]
			if d and #o > 1 then
				table.sort(o, function(b, Y)
					local P, H = d[b] or 0, d[Y] or 0
					if P ~= H then
						return P > H
					end
					return O[b] < O[Y]
				end)
			end
			if C then
				if #o > 1 then
					R = table.find(o, C)
					if R then
						if R > 1 then
							table.remove(o, R)
							table.insert(o, 1, C)
						end
					end
				end
			end
			return o
		end
		local function C(b, d, O)
			if O then
				if O <= 0 then
					return { b }
				end
			else
				return { b }
			end
			local o, R = { b }, CFrame.new(b, d) * CFrame.Angles(0, 0, math.rad(math.random(1, 90)))
			for b, b in ipairs(_) do
				o[#o + 1] = R * (b * O)
			end
			return o
		end
		local function b(_, d, O, o)
			if O then
				if O <= 0 then
					return { _ }
				elseif o <= 0 then
					return { _ }
				end
			else
				return { _ }
			end
			local R, Y = { _ }, if d.Magnitude <= 0.001 then Vector3.new(0, 0, -1) else d.Unit
			d = math.abs(Y.X) < 0.9 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
			local P = Y:Cross(d).Unit
			d = Y:Cross(P).Unit
			for H = 0, o - 1, 1 do
				local X, z = H * 0.6180339887 * 2 * 3.141592653589793, 1 - (H + 0.5) / o
				local o, A = math.sqrt(math.max(0, 1 - z * z)), O * math.random() ^ 0.3333333333333333
				H = P * (o * math.cos(X)) + d * (o * math.sin(X)) + Y * z
				R[#R + 1] = _ + H * A
			end
			return R
		end
		local function _(d, O)
			local o = {}
			for R = 1, d, 1 do
				local d, Y = O * math.random() ^ 0.3333333333333333, math.random() * 2 - 1
				local O, P = d * math.sqrt(math.max(0, 1 - Y * Y)), math.random() * 6.283185307179586
				o[R] = Vector3.new(O * math.cos(P), O * math.sin(P), d * Y)
			end
			return o
		end
		local function d(O, o)
			local R, Y = {}, #v
			local P = math.max(1, math.ceil(O / Y))
			for H = 1, O, 1 do
				local O = math.floor((H - 1) / Y)
				R[H] = v[(H - 1) % Y + 1] * (o * (1 - O / P))
			end
			return R
		end
		local function O(o, R)
			local Y = { Vector3.new(0, 0, 0) }
			for P = 1, o, 1 do
				local H, X, z = P, 0.5, 0
				while H > 0 do
					z = if H % 2 == 1 then z + X else z
					H, X = (math.floor(H / 2)), X * 0.5
				end
				local X, A = P / o, 6.283185307179586 * z
				H = math.acos(1 - 2 * X)
				X = math.sin(H)
				Y[#Y + 1] = Vector3.new(R * X * math.cos(A), R * math.cos(H), R * X * math.sin(A))
			end
			return Y
		end
		local function o(R, Y)
			local P = {}
			for H = 1, R, 1 do
				P[H] =
					Vector3.new((math.random() * 2 - 1) * Y, (math.random() * 2 - 1) * Y, (math.random() * 2 - 1) * Y)
			end
			return P
		end
		local function R(Y, P)
			local H = {}
			for X = 0, Y - 1, 1 do
				local z = X / math.max(Y, 1)
				local Y, A = math.acos(1 - 2 * z), 10.166407384630519 * X
				local X, z, i = math.sin(Y) * math.cos(A), math.sin(Y) * math.sin(A), math.cos(Y)
				H[#H + 1] = Vector3.new(X * P, z * P, i * P)
			end
			return H
		end
		local function Y(P, H)
			local X = {}
			for z = 1, #v, 1 do
				X[z] = v[z] * H
			end
			for v = 1, P, 1 do
				v = math.random() * 2 - 1
				local P, z = H * math.sqrt(math.max(0, 1 - v * v)), math.random() * 6.283185307179586
				X[#X + 1] = Vector3.new(P * math.cos(z), P * math.sin(z), H * v)
			end
			return X
		end
		local function v(P, H, X, z, A)
			local i = {}
			if X then
				i[#i + 1] = P
			end
			if z then
				i[#i + 1] = P + Vector3.new(0, A, 0)
			end
			for X, X in ipairs(H) do
				z = X.Magnitude
				X = if z > A then X * (A / z) else X
				i[#i + 1] = P + X
			end
			return i
		end
		local function P(H, X, z)
			local A = z:Cross(Vector3.new(0, 1, 0))
			A = if A.Magnitude <= 0.001 then z:Cross(Vector3.new(1, 0, 0)) else A
			if A.Magnitude <= 0.001 then
				return { Vector3.zero }
			end
			A = A.Unit
			local i = z:Cross(A)
			if i.Magnitude <= 0.001 then
				return { Vector3.zero }
			end
			i = i.Unit
			z = {}
			for j = 1, H, 1 do
				local f, Z = 6.283185307179586 * (j - 1) / H, j % 2 == 0 and 0.55 or 1
				z[j] = A * (math.cos(f) * X * Z) + i * (math.sin(f) * X * Z)
			end
			return z
		end
		local function H(X, z)
			local A, i = {}, z * 0.5
			for j = 1, X, 1 do
				local f, Z, s = 6.283185307179586 * (j - 1) / X, 0.5 + j % 3 * 0.25, (j % 5 - 2) / 2
				A[j] = Vector3.new(math.cos(f) * z * Z, s * i, math.sin(f) * z * Z)
			end
			return A
		end
		local function X(z, A, i, j, f)
			if j <= 0 then
				return { A }
			elseif f <= 0 then
				return { A }
			end
			if z == "Fixed" then
				return C(A, i, j)
			elseif z == "Hemi" then
				local C = i - A
				if C.Magnitude <= 0.001 then
					return { A }
				end
				return b(A, C.Unit, j, f)
			elseif z == "Femboy" then
				local C = R(f, j)
				table.insert(C, 1, Vector3.zero)
				return v(A, C, false, false, j)
			elseif z == "Bounce" then
				return v(A, _(f, j), true, false, j)
			elseif z == "Random" then
				return v(A, _(f, j), true, true, j)
			elseif z == "Cardinals" then
				return v(A, d(f, j), true, false, j)
			elseif z == "Vector" then
				return v(A, o(f, j), true, false, j)
			elseif z == "Hammersley" then
				return v(A, O(f, j), true, false, j)
			elseif z == "Halo" then
				local C = i - A
				if C.Magnitude <= 0.001 then
					return { A }
				end
				return v(A, P(f, j, C.Unit), true, false, j)
			elseif z == "Cylinder" then
				return v(A, H(f, j), true, false, j)
			elseif z == "Shell" then
				return v(A, Y(f, j), true, false, j)
			end
			return { A }
		end
		local function C(b, _, v, d, O)
			local o
			local o, o, R, Y = u, math.max(1, math.floor(tonumber(u.path_Candidates) or 120)), { Gap = math.huge }, F
			for P, H in ipairs(v) do
				h()
				n.Left = n.Left - 1
				P = H.Position + Y
				local z, A = q(b.Position, P, true)
				if z then
					return b.Position, P, H, "Direct"
				end
				if A then
					if A < R.Gap then
						R.Gap = A
						R.From = b.Position
						R.To = P
						R.BestPart = H
						R.BestMethod = "Direct"
					end
				end
			end
			local P = G(O, _)
			if #P == 0 then
				return nil
			end
			local G, G, H, z, z, A, A, i, j, j, f =
				u,
				math.clamp(tonumber(u.path_Origin_Shift_Range) or 19, 0.1, 19.5),
				W(),
				u,
				math.max(1, math.floor(tonumber(u.path_Origin_Scans) or 20)),
				u,
				math.max(1, math.floor(tonumber(u.path_Hit_Scans) or 20)),
				#v,
				u,
				math.clamp(tonumber(u.hitbox_Bias) or 100, 0, 100) / 100,
				0
			for Z = 1, i, 1 do
				f += d[Z]
			end
			local Z, s = 0, o
			local function k(w, yq, uq)
				local Iq = Z
				if Iq >= s then
					return false, true
				elseif n.Left <= 0 then
					return false, true
				end
				h()
				Z += 1
				n.Left = n.Left - 1
				local Iq, Uq = q(w, yq, uq)
				if not Iq then
					if R.Part then
						if Uq then
							if Uq < R.Gap then
								R.Gap = Uq
								R.From = w
								R.To = yq
								R.BestPart = R.Part
								R.BestMethod = R.Method
							end
						end
					end
				end
				uq = Z >= s or n.Left <= 0
				return Iq, uq
			end
			O = v[1].Position + Y
			for w, yq in ipairs(P) do
				Z, s = 0, o
				w = n.Left <= 0
				if w then
					break
				end
				w = yq == "Bounce"
				if w then
					local P = #r
					local uq, Iq = S(_, "Bounce", P), 0
					while Iq < P do
						local Uq = (uq + Iq) % P
						local Mq = r[Uq + 1]
						Iq += 1
						local r = b.Position + Mq * (G * 0.8)
						local xq, Vq = k(b.Position, r)
						if xq then
							for Kq, mq in ipairs(v) do
								Mq = X(yq, mq.Position + Y, r, H, A)
								R.Part = mq
								R.Method = yq
								for Dq, nq in ipairs(Mq) do
									Kq, Dq = k(r, nq, true)
									if Kq then
										l(_, "Bounce", Uq)
										I(_, yq, true)
										return r, nq, mq, yq
									end
									if Dq then
										break
									end
								end
								R.Part = nil
								mq = Z >= s
								if mq then
									break
								end
							end
						end
						if Vq then
							break
						else
							xq = Z >= s
							if xq then
								break
							end
						end
					end
					l(_, "Bounce", (uq + Iq) % P)
				else
					local r, P = X(yq, b.Position, O, G, z), 0
					for G, O in ipairs(v) do
						P += d[G]
						if G == i then
							s = o
						else
							local v = G / i
							local d = v + (P / f - v) * j
							s = math.clamp(math.floor(o * d + 0.5), G, o)
						end
						local v, d = X(yq, O.Position + Y, b.Position, H, A), #r
						G = #v * d
						if G > 0 then
							local b = yq .. O.Name
							local Y = S(_, b, G)
							R.Part = O
							R.Method = yq
							local S = 0
							while S < G do
								local P = (Y + S) % G
								local H, X = v[math.floor(P / d) + 1], r[P % d + 1]
								S += 1
								local v, r = k(X, H, true)
								if v then
									l(_, b, P)
									I(_, yq, true)
									return X, H, O, yq
								end
								if r then
									break
								end
							end
							l(_, b, (Y + S) % G)
							R.Part = nil
						end
						d = Z >= o
						if d then
							break
						end
					end
				end
				w = Z > 0
				if w then
					I(_, yq, false)
				end
			end
			return nil, nil, nil, nil, R
		end
		local function I(G, b)
			local _, v = J(b)
			if #_ == 0 then
				return nil
			end
			local r, r
			local r, d = { U[4][U[6]], M.Character, b }, {}
			for U, M in ipairs(r) do
				d[U] = M
			end
			n.Base = r
			n.ServerScratch = d
			L.FilterDescendantsInstances = r
			c.FilterDescendantsInstances = d
			local U = b:FindFirstChild("HumanoidRootPart")
			e = 0
			local M
			local M = u
			local O = M.hit_Slack
			if O then
				local S, S, l = u, math.max(0, tonumber(u.hit_Slack_Range) or 25), u
				S = if l.hit_Slack_Velocity then if U then S + U.AssemblyLinearVelocity.Magnitude else S else S
				e = S
			end
			F = g(b)
			O = n.Scan
			if O then
				O.Base = r
				O.Scratch = d
				O.Slack = e
				O.Lead = F
			end
			r = u
			local S, l, l, o, o, R, Y =
				r.wall_Bang == true,
				u,
				math.max(0.1, tonumber(u.wall_Thickness) or 4),
				u,
				math.max(1, math.floor(tonumber(u.wall_Count) or 1)),
				y[b]
			if R then
				U = 1
				while U <= #R do
					r = R[U]
					d = r.Part
					M = (if d then not d.Parent else not d) or not table.find(_, d) or r.Wall and not S
					if M then
						table.remove(R, U)
					else
						h()
						local Y, P, H, X = G.Position + r.OriginOffset, d.Position + F + r.HitOffset, r.Wall
						if H then
							local H, z, A, i = E(Y, P, o)
							n.Left = n.Left - (z * 2 + 1)
							local j, f, Z = false, x[4][x[6]]
							if f then
								Z, j = x[4][x[6]](A and A.Name or nil, i, l)
							else
								Z = l
							end
							X = z > 0 and H <= Z
							if X then
								t.Thickness = H
								t.Walls = z
								t.Material = A and A.Name or "Unknown"
								t.Name = i or "Unknown"
								t.Learned = j
							end
						else
							n.Left = n.Left - 1
							X = (q(Y, P, true))
						end
						if X then
							r.Fails = 0
							if U > 1 then
								table.remove(R, U)
								table.insert(R, 1, r)
							end
							return Y, P, d, r.Method, true, false, r.Wall == true
						end
						r.Fails = (r.Fails or 0) + 1
						if r.Fails >= 3 then
							table.remove(R, U)
						else
							U += 1
						end
					end
				end
				if #R == 0 then
					y[b] = nil
				end
			end
			r = u
			M = r.shot_Cache and Q[b] or nil
			if M then
				r, d = u, math.max(0, tonumber(u.shot_Cache_Tolerance) or 0.6)
				local r, r, Y, P = u, math.clamp(tonumber(u.path_Origin_Shift_Range) or 19, 0.1, 19.5) + d, W() + d, 1
				while P <= #M do
					O = M[P]
					U = O.Part
					if U then
						local H = U.Parent
						if H then
							local H = table.find(_, U)
							if H then
								h()
								local H = U.Position + F
								if n.Left > 0 then
									if (G.Position - O.Origin).Magnitude <= r then
										if (H - O.Goal).Magnitude <= Y then
											n.Left = n.Left - 1
											if q(O.Origin, O.Goal, true) then
												return O.Origin, O.Goal, U, O.Method, true, false, false
											end
										end
									end
								end
								P += 1
							else
								table.remove(M, P)
							end
						else
							table.remove(M, P)
						end
					else
						table.remove(M, P)
					end
				end
				if #M == 0 then
					Q[b] = nil
				end
			end
			if n.Left <= 0 then
				return nil, nil, nil, nil, false, true
			end
			local r, q, Y, P, H = C(G, b, _, v, R and R[1] and R[1].Method)
			v, O = false, (if r then not r else S) and H
			if O then
				M = H.BestPart
				if M then
					S = H.BestPart.Parent
					if S then
						h()
						d, U, R, _ = E(H.From, H.To, o)
						n.Left = n.Left - (U * 2 + 1)
						local C, E, O = false, x[4][x[6]]
						if E then
							O, C = x[4][x[6]](R and R.Name or nil, _, l)
						else
							O = l
						end
						if U > 0 then
							if d <= O then
								local x, E, O, h, o = H.From, H.To, H.BestPart, H.BestMethod, true
								t.Thickness = d
								t.Walls = U
								t.Material = R and R.Name or "Unknown"
								t.Name = _ or "Unknown"
								t.Learned = C
								r, q, Y, P, v = x, E, O, h, o
							else
							end
						else
						end
					else
					end
				else
				end
			else
			end
			if r then
				B(
					b,
					{
						OriginOffset = r - G.Position,
						HitOffset = q - (Y.Position + F),
						Part = Y,
						Method = P,
						Wall = v,
						Fails = 0,
						Shots = 0,
					}
				)
				U = u
				S = U.shot_Cache and not v
				if S then
					M = Q[b]
					if M then
					else
						M = {}
						Q[b] = M
					end
					table.insert(M, 1, { Origin = r, Goal = q, Part = Y, Method = P })
					H, l = u, math.max(1, math.floor(tonumber(u.shot_Cache_Size) or 5))
					for U = #M, l + 1, -1 do
						M[U] = nil
					end
				end
			end
			return r, q, Y, P, false, false, v
		end
		local function U(M, x)
			local B, G = os.clock(), x and (x:FindFirstChild("HumanoidRootPart"))
			if not G then
				return nil
			end
			local C, b = K[x], T()
			local T = B - n.Time >= b
			if T then
				n.Time = B
				local E, E
				E, n.Left = u, math.max(1, math.floor(tonumber(u.path_Ray_Budget) or 1500))
			end
			if C then
				if B - C.Time < b then
					if not C.Found then
						return nil
					end
					if C.HitPart then
						if not C.HitPart.Parent then
							return nil
						end
					else
						return nil
					end
					local E, _ = M.Position - C.LocalPosition, G.Position - C.TargetPosition
					if E.Magnitude > 24 then
						return nil
					elseif _.Magnitude > 24 then
						return nil
					end
					if C.Wall then
						t.Thickness = C.WallThickness or 0
						t.Walls = C.WallCount or 0
						t.Material = C.WallMaterial or "Unknown"
						t.Name = C.WallName or "Unknown"
						t.Learned = C.WallLearned == true
					end
					return C.ShootPosition + E, C.HitPosition + _, C.HitPart, C.Method, true, C.Wall
				end
			end
			C = n.Scans
			T = C[x]
			if T then
				if T.Root ~= M then
					C[x] = nil
					T = nil
				else
					if B - T.Time > 0.25 then
						C[x] = nil
						T = nil
					else
					end
				end
			else
			end
			if B > n.Deadline then
				return nil
			end
			if T then
			else
				T = { Root = M, Thread = coroutine.create(I) }
				C[x] = T
			end
			T.Time = B
			n.Scan = T
			b = T.Base
			if b then
				local I = n.Last ~= T
				if I then
					n.Base = T.Base
					n.ServerScratch = T.Scratch
					L.FilterDescendantsInstances = T.Base
					c.FilterDescendantsInstances = T.Scratch
					e = T.Slack
					F = T.Lead
				end
			end
			n.Last = T
			local I, e, F, L, c, b, E, _ = coroutine.resume(T.Thread, M, x)
			n.Scan = nil
			if coroutine.status(T.Thread) ~= "dead" then
				return nil
			end
			if C[x] == T then
				C[x] = nil
			end
			if I then
				if E then
					return nil
				end
			else
				return nil
			end
			K[x] = {
				Time = B,
				LocalPosition = M.Position,
				TargetPosition = G.Position,
				Found = e ~= nil,
				ShootPosition = e,
				HitPosition = F,
				HitPart = L,
				Method = c,
				Wall = _,
				WallThickness = _ and t.Thickness or nil,
				WallCount = _ and t.Walls or nil,
				WallMaterial = _ and t.Material or nil,
				WallName = _ and t.Name or nil,
				WallLearned = _ and t.Learned or nil,
			}
			return e, F, L, c, b, _
		end
		D = {
			ClearCache = function()
				table.clear(K)
				table.clear(y)
				table.clear(m)
				table.clear(V)
				table.clear(Q)
				table.clear(N)
				table.clear(n.Scans)
				n.Scan = nil
				n.Last = nil
			end,
			Find = U,
			NoteShot = a,
			Frame = function()
				local y = os.clock()
				local I, I
				I, n.Deadline = u, y + math.clamp(tonumber(u.path_Frame_Time) or 4, 1, 16) / 1000
				for u, I in pairs(n.Scans) do
					if y - I.Time > 0.25 then
						n.Scans[u] = nil
					end
				end
			end,
			Lead = g,
			HitRadius = W,
			Parts = J,
			Bones = p,
			WallInfo = t,
		}
		return D
	end
end

Source.UpdateDamageTracker = function(Bindings)
	local u = Bindings[1]
	local I = Bindings[2]
	local U = Bindings[3]
	local M = Bindings[4]
	local x = Bindings[5]
	return function()
		local y
		local y = u
		if not y.Enabled then
			return
		end
		y = os.clock()
		local V
		local V = I
		local I, K = V(), pairs
		for m, D in K(I) do
			local n
			V = U
			V(m, D)
		end
		V, K = pairs, u
		local U = K.Watched
		for m, D in V(U) do
			local n, e = I[m]
			if n then
				D.LastSeen = y
				K = D.Humanoid
				if K then
					local n = K.Parent
					if n then
						local n = M
						n(m, D, K.Health)
					end
				end
			else
				local n, n = u, y - D.LastSeen > u.TargetGrace
				if n then
					local n
					local n = x
					n(m)
				else
					local x = D.Humanoid
					if x then
						local n = x.Parent
						if n then
							local n = M
							n(m, D, x.Health)
						end
					end
				end
			end
		end
		U = u
		I = #U.RecentDamage
		for M = I, 1, -1 do
			K = u
			U, V = u, y - K.RecentDamage[M].Time > u.ConfirmWindow + 0.35
			if V then
				table.remove(u.RecentDamage, M)
			end
		end
		V = u
		I = V.LastHitmarkerPulse > 0
		if I then
			K = u
			local I, I = u, y - K.LastHitmarkerPulse > u.ConfirmWindow
			if I then
				V = u
				V.LastHitmarkerPulse = 0
			end
		end
	end
end

Source.FindMagazinePart = function(Bindings)
	local CameraSlot = Bindings[1]
	local State = Bindings[2]
	return function(Tool)
		local Camera = workspace.CurrentCamera or CameraSlot[4][CameraSlot[6]]
		local ViewModel = Camera and Camera:FindFirstChild("ViewModel")
		local ViewModelMagazine = ViewModel and ViewModel:FindFirstChild("MagPart", true)
		if ViewModelMagazine then
			return ViewModelMagazine, true
		end
		local CachedMagazine = State.MagCache[Tool]
		if CachedMagazine and CachedMagazine.Parent then
			return CachedMagazine, false
		end
		local Handle = Tool:FindFirstChild("Handle")
		local Parts = Handle and Handle:FindFirstChild("Parts")
		local Magazine = Parts and Parts:FindFirstChild("MagPart") or Handle
		if Magazine then
			State.MagCache[Tool] = Magazine
		end
		return Magazine, false
	end
end

return Source
