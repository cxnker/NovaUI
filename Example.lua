local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/NovaUI/main/src/nova.lua"))()

local Window = Library:MakeWindow({
  Title = "Nova UI | Example",
  SubTitle = "by nova",
  SaveFolder = "nova_data.lua"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://120545479757972", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(1,1) },
})

local Tab1 = Window:MakeTab({"Tab1", "info"})
local Tab2 = Window:MakeTab({"Tab2", "house"})

Tab1:AddButton({"Custom Theme", function()
  Library:SetTheme("Custom")
end})

Window:SelectTab(Tab2)
local Section = Tab2:AddSection({"Section", "info"})

Tab2:AddDiscordInvite({
    Name = "Name Hub",
    Description = "Join server",
    Logo = "rbxassetid://18751483361",
    Invite = "Link discord invite",
})

local Paragraph = Tab2:AddParagraph({"Paragraph", "This is a Paragraph\nSecond Line"})

local Number = 0
local Button = Tab2:AddButton({"Button", function()
  Number = Number + 1
  Section:Set("Number : " .. tostring(Number))
  local Dialog = Window:Dialog({
    Title = "Dialog",
    Text = "This is a Dialog",
    Options = {
      {"Confirm", function()
        
      end},
      {"Maybe", function()
        
      end},
      {"Cancel", function()
        
      end}
    }
  })
end})

local Button = Tab2:AddButton({
  Name = "Invisible Toggle",
  Description = "Makes the Toggles Invisible"
})

local Toggle1 = Tab2:AddToggle({
  Name = "Toggle 1",
  Description = "This is a <font color='rgb(88, 101, 242)'>Toggle</font> Example",
  Default = false
})

local Toggle2 = Tab2:AddToggle({
  Name = "Toggle 2",
  Default = true
})

Button:Callback(Toggle1.Visible)
Button:Callback(Toggle2.Visible)

Toggle1:Callback(function(Value)
  Toggle2:Set(false)
end)
Toggle2:Callback(function(Value)
  Toggle1:Set(false)
end)

Tab2:AddSlider({
  Name = "Slider",
  Min = 1,
  Max = 10,
  Increase = 1,
  Default = 5,
  Callback = function(Value)
    
  end
})

local Dropdown = Tab2:AddDropdown({
  Name = "Players List",
  Description = "Select the <font color='rgb(88, 101, 242)'>Number</font>",
  Options = {"one", "two", "three"},
  Default = "two",
  Flag = "dropdown teste",
  Callback = function(Value)
    
  end
})

local Button = Tab2:AddButton({"Refresh Dropdown"})

Button:Callback(function()
  Dropdown:Set(game.Players:GetPlayers())
  Dropdown:Remove(game.Players.LocalPlayer.Name)
end)

Dropdown:Remove(Player.Name)
Dropdown:Select(1)

Tab2:AddTextBox({
  Name = "Textbox",
  Description = "this is a Text box",
  Default = "Text",
  Callback = function(Value)
    
  end
})

Tab2:AddButton({"Notify Test", function()
Library:Notify({
    Title = "Notify Test",
    Content = "Description",
    Icon = "rbxassetid://10723415903",
    Duration = 4
})
end})

--[[function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end

    return result
end

local Paragraph = Tab2:AddParagraph({"Paragraph ", gradient("NovaUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF"))})]]

--[[ Soon
Tab3:Dropdown({
    Name = "Theme",
    Options = {"Default", "Custom", "Amethyst", "Bloom", "Dark", "DarkBlue", "Light", "Serenity"},
    CurrentOption = {"Default"},
    Flag = "ThemeDropdown",
    Callback = function(option)
        Window.ModifyTheme(option[1])
    end
})]]
