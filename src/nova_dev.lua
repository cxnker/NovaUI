local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local novalib = {
	Themes = {
		Custom = {
			["Color Hub 1"] = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(14, 14, 28)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(22, 22, 44)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 100, 200))
			}),
			["Color Hub 2"] = Color3.fromRGB(28, 28, 38),
			["Color Stroke"] = Color3.fromRGB(42, 46, 62),
			["Color Theme"] = Color3.fromRGB(58, 122, 232),
			["Color Text"] = Color3.fromRGB(218, 222, 232),
			["Color Dark Text"] = Color3.fromRGB(148, 152, 162)
		}
	},
	Save = {
		UISize = {550, 380},
		TabSize = 160,
		Theme = "Custom"
	},
	Settings = {},
	Connection = {},
	Instances = {},
	Elements = {},
	Options = {},
	Tabs = {},
	Icons = loadstring(game:HttpGet("https://pastefy.app/phzWzDsM/raw"))()
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local Settings = novalib.Settings

local SetProps, SetChildren, InsertTheme, Create do
	InsertTheme = function(Instance, Type)
		table.insert(novalib.Instances, {Instance = Instance, Type = Type})
		return Instance
	end
	
	SetChildren = function(Instance, Children)
		if Children then
			for _, Child in ipairs(Children) do
				Child.Parent = Instance
			end
		end
		return Instance
	end
	
	SetProps = function(Instance, Props)
		if Props then
			for prop, value in pairs(Props) do
				Instance[prop] = value
			end
		end
		return Instance
	end
	
	Create = function(...)
		local args = {...}
		if type(args) ~= "table" then return end
		local new = Instance.new(args[1])
		
		if type(args[2]) == "table" then
			SetProps(new, args[2])
			SetChildren(new, args[3])
		elseif typeof(args[2]) == "Instance" then
			new.Parent = args[2]
			SetProps(new, args[3])
			SetChildren(new, args[4])
		end
		return new
	end
	
	local function Save(file)
		if readfile and isfile and isfile(file) then
			local decode = HttpService:JSONDecode(readfile(file))
			
			if type(decode) == "table" then
				if decode.UISize then novalib.Save.UISize = decode.UISize end
				if decode.TabSize then novalib.Save.TabSize = decode.TabSize end
				if decode.Theme and VerifyTheme(decode.Theme) then novalib.Save.Theme = decode.Theme end
			end
		end
	end
	
	pcall(Save, "novalib.json")
end

local Funcs = {} do
	function Funcs:InsertCallback(tab, func)
		if type(func) == "function" then
			table.insert(tab, func)
		end
		return func
	end
	
	function Funcs:FireCallback(tab, ...)
		for _, v in ipairs(tab) do
			if type(v) == "function" then
				task.spawn(v, ...)
			end
		end
	end
	
	function Funcs:ToggleVisible(Obj, Bool)
		Obj.Visible = Bool ~= nil and Bool or Obj.Visible
	end
	
	function Funcs:ToggleParent(Obj, Parent)
		if Bool ~= nil then
			Obj.Parent = Bool
		else
			Obj.Parent = not Obj.Parent and Parent
		end
	end
	
	function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
		local Connected = {Function = func, Connected = true}
		
		function Connected:Disconnect()
			if self.Connected then
				for i = 1, #ConnectedFuncs do
					if ConnectedFuncs[i] == self.Function then
						table.remove(ConnectedFuncs, i)
						break
					end
				end
				self.Connected = false
			end
		end
		
		function Connected:Fire(...)
			if self.Connected then
				task.spawn(self.Function, ...)
			end
		end
		
		return Connected
	end
	
	function Funcs:GetCallback(Configs, index)
		local func = Configs[index] or Configs.Callback or function() end
		
		if type(func) == "table" then
			return {function(Value) func[1][func[2]] = Value end}
		end
		return {func}
	end
end

local Connections, Connection = {}, novalib.Connection do
	local function NewConnectionList(List)
		if type(List) ~= "table" then return end
		
		for _, CoName in ipairs(List) do
			local ConnectedFuncs = {}
			local Connect = {}
			
			Connection[CoName] = Connect
			Connections[CoName] = ConnectedFuncs
			Connect.Name = CoName
			
			function Connect:Connect(func)
				if type(func) == "function" then
					table.insert(ConnectedFuncs, func)
					return Funcs:GetConnectionFunctions(ConnectedFuncs, func)
				end
			end
			
			function Connect:Once(func)
				if type(func) == "function" then
					local Connected
					local _NFunc = function(...)
						task.spawn(func, ...)
						Connected:Disconnect()
					end
					Connected = Funcs:GetConnectionFunctions(ConnectedFuncs, _NFunc)
					return Connected
				end
			end
		end
	end
	
	function Connection:FireConnection(CoName, ...)
		local ConnectionList = type(CoName) == "string" and Connections[CoName] or Connections[CoName.Name]
		for _, Func in pairs(ConnectionList) do
			task.spawn(Func, ...)
		end
	end
	
	NewConnectionList({"ThemeChanged", "FileSaved", "ThemeChanging", "OptionAdded"})
end

local ScreenGui = Create("ScreenGui", CoreGui, {
	Name = "Nova Lib",
}, {
	Create("UIScale", {Scale = UIScale, Name = "Scale"})
})

local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
	ScreenFind:Destroy()
end

local function GetStr(val)
	return type(val) == "function" and val() or val
end

local function ConnectSave(Instance, func)
	Instance.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				task.wait()
			end
		end
		func()
	end)
end

local function CreateTween(Configs)
	local Instance = Configs[1] or Configs.Instance
	local Prop = Configs[2] or Configs.Prop
	local NewVal = Configs[3] or Configs.NewVal
	local Time = Configs[4] or Configs.Time or 0.5
	local TweenWait = Configs[5] or Configs.wait or false
	
	local Tween = TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quint), {[Prop] = NewVal})
	Tween:Play()
	if TweenWait then
		Tween.Completed:Wait()
	end
	return Tween
end

local function MakeDrag(Instance)
	task.spawn(function()
		SetProps(Instance, {Active = true, AutoButtonColor = false})
		
		local DragStart, StartPos, InputOn
		
		local function Update(Input)
			local delta = Input.Position - DragStart
			local Position = UDim2.new(
				StartPos.X.Scale, 
				StartPos.X.Offset + delta.X / UIScale,
				StartPos.Y.Scale, 
				StartPos.Y.Offset + delta.Y / UIScale
			)
			CreateTween({Instance, "Position", Position, 0.35})
		end
		
		Instance.MouseButton1Down:Connect(function()
			InputOn = true
		end)
		
		Instance.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				StartPos = Instance.Position
				DragStart = Input.Position
				
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					RunService.Heartbeat:Wait()
					if InputOn then
						Update(Input)
					end
				end
				InputOn = false
			end
		end)
	end)
	return Instance
end

local function VerifyTheme(Theme)
	for name in pairs(novalib.Themes) do
		if name == Theme then return true end
	end
	return false
