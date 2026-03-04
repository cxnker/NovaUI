local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/NovaUI/main/src/nova_dev.lua"))()

local Window = Library:MakeWindow({
  Title = "Nova UI | Example LT",
  SubTitle = "by nova"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://120545479757972", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(1,1) },
})

local Tab1 = Window:MakeTab({"Tab", "rbxassetid://10723415903"})

Tab1:AddDiscordInvite({
    Name = "Server Name",
    Description = "Join server",
    Logo = "rbxassetid://18751483361",
    Invite = "Link discord invite",
})

local Section = Tab1:AddSection({"Section", "rbxassetid://10723415903"})

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
  Name = "Speed",
  Min = 1,
  Max = 100,
  Increase = 1,
  Default = 16,
  Callback = function(Value)
  
  end
})

local Dropdown = Tab1:AddDropdown({
  Name = "Players List",
  Description = "Select the <font color='rgb(88, 101, 242)'>Number</font>",
  Options = {"one", "two", "three"},
  Default = "two",
  Flag = "dropdown teste",
  Callback = function(Value)
    
  end
})

Tab1:AddTextBox({
  Name = "Name item",
  Description = "1 Item on 1 Server", 
  PlaceholderText = "item only",
  Callback = function(Value)
    
  end
})

Tab1:AddButton({"Custom Theme", function()
novalib:Notify({
    Title = "Éxito",
    Content = "Operación completada",
    Icon = "rbxassetid://10723415903",
    Duration = 3
})
end})
