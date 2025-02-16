-- todo

--[[
setting values for elements, and making them work for callback etc
]]


-- locals
local Game = game

local NewVector3 = Vector3.new
local NewVector2 = Vector2.new
local NewRender = Instance.new
local NewUDim2 = UDim2.new

local ZeroVector3 = Vector3.zero
local ZeroVector2 = Vector2.zero

local NewRGB = Color3.fromRGB

local Format = string.format

local Remove = table.remove
local Concat = table.concat
local Clear = table.clear
local Find = table.find

local Round = math.round
local Clamp = math.clamp
local Floor = math.floor
local Ceil = math.ceil
local Max = math.max

local Spawn = task.spawn
local Wait = task.wait

-- services
local UserInputService = Game:GetService("UserInputService")
local HttpService = Game:GetService("HttpService")
local RunService = Game:GetService("RunService")
local Players = Game:GetService("Players")


-- vars
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = Game:GetService("CoreGui")


-- tables
local Menu = {
	Connections = {},
	Windows = {},
	Renders = {},
	
	TextFont = nil,
	TextSize = 9,

    CurrentZIndex = 0,
	
	Debug = true
}

-- Fonts
do
    local Data = {
        name = "Pixel",
        faces = {
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset("Pixel.ttf"),
            },
        },
    }

    writefile("Pixel.font", HttpService:JSONEncode(Data))
    Menu.TextFont = Font.new(getcustomasset("Pixel.font"), Enum.FontWeight.Regular)
end