end

local function SaveJson(FileName, save)
	if writefile then
		local json = HttpService:JSONEncode(save)
		writefile(FileName, json)
	end
end

local Theme = novalib.Themes[novalib.Save.Theme]

local function AddEle(Name, Func)
	novalib.Elements[Name] = Func
end

local function Make(Ele, Instance, props, ...)
	return novalib.Elements[Ele](Instance, props, ...)
end

AddEle("Corner", function(parent, CornerRadius)
	return SetProps(Create("UICorner", parent, {
		CornerRadius = CornerRadius or UDim.new(0, 12)
	}), props)
end)

AddEle("Stroke", function(parent, props, ...)
	local args = {...}
	local New = InsertTheme(SetProps(Create("UIStroke", parent, {
		Color = args[1] or Theme["Color Stroke"],
		Thickness = args[2] or 1.4,
		ApplyStrokeMode = "Border",
		Transparency = 0.35
	}), props), "Stroke")
	return New
end)

AddEle("Button", function(parent, props, ...)
	local args = {...}
	local New = InsertTheme(SetProps(Create("TextButton", parent, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme["Color Hub 2"],
		BackgroundTransparency = 0.3,
		AutoButtonColor = false
	}), props), "Frame")
	
	New.MouseEnter:Connect(function()
		CreateTween({New, "BackgroundTransparency", 0.1, 0.2})
	end)
	New.MouseLeave:Connect(function()
		CreateTween({New, "BackgroundTransparency", 0.3, 0.2})
	end)
	if args[1] then
		New.Activated:Connect(args[1])
	end
	return New
end)

AddEle("Gradient", function(parent, props, ...)
	return InsertTheme(SetProps(Create("UIGradient", parent, {
		Color = Theme["Color Hub 1"]
	}), props), "Gradient")
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
	local TitleL = InsertTheme(Create("TextLabel", {
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme["Color Text"],
		Size = UDim2.new(1, -20),
		AutomaticSize = "Y",
		Position = UDim2.new(0, 0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		TextTruncate = "AtEnd",
		TextSize = 11,
		TextXAlignment = "Left",
		Text = "",
		RichText = true
	}), "Text")
	
	local DescL = InsertTheme(Create("TextLabel", {
		Font = Enum.Font.Gotham,
		TextColor3 = Theme["Color Dark Text"],
		Size = UDim2.new(1, -20),
		AutomaticSize = "Y",
		Position = UDim2.new(0, 12, 0, 15),
		BackgroundTransparency = 1,
		TextWrapped = true,
		TextSize = 9,
		TextXAlignment = "Left",
		Text = "",
		RichText = true
	}), "DarkText")

	local Frame = Make("Button", Instance, {
		Size = UDim2.new(1, 0, 0, 28),
		AutomaticSize = "Y",
		Name = "Option"
	})
	Make("Corner", Frame, UDim.new(0, 8))
	Make("Stroke", Frame)
	
	local LabelHolder = Create("Frame", Frame, {
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Size = HolderSize,
		Position = UDim2.new(0, 12, 0),
		AnchorPoint = Vector2.new(0, 0)
	}, {
		Create("UIListLayout", {
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 3)
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6)
		}),
		TitleL,
		DescL,
	})
	
	local Label = {}
	function Label:SetTitle(NewTitle)
		if type(NewTitle) == "string" and NewTitle:gsub(" ", "") ~= "" then
			TitleL.Text = NewTitle
		end
	end
	
	function Label:SetDesc(NewDesc)
		if type(NewDesc) == "string" and NewDesc:gsub(" ", "") ~= "" then
			DescL.Visible = true
			DescL.Text = NewDesc
			LabelHolder.Position = UDim2.new(0, 12, 0)
			LabelHolder.AnchorPoint = Vector2.new(0, 0)
		else
			DescL.Visible = false
			DescL.Text = ""
			LabelHolder.Position = UDim2.new(0, 12, 0.5)
			LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
		end
	end
	
	Label:SetTitle(Title)
	Label:SetDesc(Description)
	return Frame, Label
end

local function GetColor(Instance)
	if Instance:IsA("Frame") then
		return "BackgroundColor3"
	elseif Instance:IsA("ImageLabel") or Instance:IsA("ImageButton") then
		return "ImageColor3"
	elseif Instance:IsA("TextLabel") or Instance:IsA("TextButton") then
		return "TextColor3"
	elseif Instance:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Instance:IsA("UIStroke") then
		return "Color"
	end
	return ""
end

function novalib:GetIcon(index)
	if type(index) ~= "string" or index:find("rbxassetid://") or #index == 0 then
		return index
	end
	
	local firstMatch = nil
	index = string.lower(index):gsub("lucide", ""):gsub("-", "")
	
	if self.Icons[index] then
		return self.Icons[index]
	end
	
	for Name, Icon in pairs(self.Icons) do
		if Name == index then
			return Icon
		elseif not firstMatch and Name:find(index, 1, true) then
			firstMatch = Icon
		end
	end
	return firstMatch or index
end

local ThemeHandlers = {
	Gradient = function(inst) inst.Color = Theme["Color Hub 1"] end,
	Frame = function(inst) inst.BackgroundColor3 = Theme["Color Hub 2"] end,
	Stroke = function(inst) inst[GetColor(inst)] = Theme["Color Stroke"] end,
	Theme = function(inst) inst[GetColor(inst)] = Theme["Color Theme"] end,
	Text = function(inst) inst[GetColor(inst)] = Theme["Color Text"] end,
	DarkText = function(inst) inst[GetColor(inst)] = Theme["Color Dark Text"] end,
	ScrollBar = function(inst) inst[GetColor(inst)] = Theme["Color Theme"] end,
}

function novalib:SetTheme(NewTheme)
	if not VerifyTheme(NewTheme) then return end
	
	self.Save.Theme = NewTheme
	SaveJson("novalib.json", self.Save)
	Theme = self.Themes[NewTheme]
	
	Connection:FireConnection("ThemeChanged", NewTheme)
	
	for _, Val in ipairs(self.Instances) do
		local handler = ThemeHandlers[Val.Type]
		if handler then
			handler(Val.Instance)
		end
	end
end

function novalib:SetScale(NewScale)
	NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
	UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

