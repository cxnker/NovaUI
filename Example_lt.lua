local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/NovaUI/main/src/nova_lt.lua"))()

local Window = Library:MakeWindow({
  Title = "Nova UI | Example LT",
  SubTitle = "by nova"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://120545479757972", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(1,1) },
})

local Tab1 = Window:MakeTab({"Info", "rbxassetid://10723415903"})
local Tab2 = Window:MakeTab({"Custom", "rbxassetid://137986121120732"})

Tab1:AddDiscordInvite({
    Name = "Server Name",
    Description = "Server Description",
    Logo = "rbxassetid://18751483361",
    Invite = "Link discord invite",
})

local Section = Tab1:AddSection({"Section", "info"})

local Paragraph = Tab1:AddParagraph({"Paragraph", "This is a Paragraph\nSecond Line"})

local Toggle1 = Tab1:AddToggle({
    Name = "Toggle",
    Description = "This is a <font color='rgb(88, 101, 242)'>Toggle</font> Example",
    Default = false 
})

Toggle1:Callback(function(Value)
 
end)

Tab1:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(v)

    end
})

Tab1:AddSlider({
    Name = "Slider Name",
    Description = "Slider Description", 
    Min = 1,
    Max = 100,
    Increase = 1,
    Default = 16,
    Callback = function(Value)
  
    end
})

Tab1:AddTextBox({
    Name = "Textbox Name",
    Description = "Textbox Description", 
    PlaceholderText = "Textbox Text",
    Callback = function(Value)
    
    end
})

local Dropdown = Tab1:AddDropdown({
    Name = "Players List",
    Description = "Select the <font color='rgb(88, 101, 242)'>Number</font>",
    Options = {"One", "Two", "Three"},
    Default = "Two",
    -- Flag = "dropdown_data",
    Callback = function(Value)
    
    end
})

local Button = Tab1:AddButton({"Refresh Dropdown"})

Button:Callback(function()
    Dropdown:Set(game.Players:GetPlayers())
    Dropdown:Remove(game.Players.LocalPlayer.Name)
end)

Dropdown:Remove(Player.Name)
Dropdown:Select(1)

local Section2 = Tab2:AddSection({"Theme", "rbxassetid://137986121120732"})

Tab2:AddButton({"Set Custom Theme", function()
    Library:SetTheme("Custom")
end})