function Menu:Draw(Type, Properties, Table)
	local Render = nil
	
	if Type == "Frame" then
		Render = NewRender("Frame")
		Render.BorderSizePixel = 1
		Render.BackgroundTransparency = 0
		Render.BorderColor3 = NewRGB(0, 0, 0)
		Render.BackgroundColor3 = NewRGB(0, 0, 0)
        Render.ZIndex = Menu.CurrentZIndex
		Render.Visible = true
	elseif Type == "UIStroke" then
		Render = NewRender("UIStroke")
		Render.LineJoinMode = Enum.LineJoinMode.Miter
        Render.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Render.Color = NewRGB(0, 0, 0)
		Render.Transparency = 0
        Render.Thickness = 1
	elseif Type == "TextLabel" then
		Render = NewRender("TextLabel")
		Render.BackgroundTransparency = 1
		Render.TextStrokeTransparency = 0
		Render.TextTransparency = 0
		Render.TextColor3 = NewRGB(255, 255, 255)
		Render.TextStrokeColor3 = NewRGB(0, 0, 0)
		Render.FontFace = Menu.TextFont
		Render.TextSize = Menu.TextSize
        Render.ZIndex = Menu.CurrentZIndex
		Render.Visible = true
    elseif Type == "TextButton" then
        Render = NewRender("TextButton")
        Render.BorderSizePixel = 1
		Render.BackgroundTransparency = 0
        Render.TextStrokeTransparency = 0
		Render.BorderColor3 = NewRGB(0, 0, 0)
		Render.BackgroundColor3 = NewRGB(50, 50, 50)
        Render.TextColor3 = NewRGB(255, 255, 255)
		Render.TextStrokeColor3 = NewRGB(0, 0, 0)
		Render.FontFace = Menu.TextFont
		Render.TextSize = Menu.TextSize
        Render.AutoButtonColor = false
        Render.RichText = true
        Render.ZIndex = Menu.CurrentZIndex
		Render.Visible = true
	elseif Type == "ScreenGui" then
		Render = NewRender("ScreenGui")
		Render.DisplayOrder = 2
		Render.ZIndexBehavior = Enum.ZIndexBehavior.Global
	end
	
	if Menu.Debug then assert(Render, "[-] Invalid Render Type: " .. Type) end
	
	for Index, Value in next, Properties do
		Render[Index] = Value
	end

    Menu.CurrentZIndex = Menu.CurrentZIndex + 1
	
	if Table then
		Table[#Table + 1] = Render
	else
		Menu.Renders[#Menu.Renders + 1] = Render
	end
	
	return Render
end

function Menu:NewWindow(Args)
	local Args = Args or {}
	local Name = Args.Name or "chudvision.net"
    local Size = Args.Size or nil -- todo
		
	local Window = {
		Name = Name,
        CurrentTab = nil,
        IsOpen = true, -- by default, wont affect current menu visibility TODO
		Renders = {},
		Tabs = {},
	}
	
	Menu.Windows[#Menu.Windows + 1] = Window
	
    -- Renders
    do
        local ScreenGui = Menu:Draw("ScreenGui", {Parent = CoreGui, Name = Window.Name}, Window.Renders)
        
        local Frame1 = Menu:Draw("Frame", {Parent = ScreenGui, AnchorPoint = NewVector2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = NewUDim2(0, 579 - 2, 0, 469 - 2), BackgroundColor3 = NewRGB(10, 10, 10)})
        local Frame2 = Menu:Draw("Frame", {Parent = Frame1, Position = NewUDim2(0, 2, 0, 2), Size = NewUDim2(1, -4, 1, -4), BackgroundColor3 = NewRGB(28, 28, 28), BorderSizePixel = 0, Active = true})
        local Frame3 = Menu:Draw("Frame", {Parent = Frame2, Position = NewUDim2(0, 5, 0, 20), Size = NewUDim2(1, -10, 1, -25), Name = "Frame3", BackgroundColor3 = NewRGB(33, 33, 33), BorderColor3 = NewRGB(29, 29, 29), BorderMode = Enum.BorderMode.Inset})
        local Frame3Stroke = Menu:Draw("UIStroke", {Parent = Frame3})
        local Title = Menu:Draw("TextLabel", {Parent = Frame2, Text = Name, TextXAlignment = Enum.TextXAlignment.Left, Position = NewUDim2(0, 6, 0, 9)})

        local Scale = Frame2.AbsoluteSize.X * 0.23
        local TabsHolder = Menu:Draw("Frame", {Parent = Frame2, Position = NewUDim2(0, Scale, 0, 3), Size = NewUDim2(0, Frame2.AbsoluteSize.X - 44 - Scale, 0, 16)})

        Window["Frame1"] = Frame1
        Window["Frame2"] = Frame2
        Window["Frame3"] = Frame3
        Window["TabsHolder"] = TabsHolder
    end

    local TabsFrames = {
        [1] = Menu:Draw("Frame", {Parent = nil, BackgroundColor3 = NewRGB(28, 28, 28), BorderSizePixel = 0}),
        [2] = Menu:Draw("Frame", {Parent = nil, BackgroundColor3 = NewRGB(33, 33, 33), BorderSizePixel = 0})
    }

    function Window:NewTab(Args)
        local Args = Args or {}
        local Name = Args.Name or "Tab"
        local HasSubs = Args.Subs or false

        local Tab = {
            Name = Name,
            HasSubs = HasSubs,
            IsOpen = false, -- todo add this bullshit (auto open first tab)
            CurrentSub = nil,
            Type = "Tab",
            Sections = {},
            Renders = {},
            Subs = {}
        }

        Window.Tabs[#Window.Tabs + 1] = Tab

        -- Renders
        do
            local TabButton = Menu:Draw("TextButton", {Parent = Window["TabsHolder"], Size = NewUDim2(0, 0, 0, 0), Position = NewUDim2(0, 0, 0, 0), Name = Name, Text = Name, BackgroundColor3 = NewRGB(46, 46, 46), TextColor3 = NewRGB(165, 165, 165)})
            local TabButtonStroke = Menu:Draw("UIStroke", {Parent = TabButton, Color = NewRGB(39, 39, 39)})

            if HasSubs then
                local SubsHolder = Menu:Draw("Frame", {Parent = Window["Frame3"], Position = NewUDim2(0, 5, 0, 4), Size = NewUDim2(0, Window["Frame3"].AbsoluteSize.X - 12, 0, 18), BorderColor3 = NewRGB(28, 28, 28), Visible = Tab.IsOpen}, Tab.Renders)
                Tab["SubsHolder"] = SubsHolder
            else
                local SectionsHolder = Menu:Draw("Frame", {Parent = Window["Frame3"], Position = NewUDim2(0, 5, 0, 5), Size = NewUDim2(1, -10, 1, -10), BackgroundColor3 = NewRGB(33, 33, 33), BorderSizePixel = 0, Name = "SectionsHolder", Visible = Tab.IsOpen}, Tab.Renders)
                
                Tab["SectionsHolder"] = SectionsHolder
            end

            Tab["Button"] = TabButton
            Tab["Stroke"] = TabButtonStroke

            Window:ResizeTabs(Window)
        end

        -- Functions
        do
            function Tab:SetContent(Bool)
                for i = 1, #Tab.Renders do
                    Tab.Renders[i].Visible = Bool
                end

                for i = 1, #Tab.Sections do
                    Tab.Sections[i]:SetContent(Bool)
                end

                for i = 1, #Tab.Subs do
                    local Sub = Tab.Subs[i]
                    for k = 1, #Sub.Renders do
                        Sub.Renders[k].Visible = Bool
                    end

                    if not Bool then
                        Sub:SetContent(Bool)
                    elseif Tab.CurrentSub == Sub then
                        Sub:SetContent(true)
                    end
                end
            end

            function Tab:SetOpen(Bool) -- TODO add a bool here
                if Window.CurrentTab == Tab then return end
                Bool = Bool or not Tab.IsOpen

                if Window.CurrentTab then
                    Window.CurrentTab["Button"].BackgroundColor3 = NewRGB(46, 46, 46)
                    Window.CurrentTab["Button"].TextColor3 = NewRGB(165, 165, 165)
                    Window.CurrentTab["Stroke"].Color = NewRGB(39, 39, 39)
                    Window.CurrentTab.IsOpen = false
                    Window.CurrentTab:SetContent(false)

                    if Window.CurrentTab.CurrentSub then
                        Window.CurrentTab.CurrentSub:SetOpen(false)
                    end
                end

                Window.CurrentTab = Tab
                Tab["Button"].BackgroundColor3 = NewRGB(33, 33, 33)
                Tab["Button"].TextColor3 = NewRGB(240, 133, 72)
                Tab["Stroke"].Color = NewRGB(28, 28, 28)
                Tab.IsOpen = true
                Tab:SetContent(true)

                if Tab.CurrentSub then
                    Tab.CurrentSub:SetOpen(true)
                end

                for i = 1, 2 do
                    local Frame = TabsFrames[i]
                    Frame.Parent = TabButton
                    Frame.Position = (i == 1 and NewUDim2(0, -1, 0, 15) or NewUDim2(0, 0, 0, 14))
                    Frame.Size = (i == 1 and NewUDim2(1, 2, 0, 1) or NewUDim2(1, 0, 0, 3))
                end
            end
        end

        function Tab:NewSub(Args)
            if not Tab.HasSubs then print("idiot, tab disallows subs") return end
            local Args = Args or {}
            local Name = Args.Name or "Sub Tab #" .. #Tab.Subs

            local Sub = {
                Name = Name,
                IsOpen = false,
                Type = "Sub",
                HasSubs = true,
                Renders = {}, -- Sub Tab Renders (Buttonz)
                SubRenders = {}, -- stuff like section
                Sections = {}, -- section shit
            }

            Tab.Subs[#Tab.Subs + 1] = Sub

            -- Renders
            do
                local SectionsHolder = Menu:Draw("Frame", {Parent = Window["Frame3"], Position = NewUDim2(0, 5, 0, 30), Size = NewUDim2(1, -10, 1, -35), Name = "SectionsHolder" .. Name, BackgroundColor3 = NewRGB(33, 33, 33), BorderSizePixel = 0, Visible = Sub.IsOpen}, Sub.SubRenders)
                local SubButton = Menu:Draw("TextButton", {Parent = Tab["SubsHolder"], Size = NewUDim2(0, 0, 1, -4), Position = NewUDim2(0, 0, 0, 2), Name = Name, Text = Name, BackgroundColor3 = NewRGB(46, 46, 46), BorderColor3 = NewRGB(39, 39, 39), TextColor3 = NewRGB(165, 165, 165), Visible = Tab.IsOpen}, Sub.Renders)

                Sub["Button"] = SubButton
                Sub["SectionsHolder"] = SectionsHolder
                
                Window:ResizeSubs(Tab)
            end

            function Sub:SetContent(Bool)
                for i = 1, #Sub.SubRenders do
                    Sub.SubRenders[i].Visible = Bool
                end

                for i = 1, #Sub.Sections do
                    Sub.Sections[i]:SetContent(Bool)
                end
            end

            function Sub:SetOpen(Bool) -- TODO add a bool here, or.. not?
                if Tab.CurrentSub == Sub then return end
                Bool = Bool or not Tab.IsOpen

                if Tab.CurrentSub then
                    Tab.CurrentSub["Button"].BackgroundColor3 = NewRGB(46, 46, 46)
                    Tab.CurrentSub["Button"].BorderColor3 = NewRGB(39, 39, 39)
                    Tab.CurrentSub["Button"].TextColor3 = NewRGB(165, 165, 165)
                    Tab.CurrentSub.IsOpen = false
                    Tab.CurrentSub:SetContent(false)
                end

                Tab.CurrentSub = Sub
                Sub["Button"].BackgroundColor3 = NewRGB(28, 28, 28)
                Sub["Button"].BorderColor3 = NewRGB(22, 22, 22)
                Sub["Button"].TextColor3 = NewRGB(240, 133, 72)
                Sub.IsOpen = true
                Sub:SetContent(true)
            end

            function Sub:NewSection(Args)
                return Window:NewSection(Args, Sub)
            end

            Sub["Button"].MouseButton1Down:Connect(Sub.SetOpen)

            return Sub
        end

        function Tab:NewSection(Args)
            return Window:NewSection(Args, Tab)
        end
        
        Tab["Button"].MouseButton1Down:Connect(Tab.SetOpen)

        return Tab
    end

    function Window:NewSection(Args, Element)
        local Args = Args or {}
        local Side = Args.Side or "Left"
        local Name = Args.Name or "Section"

        local Section = {
            Name = Name,
            Side = Side,
            IsOpen = Element.IsOpen,
            Offsets = {
                ["Left"] = 9,
                ["Right"] = 9
            },
            Content = {}
        }

        Element.Sections[#Element.Sections + 1] = Section

        local Type = Element.Type
        local IsLeft = Side == "Left"
        local TableType = Type == "Sub" and Element.SubRenders or Element.Renders

        local CoolSizeFix = Floor(Element["SectionsHolder"].AbsoluteSize.X * 0.5)
        local SectionOutFrame = Menu:Draw("Frame", {Parent = Element["SectionsHolder"], Position = NewUDim2(IsLeft and 0 or 0.5, IsLeft and 0 or 2, 0, 0), Size = NewUDim2(0, CoolSizeFix - 1, 1, 0), Name = Name, BackgroundColor3 = NewRGB(0, 0, 0), BorderColor3 = NewRGB(22, 22, 22), Visible = Element.IsOpen}, TableType)
        local SectionFrame = Menu:Draw("Frame", {Parent = SectionOutFrame, Position = NewUDim2(0, 2, 0, 2), Size = NewUDim2(1, -4, 1, -4), BackgroundColor3 = NewRGB(28, 28, 28), BorderColor3 = NewRGB(22, 22, 22), Visible = Element.IsOpen}, TableType)
        local SectionTitle = Menu:Draw("TextLabel", {Parent = SectionOutFrame, Position = NewUDim2(0, 15, 0, 0), TextColor3 = NewRGB(185, 185, 185), TextXAlignment = Enum.TextXAlignment.Left, Text = Name}, TableType)

        Section["Frame"] = SectionFrame

        function Section:SetContent(Bool)
            for i = 1, #Section.Content do
                Section.Content[i].Visible = Bool
            end
        end

        function Section:NewToggle(Args)
            local Args = Args or {}
            local Name = Args.Name or "Toggle"
            local Default = Args.Default or false
            local Callback = Args.Callback or nil

            local Toggle = {
                Current = Default
            }

            local ToggleOutline = Menu:Draw("Frame", {Parent = Section["Frame"], Position = NewUDim2(0, 8, 0, Section.Offsets[Section.Side]), Size = NewUDim2(0, 9, 0, 9), BackgroundColor3 = NewRGB(13, 13, 13), BorderColor3 = NewRGB(0, 0, 0), Visible = Section.IsOpen}, Section.Content)
            local ToggleFrame = Menu:Draw("Frame", {Parent = ToggleOutline, Position = NewUDim2(0, 1, 0, 1), Size = NewUDim2(1, -2, 1, -2), BackgroundColor3 = NewRGB(226, 93, 17), BorderColor3 = NewRGB(156, 62, 9), BackgroundTransparency = Default and 0 or 1, Visible = Section.IsOpen}, Section.Content)
            local ToggleButton = Menu:Draw("TextButton", {Parent = Section["Frame"], Size = NewUDim2(1, -2, 0, 9), Position = NewUDim2(0, 1, 0, Section.Offsets[Section.Side]), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Text = "     " .. Name, Visible = Section.IsOpen}, Section.Content)

            Toggle["Frame"] = ToggleFrame
            Toggle["Button"] = ToggleButton

            function Toggle:Set(Bool)
                Bool = Bool or not Toggle.Current

                Toggle.Current = Bool
                Toggle["Frame"].BackgroundTransparency = Bool and 0 or 1

                if Callback ~= nil then
                    Callback(Bool)
                end
            end

            Toggle["Button"].MouseButton1Down:Connect(function()
                local Current = not Toggle.Current

                Toggle.Current = Current
                Toggle["Frame"].BackgroundTransparency = Current and 0 or 1

                if Callback ~= nil then
                    Callback(Current)
                end
            end)

            Section.Offsets[Section.Side] = Section.Offsets[Section.Side] + 17

            return Toggle
        end

        function Section:NewSlider(Args)
            local Args = Args or {}
            local Name = Args.Name or "Slider"
            local Min = Args.Min or 0
            local Max = Args.Max or 100
            local Default = Args.Default or 50
            local Prefix = Args.Prefix or ""
            local Decimals = Args.Decimals or 1
            local Callback = Args.Callback or nil

            Default = Clamp(Default, Min, Max)
            Decimals = 1 / Decimals

            local Slider = {
                Min = Min,
                Max = Max,
                Prefix = Prefix,
                Decimals = Decimals,
                Current = Default
            }

            local SliderButton1 = Menu:Draw("TextButton", {Parent = Section["Frame"], Position = NewUDim2(0, 20, 0, Section.Offsets[Section.Side] + 15), Size = NewUDim2(1, -91, 0, 7), BackgroundColor3 = NewRGB(0, 0, 0), Text = "", Visible = Section.IsOpen}, Section.Content)
            local SliderButton2 = Menu:Draw("TextButton", {Parent = SliderButton1, Position = NewUDim2(0, 0, 0, 0), Size = NewUDim2(0, (SliderButton1.AbsoluteSize.X / (Slider.Max - Slider.Min)) * (Slider.Current - Slider.Min), 1, 0), BackgroundColor3 = NewRGB(226, 93, 17), Text = "", Interactable = false, Visible = Section.IsOpen}, Section.Content)
            local SliderValue = Menu:Draw("TextLabel", {Parent = SliderButton2, Position = NewUDim2(1, 0, 0, 7), Text = Slider.Current .. Slider.Prefix, TextXAlignment = Enum.TextXAlignment.Center, Visible = Section.IsOpen}, Section.Content)
            local SliderMinus = Menu:Draw("TextButton", {Parent = SliderButton1, Position = NewUDim2(0, -6, 0, 1), Size = NewUDim2(0, 5, 0, 5), BackgroundTransparency = 1, Text = "-", Visible = Section.IsOpen}, Section.Content)
            local SliderPlus = Menu:Draw("TextButton", {Parent = SliderButton1, Position = NewUDim2(1, 3, 0, 1), Size = NewUDim2(0, 5, 0, 5), BackgroundTransparency = 1, Text = "+", Visible = Section.IsOpen}, Section.Content)
            local SliderTitle = Menu:Draw("TextLabel", {Parent = SliderButton1, Position = NewUDim2(0, 1, 0, -9), Text = Name, TextXAlignment = Enum.TextXAlignment.Left, Visible = Section.IsOpen}, Section.Content)

            Slider["Button1"] = SliderButton1
            Slider["Button2"] = SliderButton2
            Slider["Value"] = SliderValue
            Slider["Minus"] = SliderMinus
            Slider["Plus"] = SliderPlus

            function Slider:Set(Value)
                local OldValue = Slider.Current
                Slider.Current = Clamp(Round(Value * Slider.Decimals) / Slider.Decimals, Slider.Min, Slider.Max)
                
                if Slider.Current ~= OldValue then
                    local Percent = 1 - (Slider.Max - Slider.Current) / (Slider.Max - Slider.Min)
                    
                    Slider["Button2"].Size = NewUDim2(0, Percent * Slider["Button1"].AbsoluteSize.X, 1, 0)
                    
                    Slider["Value"].Position = NewUDim2(1, 0, 0, 7)
                    Slider["Value"].Text = Slider.Current .. Slider.Prefix
                    
                    Slider["Minus"].Visible = Slider.Current > Slider.Min
                    Slider["Plus"].Visible = Slider.Current < Slider.Max
                    
                    if Callback ~= nil then
                        Callback(Slider.Current)
                    end
                end
            end

            function Slider:Refresh()
                local X = Slider["Button1"].AbsoluteSize.X
                local Percent = Clamp(Mouse.X - Slider["Button2"].AbsolutePosition.X, 0, X) / X
                local Value = Round((Slider.Min + (Slider.Max - Slider.Min) * Percent) * Slider.Decimals) / Slider.Decimals
                Value = Clamp(Value, Slider.Min, Slider.Max)
                Slider:Set(Value)
            end
            
            local MoveConnection
            local ReleaseConnection
            
            Slider["Button1"].MouseButton1Down:Connect(function()
                Slider:Refresh()
                
                MoveConnection = Mouse.Move:Connect(Slider.Refresh)
                ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Slider:Refresh()
                        
                        MoveConnection:Disconnect()
                        ReleaseConnection:Disconnect()
                    end
                end)
            end)

            Slider["Plus"].MouseButton1Down:Connect(function()
                Slider:Set(Slider.Current + 1)
            end)
            
            Slider["Minus"].MouseButton1Down:Connect(function()
                Slider:Set(Slider.Current - 1)
            end)

            Section.Offsets[Section.Side] = Section.Offsets[Section.Side] + 32
    
            return Slider
        end

        function Section:NewDropdown(Args)
            local Args = Args or {}
            local Name = Args.Name or "Dropdown"
            local Options = Args.Options or {"Option 1", "Option 2", "Option 3"}
            local Min = Args.Min or 1
            local Max = Args.Max or #Options
            local Default = Args.Default or {Options[1]}
            local Callback = Args.Callback or nil

            local Dropdown = {
                Name = Name,
                Options = Options,
                Current = Default,
                Min = Min,
                Max = Max,
                IsOpen = false,
                Connections = {},
                Frames = {}
            }

            local DropdownFrame = Menu:Draw("Frame", {Parent = Section["Frame"], Position = NewUDim2(0, 20, 0, Section.Offsets[Section.Side] + 15), Size = NewUDim2(1, -91, 0, 12), Visible = Section.IsOpen}, Section.Content)
            local DropdownFrame2 = Menu:Draw("TextButton", {Parent = DropdownFrame, Position = NewUDim2(0, 1, 0, 1), Size = NewUDim2(1, -2, 1, -2), BackgroundColor3 = NewRGB(42, 42, 42), BorderColor3 = NewRGB(28, 28, 28), TextXAlignment = Enum.TextXAlignment.Left, Text = " " .. Concat(Dropdown.Current, ", "), Visible = Section.IsOpen}, Section.Content)
            local DropdownTitle = Menu:Draw("TextLabel", {Parent = DropdownFrame, Position = NewUDim2(0, 1, 0, -9), Text = Name, TextXAlignment = Enum.TextXAlignment.Left, Visible = Section.IsOpen}, Section.Content)

            Dropdown["Frame"] = DropdownFrame
            Dropdown["Frame2"] = DropdownFrame2

            function Dropdown:Set(Value, Index)
                local Found = Find(Dropdown.Current, Value)
                local Options = #Dropdown.Current

                if Max ~= 1 or Min ~= 1 then
                    if Options < Max then
                        if Found then
                            if Options ~= Min then
                                Remove(Dropdown.Current, Found)
                            end
                        else
                            Dropdown.Current[Options + 1] = Value
                        end
                    elseif Found and Options > Min then
                        Remove(Dropdown.Current, Found)
                    end
                else
                    Dropdown.Current = {Dropdown.Options[Index]}
                end
                
                if Callback ~= nil then Callback(Dropdown.Current) end
                Dropdown.Frames[Index].TextColor3 = Find(Dropdown.Current, Dropdown.Options[Index]) ~= nil and NewRGB(240, 133, 72) or NewRGB(255, 255, 255)
                Dropdown["Frame2"].Text = " " .. Concat(Dropdown.Current, ", ")
            end
            
            function Dropdown:SetOpen(Bool)
                Dropdown.IsOpen = Bool
                local OldIndex = Dropdown["Frame2"].ZIndex
                Dropdown["Frame2"].ZIndex = 999
            
                if Bool then
                    local Frame = Menu:Draw("Frame", {Parent = Dropdown["Frame"], ZIndex = 1000, Position = NewUDim2(0, 0, 0, 12), Size = NewUDim2(1, 0, 0, (14 * #Dropdown.Options)), BackgroundColor3 = NewRGB(42, 42, 42), BorderColor3 = NewRGB(0, 0, 0), Visible = true})
                    
                    for i = 1, #Dropdown.Options do
                        local Frame2 = Menu:Draw("TextButton", {Parent = Frame, ZIndex = 1001, Position = NewUDim2(0, 1, 0, (14 * (i - 1))), Size = NewUDim2(1, -2, 0, 13), BackgroundColor3 = NewRGB(42, 42, 42), BorderColor3 = NewRGB(28, 28, 28), TextColor3 = Find(Dropdown.Current, Dropdown.Options[i]) and NewRGB(240, 133, 72) or NewRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Text = " " .. Dropdown.Options[i], Visible = true})
                        
                        Dropdown.Connections[i] = Frame2.MouseButton1Down:Connect(function() Dropdown:Set(Dropdown.Options[i], i) end)
                        Dropdown.Frames[#Dropdown.Frames + 1] = Frame2
                    end
            
                    Dropdown.OpenFrame = Frame
                elseif Dropdown.OpenFrame then
                    Dropdown["Frame2"].ZIndex = OldIndex
                    Dropdown.OpenFrame:Destroy()
        
                    for i = 1, #Dropdown.Connections do
                        Dropdown.Connections[i]:Disconnect()
                    end
        
                    Dropdown.Frames = {}
                end
            end

            Dropdown["Frame2"].MouseButton1Down:Connect(function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Section.Offsets[Section.Side] = Section.Offsets[Section.Side] + 32

            return Dropdown
        end

        function Section:NewButton(Args)
            local Args = Args or {}
            local Name = Args.Name or "Button"
            local Confirm = Args.Confirm or false
            local Callback = Args.Callback or nil

            local Button = {

                Confirmable = false
            }

            local ButtonFrame = Menu:Draw("Frame", {Parent = Section["Frame"], Position = NewUDim2(0, 20, 0, Section.Offsets[Section.Side]), Size = NewUDim2(1, -40, 0, 12), Visible = Section.IsOpen}, Section.Content)
            local ButtonFrame2 = Menu:Draw("TextButton", {Parent = ButtonFrame, Position = NewUDim2(0, 1, 0, 1), Size = NewUDim2(1, -2, 1, -2), BackgroundColor3 = NewRGB(42, 42, 42), BorderColor3 = NewRGB(28, 28, 28), TextXAlignment = Enum.TextXAlignment.Center, Text = " " .. Name, Visible = Section.IsOpen}, Section.Content)

            ButtonFrame2.MouseButton1Down:Connect(function()
                if Callback == nil then return end
            
                if Confirm then
                    if Button.Confirmable then
                        Callback()
                    else
                        Spawn(function()
                            for i = 3.00, 0, -0.1 do
                                ButtonFrame2.Text = Format("Confirm? [%.1f]", i)
                                ButtonFrame2.TextColor3 = NewRGB(240, 133, 72)

                                Button.Confirmable = true
                                Wait(0.1)
                            end

                            Button.Confirmable = false
                            ButtonFrame2.TextColor3 = NewRGB(255, 255, 255)
                            ButtonFrame2.Text = Name
                        end)
                    end
                else
                    Callback()
                end
            end)

            Section.Offsets[Section.Side] = Section.Offsets[Section.Side] + 20

            return Button
        end

        repeat Wait(0.0001) until SectionFrame.AbsoluteSize.X ~= 0
        -- So the cheat is loading so fast, that roblox doesnt have time to properly render and it loads further before it even sizes correctly, im goated

        return Section
    end

    function Window:Unload()
        for i = 1, #Window.Renders do
            Window.Renders[i]:Destroy()
        end

        Clear(Window.Renders)
    end

    -- wow dynamic sizing and positions
    -- these 2 fucking functions took me almost 3 hours to code
    -- TODO re-adjust the calculation to make all the tabs as similliar in size as possible, 2 subtabs with 2 sections show the difference
    function Window:ResizeTabs(Window)
        local TabButtonCount = #Window.Tabs
        local TabsHolderWidth = Window["TabsHolder"].AbsoluteSize.X
        local Width = (TabsHolderWidth - TabButtonCount) / TabButtonCount
        local LeftSpace = TabsHolderWidth - (Width * TabButtonCount)
    
        local LastTabPos = 1
    
        for i = 1, TabButtonCount do
            local Tab = Window.Tabs[i]
            local TabButtonSize = NewUDim2(0, Width, 1, -2)
    
            if i == TabButtonCount then
                local Extra = Max(0, LeftSpace - 1) - 2
                TabButtonSize = NewUDim2(0, TabButtonCount ~= 1 and (Width - LeftSpace - (TabButtonCount - 1) + Extra) or Width - 3, 1, -2)
            end
    
            Tab.Button.Size = TabButtonSize
            Tab.Button.Position = NewUDim2(0, LastTabPos, 0, 1)
    
            LastTabPos = LastTabPos + Tab.Button.Size.X.Offset + 3
        end
    end

    function Window:ResizeSubs(Tab)
        local SubButtonCount = #Tab.Subs
        local SubsHolderWidth = Tab["SubsHolder"].AbsoluteSize.X
        local Width = (SubsHolderWidth - SubButtonCount) / SubButtonCount
        local LeftSpace = SubsHolderWidth - (Width * SubButtonCount)
    
        local LastSubPos = 2
    
        for i = 1, SubButtonCount do
            local Sub = Tab.Subs[i]
            local SubButtonSize = NewUDim2(0, Width, 1, -4)
    
            if i == SubButtonCount then
                local Extra = Max(0, LeftSpace - 1) - 2
                SubButtonSize = NewUDim2(0, SubButtonCount ~= 1 and (Width - LeftSpace - (SubButtonCount - 1) + Extra) or Width - 3, 1, -4)
            end
    
            Sub.Button.Size = SubButtonSize
            Sub.Button.Position = NewUDim2(0, LastSubPos, 0, 2)
    
            LastSubPos = LastSubPos + Sub.Button.Size.X.Offset + 3
        end
    end

    function Window:Fade(Bool) -- todo make this fade lol... or not? for fps.
        Bool = Bool or not Window.IsOpen

        Window["Frame1"].Visible = Bool

        Window.IsOpen = Bool
    end

    -- todo finish this (window.keybind or whatever)
    Menu.Connections[#Menu.Connections + 1] = UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.Home then
            Window:Fade(not Window.IsOpen)
        end
    end)

    Window["Frame2"].InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = NewVector2(Mouse.X - Window["Frame1"].AbsolutePosition.X, Mouse.Y - Window["Frame1"].AbsolutePosition.Y)

            if ObjPos.Y > 40 then
                return
            end

            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Window["Frame1"].Position = NewUDim2(0, Mouse.X - ObjPos.X + (Window["Frame1"].Size.X.Offset * Window["Frame1"].AnchorPoint.X), 0, Mouse.Y - ObjPos.Y + (Window["Frame1"].Size.Y.Offset * Window["Frame1"].AnchorPoint.Y))

                RunService.RenderStepped:Wait()
            end
        end
    end)

	return Window
end

function Menu:Loader(Args)
    local Args = Args or {}
    local Name = Args.Name or "chudvision.net"


    local Loader = {}

    return Loader
end

function Menu:Unload()
    for i = 1, #Menu.Windows do
        Menu.Windows[i]:Unload()
    end

    for i = 1, #Menu.Renders do
        Menu.Renders[i]:Destroy()
    end

    for i = 1, #Menu.Connections do
        Menu.Connections[i]:Disconnect()
    end

    Clear(Menu.Windows)
    Clear(Menu.Renders)
    Clear(Menu.Connections)

    Menu = nil
end

return Menu