function novalib:MakeWindow(Configs)
	local WTitle = Configs[1] or Configs.Name or Configs.Title or "Nova UI Library"
	local WMiniText = Configs[2] or Configs.SubTitle or "by Nova"
	
	local UISizeX, UISizeY = unpack(novalib.Save.UISize)
	local MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
		Size = UDim2.fromOffset(UISizeX, UISizeY),
		Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
		BackgroundTransparency = 0.06,
		Name = "Hub"
	}), "Main")
	Make("Stroke", MainFrame)
	Make("Gradient", MainFrame, {Rotation = 45})
	Make("Corner", MainFrame)
	MakeDrag(MainFrame)

	local Components = Create("Folder", MainFrame, {Name = "Components"})
	
	local TopBar = Create("Frame", Components, {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "Top Bar"
	})
	
	local Title = InsertTheme(Create("TextLabel", TopBar, {
		Position = UDim2.new(0, 15, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = "XY",
		Text = WTitle,
		TextXAlignment = "Left",
		TextSize = 13,
		TextColor3 = Theme["Color Text"],
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Name = "Title"
	}, {
		InsertTheme(Create("TextLabel", {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = "X",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(1, 5, 0.9),
			Text = WMiniText,
			TextColor3 = Theme["Color Dark Text"],
			BackgroundTransparency = 1,
			TextXAlignment = "Left",
			TextYAlignment = "Bottom",
			TextSize = 9,
			Font = Enum.Font.Gotham,
			Name = "SubTitle"
		}), "DarkText")
	}), "Text")

	local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
		Size = UDim2.new(0, novalib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
		ScrollBarImageColor3 = Theme["Color Theme"],
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		ScrollBarThickness = 2,
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = "Y",
		ScrollingDirection = "Y",
		BorderSizePixel = 0,
		Name = "Tab Scroll"
	}, {
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10)
		}),
		Create("UIListLayout", {Padding = UDim.new(0, 6)})
	}), "ScrollBar")
	
	local Containers = Create("Frame", Components, {
		Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Name = "Containers"
	})
	
	local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
		Size = UDim2.new(0, 35, 0, 35),
		Position = MainFrame.Size,
		Active = true,
		AnchorPoint = Vector2.new(0.8, 0.8),
		BackgroundTransparency = 1,
		Name = "Control Hub Size"
	})), MakeDrag(Create("ImageButton", MainFrame, {
		Size = UDim2.new(0, 20, 1, -30),
		Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		Active = true,
		BackgroundTransparency = 1,
		Name = "Control Tab Size"
	}))
	
	local function ControlSize()
		local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
		ControlSize1.Position = UDim2.fromOffset(
			math.clamp(Pos1.X.Offset, 430, 1000),
			math.clamp(Pos1.Y.Offset, 200, 500)
		)
		ControlSize2.Position = UDim2.new(
			0, math.clamp(Pos2.X.Offset, 135, 250),
			1, 0
		)
		
		MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
		Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
		MainFrame.Size = ControlSize1.Position
	end
	
	ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
	ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)
	
	ConnectSave(ControlSize1, function()
		if not Minimized then
			novalib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
			SaveJson("novalib.json", novalib.Save)
		end
	end)
	
	ConnectSave(ControlSize2, function()
		novalib.Save.TabSize = MainScroll.Size.X.Offset
		SaveJson("novalib.json", novalib.Save)
	end)
	
	local ButtonsFolder = Create("Folder", TopBar, {Name = "Buttons"})
	
	local CloseButton = InsertTheme(Create("ImageButton", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -12, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://10747384394",
		ImageColor3 = Theme["Color Text"],
		AutoButtonColor = false,
		Name = "Close"
	}), "Text")
	
	local MinimizeButton = InsertTheme(SetProps(CloseButton:Clone(), {
		Position = UDim2.new(1, -38, 0.5),
		Image = "rbxassetid://10734896206",
		ImageColor3 = Theme["Color Text"],
		Name = "Minimize"
	}), "Text")
	
	CloseButton.MouseEnter:Connect(function()
		CreateTween({CloseButton, "ImageColor3", Color3.fromRGB(255, 80, 80), 0.2})
	end)
	CloseButton.MouseLeave:Connect(function()
		CreateTween({CloseButton, "ImageColor3", Theme["Color Text"], 0.2})
	end)
	
	MinimizeButton.MouseEnter:Connect(function()
		CreateTween({MinimizeButton, "ImageColor3", Theme["Color Theme"], 0.2})
	end)
	MinimizeButton.MouseLeave:Connect(function()
		CreateTween({MinimizeButton, "ImageColor3", Theme["Color Text"], 0.2})
	end)
	
	SetChildren(ButtonsFolder, {CloseButton, MinimizeButton})
	
	local Minimized, SaveSize, WaitClick
	local Window, FirstTab = {}, false
	
	function Window:CloseBtn()
		ScreenGui:Destroy()
	end
	
	function Window:MinimizeBtn()
		if WaitClick then return end
		WaitClick = true
		
		if Minimized then
			MinimizeButton.Image = "rbxassetid://10734896206"
			CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
			ControlSize1.Visible = true
			ControlSize2.Visible = true
			Minimized = false
		else
			MinimizeButton.Image = "rbxassetid://10734924532"
			SaveSize = MainFrame.Size
			ControlSize1.Visible = false
			ControlSize2.Visible = false
			CreateTween({MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 32), 0.25, true})
			Minimized = true
		end
		
		WaitClick = false
	end
	
	function Window:Minimize()
		MainFrame.Visible = not MainFrame.Visible
	end
	
	function Window:AddMinimizeButton(Configs)
		local Button = MakeDrag(Create("ImageButton", ScreenGui, {
			Size = UDim2.fromOffset(45, 45),
			Position = UDim2.fromScale(0.2, 0.15),
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme["Color Hub 2"],
			AutoButtonColor = false
		}))

		local Stroke, Corner
		if Configs.Corner then
			Corner = Make("Corner", Button)
			SetProps(Corner, Configs.Corner)
		end
		if Configs.Stroke then
			Stroke = Make("Stroke", Button)
			SetProps(Stroke, Configs.Stroke)
		end
		
		SetProps(Button, Configs.Button)
		Button.Activated:Connect(Window.Minimize)
		
		return {Stroke = Stroke, Corner = Corner, Button = Button}
	end
	
	function Window:Set(Val1, Val2)
		if type(Val1) == "string" and type(Val2) == "string" then
			Title.Text = Val1
			Title.SubTitle.Text = Val2
		elseif type(Val1) == "string" then
			Title.Text = Val1
		end
	end
	
	local ContainerList = {}
	
	function Window:MakeTab(paste, Configs)
		if type(paste) == "table" then Configs = paste end
		local TName = Configs[1] or Configs.Title or "Tab!"
		local TIcon = Configs[2] or Configs.Icon or ""
		
		TIcon = novalib:GetIcon(TIcon)
		if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
			TIcon = false
		end
		
		local TabSelect = Make("Button", MainScroll, {Size = UDim2.new(1, 0, 0, 30)})
		Make("Corner", TabSelect, UDim.new(0, 8))
		
		local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
			Size = UDim2.new(1, TIcon and -30 or -15, 1),
			Position = UDim2.fromOffset(TIcon and 32 or 15),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = TName,
			TextColor3 = Theme["Color Text"],
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = (FirstTab and 0.5) or 0,
			TextTruncate = "AtEnd"
		}), "Text")
		
		local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
			Position = UDim2.new(0, 10, 0.5),
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = TIcon or "",
			BackgroundTransparency = 1,
			ImageTransparency = (FirstTab and 0.5) or 0,
			ImageColor3 = Theme["Color Text"]
		}), "Text")
		
		local Selected = InsertTheme(Create("Frame", TabSelect, {
			Size = FirstTab and UDim2.new(0, 3, 0, 0) or UDim2.new(0, 3, 0, 18),
			Position = UDim2.new(0, 0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme["Color Theme"],
			BackgroundTransparency = FirstTab and 1 or 0
		}), "Theme")
		Make("Corner", Selected, UDim.new(0.5, 0))
		
		local Container = InsertTheme(Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 1),
			AnchorPoint = Vector2.new(0, 1),
			ScrollBarThickness = 2,
			BackgroundTransparency = 1,
			ScrollBarImageTransparency = 0.3,
			ScrollBarImageColor3 = Theme["Color Theme"],
			AutomaticCanvasSize = "Y",
			ScrollingDirection = "Y",
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName)
		}, {
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10)
			}),
			Create("UIListLayout", {Padding = UDim.new(0, 6)})
		}), "ScrollBar")
		
		table.insert(ContainerList, Container)
		
		if not FirstTab then
			Container.Parent = Containers
		end
		
		local function Tabs()
			if Container.Parent then return end
			
			for _, Frame in ipairs(ContainerList) do
				if Frame:IsA("ScrollingFrame") and Frame ~= Container then
					Frame.Parent = nil
				end
			end
			
			Container.Parent = Containers
			Container.Size = UDim2.new(1, 0, 1, 150)
			
			for _, Tab in ipairs(novalib.Tabs) do
				if Tab.Cont ~= Container then
					Tab.func:Disable()
				end
			end
			
			CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
			CreateTween({LabelTitle, "TextTransparency", 0, 0.3})
			CreateTween({LabelIcon, "ImageTransparency", 0, 0.3})
			CreateTween({Selected, "Size", UDim2.new(0, 3, 0, 16), 0.3})
			CreateTween({Selected, "BackgroundTransparency", 0, 0.3})
		end
		
		TabSelect.Activated:Connect(Tabs)
		
		FirstTab = true
		local Tab = {}
		table.insert(novalib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
		Tab.Cont = Container
		
		function Tab:Disable()
			Container.Parent = nil
			CreateTween({LabelTitle, "TextTransparency", 0.5, 0.3})
			CreateTween({LabelIcon, "ImageTransparency", 0.5, 0.3})
			CreateTween({Selected, "Size", UDim2.new(0, 3, 0, 0), 0.3})
			CreateTween({Selected, "BackgroundTransparency", 1, 0.3})
		end
		
		function Tab:Enable()
			Tabs()
		end
		
		function Tab:Visible(Bool)
			Funcs:ToggleVisible(TabSelect, Bool)
			Funcs:ToggleParent(Container, Bool, Containers)
		end
		
		function Tab:Destroy()
			TabSelect:Destroy()
			Container:Destroy()
		end
		
		function Tab:AddSection(Configs)
			local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
			local SectionIcon = type(Configs) == "table" and (Configs.Icon or Configs[2])
	
			local SectionFrame = Create("Frame", Container, {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Name = "Option"
			})
	
			if SectionIcon then
				Create("ImageLabel", SectionFrame, {
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new(0, 8, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Image = novalib:GetIcon(SectionIcon),
					ImageColor3 = Theme["Color Text"]
				})
			end
	
			local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
				Font = Enum.Font.GothamBold,
				Text = SectionName,
				TextColor3 = Theme["Color Text"],
				Size = UDim2.new(1, SectionIcon and -30 or -10, 1, 0),
				Position = UDim2.new(0, SectionIcon and 28 or 5),
				BackgroundTransparency = 1,
				TextTruncate = "AtEnd",
				TextSize = 13,
				TextXAlignment = "Left"
			}), "Theme")
	
			local Section = {}
			table.insert(novalib.Options, {type = "Section", Name = SectionName, func = Section})
	
			function Section:Visible(Bool)
				if Bool == nil then
					SectionFrame.Visible = not SectionFrame.Visible
				else
					SectionFrame.Visible = Bool
				end
			end
	
			function Section:Destroy()
				SectionFrame:Destroy()
			end
	
			function Section:Set(New)
				if New then
					SectionLabel.Text = GetStr(New)
				end
			end
			return Section
		end
		
		function Tab:AddParagraph(Configs)
			local PName = Configs[1] or Configs.Title or "Paragraph"
			local PDesc = Configs[2] or Configs.Text or ""
			
			local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
			
			local Paragraph = {}
			function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end
			function Paragraph:Destroy() Frame:Destroy() end
			function Paragraph:SetTitle(Val)
				LabelFunc:SetTitle(GetStr(Val))
			end
			function Paragraph:SetDesc(Val)
				LabelFunc:SetDesc(GetStr(Val))
			end
			function Paragraph:Set(Val1, Val2)
				if Val1 and Val2 then
					LabelFunc:SetTitle(GetStr(Val1))
					LabelFunc:SetDesc(GetStr(Val2))
				elseif Val1 then
					LabelFunc:SetDesc(GetStr(Val1))
				end
			end
			return Paragraph
		end
		
		function Tab:AddButton(Configs)
			local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
			local BDescription = Configs.Desc or Configs.Description or ""
			local Callback = Funcs:GetCallback(Configs, 2)
			
			local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -30))
			
			local ButtonIcon = InsertTheme(Create("ImageLabel", FButton, {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(1, -12, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://10709791437",
				ImageColor3 = Theme["Color Theme"]
			}), "Theme")
			
			FButton.Activated:Connect(function()
				Funcs:FireCallback(Callback)
				CreateTween({ButtonIcon, "Rotation", 360, 0.3})
				task.wait(0.3)
				ButtonIcon.Rotation = 0
			end)
			
			local Button = {}
			function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end
			function Button:Destroy() FButton:Destroy() end
			function Button:Callback(...) Funcs:InsertCallback(Callback, ...) end
			function Button:Set(Val1, Val2)
				if type(Val1) == "string" and type(Val2) == "string" then
					LabelFunc:SetTitle(Val1)
					LabelFunc:SetDesc(Val2)
				elseif type(Val1) == "string" then
					LabelFunc:SetTitle(Val1)
				elseif type(Val1) == "function" then
					Callback = {Val1}
				end
			end
			return Button
		end
		
		function Tab:AddToggle(Configs)
			local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
			local TDesc = Configs.Desc or Configs.Description or ""
			local Callback = Funcs:GetCallback(Configs, 3)
			local Default = Configs[2] or Configs.Default or false
			
			local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -48))
			
			local ToggleHolder = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 40, 0, 18),
				Position = UDim2.new(1, -12, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"],
				BackgroundTransparency = 0.3
			}), "Stroke")
			Make("Corner", ToggleHolder, UDim.new(1, 0))
			Make("Stroke", ToggleHolder)
			
			local Slider = Create("Frame", ToggleHolder, {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.95, 0, 0.95, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
			
			local Toggle = InsertTheme(Create("Frame", Slider, {
				Size = UDim2.new(0, 24, 0, 16),
				Position = UDim2.new(0, 0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme["Color Text"]
			}), "Theme")
			Make("Corner", Toggle, UDim.new(1, 0))
			
			local WaitClick
			local function SetToggle(Val)
				if WaitClick then return end
				
				WaitClick, Default = true, Val
				Funcs:FireCallback(Callback, Default)
				
				if Default then
					CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.35})
					CreateTween({Toggle, "BackgroundTransparency", 0, 0.35})
					CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.35})
					CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Theme"], 0.35})
					CreateTween({ToggleHolder, "BackgroundTransparency", 0.35, 0.35, true})
				else
					CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.3})
					CreateTween({Toggle, "BackgroundTransparency", 0, 0.3})
					CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.3})
					CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Stroke"], 0.3})
					CreateTween({ToggleHolder, "BackgroundTransparency", 0.3, 0.3, true})
				end
				WaitClick = false
			end
			
			SetToggle(Default)
			
			Button.Activated:Connect(function()
				SetToggle(not Default)
			end)
			
			local Toggle = {}
			function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Toggle:Destroy() Button:Destroy() end
			function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
			function Toggle:Set(Val1, Val2)
				if type(Val1) == "string" and type(Val2) == "string" then
					LabelFunc:SetTitle(Val1)
					LabelFunc:SetDesc(Val2)
				elseif type(Val1) == "string" then
					LabelFunc:SetTitle(Val1)
				elseif type(Val1) == "boolean" then
					if WaitClick and Val2 then
						repeat task.wait() until not WaitClick
					end
					SetToggle(Val1)
				elseif type(Val1) == "function" then
					Callback = {Val1}
				end
			end
			return Toggle
		end
		
		function Tab:AddDropdown(Configs)
			local DName = Configs[1] or Configs.Name or Configs.Title or "Dropdown"
			local DDesc = Configs.Desc or Configs.Description or ""
			local DOptions = Configs[2] or Configs.Options or {}
			local OpDefault = Configs[3] or Configs.Default or {}
			local DMultiSelect = Configs.MultiSelect or false
			local Callback = Funcs:GetCallback(Configs, 4)
			local Button, LabelFunc = ButtonFrame(Container, DName, DDesc, UDim2.new(1, -190))
			
			local SelectedFrame = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 160, 0, 22),
				Position = UDim2.new(1, -12, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"],
				BackgroundTransparency = 0.3
			}), "Stroke")
			Make("Corner", SelectedFrame, UDim.new(0, 8))
			Make("Stroke", SelectedFrame)
			
			local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
				Size = UDim2.new(1, -30, 1, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = Theme["Color Text"],
				TextXAlignment = "Left",
				TextTruncate = "AtEnd",
				Text = "..."
			}), "Text")
			
			local Arrow = InsertTheme(Create("ImageLabel", SelectedFrame, {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -8, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://10709791523",
				ImageColor3 = Theme["Color Text"],
				BackgroundTransparency = 1
			}), "Text")
			
			local NoClickFrame = Create("TextButton", ScreenGui, {
				Name = "AntiClick",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Visible = false,
				Text = ""
			})
			
			local DropFrame = InsertTheme(Create("Frame", NoClickFrame, {
				Size = UDim2.new(SelectedFrame.Size.X, 0, 0),
				BackgroundTransparency = 0.3,
				BackgroundColor3 = Theme["Color Hub 2"],
				AnchorPoint = Vector2.new(0, 1),
				Name = "DropdownFrame",
				ClipsDescendants = true,
				Active = true
			}), "Frame")
			Make("Corner", DropFrame, UDim.new(0, 8))
			Make("Stroke", DropFrame)
			Make("Gradient", DropFrame, {Rotation = 60})
			
			local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
				ScrollBarImageColor3 = Theme["Color Theme"],
				Size = UDim2.new(1, 0, 1, 0),
				ScrollBarThickness = 2,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(),
				ScrollingDirection = "Y",
				AutomaticCanvasSize = "Y",
				ScrollBarImageTransparency = 0.2,
				Active = true
			}, {
				Create("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5)
				}),
				Create("UIListLayout", {Padding = UDim.new(0, 5)})
			}), "ScrollBar")
			
			local ScrollSize, WaitClick = 5
			local function Disable()
				WaitClick = true
				CreateTween({Arrow, "Rotation", 0, 0.2})
				CreateTween({DropFrame, "Size", UDim2.new(0, 162, 0, 0), 0.2, true})
				CreateTween({Arrow, "ImageColor3", Theme["Color Text"], 0.2})
				Arrow.Image = "rbxassetid://10709791523"
				NoClickFrame.Visible = false
				WaitClick = false
			end
			
			local function GetFrameSize()
				return UDim2.fromOffset(162, ScrollSize)
			end
			
			local function CalculateSize()
				local Count = 0
				for _, Frame in ipairs(ScrollFrame:GetChildren()) do
					if Frame:IsA("Frame") or Frame.Name == "Option" then
						Count = Count + 1
					end
				end
				ScrollSize = (math.clamp(Count, 0, 8) * 28) + 10
				if NoClickFrame.Visible then
					CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
				end
			end
			
			local function Minimize()
				if WaitClick then return end
				WaitClick = true
				if NoClickFrame.Visible then
					Arrow.Image = "rbxassetid://10709791523"
					CreateTween({Arrow, "ImageColor3", Theme["Color Text"], 0.2})
					CreateTween({DropFrame, "Size", UDim2.new(0, 162, 0, 0), 0.2, true})
					NoClickFrame.Visible = false
				else
					NoClickFrame.Visible = true
					Arrow.Image = "rbxassetid://10709790948"
					CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2})
					CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
				end
				WaitClick = false
			end
			
			local function CalculatePos()
				local FramePos = SelectedFrame.AbsolutePosition
				local ScreenSize = ScreenGui.AbsoluteSize
				local ClampX = math.clamp(FramePos.X / UIScale, 0, ScreenSize.X / UIScale - DropFrame.Size.X.Offset)
				local ClampY = math.clamp(FramePos.Y / UIScale, 0, ScreenSize.Y / UIScale)
				local NewPos = UDim2.fromOffset(ClampX, ClampY)
				local AnchorPoint = FramePos.Y > ScreenSize.Y / 1.4 and 1 or (ScrollSize > 80 and 0.5 or 0)
				
				DropFrame.AnchorPoint = Vector2.new(0, AnchorPoint)
				CreateTween({DropFrame, "Position", NewPos, 0.1})
			end
			
			local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected do
				local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
				local MultiSelect = DMultiSelect
				local Options = {}
				Selected = MultiSelect and {} or Default[1]
				
				if MultiSelect then
					for index, Value in pairs(Default) do
						if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then
							Selected[index] = Value
						elseif DOptions[Value] then
							Selected[Value] = true
						end
					end
				end
				
				local function CallbackSelected()
					Funcs:FireCallback(Callback, Selected)
				end
				
				local function UpdateLabel()
					if MultiSelect then
						local list = {}
						for index, Value in pairs(Selected) do
							if Value then
								table.insert(list, index)
							end
						end
						ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
					else
						ActiveLabel.Text = tostring(Selected or "...")
					end
				end
				
				local function UpdateSelected()
					if MultiSelect then
						for _, v in pairs(Options) do
							local nodes, Stats = v.nodes, v.Stats
							CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 1, 0.25})
							CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(3, 14) or UDim2.fromOffset(3, 4), 0.25})
							CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.25})
						end
					else
						for _, v in pairs(Options) do
							local Slt = v.Value == Selected
							local nodes = v.nodes
							CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.25})
							CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(3, 16) or UDim2.fromOffset(3, 4), 0.25})
							CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.25})
						end
					end
					UpdateLabel()
				end
				
				local function Select(Option)
					if MultiSelect then
						Option.Stats = not Option.Stats
						Selected[Option.Name] = Option.Stats
						CallbackSelected()
					else
						Selected = Option.Value
						CallbackSelected()
					end
					UpdateSelected()
				end
				
				AddOption = function(index, Value)
					local Name = tostring(type(index) == "string" and index or Value)
					if Options[Name] then return end
					Options[Name] = {
						index = index,
						Value = Value,
						Name = Name,
						Stats = false,
						LastCB = 0
					}
					
					if MultiSelect then
						local Stats = Selected[Name]
						Selected[Name] = Stats or false
						Options[Name].Stats = Stats
					end
					
					local OptionButton = Make("Button", ScrollFrame, {
						Name = "Option",
						Size = UDim2.new(1, 0, 0, 24),
						Position = UDim2.new(0, 0, 0.5),
						AnchorPoint = Vector2.new(0, 0.5)
					})
					Make("Corner", OptionButton, UDim.new(0, 8))
					Make("Stroke", OptionButton)
					
					local IsSelected = InsertTheme(Create("Frame", OptionButton, {
						Position = UDim2.new(0, 1, 0.5),
						Size = UDim2.new(0, 3, 0, 4),
						BackgroundColor3 = Theme["Color Theme"],
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 0.5)
					}), "Theme")
					Make("Corner", IsSelected, UDim.new(1, 0))
					
					local OptioneName = InsertTheme(Create("TextLabel", OptionButton, {
						Size = UDim2.new(1, -20, 1),
						Position = UDim2.new(0, 12),
						Text = Name,
						TextColor3 = Theme["Color Text"],
						Font = Enum.Font.GothamBold,
						TextSize = 10,
						TextXAlignment = "Left",
						BackgroundTransparency = 1,
						TextTransparency = 0.4
					}), "Text")
					
					OptionButton.Activated:Connect(function()
						Select(Options[Name])
					end)
					Options[Name].nodes = {OptionButton, IsSelected, OptioneName}
				end
				
				RemoveOption = function(index, Value)
					local Name = tostring(type(index) == "string" and index or Value)
					if Options[Name] then
						if MultiSelect then Selected[Name] = nil else Selected = nil end
						Options[Name].nodes[1]:Destroy()
						Options[Name] = nil
					end
				end
				
				GetOptions = function()
					return Options
				end
				
				AddNewOptions = function(List, Clear)
					if Clear then
						for k in pairs(Options) do
							RemoveOption(k, Options[k].Value)
						end
					end
					for _, v in ipairs(List) do
						AddOption(v, v)
					end
					CallbackSelected()
					UpdateSelected()
				end
				
				for k, v in pairs(DOptions) do
					AddOption(k, v)
				end
				CallbackSelected()
				UpdateSelected()
			end
			
			Button.Activated:Connect(Minimize)
			NoClickFrame.MouseButton1Down:Connect(Disable)
			NoClickFrame.MouseButton1Click:Connect(Disable)
			
			MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
				if NoClickFrame.Visible then Disable() end
			end)
			
			SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)
			Button.Activated:Connect(CalculateSize)
			ScrollFrame.ChildAdded:Connect(CalculateSize)
			ScrollFrame.ChildRemoved:Connect(CalculateSize)
			CalculatePos()
			CalculateSize()
			
			local Dropdown = {}
			
			function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Dropdown:Destroy() Button:Destroy() end
			function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)(Selected) end
			
			function Dropdown:Add(...)
				local NewOptions = {...}
				local list = type(NewOptions[1]) == "table" and NewOptions[1] or NewOptions
				for _, Name in ipairs(list) do
					AddOption(Name, Name)
				end
			end
			
			function Dropdown:Remove(Option)
				for index, Value in pairs(GetOptions()) do
					if (type(Option) == "number" and index == Option) or Value.Name == Option then
						RemoveOption(index, Value.Value)
					end
				end
			end
			
			function Dropdown:Select(Option)
				for _, Val in pairs(GetOptions()) do
					if (type(Option) == "string" and Val.Name == Option) or type(Option) == "number" then
						Select(Val)
						break
					end
				end
			end
			
			function Dropdown:Set(Val1, Clear)
				if type(Val1) == "table" then
					AddNewOptions(Val1, not Clear)
				elseif type(Val1) == "function" then
					Callback = {Val1}
				end
			end
			return Dropdown
		end
		
		function Tab:AddSlider(Configs)
			local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
			local SDesc = Configs.Desc or Configs.Description or ""
			local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
			local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
			local Increase = Configs[4] or Configs.Increase or 1
			local Callback = Funcs:GetCallback(Configs, 6)
			local Default = Configs[5] or Configs.Default or 25
			Min, Max = Min / Increase, Max / Increase
			
			local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -190))
			
			local SliderHolder = Create("TextButton", Button, {
				Size = UDim2.new(0, 160, 1),
				Position = UDim2.new(1, -10),
				AnchorPoint = Vector2.new(1, 0),
				AutoButtonColor = false,
				Text = "",
				BackgroundTransparency = 1
			})
			
			local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
				BackgroundColor3 = Theme["Color Stroke"],
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, -20, 0, 4),
				Position = UDim2.new(0.5, 0, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5)
			}), "Stroke")
			Make("Corner", SliderBar, UDim.new(1, 0))
			Make("Stroke", SliderBar)
			
			local Indicator = InsertTheme(Create("Frame", SliderBar, {
				BackgroundColor3 = Theme["Color Theme"],
				Size = UDim2.fromScale(0.3, 1),
				BorderSizePixel = 0
			}), "Theme")
			Make("Corner", Indicator, UDim.new(1, 0))
			
			local SliderIcon = Create("Frame", SliderBar, {
				Size = UDim2.new(0, 20, 0, 11),
				BackgroundColor3 = Color3.fromRGB(220, 220, 220),
				Position = UDim2.fromScale(0.3, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0
			})
			Make("Corner", SliderIcon)
			
			local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
				Size = UDim2.new(0, 18, 0, 18),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0, -5, 0.5),
				BackgroundTransparency = 1,
				TextColor3 = Theme["Color Text"],
				Font = Enum.Font.GothamBold,
				TextSize = 11
			}), "Text")
			
			local UIScaleObj = Create("UIScale", LabelVal)
			
			local BaseMousePos = Create("Frame", SliderBar, {
				Position = UDim2.new(0, 0, 0.5, 0),
				Visible = false
			})
			
			local function UpdateLabel(NewValue)
				local Number = tonumber(NewValue * Increase)
				Number = math.floor(Number * 100) / 100
				Default, LabelVal.Text = Number, tostring(Number)
				Funcs:FireCallback(Callback, Default)
			end
			
			local function ControlPos()
				local MousePos = Player:GetMouse()
				local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
				local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X
				SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
			end
			
			local function UpdateValues()
				Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
				local SliderPos = SliderIcon.Position.X.Scale
				local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
				UpdateLabel(NewValue)
			end
			
			SliderHolder.MouseButton1Down:Connect(function()
				CreateTween({SliderIcon, "BackgroundTransparency", 0.4, 0})
				CreateTween({SliderIcon, "Size", UDim2.new(0, 22, 0, 12), 0.2})
				Container.ScrollingEnabled = false
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					task.wait()
					ControlPos()
				end
				CreateTween({SliderIcon, "BackgroundTransparency", 0, 0.4})
				CreateTween({SliderIcon, "Size", UDim2.new(0, 20, 0, 11), 0.2})
				Container.ScrollingEnabled = true
			end)
			
			LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
				UIScaleObj.Scale = 0.3
				CreateTween({UIScaleObj, "Scale", 1.1, 0.1})
				CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 3, 0.12, true})
				CreateTween({UIScaleObj, "Scale", 1, 0.15})
				CreateTween({LabelVal, "Rotation", 0, 0.1})
			end)
			
			function SetSlider(NewValue)
				if type(NewValue) ~= "number" then return end
				local SliderPos = (NewValue - Min * Increase) / (Max * Increase - Min * Increase)
				CreateTween({SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true})
			end
			
			SetSlider(Default)
			SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues)
			UpdateValues()
			
			local Slider = {}
			function Slider:Set(NewVal1, NewVal2)
				if NewVal1 and NewVal2 then
					LabelFunc:SetTitle(NewVal1)
					LabelFunc:SetDesc(NewVal2)
				elseif type(NewVal1) == "string" then
					LabelFunc:SetTitle(NewVal1)
				elseif type(NewVal1) == "function" then
					Callback = {NewVal1}
				elseif type(NewVal1) == "number" then
					SetSlider(NewVal1)
				end
			end
			function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end
			function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Slider:Destroy() Button:Destroy() end
			return Slider
		end
		
		function Tab:AddTextBox(Configs)
			local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
			local TDesc = Configs.Desc or Configs.Description or ""
			local TDefault = Configs[2] or Configs.Default or ""
			local TPlaceholderText = Configs[5] or Configs.PlaceholderText or "Input"
			local TClearText = Configs[3] or Configs.ClearText or false
			local Callback = Funcs:GetCallback(Configs, 4)
			
			if type(TDefault) ~= "string" or TDefault:gsub(" ", "") == "" then
				TDefault = false
			end
			
			local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -48))
			
			local SelectedFrame = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 160, 0, 22),
				Position = UDim2.new(1, -12, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"],
				BackgroundTransparency = 0.3
			}), "Stroke")
			Make("Corner", SelectedFrame, UDim.new(0, 8))
			Make("Stroke", SelectedFrame)
			
			local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
				Size = UDim2.new(1, -35, 1, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = Theme["Color Text"],
				TextXAlignment = "Left",
				ClearTextOnFocus = TClearText,
				PlaceholderText = TPlaceholderText,
				PlaceholderColor3 = Theme["Color Dark Text"],
				Text = ""
			}), "Text")
			
			local Pencil = InsertTheme(Create("ImageLabel", SelectedFrame, {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -8, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://15637081879",
				ImageColor3 = Theme["Color Text"],
				BackgroundTransparency = 1
			}), "Text")
			
			local TextBox = {}
			local function Input()
				local Text = TextBoxInput.Text
				if Text:gsub(" ", "") ~= "" then
					if TextBox.OnChanging then
						Text = TextBox.OnChanging(Text) or Text
					end
					Funcs:FireCallback(Callback, Text)
					TextBoxInput.Text = Text
				end
			end
			
			TextBoxInput.FocusLost:Connect(Input)
			Input()
			
			TextBoxInput.FocusLost:Connect(function()
				CreateTween({Pencil, "ImageColor3", Theme["Color Text"], 0.2})
				CreateTween({SelectedFrame, "BackgroundTransparency", 0.3, 0.2})
			end)
			TextBoxInput.Focused:Connect(function()
				CreateTween({Pencil, "ImageColor3", Theme["Color Theme"], 0.2})
				CreateTween({SelectedFrame, "BackgroundTransparency", 0.1, 0.2})
			end)
			
			TextBox.OnChanging = false
			function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function TextBox:Destroy() Button:Destroy() end
			return TextBox
		end
		
		function Tab:AddDiscordInvite(Configs)
			local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
			local Desc = Configs.Desc or Configs.Description or ""
			local Logo = Configs[2] or Configs.Logo or ""
			local Invite = Configs[3] or Configs.Invite or ""
			
			local InviteHolder = Create("Frame", Container, {
				Size = UDim2.new(1, 0, 0, 95),
				Name = "Option",
				BackgroundTransparency = 1
			})
			
			local InviteLabel = InsertTheme(Create("TextLabel", InviteHolder, {
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.new(0, 5),
				TextColor3 = Theme["Color Theme"],
				Font = Enum.Font.GothamBold,
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 11,
				Text = Invite
			}), "Theme")
			
			local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
				Size = UDim2.new(1, 0, 0, 75),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1),
				BackgroundColor3 = Theme["Color Hub 2"],
				BackgroundTransparency = 0.3
			}), "Frame")
			Make("Corner", FrameHolder, UDim.new(0, 8))
			Make("Stroke", FrameHolder)
			Make("Gradient", FrameHolder, {Rotation = 45})
			
			local ImageLabel = Create("ImageLabel", FrameHolder, {
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 8, 0, 8),
				Image = Logo,
				BackgroundTransparency = 1
			})
			Make("Corner", ImageLabel, UDim.new(0, 8))
			Make("Stroke", ImageLabel)
			
			local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
				Size = UDim2.new(1, -54, 0, 16),
				Position = UDim2.new(0, 48, 0, 8),
				Font = Enum.Font.GothamBold,
				TextColor3 = Theme["Color Text"],
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 11,
				Text = Title
			}), "Text")
			
			local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
				Size = UDim2.new(1, -54, 0, 0),
				Position = UDim2.new(0, 48, 0, 24),
				TextWrapped = "Y",
				AutomaticSize = "Y",
				Font = Enum.Font.Gotham,
				TextColor3 = Theme["Color Dark Text"],
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 10,
				Text = Desc
			}), "DarkText")
			
			local JoinButton = InsertTheme(Create("TextButton", FrameHolder, {
				Size = UDim2.new(1, -16, 0, 20),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -8),
				Text = "Join",
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = Theme["Color Text"],
				BackgroundColor3 = Color3.fromRGB(70, 180, 70),
				BackgroundTransparency = 0.2
			}), "Custom")
			Make("Corner", JoinButton, UDim.new(0, 8))
			
			local ClickDelay
			JoinButton.Activated:Connect(function()
				setclipboard(Invite)
				if ClickDelay then return end
				ClickDelay = true
				SetProps(JoinButton, {
					Text = "Copied!",
					BackgroundColor3 = Theme["Color Theme"],
					TextColor3 = Theme["Color Text"]
				})
				task.wait(3)
				SetProps(JoinButton, {
					Text = "Join",
					BackgroundColor3 = Color3.fromRGB(70, 180, 70),
					TextColor3 = Theme["Color Text"]
				})
				ClickDelay = false
			end)
			
			local DiscordInvite = {}
			function DiscordInvite:Destroy() InviteHolder:Destroy() end
			function DiscordInvite:Visible(...) Funcs:ToggleVisible(InviteHolder, ...) end
			return DiscordInvite
		end

--[[
    Sistema de Notificaciones Optimizado para Nova Lib
    Con animaciones de entrada y salida
]]

function novalib:Notify(Configs)
    Configs = Configs or {}
    local Title = Configs.Title or "Notification"
    local Content = Configs.Content or ""
    local Icon = Configs.Icon and self:GetIcon(Configs.Icon) or "rbxassetid://10747384394"
    local Duration = Configs.Duration or 5
    
    -- Crear contenedor si no existe
    if not self.NotificationHolder then
        self.NotificationHolder = Create("Frame", ScreenGui, {
            Name = "NotificationHolder",
            Size = UDim2.new(0, 300, 1, -156),
            Position = UDim2.new(1, -29, 0, 56),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {
                VerticalAlignment = "Bottom",
                Padding = UDim.new(0, 8)
            }),
            Create("UIPadding", {PaddingBottom = UDim.new(0, 29)})
        })
    end
    
    -- Frame principal de la notificación
    local Notification = Create("Frame", self.NotificationHolder, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = "Y",
        Position = UDim2.new(2, 0, 1, 0), -- Fuera de la pantalla (derecha)
        AnchorPoint = Vector2.new(0, 1)
    })
    
    -- Contenido de la notificación
    local ContentFrame = InsertTheme(Create("Frame", Notification, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundColor3 = Theme["Color Hub 2"],
        BackgroundTransparency = 0.25
    }), "Frame")
    Make("Corner", ContentFrame, UDim.new(0, 16))
    Make("Stroke", ContentFrame)
    
    -- Ícono
    local IconLabel = InsertTheme(Create("ImageLabel", ContentFrame, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0, 12),
        Image = Icon,
        BackgroundTransparency = 1,
        ImageColor3 = Theme["Color Theme"]
    }), "Theme")
    
    -- Botón cerrar
    local CloseBtn = InsertTheme(Create("ImageButton", ContentFrame, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -12, 0, 12),
        AnchorPoint = Vector2.new(1, 0),
        Image = "rbxassetid://10747384394",
        BackgroundTransparency = 1,
        ImageColor3 = Theme["Color Text"]
    }), "Text")
    
    -- Efecto hover del botón cerrar
    CloseBtn.MouseEnter:Connect(function()
        CreateTween({CloseBtn, "ImageColor3", Color3.fromRGB(255, 80, 80), 0.15})
    end)
    CloseBtn.MouseLeave:Connect(function()
        CreateTween({CloseBtn, "ImageColor3", Theme["Color Text"], 0.15})
    end)
    
    -- Contenedor de texto
    local TextContainer = Create("Frame", ContentFrame, {
        Size = UDim2.new(1, -52, 0, 0),
        Position = UDim2.new(0, 44, 0, 8),
        BackgroundTransparency = 1,
        AutomaticSize = "Y"
    }, {
        Create("UIListLayout", {Padding = UDim.new(0, 2)}),
        Create("UIPadding", {PaddingBottom = UDim.new(0, 8)})
    })
    
    -- Título
    local TitleLabel = InsertTheme(Create("TextLabel", TextContainer, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme["Color Text"],
        TextXAlignment = "Left",
        BackgroundTransparency = 1
    }), "Text")
    
    -- Descripción (solo si existe)
    if Content and Content ~= "" then
        InsertTheme(Create("TextLabel", TextContainer, {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = "Y",
            Text = Content,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme["Color Dark Text"],
            TextXAlignment = "Left",
            BackgroundTransparency = 1
        }), "DarkText")
    end
    
    -- Barra de progreso
    local ProgressBar
    if Duration > 0 then
        ProgressBar = InsertTheme(Create("Frame", ContentFrame, {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Theme["Color Theme"],
            BackgroundTransparency = 0.5
        }), "Theme")
        Make("Corner", ProgressBar, UDim.new(1, 0))
    end
    
    -- Función de cierre
    local Closed = false
    local function Close()
        if Closed then return end
        Closed = true
        
        -- Animación de salida (deslizar hacia la derecha)
        CreateTween({Notification, "Position", UDim2.new(2, 0, 1, 0), 0.25})
        task.wait(0.25)
        Notification:Destroy()
    end
    
    CloseBtn.MouseButton1Click:Connect(Close)
    
    -- Animación de entrada (deslizar desde la derecha)
    CreateTween({Notification, "Position", UDim2.new(0, 0, 1, 0), 0.3})
    
    -- Auto-cierre
    if Duration > 0 then
        CreateTween({ProgressBar, "Size", UDim2.new(0, 0, 0, 2), Duration})
        task.spawn(function()
            task.wait(Duration)
            Close()
        end)
    end
    
    -- Métodos públicos
    return {
        Close = Close,
        SetTitle = function(_, t) if t then TitleLabel.Text = tostring(t) end end,
        SetDesc = function(_, d) 
            if d then
                local descLabel = TextContainer:FindFirstChildOfClass("TextLabel")
                if descLabel and descLabel ~= TitleLabel then
                    descLabel.Text = tostring(d)
                end
            end
        end
    }
end

-- Función para cambiar posición
function novalib:SetNotificationLower(Lower)
    if self.NotificationHolder then
        self.NotificationHolder.Size = Lower and 
            UDim2.new(0, 300, 1, -56) or 
            UDim2.new(0, 300, 1, -156)
    end
end
      
		return Tab
	end
	
	CloseButton.Activated:Connect(Window.CloseBtn)
	MinimizeButton.Activated:Connect(Window.MinimizeBtn)
	return Window
end

return novalib
