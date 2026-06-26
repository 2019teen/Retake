local Library = {
    Tabs = {},
    CurrentTab = nil,
    flags = {},
    Elements = {},
    Accent = Color3.fromRGB(183, 0, 0),
    _connections = {} -- tracks global event connections for cleanup
}
--//ANCHOR - ui
        local HttpService = game:GetService("HttpService")

        local FOLDER_NAME = "RetakeWin_Configs"

        local DESIGN_CONFIG = {
            TweenSpeed = 0.2,
            FontProfile = "",

            -- Base Styling Properties
            Background = Color3.fromRGB(22, 22, 22),
            HeaderBackground = Color3.fromRGB(31, 31, 31),
            PagesBackground = Color3.fromRGB(19, 19, 19),
            SubPageBackground = Color3.fromRGB(13, 13, 13),
            BorderColor = Color3.fromRGB(16, 16, 16),

            -- Element Sizing Manifest
            WindowSize = UDim2.new(0, 462, 0, 517),
            DefaultWindowPosition = UDim2.new(0.27488, 0, 0.10702, 0)
        }

        local CustomFont = { } do
            function CustomFont:New(Name, Weight, Style, FontData)
                if not isfile(FontData.Id) then 
                    writefile(FontData.Id, game:HttpGet(FontData.Url))
                end

                local fontConfig = {
                    name = Name,
                    faces = {
                        {
                            name = Name,
                            weight = Weight,
                            style = Style,
                            assetId = getcustomasset(FontData.Id)
                        }
                    }
                }

                writefile(`{Name}.font`, HttpService:JSONEncode(fontConfig))
                return Font.new(getcustomasset(`{Name}.font`))
            end

            DESIGN_CONFIG.FontProfile = CustomFont:New("TahomaXP", 400, "Regular", {
                Id = "TahomaXP",
                Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/windows-xp-tahoma.ttf"
            })
        end

        --//ANCHOR - style presets (eliminates 50+ duplicated ColorSequence definitions)
        local GRADIENT_HEADER = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.509, Color3.fromRGB(237, 237, 237)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(223, 223, 223))
        })
        local GRADIENT_DIVIDER = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(45, 45, 45))
        })
        local GRADIENT_BOTTOM_LINE = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(153, 153, 153))
        })
        local GRADIENT_TAB = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(239, 239, 239)),
            ColorSequenceKeypoint.new(0.512, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))
        })
        local GRADIENT_TAB_ACTIVE = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(0.512, Color3.fromRGB(133, 133, 133)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(121, 121, 121))
        })
        local GRADIENT_BUTTON = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(219, 219, 219)),
            ColorSequenceKeypoint.new(0.509, Color3.fromRGB(237, 237, 237)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(214, 214, 214))
        })
        local GRADIENT_ACCENT_FILL = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(130, 130, 130))
        })
        local GRADIENT_SLIDER_TRACK = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, Color3.fromRGB(223, 223, 223)),
            ColorSequenceKeypoint.new(0.509, Color3.fromRGB(237, 237, 237)),
            ColorSequenceKeypoint.new(1.000, Color3.fromRGB(223, 223, 223))
        })

        --//ANCHOR - reusable helpers
        function Library:NewInstance(className, properties)
            local instance = Instance.new(className)
            for prop, val in pairs(properties) do
                instance[prop] = val
            end
            return instance
        end

        function Library:Gradient(parent, rotation, preset)
            return self:NewInstance("UIGradient", {
                Parent = parent,
                Rotation = rotation or 90,
                Color = preset or GRADIENT_HEADER
            })
        end

        function Library:Stroke(parent, overrides)
            overrides = overrides or {}
            return self:NewInstance("UIStroke", {
                Parent = parent,
                Color = overrides.Color or DESIGN_CONFIG.BorderColor,
                ApplyStrokeMode = overrides.ApplyStrokeMode or Enum.ApplyStrokeMode.Border,
                LineJoinMode = overrides.LineJoinMode or Enum.LineJoinMode.Miter,
                ZIndex = overrides.ZIndex,
                Thickness = overrides.Thickness,
                Enabled = overrides.Enabled
            })
        end

        function Library:LabelWithStroke(parent, text, extraProps)
            extraProps = extraProps or {}
            local label = self:NewInstance("TextLabel", {
                Parent = parent,
                Text = text,
                TextSize = extraProps.TextSize or 12,
                TextXAlignment = extraProps.TextXAlignment or Enum.TextXAlignment.Left,
                TextColor3 = extraProps.TextColor3 or Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = extraProps.Size or UDim2.new(0, 150, 1, 0),
                Position = extraProps.Position or UDim2.new(0, 8, 0, 0),
                ZIndex = extraProps.ZIndex
            })
            self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })
            return label
        end

        function Library:BottomLine(parent)
            local line = self:NewInstance("Frame", {
                Parent = parent,
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -2)
            })
            self:Gradient(line, 90, GRADIENT_BOTTOM_LINE)
            return line
        end

        function Library:MakeDraggable(handle, target)
            local uis = game:GetService("UserInputService")
            target = target or handle
            local dragging, dragStart, startPos
            local conns = {}

            conns.begin = handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = target.Position

                    conns.ended = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)

            conns.changed = uis.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)

            return conns
        end

        -- Sub-element container for conditional visibility
        function Library:CreateSubContainer(parent, name)
            local container = self:NewInstance("Frame", {
                Name = (name or "Sub") .. "_Sub",
                Parent = parent,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                Visible = false
            })
            self:NewInstance("UIListLayout", {
                Parent = container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })
            return container
        end

        function Library:AnimateSubContainer(container, show)
            container.Visible = show
        end

        function Library:GetBindName(bind)
            if typeof(bind) == "EnumItem" then
                if bind == Enum.KeyCode.Unknown then return "NONE" end
                if bind.EnumType == Enum.KeyCode then return bind.Name end
                if bind == Enum.UserInputType.MouseButton1 then return "MB1"
                elseif bind == Enum.UserInputType.MouseButton2 then return "MB2"
                elseif bind == Enum.UserInputType.MouseButton3 then return "MB3"
                elseif bind == Enum.UserInputType.MouseWheel then return "MWheel"
                end
            end
            return "NONE"
        end

        function Library:IsBindMatch(input, bind)
            if typeof(bind) == "EnumItem" and bind ~= Enum.KeyCode.Unknown then
                if bind.EnumType == Enum.KeyCode then
                    return input.KeyCode == bind and input.UserInputType == Enum.UserInputType.Keyboard
                elseif bind.EnumType == Enum.UserInputType then
                    return input.UserInputType == bind
                end
            end
            return false
        end

        function Library:IsInputBindable(input)
            return input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3
        end

        function Library:BindFromInput(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                return input.KeyCode
            else
                return input.UserInputType
            end
        end

        function Library:ResolveBind(name)
            if name == "NONE" or name == "Unknown" then return Enum.KeyCode.Unknown end
            if name == "MB1" then return Enum.UserInputType.MouseButton1 end
            if name == "MB2" then return Enum.UserInputType.MouseButton2 end
            if name == "MB3" then return Enum.UserInputType.MouseButton3 end
            if name == "MWheel" then return Enum.UserInputType.MouseWheel end
            return Enum.KeyCode[name] or Enum.KeyCode.Unknown
        end

        -- Track a connection for later cleanup
        function Library:Track(connection)
            table.insert(self._connections, connection)
            return connection
        end

        -- Clean up all tracked connections and hide UI
        function Library:Destroy()
            for _, conn in ipairs(self._connections) do
                pcall(function() conn:Disconnect() end)
            end
            self._connections = {}
            if self.ScreenGui then
                self.ScreenGui:Destroy()
            end
        end

        function Library:Init(hubName)
            hubName = hubName or "Legendary Lion Stinks"
            self.IsOpen = true

            -- G2L["1"] - Base ScreenGui Environment Context Hook
            self.ScreenGui = self:NewInstance("ScreenGui", {
                Name = "RetakeWin_Gui",
                Parent = gethui(),
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            })

            -- G2L["2"] - Main Windows Framework Panel
            self.MainFrame = self:NewInstance("CanvasGroup", {
                Name = "MainFrame",
                Parent = self.ScreenGui,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                Size = DESIGN_CONFIG.WindowSize,
                Position = DESIGN_CONFIG.DefaultWindowPosition,
                GroupTransparency = 0
            })

            -- G2L["d"] - Mitered Window Outer Edge Shadowing Border
            self.MainStroke = self:NewInstance("UIStroke", {
                Parent = self.MainFrame,
                ZIndex = 2,
                Color = DESIGN_CONFIG.BorderColor,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            -- G2L["3"] - Header Banner Bar (Acts as the Drag handle)
            local headerBar = self:NewInstance("Frame", {
                Name = "HeaderBar",
                Parent = self.MainFrame,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.HeaderBackground,
                Size = UDim2.new(0, DESIGN_CONFIG.WindowSize.X.Offset, 0, 24),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            -- G2L["4"]
            self:Gradient(headerBar)

            -- G2L["5"] - Application Title Label Text Block
            local titleLabel = self:NewInstance("TextLabel", {
                Parent = headerBar,
                Text = hubName,
                TextSize = 12,
                TextStrokeTransparency = 0,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Center
            })

            -- G2L["6"]
            self:NewInstance("UIStroke", { Parent = titleLabel, LineJoinMode = Enum.LineJoinMode.Miter })

            -- G2L["7"]
            self:Gradient(titleLabel)

            -- G2L["8"] - Top Accent Divider Trim Splitter Line
            local topAccentLine = self:NewInstance("Frame", {
                Parent = self.MainFrame,
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(41, 41, 41),
                Size = UDim2.new(0, DESIGN_CONFIG.WindowSize.X.Offset, 0, 2),
                Position = UDim2.new(0, 0, 0.04571, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            -- G2L["9"]
            self:Gradient(topAccentLine, 90, GRADIENT_DIVIDER)

            -- G2L["a"] - Horizontal Navigation Control Strip
            self.TabContainer = self:NewInstance("Frame", {
                Parent = self.MainFrame,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                Size = UDim2.new(0, DESIGN_CONFIG.WindowSize.X.Offset, 0, 27),
                Position = UDim2.new(0, 0, 0.04933, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            -- G2L["b"]
            self:Gradient(self.TabContainer, 90, GRADIENT_TAB)

            -- G2L["c"] - Automated Flex Navigation System Grid Layer
            self:NewInstance("UIListLayout", {
                Parent = self.TabContainer,
                Padding = UDim.new(0, 1),
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                VerticalFlex = Enum.UIFlexAlignment.Fill,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal
            })

            -- G2L["e"] - Internal Modular Content Matrix Core
            self.PagesFolder = self:NewInstance("Frame", {
                Name = "PagesDisplayMatrix",
                Parent = self.MainFrame,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.PagesBackground,
                Size = UDim2.new(0, 454, 0, 454),
                Position = UDim2.new(0, 4, 0, 59),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            -- G2L["f"]
            self:Stroke(self.PagesFolder, { ZIndex = 2 })

            -- G2L["10"] - Modular Workspace Dynamic Structural Manifest Storage
            self.PagesRegistry = self:NewInstance("Folder", { Name = "TabPagesStorage", Parent = self.PagesFolder })

            -- Context Window Dragging System Architecture
            self:MakeDraggable(headerBar, self.MainFrame)

            -- Keybind List Window Setup
            self.KeybindListFrame = self:NewInstance("Frame", {
                Name = "KEYBINDLIST",
                Parent = self.ScreenGui,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(31, 31, 31),
                Size = UDim2.new(0, 170, 0, 24),
                Position = UDim2.new(0.01631, 0, 0.34245, 0)
            })

            self:Gradient(self.KeybindListFrame)

            local keybindTitle = self:NewInstance("TextLabel", {
                Parent = self.KeybindListFrame,
                Text = "Keybinds",
                TextStrokeTransparency = 0,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0)
            })
            self:NewInstance("UIStroke", { Parent = keybindTitle, LineJoinMode = Enum.LineJoinMode.Miter })
            self:Gradient(keybindTitle)

            local listDivider = self:NewInstance("Frame", {
                Parent = self.KeybindListFrame,
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(41, 41, 41),
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, 0)
            })
            self:Gradient(listDivider, 90, GRADIENT_DIVIDER)

            self:Stroke(self.KeybindListFrame, { ZIndex = 2, Color = Color3.fromRGB(16, 16, 16) })

            local bindHolder = self:NewInstance("Frame", {
                Parent = self.KeybindListFrame,
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(139, 139, 139),
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, 2)
            })
            self:Gradient(bindHolder, 90, GRADIENT_DIVIDER)
            self:Stroke(bindHolder, { ZIndex = 2, Color = Color3.fromRGB(16, 16, 16) })

            self.KeybindContainer = self:NewInstance("Frame", {
                Parent = bindHolder,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            self:NewInstance("UIListLayout", {
                Parent = self.KeybindContainer,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            self:Gradient(self.KeybindContainer)
            self:Stroke(self.KeybindContainer, { ZIndex = 2, Color = Color3.fromRGB(16, 16, 16) })

            -- Dragging for Keybind List
            self:MakeDraggable(self.KeybindListFrame)

            -- Notifications container setup
            self.NotificationsContainer = self:NewInstance("Frame", {
                Name = "NotificationsContainer",
                Parent = self.ScreenGui,
                Size = UDim2.new(0, 259, 0.8, 0),
                Position = UDim2.new(0.0155, 0, 0.05, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })
            self:NewInstance("UIListLayout", {
                Parent = self.NotificationsContainer,
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        function Library:CreateTab(tabName)
            local tab = {}
            local tweenService = game:GetService("TweenService")
            local colorTweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local fadeTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            tab.Button = self:NewInstance("TextButton", {
                Name = tabName .. "TabBtn",
                Parent = self.TabContainer,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                Size = UDim2.new(0, 100, 1, 0),
                BorderColor3 = Color3.fromRGB(26, 26, 26),
                BorderMode = Enum.BorderMode.Inset
            })

            tab.Gradient = self:Gradient(tab.Button, 90, GRADIENT_TAB)

            tab.Label = self:NewInstance("TextLabel", {
                Parent = tab.Button,
                Text = tabName,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(145, 145, 145),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0)
            })

            tab.Stroke1 = self:Stroke(tab.Button)

            self:NewInstance("UIStroke", { Parent = tab.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            tab.indicator = self:NewInstance("Frame", {
                Parent = tab.Button,
                Visible = true,
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -1),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            self:Gradient(tab.indicator, 90, GRADIENT_BOTTOM_LINE)

            -- G2L["11"] - Primary Tab Page Viewing Shell Frame
            tab.PageFrame = self:NewInstance("CanvasGroup", {
                Name = tabName .. "PageMatrixFrame",
                Parent = self.PagesRegistry,
                Visible = false,
                GroupTransparency = 1,
                BackgroundTransparency = 0,
                BackgroundColor3 = DESIGN_CONFIG.SubPageBackground,
                Size = UDim2.new(0, 447, 0, 443),
                Position = UDim2.new(0, 4, 0, 5),
                BorderColor3 = Color3.fromRGB(18, 18, 18)
            })

            -- G2L["12"] - Left Column Structural Layout Scrolling Canvas
            tab.LeftColumn = self:NewInstance("ScrollingFrame", {
                Name = "Left",
                Parent = tab.PageFrame,
                Active = true,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarImageTransparency = 1,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(0, 213, 0, 432),
                Position = UDim2.new(0.01342, 0, 0.01557, 0),
                BorderColor3 = DESIGN_CONFIG.SubPageBackground,
                ScrollBarThickness = 0,
                BackgroundTransparency = 1
            })

            self:NewInstance("UIListLayout", {
                Parent = tab.LeftColumn,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            self:Stroke(tab.LeftColumn, { ZIndex = 0, Color = Color3.fromRGB(10, 10, 10), ApplyStrokeMode = nil })

            -- G2L["32"] - Right Column Structural Layout Scrolling Canvas
            tab.RightColumn = self:NewInstance("ScrollingFrame", {
                Name = "Right",
                Parent = tab.PageFrame,
                Active = true,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarImageTransparency = 1,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(0, 213, 0, 429),
                Position = UDim2.new(0.50733, 0, 0.01557, 0),
                BorderColor3 = DESIGN_CONFIG.SubPageBackground,
                ScrollBarThickness = 0,
                BackgroundTransparency = 1
            })

            self:NewInstance("UIListLayout", {
                Parent = tab.RightColumn,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            self:Stroke(tab.RightColumn, { ZIndex = 0, Color = Color3.fromRGB(10, 10, 10), ApplyStrokeMode = nil })

            local function activate()
                if self.CurrentTab == tab then return end

                if self.CurrentTab then
                    local oldTab = self.CurrentTab
                    local fadeOut = tweenService:Create(oldTab.PageFrame, fadeTweenInfo, { GroupTransparency = 1 })
                    fadeOut:Play()
                    fadeOut.Completed:Connect(function()
                        if self.CurrentTab ~= oldTab then oldTab.PageFrame.Visible = false end
                    end)

                    tweenService:Create(oldTab.Label, colorTweenInfo, { TextColor3 = Color3.fromRGB(145, 145, 145) }):Play()
                    tweenService:Create(oldTab.Button, colorTweenInfo, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) }):Play()

                    oldTab.Gradient.Color = GRADIENT_TAB

                    oldTab.Stroke1.Enabled = true	
                    oldTab.indicator.Visible = true
                end

                self.CurrentTab = tab
                tab.PageFrame.Visible = true

                tweenService:Create(tab.PageFrame, fadeTweenInfo, { GroupTransparency = 0 }):Play()
                tweenService:Create(tab.Label, colorTweenInfo, { TextColor3 = self.Accent }):Play()
                tweenService:Create(tab.Button, colorTweenInfo, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()

                tab.Gradient.Color = GRADIENT_TAB_ACTIVE

                tab.Stroke1.Enabled = false
                tab.indicator.Visible = false
            end

            tab.Button.MouseButton1Click:Connect(activate)
            table.insert(self.Tabs, tab)

            if #self.Tabs == 1 then
                self.CurrentTab = tab
                tab.PageFrame.Visible = true
                tab.PageFrame.GroupTransparency = 0
                tab.Label.TextColor3 = self.Accent
                tab.Stroke1.Enabled = false
                tab.indicator.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                tab.Gradient.Color = GRADIENT_TAB_ACTIVE
            end

            return tab
        end

        function Library:CreateSection(tabColumn, sectionName)
            local section = {}

            -- G2L["15"] - Section Parent Alignment Canvas Node
            section.Frame = self:NewInstance("Frame", {
                Name = sectionName .. "SectionZone",
                Parent = tabColumn,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(0, 213, 0, 25),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            self:Gradient(section.Frame)

            self:Stroke(section.Frame, { Color = Color3.fromRGB(40, 40, 40) })

            -- G2L["2f"] - Header Section Text Display Label
            section.Title = self:NewInstance("TextLabel", {
                Parent = section.Frame,
                Text = sectionName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 81, 0, 25),
                Position = UDim2.new(0.04, 0, 0, 0)
            })

            self:NewInstance("UIStroke", { Parent = section.Title, LineJoinMode = Enum.LineJoinMode.Miter })

            -- G2L["16"] - Core Content Element Insertion Panel Frame
            section.Container = self:NewInstance("Frame", {
                Name = "InsertFrame",
                Parent = section.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(41, 41, 41), 
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 0, 25),
                BorderColor3 = Color3.fromRGB(0, 0, 0)
            })

            self:Gradient(section.Container, 90, GRADIENT_DIVIDER)

            self:NewInstance("UIListLayout", {
                Parent = section.Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })

            return section
        end

        function Library:CreateToggle(sectionParent, config)
            local userInputService = game:GetService("UserInputService")
            local tweenService = game:GetService("TweenService")

            local toggleName = config.name or "Toggle"
            local flag = config.flag
            local bindFlag = config.bindFlag
            local callback = config.callback

            local toggle = { 
                State = config.default or false,
                Bind = config.defaultBind or Enum.KeyCode.Unknown,
                Mode = "Toggle",
                MenuOpen = false,
                BindingModeActive = false,
                Name = toggleName
            }

            if flag then
                Library.flags[flag] = toggle.State
                Library.Elements[flag] = toggle
            end
            if bindFlag then
                Library.flags[bindFlag] = toggle.Bind
                Library.Elements[bindFlag] = toggle
            end

            local tweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local topLevelGui = sectionParent.Container:FindFirstAncestorOfClass("ScreenGui")

            toggle.Frame = self:NewInstance("Frame", {
                Name = toggleName .. "ToggleNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 213, 0, 24),
                BackgroundTransparency = 1
            })

            local surfaceRow = self:NewInstance("Frame", {
                Parent = toggle.Frame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local actionButton = self:NewInstance("TextButton", {
                Parent = surfaceRow,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })
            toggle.ActionButton = actionButton

            toggle.Label = self:NewInstance("TextLabel", {
                Parent = toggle.ActionButton,
                Text = toggleName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, 8, 0, 0)
            })
            self:NewInstance("UIStroke", { Parent = toggle.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            toggle.StatusBox = self:NewInstance("Frame", {
                Parent = toggle.ActionButton,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 207, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ZIndex = 5
            })

            self:Gradient(toggle.StatusBox)
            self:Stroke(toggle.StatusBox, { ZIndex = 6, Color = Color3.fromRGB(9, 9, 9) })

            toggle.IndicatorFill = self:NewInstance("Frame", {
                Parent = toggle.StatusBox,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = toggle.State and 0 or 1,
                ZIndex = 7
            })

            self:Gradient(toggle.IndicatorFill, 90, GRADIENT_ACCENT_FILL)

            self:BottomLine(surfaceRow)

            -- DETACHED SCREEN-LEVEL KEYBIND OVERLAY
            local bindMenu = self:NewInstance("Frame", {
                Name = toggleName .. "_KeybindOverlay",
                Parent = topLevelGui, 
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                Size = UDim2.new(0, 127, 0, 0), 
                BackgroundTransparency = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 9999 
            })
            self:Stroke(bindMenu, { ZIndex = 101, Color = Color3.fromRGB(9, 9, 9) })

            local menuHeader = self:NewInstance("Frame", {
                Parent = bindMenu,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = DESIGN_CONFIG.HeaderBackground,
                BorderSizePixel = 0,
                ZIndex = 102
            })
            self:Gradient(menuHeader)

            local menuTitle = self:NewInstance("TextLabel", {
                Parent = menuHeader,
                Text = "Keybind Menu",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 103
            })
            self:NewInstance("UIStroke", { Parent = menuTitle, LineJoinMode = Enum.LineJoinMode.Miter })

            local bindTriggerRow = self:NewInstance("Frame", {
                Parent = bindMenu,
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundTransparency = 1,
                ZIndex = 102
            })

            local bindLabel = self:NewInstance("TextLabel", {
                Parent = bindTriggerRow,
                Text = "Keybind",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.04, 0, 0, 0),
                Size = UDim2.new(0, 50, 1, 0),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 103
            })

            local bindTextBtn = self:NewInstance("TextButton", {
                Parent = bindTriggerRow,
                Text = "[" .. Library:GetBindName(toggle.Bind) .. "]",
                TextSize = 12,
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(109, 109, 109),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 32, 0, 12),
                Position = UDim2.new(0.96, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                AutoButtonColor = false,
                ZIndex = 103
            })
            self:Stroke(bindTextBtn, { ZIndex = 104, Color = Color3.fromRGB(9, 9, 9) })

            local clearBindBtn = self:NewInstance("TextButton", {
                Parent = bindTriggerRow,
                Text = "x",
                TextSize = 10,
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(180, 60, 60),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -2, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ZIndex = 104
            })
            clearBindBtn.MouseButton1Click:Connect(function()
                toggle.Bind = Enum.KeyCode.Unknown
                bindTextBtn.Text = "[NONE]"
                if bindFlag then Library.flags[bindFlag] = Enum.KeyCode.Unknown end
                Library:UpdateKeybindList()
            end)

            local rowSplitLine = self:NewInstance("Frame", {
                Parent = bindTriggerRow,
                ZIndex = 103,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, 0)
            })
            self:Gradient(rowSplitLine, 90, GRADIENT_BOTTOM_LINE)

            local modeTriggerRow = self:NewInstance("Frame", {
                Parent = bindMenu,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 44),
                BackgroundTransparency = 1,
                ZIndex = 102
            })

            local modeDropdownBtn = self:NewInstance("TextButton", {
                Parent = modeTriggerRow,
                Text = "",
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 115, 0, 15),
                Position = UDim2.new(0.043, 0, 0.26, 0),
                AutoButtonColor = false,
                ZIndex = 103
            })
            self:Stroke(modeDropdownBtn, { ZIndex = 104, Color = Color3.fromRGB(9, 9, 9) })

            local modeDisplayLabel = self:NewInstance("TextLabel", {
                Parent = modeDropdownBtn,
                Text = "Keybind mode",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(157, 157, 157),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0.05, 0, 0, 0),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 104
            })

            local modeCycleIcon = self:NewInstance("TextButton", {
                Parent = modeTriggerRow,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0.877, 0, 0.37, 0),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 104
            })

            local modeBottomLine = self:NewInstance("Frame", {
                Parent = modeTriggerRow,
                ZIndex = 103,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, 0)
            })
            self:Gradient(modeBottomLine, 90, GRADIENT_BOTTOM_LINE)

            local function updateToggleState(forcedState)
                if toggle.Mode == "Always" then
                    toggle.State = true
                elseif forcedState ~= nil then
                    toggle.State = forcedState
                else
                    toggle.State = not toggle.State
                end

                if flag then
                    Library.flags[flag] = toggle.State
                end
                Library:UpdateKeybindList()

                local targetTransparency = toggle.State and 0 or 1
                local targetLabelColor = toggle.State and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(176, 176, 176)

                tweenService:Create(toggle.IndicatorFill, tweenInfo, { BackgroundTransparency = targetTransparency }):Play()
                tweenService:Create(toggle.Label, tweenInfo, { TextColor3 = targetLabelColor }):Play()

                if callback then
                    callback(toggle.State)
                end

                -- Sub-element visibility
                if toggle.SubContainer then
                    Library:AnimateSubContainer(toggle.SubContainer, toggle.State)
                    if toggle._subBuilder then
                        -- Clear existing children to prevent duplication
                        for _, child in ipairs(toggle.SubContainer:GetChildren()) do
                            if child:IsA("GuiObject") then child:Destroy() end
                        end
                        toggle._subBuilder(toggle.SubContainer, toggle.State)
                    end
                end
            end

            local function updateMenuPosition()
                local toggleLocation = toggle.Frame.AbsolutePosition
                bindMenu.Position = UDim2.new(0, toggleLocation.X + 220, 0, toggleLocation.Y)
            end

            local function closeMenuSmoothly()
                if not toggle.MenuOpen then return end
                toggle.MenuOpen = false

                local closeTween = tweenService:Create(bindMenu, tweenInfo, { Size = UDim2.new(0, 127, 0, 0) })
                closeTween:Play()
                closeTween.Completed:Connect(function()
                    if not toggle.MenuOpen then bindMenu.Visible = false end
                end)
            end

            local function toggleMenuState()
                toggle.MenuOpen = not toggle.MenuOpen
                local targetHeight = toggle.MenuOpen and 74 or 0 

                if toggle.MenuOpen then
                    updateMenuPosition()
                    bindMenu.Visible = true
                end

                local menuTween = tweenService:Create(bindMenu, tweenInfo, { Size = UDim2.new(0, 127, 0, targetHeight) })
                menuTween:Play()

                if not toggle.MenuOpen then
                    menuTween.Completed:Connect(function()
                        if not toggle.MenuOpen then bindMenu.Visible = false end
                    end)
                end
            end

            local isHovering = false

            bindMenu.MouseEnter:Connect(function()
                isHovering = true
            end)

            bindMenu.MouseLeave:Connect(function()
                isHovering = false
            end)

            self:Track(userInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if toggle.MenuOpen and not toggle.BindingModeActive then
                        local mousePos = userInputService:GetMouseLocation()
                        if not isHovering then
                            closeMenuSmoothly()
                        end
                    end
                end
            end))

            toggle.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                if toggle.MenuOpen then
                    updateMenuPosition()
                end
            end)

            toggle.ActionButton.MouseButton1Click:Connect(function()
                if toggle.Mode ~= "Always" then updateToggleState() end
            end)

            toggle.ActionButton.MouseButton2Click:Connect(toggleMenuState)

            local subModes = { "Toggle", "Hold", "Always" }
            local currentModeIdx = 1

            local function cycleMode()
                currentModeIdx = (currentModeIdx % #subModes) + 1
                toggle.Mode = subModes[currentModeIdx]
                modeDisplayLabel.Text = toggle.Mode

                if toggle.Mode == "Always" then
                    updateToggleState(true)
                elseif toggle.Mode == "Hold" then
                    updateToggleState(false)
                end
            end

            modeDropdownBtn.MouseButton1Click:Connect(cycleMode)
            modeCycleIcon.MouseButton1Click:Connect(cycleMode)

            bindTextBtn.MouseButton1Click:Connect(function()
                if toggle.BindingModeActive then return end
                toggle.BindingModeActive = true
                bindTextBtn.Text = "[...]"
                bindTextBtn.TextColor3 = self.Accent

                local connection
                connection = userInputService.InputBegan:Connect(function(input, processed)
                    -- Always allow Escape to unbind (engine marks it as processed)
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                        connection:Disconnect()
                        toggle.Bind = Enum.KeyCode.Unknown
                        bindTextBtn.Text = "[NONE]"
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        toggle.BindingModeActive = false
                        if bindFlag then Library.flags[bindFlag] = Enum.KeyCode.Unknown end
                        Library:UpdateKeybindList()
                        return
                    end
                    if processed then return end
                    if Library:IsInputBindable(input) then
                        connection:Disconnect()
                        toggle.Bind = Library:BindFromInput(input)
                        bindTextBtn.Text = "[" .. Library:GetBindName(toggle.Bind) .. "]"
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        toggle.BindingModeActive = false
                        if bindFlag then Library.flags[bindFlag] = toggle.Bind end
                        Library:UpdateKeybindList()
                    end
                end)
            end)

            self:Track(userInputService.InputBegan:Connect(function(input, processed)
                if processed or not Library:IsBindMatch(input, toggle.Bind) then return end
                if toggle.Mode == "Toggle" then
                    updateToggleState()
                elseif toggle.Mode == "Hold" then
                    updateToggleState(true)
                end
            end))

            self:Track(userInputService.InputEnded:Connect(function(input, processed)
                if not Library:IsBindMatch(input, toggle.Bind) then return end
                if toggle.Mode == "Hold" then
                    updateToggleState(false)
                end
            end))

            toggle.Frame.Destroying:Connect(function()
                bindMenu:Destroy()
            end)

            function toggle:Set(state)
                updateToggleState(state)
            end

            function toggle:SetBind(key)
                toggle.Bind = key
                bindTextBtn.Text = "[" .. Library:GetBindName(key) .. "]"
                if bindFlag then Library.flags[bindFlag] = key end
                Library:UpdateKeybindList()
            end

            function toggle:SetMode(mode)
                toggle.Mode = mode
                modeDisplayLabel.Text = mode
                local idx = table.find(subModes, mode)
                if idx then
                    currentModeIdx = idx
                end
                if mode == "Always" then
                    updateToggleState(true)
                elseif mode == "Hold" then
                    updateToggleState(false)
                end
                Library:UpdateKeybindList()
            end

            function toggle:AddSubElement(builder)
                if not toggle.SubContainer then
                    local sectionContainer = toggle.Frame.Parent
                    toggle.SubContainer = Library:CreateSubContainer(sectionContainer, toggleName)
                    toggle.SubContainer.LayoutOrder = toggle.Frame.LayoutOrder + 0.5
                end
                toggle._subBuilder = builder
                builder(toggle.SubContainer, toggle.State)
                if toggle.State then
                    Library:AnimateSubContainer(toggle.SubContainer, true)
                end
                return toggle
            end

            function toggle:CreateColorPicker(config)
                return Library:CreateColorPicker(toggle, config)
            end

            updateToggleState(toggle.State)
            return toggle
        end

        function Library:CreateSlider(sectionParent, config)
            local sliderName = config.name or "Slider"
            local min = config.min or 0
            local max = config.max or 100
            local step = config.step or 1
            local flag = config.flag

            local slider = { Value = config.default or min }
            local userInputService = game:GetService("UserInputService")
            if flag then
                self.flags[flag] = slider.Value
                self.Elements[flag] = slider
            end

            slider.Frame = self:NewInstance("Frame", {
                Name = sliderName .. "SliderNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 213, 0, 38),
                BackgroundTransparency = 1
            })

            slider.Label = self:NewInstance("TextLabel", {
                Parent = slider.Frame,
                Text = sliderName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 150, 0, 20),
                Position = UDim2.new(0, 8, 0, 2)
            })

            self:NewInstance("UIStroke", { Parent = slider.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            slider.Track = self:NewInstance("TextButton", {
                Parent = slider.Frame,
                Text = "",
                Size = UDim2.new(0, 199, 0, 10),
                Position = UDim2.new(0, 8, 0, 22),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                BorderSizePixel = 0,
                AutoButtonColor = false
            })

            self:Gradient(slider.Track, 90, GRADIENT_SLIDER_TRACK)

            self:Stroke(slider.Track, { ZIndex = 2, Color = Color3.fromRGB(9, 9, 9) })

            slider.Fill = self:NewInstance("Frame", {
                Parent = slider.Track,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(0, 0, 1, 0)
            })

            self:Gradient(slider.Fill, 90, GRADIENT_ACCENT_FILL)

            slider.ValLabel = self:NewInstance("TextLabel", {
                Parent = slider.Track,
                Text = tostring(slider.Value),
                TextSize = 12,
                TextColor3 = Color3.fromRGB(157, 157, 157),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 5
            })

            self:NewInstance("UIStroke", { Parent = slider.ValLabel, LineJoinMode = Enum.LineJoinMode.Miter })

            local incBtn = self:NewInstance("TextButton", {
                Parent = slider.Frame,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 207, 0, 12), 
                AnchorPoint = Vector2.new(1, 0.5),
                FontFace = DESIGN_CONFIG.FontProfile 
            })

            local decBtn = self:NewInstance("TextButton", {
                Parent = slider.Frame,
                Text = "-",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 193, 0, 12), 
                AnchorPoint = Vector2.new(1, 0.5),
                FontFace = DESIGN_CONFIG.FontProfile 
            })

            self:BottomLine(slider.Frame)

            local isDragging = false

            local function updateToValue(targetVal)
                slider.Value = math.clamp(math.round(targetVal / step) * step, min, max)
                slider.ValLabel.Text = tostring(slider.Value)

                local percent = (slider.Value - min) / (max - min)
                slider.Fill.Size = UDim2.new(percent, 0, 1, 0)

                if flag then
                    self.flags[flag] = slider.Value
                end
                if config.callback then 
                    config.callback(slider.Value) 
                end

                -- Sub-element update
                if slider._subBuilder then
                    for _, child in ipairs(slider.SubContainer:GetChildren()) do
                        if child:IsA("GuiObject") then child:Destroy() end
                    end
                    slider._subBuilder(slider.SubContainer, slider.Value)
                end
            end

            local function updateFromInput(input)
                local xOffset = math.clamp(input.Position.X - slider.Track.AbsolutePosition.X, 0, slider.Track.AbsoluteSize.X)
                local percent = xOffset / slider.Track.AbsoluteSize.X
                local targetVal = min + (percent * (max - min))
                updateToValue(targetVal)
            end

            slider.Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    updateFromInput(input)
                end
            end)

            self:Track(userInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input)
                end
            end))

            self:Track(userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end))

            decBtn.MouseButton1Click:Connect(function() updateToValue(slider.Value - step) end)
            incBtn.MouseButton1Click:Connect(function() updateToValue(slider.Value + step) end)

            function slider:Set(val)
                updateToValue(val)
            end

            function slider:AddSubElement(builder)
                if not slider.SubContainer then
                    local sectionContainer = slider.Frame.Parent
                    slider.SubContainer = Library:CreateSubContainer(sectionContainer, sliderName)
                    slider.SubContainer.LayoutOrder = slider.Frame.LayoutOrder + 0.5
                end
                slider._subBuilder = builder
                builder(slider.SubContainer, slider.Value)
                Library:AnimateSubContainer(slider.SubContainer, true)
                return slider
            end

            updateToValue(slider.Value)
            return slider
        end

        function Library:CreateDropdown(sectionParent, config)
            local dropdownName = config.name or "Dropdown"
            local options = config.options or {}
            local flag = config.flag

            local dropdown = { 
                Value = config.default or options[1] or "",
                Open = false,
                OptionInstances = {}
            }

            if flag then
                self.flags[flag] = dropdown.Value
                self.Elements[flag] = dropdown
            end

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            dropdown.Frame = self:NewInstance("Frame", {
                Name = dropdownName .. "DropdownNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 213, 0, 43),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ClipsDescendants = false 
            })

            dropdown.Label = self:NewInstance("TextLabel", {
                Parent = dropdown.Frame,
                Text = dropdownName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 100, 0, 18),
                Position = UDim2.new(0, 8, 0, 2),
                ZIndex = 1
            })

            self:NewInstance("UIStroke", { Parent = dropdown.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            dropdown.MainButton = self:NewInstance("TextButton", {
                Parent = dropdown.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 199, 0, 15),
                Position = UDim2.new(0, 8, 0, 21),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 10 
            })

            self:Gradient(dropdown.MainButton, 90, GRADIENT_BUTTON)

            self:Stroke(dropdown.MainButton, { ZIndex = 11, Color = Color3.fromRGB(9, 9, 9) })

            dropdown.SelectionDisplay = self:NewInstance("TextLabel", {
                Parent = dropdown.MainButton,
                Text = dropdown.Value,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.68339, 0, 1, 0),
                Position = UDim2.new(0.03518, 0, 0, 0),
                ZIndex = 12
            })

            self:NewInstance("UIStroke", { Parent = dropdown.SelectionDisplay, LineJoinMode = Enum.LineJoinMode.Miter })

            dropdown.ToggleIcon = self:NewInstance("TextButton", {
                Parent = dropdown.Frame,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 207, 0.65, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ZIndex = 12,
                FontFace = DESIGN_CONFIG.FontProfile
            })

            self:BottomLine(dropdown.Frame)

            dropdown.Container = self:NewInstance("Frame", {
                Name = "OptionsContainer",
                Parent = dropdown.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 199, 0, 0),
                Position = UDim2.new(0, 8, 0, 37), 
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 100 
            })

            local listLayout = self:NewInstance("UIListLayout", {
                Parent = dropdown.Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })

            self:Stroke(dropdown.Container, { ZIndex = 101, Color = Color3.fromRGB(9, 9, 9) })

            local function selectOption(optionValue)
                dropdown.Value = optionValue
                dropdown.SelectionDisplay.Text = optionValue

                if flag then
                    self.flags[flag] = optionValue
                end

                for optName, optBtn in pairs(dropdown.OptionInstances) do
                    if optName == optionValue then
                        optBtn.TextColor3 = self.Accent
                    else
                        optBtn.TextColor3 = Color3.fromRGB(157, 157, 157)
                    end
                end

                if config.callback then
                    config.callback(optionValue)
                end

                -- Sub-element update
                if dropdown._subBuilder then
                    for _, child in ipairs(dropdown.SubContainer:GetChildren()) do
                        if child:IsA("GuiObject") then child:Destroy() end
                    end
                    dropdown._subBuilder(dropdown.SubContainer, optionValue)
                end
            end

            local function toggleState()
                dropdown.Open = not dropdown.Open

                dropdown.Frame.ZIndex = dropdown.Open and 10 or 1
                if sectionParent then
                    local zFrame = sectionParent.Frame or sectionParent
                    if dropdown.Open then
                        sectionParent.OpenDropdowns = (sectionParent.OpenDropdowns or 0) + 1
                    else
                        sectionParent.OpenDropdowns = math.max(0, (sectionParent.OpenDropdowns or 0) - 1)
                    end
                    zFrame.ZIndex = (sectionParent.OpenDropdowns > 0) and 10 or 1
                end

                local targetContainerHeight = dropdown.Open and (#options * 16) or 0
                local targetRotation = dropdown.Open and 45 or 0 

                if dropdown.Open then
                    dropdown.Container.Visible = true
                end

                local containerTween = tweenService:Create(dropdown.Container, tweenInfo, { Size = UDim2.new(0, 199, 0, targetContainerHeight) })
                local iconTween = tweenService:Create(dropdown.ToggleIcon, tweenInfo, { Rotation = targetRotation })

                containerTween:Play()
                iconTween:Play()

                if not dropdown.Open then
                    containerTween.Completed:Connect(function()
                        if not dropdown.Open then
                            dropdown.Container.Visible = false
                        end
                    end)
                end
            end

            for idx, optName in ipairs(options) do
                local optBtn = self:NewInstance("TextButton", {
                    Name = optName .. "_Opt",
                    Parent = dropdown.Container,
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                    BorderSizePixel = 0,
                    Text = "  " .. optName,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Color3.fromRGB(157, 157, 157),
                    FontFace = DESIGN_CONFIG.FontProfile,
                    ZIndex = 102,
                    AutoButtonColor = false
                })

                optBtn.MouseButton1Click:Connect(function()
                    selectOption(optName)
                    toggleState()
                end)

                dropdown.OptionInstances[optName] = optBtn
            end

            dropdown.MainButton.MouseButton1Click:Connect(toggleState)
            dropdown.ToggleIcon.MouseButton1Click:Connect(toggleState)

            function dropdown:Set(val)
                selectOption(val)
            end

            function dropdown:AddSubElement(builder)
                if not dropdown.SubContainer then
                    local sectionContainer = dropdown.Frame.Parent
                    dropdown.SubContainer = Library:CreateSubContainer(sectionContainer, dropdownName)
                    dropdown.SubContainer.LayoutOrder = dropdown.Frame.LayoutOrder + 0.5
                end
                dropdown._subBuilder = builder
                builder(dropdown.SubContainer, dropdown.Value)
                Library:AnimateSubContainer(dropdown.SubContainer, true)
                return dropdown
            end

            function dropdown:Refresh(newOptions, selectDefault)
                for _, btn in pairs(dropdown.OptionInstances) do
                    btn:Destroy()
                end
                dropdown.OptionInstances = {}
                options = newOptions

                for idx, optName in ipairs(options) do
                    local optBtn = Library:NewInstance("TextButton", {
                        Name = optName .. "_Opt",
                        Parent = dropdown.Container,
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                        BorderSizePixel = 0,
                        Text = "  " .. optName,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromRGB(157, 157, 157),
                        FontFace = DESIGN_CONFIG.FontProfile,
                        ZIndex = 102,
                        AutoButtonColor = false
                    })

                    optBtn.MouseButton1Click:Connect(function()
                        selectOption(optName)
                        toggleState()
                    end)

                    dropdown.OptionInstances[optName] = optBtn
                end

                if selectDefault then
                    selectOption(options[1] or "")
                elseif not table.find(options, dropdown.Value) then
                    selectOption(options[1] or "")
                end
            end

            selectOption(dropdown.Value)
            return dropdown
        end

        function Library:CreateMultiDropdown(sectionParent, config)
            local dropdownName = config.name or "Multi-Dropdown"
            local options = config.options or {}
            local flag = config.flag

            local multidrop = {
                Value = config.default or {},
                Open = false,
                OptionInstances = {},
                _isMulti = true
            }

            local checkFillMap = {} -- stores checkFill frames per option (can't use custom props on Instances)

            if flag then
                self.flags[flag] = multidrop.Value
                self.Elements[flag] = multidrop
            end

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            multidrop.Frame = self:NewInstance("Frame", {
                Name = dropdownName .. "MultiNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 213, 0, 43),
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = false
            })

            multidrop.Label = self:NewInstance("TextLabel", {
                Parent = multidrop.Frame,
                Text = dropdownName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 100, 0, 18),
                Position = UDim2.new(0, 8, 0, 2),
                ZIndex = 1
            })
            self:NewInstance("UIStroke", { Parent = multidrop.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            multidrop.MainButton = self:NewInstance("TextButton", {
                Parent = multidrop.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 199, 0, 15),
                Position = UDim2.new(0, 8, 0, 21),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 10
            })
            self:Gradient(multidrop.MainButton, 90, GRADIENT_BUTTON)
            self:Stroke(multidrop.MainButton, { ZIndex = 11, Color = Color3.fromRGB(9, 9, 9) })

            multidrop.SelectionDisplay = self:NewInstance("TextLabel", {
                Parent = multidrop.MainButton,
                Text = "None selected",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(157, 157, 157),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.68339, 0, 1, 0),
                Position = UDim2.new(0.03518, 0, 0, 0),
                ZIndex = 12
            })
            self:NewInstance("UIStroke", { Parent = multidrop.SelectionDisplay, LineJoinMode = Enum.LineJoinMode.Miter })

            multidrop.ToggleIcon = self:NewInstance("TextButton", {
                Parent = multidrop.Frame,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 207, 0.65, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ZIndex = 12,
                FontFace = DESIGN_CONFIG.FontProfile
            })

            self:BottomLine(multidrop.Frame)

            multidrop.Container = self:NewInstance("Frame", {
                Name = "OptionsContainer",
                Parent = multidrop.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 199, 0, 0),
                Position = UDim2.new(0, 8, 0, 37),
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 100
            })
            self:NewInstance("UIListLayout", {
                Parent = multidrop.Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })
            self:Stroke(multidrop.Container, { ZIndex = 101, Color = Color3.fromRGB(9, 9, 9) })

            local function updateSelectionDisplay()
                local count = 0
                for _ in pairs(multidrop.Value) do count = count + 1 end
                if count == 0 then
                    multidrop.SelectionDisplay.Text = "None selected"
                    multidrop.SelectionDisplay.TextColor3 = Color3.fromRGB(157, 157, 157)
                elseif count == 1 then
                    multidrop.SelectionDisplay.Text = next(multidrop.Value) .. ""
                    multidrop.SelectionDisplay.TextColor3 = self.Accent
                else
                    multidrop.SelectionDisplay.Text = count .. " selected"
                    multidrop.SelectionDisplay.TextColor3 = self.Accent
                end
            end

            local function toggleOption(optionName)
                if multidrop.Value[optionName] then
                    multidrop.Value[optionName] = nil
                else
                    multidrop.Value[optionName] = true
                end

                if flag then self.flags[flag] = multidrop.Value end
                updateSelectionDisplay()

                -- Update checkbox visuals
                for opt, btn in pairs(multidrop.OptionInstances) do
                    local fill = checkFillMap[opt]
                    if fill then
                        fill.BackgroundTransparency = multidrop.Value[opt] and 0 or 1
                    end
                end

                if config.callback then
                    config.callback(multidrop.Value)
                end
            end

            local function toggleOpen()
                multidrop.Open = not multidrop.Open

                multidrop.Frame.ZIndex = multidrop.Open and 10 or 1
                if sectionParent then
                    local zFrame = sectionParent.Frame or sectionParent
                    if multidrop.Open then
                        sectionParent.OpenDropdowns = (sectionParent.OpenDropdowns or 0) + 1
                    else
                        sectionParent.OpenDropdowns = math.max(0, (sectionParent.OpenDropdowns or 0) - 1)
                    end
                    zFrame.ZIndex = (sectionParent.OpenDropdowns > 0) and 10 or 1
                end

                local targetHeight = multidrop.Open and (#options * 20) or 0
                local targetRotation = multidrop.Open and 45 or 0

                if multidrop.Open then
                    multidrop.Container.Visible = true
                end

                local ct = tweenService:Create(multidrop.Container, tweenInfo, { Size = UDim2.new(0, 199, 0, targetHeight) })
                local it = tweenService:Create(multidrop.ToggleIcon, tweenInfo, { Rotation = targetRotation })
                ct:Play()
                it:Play()

                if not multidrop.Open then
                    ct.Completed:Connect(function()
                        if not multidrop.Open then multidrop.Container.Visible = false end
                    end)
                end
            end

            for _, optName in ipairs(options) do
                local rowBtn = self:NewInstance("TextButton", {
                    Name = optName .. "_MOpt",
                    Parent = multidrop.Container,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 102,
                    AutoButtonColor = false
                })

                local optLabel = self:NewInstance("TextLabel", {
                    Parent = rowBtn,
                    Text = "  " .. optName,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Color3.fromRGB(157, 157, 157),
                    FontFace = DESIGN_CONFIG.FontProfile,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 160, 1, 0),
                    ZIndex = 103
                })

                local checkBox = self:NewInstance("Frame", {
                    Parent = rowBtn,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, 185, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex = 103
                })
                self:Stroke(checkBox, { Color = Color3.fromRGB(9, 9, 9) })

                local checkFill = self:NewInstance("Frame", {
                    Parent = checkBox,
                    BorderSizePixel = 0,
                    BackgroundColor3 = self.Accent,
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = multidrop.Value[optName] and 0 or 1,
                    ZIndex = 104
                })

                rowBtn.MouseButton1Click:Connect(function()
                    toggleOption(optName)
                end)

                checkFillMap[optName] = checkFill
                multidrop.OptionInstances[optName] = rowBtn
            end

            multidrop.MainButton.MouseButton1Click:Connect(toggleOpen)
            multidrop.ToggleIcon.MouseButton1Click:Connect(toggleOpen)

            function multidrop:Set(valuesTable)
                multidrop.Value = {}
                if type(valuesTable) == "table" then
                    for _, v in ipairs(valuesTable) do
                        if table.find(options, v) then
                            multidrop.Value[v] = true
                        end
                    end
                end
                if flag then Library.flags[flag] = multidrop.Value end
                updateSelectionDisplay()
                for opt, btn in pairs(multidrop.OptionInstances) do
                    local fill = checkFillMap[opt]
                    if fill then
                        fill.BackgroundTransparency = multidrop.Value[opt] and 0 or 1
                    end
                end
            end

            function multidrop:Refresh(newOptions, keepSelected)
                for _, btn in pairs(multidrop.OptionInstances) do
                    btn:Destroy()
                end
                multidrop.OptionInstances = {}
                local oldValue = multidrop.Value
                if not keepSelected then multidrop.Value = {} end
                options = newOptions

                for _, optName in ipairs(options) do
                    local rowBtn = Library:NewInstance("TextButton", {
                        Name = optName .. "_MOpt",
                        Parent = multidrop.Container,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = "",
                        ZIndex = 102,
                        AutoButtonColor = false
                    })
                    local optLabel = Library:NewInstance("TextLabel", {
                        Parent = rowBtn, Text = "  " .. optName, TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromRGB(157, 157, 157),
                        FontFace = DESIGN_CONFIG.FontProfile, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 160, 1, 0), ZIndex = 103
                    })
                    local checkBox = Library:NewInstance("Frame", {
                        Parent = rowBtn, BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 185, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 103
                    })
                    Library:Stroke(checkBox, { Color = Color3.fromRGB(9, 9, 9) })
                    local checkFill = Library:NewInstance("Frame", {
                        Parent = checkBox, BorderSizePixel = 0,
                        BackgroundColor3 = Library.Accent,
                        Size = UDim2.new(1, -4, 1, -4),
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundTransparency = 1, ZIndex = 104
                    })
                    rowBtn.MouseButton1Click:Connect(function() toggleOption(optName) end)
                    checkFillMap[optName] = checkFill
                    multidrop.OptionInstances[optName] = rowBtn
                end

                if keepSelected and oldValue then
                    for k in pairs(oldValue) do
                        if table.find(options, k) then
                            multidrop.Value[k] = true
                        end
                    end
                end
                updateSelectionDisplay()
                for opt, btn in pairs(multidrop.OptionInstances) do
                    local fill = checkFillMap[opt]
                    if fill then
                        fill.BackgroundTransparency = multidrop.Value[opt] and 0 or 1
                    end
                end
            end

            updateSelectionDisplay()
            return multidrop
        end

        function Library:CreateKeybind(sectionParent, config)
            local bindName = config.name or "Keybind"
            local flag = config.flag
            local callback = config.callback

            local bind = {
                Value = config.default or Enum.KeyCode.Unknown,
                BindingActive = false,
                Mode = config.mode or "Toggle",
                ActiveState = false,
                MenuOpen = false,
                Name = bindName
            }

            if flag then
                Library.flags[flag] = bind.Value
                Library.Elements[flag] = bind
            end

            local tweenService = game:GetService("TweenService")
            local userInputService = game:GetService("UserInputService")
            local tweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local topLevelGui = sectionParent.Container:FindFirstAncestorOfClass("ScreenGui")

            bind.Frame = self:NewInstance("Frame", {
                Name = bindName .. "KeybindNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 213, 0, 24),
                BackgroundTransparency = 1
            })

            local surfaceRow = self:NewInstance("Frame", {
                Parent = bind.Frame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local actionButton = self:NewInstance("TextButton", {
                Parent = surfaceRow,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })

            local label = self:NewInstance("TextLabel", {
                Parent = actionButton,
                Text = bindName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 120, 1, 0),
                Position = UDim2.new(0, 8, 0, 0)
            })
            self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })

            -- Mode indicator label (shows T/H/A)
            local modeLabel = self:NewInstance("TextLabel", {
                Parent = actionButton,
                Text = bind.Mode == "Toggle" and "T" or bind.Mode == "Hold" and "H" or "A",
                TextSize = 10,
                TextTransparency = 1,
                TextColor3 = Color3.fromRGB(120, 120, 120),
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 160, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5)
            })

            local bindBox = self:NewInstance("Frame", {
                Parent = actionButton,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 38, 0, 16),
                Position = UDim2.new(0, 207, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5)
            })
            local boxStroke = self:Stroke(bindBox, { Color = Color3.fromRGB(18, 18, 18) })

            local bindText = self:NewInstance("TextLabel", {
                Parent = bindBox,
                Text = "[" .. Library:GetBindName(bind.Value) .. "]",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(109, 109, 109),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                FontFace = DESIGN_CONFIG.FontProfile
            })

            self:BottomLine(surfaceRow)

            -- DETACHED OVERLAY FOR BIND + MODE
            local bindMenu = self:NewInstance("Frame", {
                Name = bindName .. "_KeyOverlay",
                Parent = topLevelGui,
                BorderSizePixel = 0,
                BackgroundColor3 = DESIGN_CONFIG.Background,
                Size = UDim2.new(0, 127, 0, 0),
                BackgroundTransparency = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 9999
            })
            self:Stroke(bindMenu, { ZIndex = 101, Color = Color3.fromRGB(9, 9, 9) })

            local menuHeader = self:NewInstance("Frame", {
                Parent = bindMenu,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = DESIGN_CONFIG.HeaderBackground,
                BorderSizePixel = 0,
                ZIndex = 102
            })
            self:Gradient(menuHeader)

            local menuTitle = self:NewInstance("TextLabel", {
                Parent = menuHeader,
                Text = bindName,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 103
            })
            self:NewInstance("UIStroke", { Parent = menuTitle, LineJoinMode = Enum.LineJoinMode.Miter })

            -- Bind row
            local bindRow = self:NewInstance("Frame", {
                Parent = bindMenu,
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundTransparency = 1,
                ZIndex = 102
            })
            local bindLabel = self:NewInstance("TextLabel", {
                Parent = bindRow, Text = "Keybind", TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1, Position = UDim2.new(0.04, 0, 0, 0),
                Size = UDim2.new(0, 50, 1, 0), FontFace = DESIGN_CONFIG.FontProfile, ZIndex = 103
            })
            local bindTextBtn = self:NewInstance("TextButton", {
                Parent = bindRow,
                Text = "[" .. Library:GetBindName(bind.Value) .. "]",
                TextSize = 12, FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(109, 109, 109),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 32, 0, 12),
                Position = UDim2.new(0.96, 1, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), AutoButtonColor = false, ZIndex = 103
            })
            self:Stroke(bindTextBtn, { ZIndex = 104, Color = Color3.fromRGB(9, 9, 9) })

            local clearBindBtn = self:NewInstance("TextButton", {
                Parent = bindRow, Text = "x", TextSize = 10,
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(180, 60, 60),
                BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -2, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), ZIndex = 104
            })
            clearBindBtn.MouseButton1Click:Connect(function()
                bind.Value = Enum.KeyCode.Unknown
                bindTextBtn.Text = "[NONE]"
                bindText.Text = "[NONE]"
                if flag then Library.flags[flag] = Enum.KeyCode.Unknown end
                Library:UpdateKeybindList()
            end)

            local rowLine = self:NewInstance("Frame", {
                Parent = bindRow, ZIndex = 103, BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0)
            })
            self:Gradient(rowLine, 90, GRADIENT_BOTTOM_LINE)

            -- Mode row
            local modeRow = self:NewInstance("Frame", {
                Parent = bindMenu, Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 44), BackgroundTransparency = 1, ZIndex = 102
            })
            local modeDropdownBtn = self:NewInstance("TextButton", {
                Parent = modeRow, Text = "", BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 115, 0, 15), Position = UDim2.new(0.043, 0, 0.26, 0),
                AutoButtonColor = false, ZIndex = 103
            })
            self:Stroke(modeDropdownBtn, { ZIndex = 104, Color = Color3.fromRGB(9, 9, 9) })
            local modeDisplayLabel = self:NewInstance("TextLabel", {
                Parent = modeDropdownBtn, Text = bind.Mode,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(157, 157, 157),
                BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0.05, 0, 0, 0), FontFace = DESIGN_CONFIG.FontProfile, ZIndex = 104
            })
            local modeCycleIcon = self:NewInstance("TextButton", {
                Parent = modeRow, Text = "+", TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1, Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0.877, 0, 0.37, 0), FontFace = DESIGN_CONFIG.FontProfile, ZIndex = 104
            })
            local modeBottomLine = self:NewInstance("Frame", {
                Parent = modeRow, ZIndex = 103, BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0)
            })
            self:Gradient(modeBottomLine, 90, GRADIENT_BOTTOM_LINE)

            local subModes = { "Toggle", "Hold", "Always" }
            local currentModeIdx = 1
            for i, m in ipairs(subModes) do if m == bind.Mode then currentModeIdx = i break end end

            local function cycleMode()
                currentModeIdx = (currentModeIdx % #subModes) + 1
                bind.Mode = subModes[currentModeIdx]
                modeDisplayLabel.Text = bind.Mode
                modeLabel.Text = bind.Mode == "Toggle" and "T" or bind.Mode == "Hold" and "H" or "A"
                if bind.Mode == "Always" then
                    bind.ActiveState = true
                    tweenService:Create(bindBox, tweenInfo, { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                else
                    bind.ActiveState = false
                    tweenService:Create(bindBox, tweenInfo, { BackgroundColor3 = Color3.fromRGB(12, 12, 12) }):Play()
                end
                Library:UpdateKeybindList()
            end
            modeDropdownBtn.MouseButton1Click:Connect(cycleMode)
            modeCycleIcon.MouseButton1Click:Connect(cycleMode)

            -- Overlay toggle
            local isHovering = false
            bindMenu.MouseEnter:Connect(function() isHovering = true end)
            bindMenu.MouseLeave:Connect(function() isHovering = false end)

            local function closeMenuSmoothly()
                if not bind.MenuOpen then return end
                bind.MenuOpen = false
                local ct = tweenService:Create(bindMenu, tweenInfo, { Size = UDim2.new(0, 127, 0, 0) })
                ct:Play()
                ct.Completed:Connect(function()
                    if not bind.MenuOpen then bindMenu.Visible = false end
                end)
            end

            local function toggleMenu()
                bind.MenuOpen = not bind.MenuOpen
                local targetHeight = bind.MenuOpen and 74 or 0
                if bind.MenuOpen then
                    local pos = bind.Frame.AbsolutePosition
                    bindMenu.Position = UDim2.new(0, pos.X + 220, 0, pos.Y)
                    bindMenu.Visible = true
                end
                local mt = tweenService:Create(bindMenu, tweenInfo, { Size = UDim2.new(0, 127, 0, targetHeight) })
                mt:Play()
                if not bind.MenuOpen then
                    mt.Completed:Connect(function()
                        if not bind.MenuOpen then bindMenu.Visible = false end
                    end)
                end
            end

            self:Track(userInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if bind.MenuOpen and not bind.BindingActive then
                        if not isHovering then closeMenuSmoothly() end
                    end
                end
            end))

            bind.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                if bind.MenuOpen then
                    local pos = bind.Frame.AbsolutePosition
                    bindMenu.Position = UDim2.new(0, pos.X + 220, 0, pos.Y)
                end
            end)

            -- Left click: enter binding mode
            actionButton.MouseButton1Click:Connect(function()
                if bind.BindingActive then return end
                bind.BindingActive = true
                bindTextBtn.Text = "[...]"
                bindTextBtn.TextColor3 = Library.Accent
                tweenService:Create(boxStroke, tweenInfo, { Color = Library.Accent }):Play()

                local connection
                connection = userInputService.InputBegan:Connect(function(input, processed)
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                        connection:Disconnect()
                        bind.Value = Enum.KeyCode.Unknown
                        bindTextBtn.Text = "[NONE]"
                        bindText.Text = "[NONE]"
                        if flag then Library.flags[flag] = Enum.KeyCode.Unknown end
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        tweenService:Create(boxStroke, tweenInfo, { Color = Color3.fromRGB(18, 18, 18) }):Play()
                        bind.BindingActive = false
                        Library:UpdateKeybindList()
                        return
                    end
                    if processed then return end
                    if Library:IsInputBindable(input) then
                        connection:Disconnect()
                        bind.Value = Library:BindFromInput(input)
                        bindTextBtn.Text = "[" .. Library:GetBindName(bind.Value) .. "]"
                        bindText.Text = "[" .. Library:GetBindName(bind.Value) .. "]"
                        if flag then Library.flags[flag] = bind.Value end
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        tweenService:Create(boxStroke, tweenInfo, { Color = Color3.fromRGB(18, 18, 18) }):Play()
                        bind.BindingActive = false
                        Library:UpdateKeybindList()
                    end
                end)
            end)

            -- Right click: toggle overlay
            actionButton.MouseButton2Click:Connect(toggleMenu)

            -- Bind capture in overlay
            bindTextBtn.MouseButton1Click:Connect(function()
                if bind.BindingActive then return end
                bind.BindingActive = true
                bindTextBtn.Text = "[...]"
                bindTextBtn.TextColor3 = Library.Accent

                local connection
                connection = userInputService.InputBegan:Connect(function(input, processed)
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                        connection:Disconnect()
                        bind.Value = Enum.KeyCode.Unknown
                        bindTextBtn.Text = "[NONE]"
                        bindText.Text = "[NONE]"
                        if flag then Library.flags[flag] = Enum.KeyCode.Unknown end
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        bind.BindingActive = false
                        Library:UpdateKeybindList()
                        return
                    end
                    if processed then return end
                    if Library:IsInputBindable(input) then
                        connection:Disconnect()
                        bind.Value = Library:BindFromInput(input)
                        bindTextBtn.Text = "[" .. Library:GetBindName(bind.Value) .. "]"
                        bindText.Text = "[" .. Library:GetBindName(bind.Value) .. "]"
                        if flag then Library.flags[flag] = bind.Value end
                        bindTextBtn.TextColor3 = Color3.fromRGB(109, 109, 109)
                        bind.BindingActive = false
                        Library:UpdateKeybindList()
                    end
                end)
            end)

            -- Input listeners with mode support
            self:Track(userInputService.InputBegan:Connect(function(input, processed)
                if processed or bind.BindingActive then return end
                if not Library:IsBindMatch(input, bind.Value) or bind.Value == Enum.KeyCode.Unknown then return end

                if bind.Mode == "Toggle" then
                    bind.ActiveState = not bind.ActiveState
                    if bind.ActiveState then
                        tweenService:Create(bindBox, TweenInfo.new(0.05, Enum.EasingStyle.Linear), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                    else
                        tweenService:Create(bindBox, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { BackgroundColor3 = Color3.fromRGB(12, 12, 12) }):Play()
                    end
                    if callback then callback(bind.ActiveState) end
                elseif bind.Mode == "Hold" or bind.Mode == "Always" then
                    bind.ActiveState = true
                    tweenService:Create(bindBox, TweenInfo.new(0.05, Enum.EasingStyle.Linear), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                    if callback then callback() end
                end
                Library:UpdateKeybindList()
            end))

            self:Track(userInputService.InputEnded:Connect(function(input)
                if not Library:IsBindMatch(input, bind.Value) or bind.Value == Enum.KeyCode.Unknown then return end
                if bind.Mode == "Always" then return end
                bind.ActiveState = false
                Library:UpdateKeybindList()
                tweenService:Create(bindBox, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { BackgroundColor3 = Color3.fromRGB(12, 12, 12) }):Play()
            end))

            bind.Frame.Destroying:Connect(function()
                bindMenu:Destroy()
            end)

            function bind:Set(key)
                bind.Value = key
                bindText.Text = "[" .. Library:GetBindName(key) .. "]"
                bindTextBtn.Text = "[" .. Library:GetBindName(key) .. "]"
                if flag then Library.flags[flag] = key end
                Library:UpdateKeybindList()
            end

            function bind:SetMode(mode)
                bind.Mode = mode
                modeDisplayLabel.Text = mode
                modeLabel.Text = mode == "Toggle" and "T" or mode == "Hold" and "H" or "A"
                local idx = table.find(subModes, mode)
                if idx then currentModeIdx = idx end
                if mode == "Always" then
                    bind.ActiveState = true
                    tweenService:Create(bindBox, tweenInfo, { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                else
                    bind.ActiveState = false
                    tweenService:Create(bindBox, tweenInfo, { BackgroundColor3 = Color3.fromRGB(12, 12, 12) }):Play()
                end
                Library:UpdateKeybindList()
            end

            return bind
        end

        function Library:CreateColorPicker(parent, config)
            local pickerName = config.name or "Color Picker"
            local flag = config.flag
            local defaultColor = config.default or Color3.fromRGB(255, 0, 0)
            local callback = config.callback

            local colorPicker = {
                Open = false,
                CanvasDragging = false,
                HueDragging = false,
                Rainbow = false,
                Speed = 1.0,
                Value = defaultColor
            }

            if flag then
                Library.flags[flag] = defaultColor
                Library.Elements[flag] = colorPicker
            end

            local userInputService = game:GetService("UserInputService")
            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(DESIGN_CONFIG.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local isToggle = (parent.StatusBox ~= nil)
            local container = isToggle and parent.Frame or parent.Container
            local topLevelGui = container:FindFirstAncestorOfClass("ScreenGui")

            local pickerBtn
            if isToggle then
                parent.ColorPickersCount = (parent.ColorPickersCount or 0) + 1
                local offset = 191 - (parent.ColorPickersCount - 1) * 20

                pickerBtn = self:NewInstance("TextButton", {
                    Parent = parent.ActionButton,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = defaultColor,
                    Size = UDim2.new(0, 16, 0, 10),
                    Position = UDim2.new(0, offset, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BorderSizePixel = 0,
                    ZIndex = 8
                })
                self:Gradient(pickerBtn)
                self:Stroke(pickerBtn, { Color = Color3.fromRGB(9, 9, 9) })
                colorPicker.Frame = pickerBtn
            else
                colorPicker.Frame = self:NewInstance("Frame", {
                    Name = pickerName .. "ColorNode",
                    Parent = parent.Container,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 213, 0, 24),
                    BackgroundTransparency = 1
                })

                local surfaceRow = self:NewInstance("Frame", {
                    Parent = colorPicker.Frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                local label = self:NewInstance("TextLabel", {
                    Parent = surfaceRow,
                    Text = pickerName,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Color3.fromRGB(176, 176, 176),
                    TextStrokeTransparency = 0,
                    FontFace = DESIGN_CONFIG.FontProfile,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 150, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0)
                })
                self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })

                pickerBtn = self:NewInstance("TextButton", {
                    Parent = surfaceRow,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = defaultColor,
                    Size = UDim2.new(0, 22, 0, 12),
                    Position = UDim2.new(0, 207, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                self:Gradient(pickerBtn)
                self:Stroke(pickerBtn, { Color = Color3.fromRGB(9, 9, 9) })

                self:BottomLine(surfaceRow)
            end

            -- DETACHED FLOATING POPUP OVERLAY (COLORPICKERMENU Style)
            local popupPanel = self:NewInstance("Frame", {
                Name = pickerName .. "_CanvasOverlay",
                Parent = topLevelGui,
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                Size = UDim2.new(0, 239, 0, 0), -- Collapsed initially
                Visible = false,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 9999
            })

            self:Gradient(popupPanel)

            local popupStroke = self:Stroke(popupPanel, { ZIndex = 101, Color = Color3.fromRGB(9, 9, 9) })

            -- Title/Header frame for the popup window
            local popupHeader = self:NewInstance("Frame", {
                Name = "Header",
                Parent = popupPanel,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(31, 31, 31),
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 102
            })

            self:Gradient(popupHeader)

            local popupTitle = self:NewInstance("TextLabel", {
                Parent = popupHeader,
                Text = pickerName,
                TextSize = 12,
                TextStrokeTransparency = 0,
                BorderSizePixel = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 103
            })
            self:NewInstance("UIStroke", { Parent = popupTitle, LineJoinMode = Enum.LineJoinMode.Miter })
            self:Gradient(popupTitle)

            ---------------------------------------------------------
            -- TAB BAR SYSTEM FOR COLOR POPUP
            ---------------------------------------------------------
            local tabBar = self:NewInstance("Frame", {
                Name = "TabBar",
                Parent = popupPanel,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 0, 0, 20),
                ZIndex = 102
            })
            self:Gradient(tabBar, 90, ColorSequence.new({
                ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1.000, Color3.fromRGB(200, 200, 200))
            }))
            self:Stroke(tabBar, { Color = Color3.fromRGB(16, 16, 16) })

            local solidTabBtn = self:NewInstance("TextButton", {
                Name = "SolidTab",
                Parent = tabBar,
                Text = "Solid",
                TextSize = 11,
                TextColor3 = self.Accent,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -1, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 103,
                AutoButtonColor = false
            })
            self:NewInstance("UIStroke", { Parent = solidTabBtn, LineJoinMode = Enum.LineJoinMode.Miter })

            local animTabBtn = self:NewInstance("TextButton", {
                Name = "AnimTab",
                Parent = tabBar,
                Text = "Animation",
                TextSize = 11,
                TextColor3 = Color3.fromRGB(145, 145, 145),
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -1, 1, 0),
                Position = UDim2.new(0.5, 1, 0, 0),
                ZIndex = 103,
                AutoButtonColor = false
            })
            self:NewInstance("UIStroke", { Parent = animTabBtn, LineJoinMode = Enum.LineJoinMode.Miter })

            ---------------------------------------------------------
            -- GENERATED 2D COLOR CANVAS (NO ASSETS)
            ---------------------------------------------------------
            local canvasWindow = self:NewInstance("Frame", {
                Name = "CanvasWindow",
                Parent = popupPanel,
                Size = UDim2.new(0, 195, 0, 80),
                Position = UDim2.new(0, 8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 102
            })
            self:NewInstance("UIStroke", { Parent = canvasWindow, Color = Color3.fromRGB(9, 9, 9), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Miter })

            -- Base Tint Frame (Changes based on selected Hue)
            local hueBaseFrame = self:NewInstance("Frame", {
                Name = "HueBase",
                Parent = canvasWindow,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 103
            })

            -- Horizontal Saturation Gradient Layer (White -> Transparent)
            local saturationGradientFrame = self:NewInstance("Frame", {
                Name = "SaturationGradient",
                Parent = canvasWindow,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 104
            })
            self:NewInstance("UIGradient", {
                Parent = saturationGradientFrame,
                Rotation = 0,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
            })

            -- Vertical Value Gradient Layer (Transparent -> Black)
            local valueGradientFrame = self:NewInstance("Frame", {
                Name = "ValueGradient",
                Parent = canvasWindow,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 105
            })
            self:NewInstance("UIGradient", {
                Parent = valueGradientFrame,
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
            })

            -- Interactive Crosshair / Cursor
            local canvasCursor = self:NewInstance("Frame", {
                Parent = canvasWindow,
                Size = UDim2.new(0, 4, 0, 4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 106
            })
            self:NewInstance("UIStroke", { Parent = canvasCursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1 })

            ---------------------------------------------------------
            -- GENERATED HUE SLIDER STRIP (NO ASSETS)
            ---------------------------------------------------------
            local hueTrack = self:NewInstance("Frame", {
                Name = "HueTrack",
                Parent = popupPanel,
                Size = UDim2.new(0, 23, 0, 102),
                Position = UDim2.new(0, 209, 0, 40),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 102
            })
            self:Stroke(hueTrack, { Color = Color3.fromRGB(9, 9, 9) })

            -- Native full-spectrum color sequence generator mapping
            self:Gradient(hueTrack, 90, ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
            }))

            local hueCursor = self:NewInstance("Frame", {
                Parent = hueTrack,
                Size = UDim2.new(1, 4, 0, 2),
                Position = UDim2.new(0, -2, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 103
            })
            self:NewInstance("UIStroke", { Parent = hueCursor, Color = Color3.fromRGB(0, 0, 0) })

            ---------------------------------------------------------
            -- COLOR MODE DROPDOWN SYSTEM
            ---------------------------------------------------------
            local colorModeDropdown = self:NewInstance("Frame", {
                Name = "ColorModeDropdown",
                Parent = popupPanel,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 195, 0, 15),
                Position = UDim2.new(0, 8, 0, 126),
                ZIndex = 102
            })

            local modeButton = self:NewInstance("TextButton", {
                Parent = colorModeDropdown,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 103
            })

            self:Gradient(modeButton, 90, GRADIENT_BUTTON)

            self:Stroke(modeButton, { ZIndex = 104, Color = Color3.fromRGB(9, 9, 9) })

            local selectedMode = "RGB"

            local modeLabel = self:NewInstance("TextLabel", {
                Parent = modeButton,
                Text = "Color Mode: RGB",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(157, 157, 157),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                ZIndex = 105
            })
            self:NewInstance("UIStroke", { Parent = modeLabel, LineJoinMode = Enum.LineJoinMode.Miter })

            local cycleIcon = self:NewInstance("TextLabel", {
                Parent = modeButton,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -16, 0.5, -6),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 105
            })

            local modeMenu = self:NewInstance("Frame", {
                Name = "ModeMenu",
                Parent = colorModeDropdown,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, -2),
                AnchorPoint = Vector2.new(0, 1),
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 200
            })
            self:Stroke(modeMenu, { ZIndex = 201, Color = Color3.fromRGB(9, 9, 9) })

            self:NewInstance("UIListLayout", {
                Parent = modeMenu,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })

            local function copyColor(mode)
                local col = colorPicker.Value
                local textToCopy = ""
                if mode == "RGB" then
                    textToCopy = string.format("%d, %d, %d", math.round(col.R * 255), math.round(col.G * 255), math.round(col.B * 255))
                elseif mode == "HEX" then
                    local r = math.clamp(math.round(col.R * 255), 0, 255)
                    local g = math.clamp(math.round(col.G * 255), 0, 255)
                    local b = math.clamp(math.round(col.B * 255), 0, 255)
                    textToCopy = string.format("#%02X%02X%02X", r, g, b)
                elseif mode == "HSV" then
                    local h, s, v = col:ToHSV()
                    textToCopy = string.format("%.2f, %.2f, %.2f", h, s, v)
                end
                
                setclipboard(textToCopy)
                Library:Notify("Copied " .. mode .. " color to clipboard!", 3.5)
            end

            local modes = {"Copy RGB", "Copy HEX", "Copy HSV"}
            local modeMenuOpen = false

            local function toggleModeMenu()
                modeMenuOpen = not modeMenuOpen
                local targetHeight = modeMenuOpen and (#modes * 16) or 0
                
                if modeMenuOpen then
                    modeMenu.Visible = true
                end
                
                local menuTween = tweenService:Create(modeMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) })
                menuTween:Play()
                
                if not modeMenuOpen then
                    menuTween.Completed:Connect(function()
                        if not modeMenuOpen then
                            modeMenu.Visible = false
                        end
                    end)
                end
            end

            for idx, modeName in ipairs(modes) do
                local optBtn = self:NewInstance("TextButton", {
                    Name = modeName .. "_Opt",
                    Parent = modeMenu,
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                    BorderSizePixel = 0,
                    Text = "  " .. modeName,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Color3.fromRGB(157, 157, 157),
                    FontFace = DESIGN_CONFIG.FontProfile,
                    ZIndex = 202,
                    AutoButtonColor = false
                })
                self:NewInstance("UIStroke", { Parent = optBtn, LineJoinMode = Enum.LineJoinMode.Miter })

                optBtn.MouseButton1Click:Connect(function()
                    local mode = modeName:gsub("Copy ", "")
                    selectedMode = mode
                    modeLabel.Text = "Color Mode: " .. mode
                    copyColor(mode)
                    toggleModeMenu()
                end)
            end

            modeButton.MouseButton1Click:Connect(toggleModeMenu)

            ---------------------------------------------------------
            -- LOGIC & MATH BRIDGING
            ---------------------------------------------------------
            local currentH, currentS, currentV = defaultColor:ToHSV()

            local updateRainbowUI
            local updateSpeedUI

            local function updateColor()
                -- Shift background spectrum
                hueBaseFrame.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)

                local combinedColor = Color3.fromHSV(currentH, currentS, currentV)
                pickerBtn.BackgroundColor3 = combinedColor
                colorPicker.Value = combinedColor
                if flag then
                    Library.flags[flag] = combinedColor
                end

                if callback then
                    callback(combinedColor)
                end
            end

            local RunService = game:GetService("RunService")
            local heartbeatConnection

            local function startRainbow()
                if heartbeatConnection then return end
                heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                    if colorPicker.Rainbow then
                        currentH = (currentH + dt * 0.05 * colorPicker.Speed) % 1.0
                        updateColor()
                        if colorPicker.Open then
                            canvasCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
                            hueCursor.Position = UDim2.new(0, -2, currentH, 0)
                        end
                    end
                end)
            end

            local function stopRainbow()
                if heartbeatConnection then
                    heartbeatConnection:Disconnect()
                    heartbeatConnection = nil
                end
            end

            local function disableRainbow()
                if colorPicker.Rainbow then
                    colorPicker.Rainbow = false
                    if updateRainbowUI then updateRainbowUI() end
                    stopRainbow()
                end
            end

            canvasCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
            hueCursor.Position = UDim2.new(0, -2, currentH, 0)
            updateColor()

            local function processCanvasInput(input)
                disableRainbow()
                local localX = math.clamp(input.Position.X - canvasWindow.AbsolutePosition.X, 0, canvasWindow.AbsoluteSize.X)
                local localY = math.clamp(input.Position.Y - canvasWindow.AbsolutePosition.Y, 0, canvasWindow.AbsoluteSize.Y)

                currentS = localX / canvasWindow.AbsoluteSize.X
                currentV = 1 - (localY / canvasWindow.AbsoluteSize.Y)

                canvasCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
                updateColor()
            end

            local function processHueInput(input)
                disableRainbow()
                local localY = math.clamp(input.Position.Y - hueTrack.AbsolutePosition.Y, 0, hueTrack.AbsoluteSize.Y)
                currentH = localY / hueTrack.AbsoluteSize.Y

                hueCursor.Position = UDim2.new(0, -2, currentH, 0)
                updateColor()
            end

            canvasWindow.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorPicker.CanvasDragging = true
                    processCanvasInput(input)
                end
            end)

            hueTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorPicker.HueDragging = true
                    processHueInput(input)
                end
            end)

            self:Track(userInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if colorPicker.CanvasDragging then
                        processCanvasInput(input)
                    elseif colorPicker.HueDragging then
                        processHueInput(input)
                    end
                end
            end))

            self:Track(userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorPicker.CanvasDragging = false
                    colorPicker.HueDragging = false
                end
            end))

            ---------------------------------------------------------
            -- ANIMATION VIEW & CONTROLS CREATION
            ---------------------------------------------------------
            local animView = self:NewInstance("Frame", {
                Name = "AnimationView",
                Parent = popupPanel,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 110),
                Position = UDim2.new(0, 0, 0, 40),
                Visible = false,
                ZIndex = 102
            })

            local rainbowRow = self:NewInstance("Frame", {
                Parent = animView,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 10),
                ZIndex = 103
            })

            local rainbowLabel = self:NewInstance("TextLabel", {
                Parent = rainbowRow,
                Text = "Rainbow Animation",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                ZIndex = 104
            })
            self:NewInstance("UIStroke", { Parent = rainbowLabel, LineJoinMode = Enum.LineJoinMode.Miter })

            local rainbowToggleBtn = self:NewInstance("TextButton", {
                Parent = rainbowRow,
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 104,
                AutoButtonColor = false
            })

            local rainbowStatusBox = self:NewInstance("Frame", {
                Parent = rainbowToggleBtn,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 231, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ZIndex = 105
            })
            self:Gradient(rainbowStatusBox)
            self:Stroke(rainbowStatusBox, { ZIndex = 106, Color = Color3.fromRGB(9, 9, 9) })

            local rainbowFill = self:NewInstance("Frame", {
                Parent = rainbowStatusBox,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = 107
            })
            self:Gradient(rainbowFill, 90, GRADIENT_ACCENT_FILL)

            updateRainbowUI = function()
                local targetTransparency = colorPicker.Rainbow and 0 or 1
                local targetLabelColor = colorPicker.Rainbow and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(176, 176, 176)
                tweenService:Create(rainbowFill, tweenInfo, { BackgroundTransparency = targetTransparency }):Play()
                tweenService:Create(rainbowLabel, tweenInfo, { TextColor3 = targetLabelColor }):Play()
            end

            rainbowToggleBtn.MouseButton1Click:Connect(function()
                colorPicker.Rainbow = not colorPicker.Rainbow
                updateRainbowUI()
                if colorPicker.Rainbow then
                    startRainbow()
                else
                    stopRainbow()
                end
            end)

            local speedRow = self:NewInstance("Frame", {
                Parent = animView,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                Position = UDim2.new(0, 0, 0, 40),
                ZIndex = 103
            })

            local speedLabel = self:NewInstance("TextLabel", {
                Parent = speedRow,
                Text = "Rainbow Speed: " .. string.format("%.1fx", colorPicker.Speed),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 150, 0, 20),
                Position = UDim2.new(0, 8, 0, 2),
                ZIndex = 104
            })
            self:NewInstance("UIStroke", { Parent = speedLabel, LineJoinMode = Enum.LineJoinMode.Miter })

            local speedTrack = self:NewInstance("TextButton", {
                Parent = speedRow,
                Text = "",
                Size = UDim2.new(0, 223, 0, 10),
                Position = UDim2.new(0, 8, 0, 22),
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = 104
            })
            self:Gradient(speedTrack, 90, GRADIENT_SLIDER_TRACK)
            self:Stroke(speedTrack, { ZIndex = 105, Color = Color3.fromRGB(9, 9, 9) })

            local speedFill = self:NewInstance("Frame", {
                Parent = speedTrack,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(0.2, 0, 1, 0),
                ZIndex = 105
            })
            self:Gradient(speedFill, 90, GRADIENT_ACCENT_FILL)

            local speedIncBtn = self:NewInstance("TextButton", {
                Parent = speedRow,
                Text = "+",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 231, 0, 12), 
                AnchorPoint = Vector2.new(1, 0.5),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 104
            })

            local speedDecBtn = self:NewInstance("TextButton", {
                Parent = speedRow,
                Text = "-",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(0, 217, 0, 12), 
                AnchorPoint = Vector2.new(1, 0.5),
                FontFace = DESIGN_CONFIG.FontProfile,
                ZIndex = 104
            })

            updateSpeedUI = function()
                local percent = (colorPicker.Speed - 0.1) / (5.0 - 0.1)
                speedFill.Size = UDim2.new(percent, 0, 1, 0)
                speedLabel.Text = "Rainbow Speed: " .. string.format("%.1fx", colorPicker.Speed)
            end

            local speedDragging = false
            local function updateSpeedFromInput(input)
                local xOffset = math.clamp(input.Position.X - speedTrack.AbsolutePosition.X, 0, speedTrack.AbsoluteSize.X)
                local percent = xOffset / speedTrack.AbsoluteSize.X
                local targetSpeed = 0.1 + percent * (5.0 - 0.1)
                colorPicker.Speed = math.round(targetSpeed / 0.1) * 0.1
                updateSpeedUI()
            end

            speedTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    speedDragging = true
                    updateSpeedFromInput(input)
                end
            end)

            self:Track(userInputService.InputChanged:Connect(function(input)
                if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSpeedFromInput(input)
                end
            end))

            self:Track(userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    speedDragging = false
                end
            end))

            speedIncBtn.MouseButton1Click:Connect(function()
                colorPicker.Speed = math.clamp(colorPicker.Speed + 0.1, 0.1, 5.0)
                updateSpeedUI()
            end)

            speedDecBtn.MouseButton1Click:Connect(function()
                colorPicker.Speed = math.clamp(colorPicker.Speed - 0.1, 0.1, 5.0)
                updateSpeedUI()
            end)

            updateSpeedUI()

            ---------------------------------------------------------
            -- TAB SWITCHING LOGIC CONNECTIONS
            ---------------------------------------------------------
            solidTabBtn.MouseButton1Click:Connect(function()
                solidTabBtn.TextColor3 = self.Accent
                animTabBtn.TextColor3 = Color3.fromRGB(145, 145, 145)
                canvasWindow.Visible = true
                hueTrack.Visible = true
                colorModeDropdown.Visible = true
                animView.Visible = false
            end)

            animTabBtn.MouseButton1Click:Connect(function()
                animTabBtn.TextColor3 = self.Accent
                solidTabBtn.TextColor3 = Color3.fromRGB(145, 145, 145)
                canvasWindow.Visible = false
                hueTrack.Visible = false
                colorModeDropdown.Visible = false
                animView.Visible = true
            end)

            local function updatePopupPosition()
                local originPos = pickerBtn.AbsolutePosition
                popupPanel.Position = UDim2.new(0, originPos.X + pickerBtn.AbsoluteSize.X - 239, 0, originPos.Y + pickerBtn.AbsoluteSize.Y + 4)
            end

            local function closeOverlaySmoothly()
                if not colorPicker.Open then return end
                colorPicker.Open = false
                local closeTween = tweenService:Create(popupPanel, tweenInfo, { Size = UDim2.new(0, 239, 0, 0) })
                closeTween:Play()
                closeTween.Completed:Connect(function()
                    if not colorPicker.Open then popupPanel.Visible = false end
                end)
            end

            local function toggleOverlayState()
                colorPicker.Open = not colorPicker.Open
                local targetHeight = colorPicker.Open and 151 or 0

                if colorPicker.Open then
                    updatePopupPosition()
                    popupPanel.Visible = true
                end

                local panelTween = tweenService:Create(popupPanel, tweenInfo, { Size = UDim2.new(0, 239, 0, targetHeight) })
                panelTween:Play()

                if not colorPicker.Open then
                    panelTween.Completed:Connect(function()
                        if not colorPicker.Open then popupPanel.Visible = false end
                    end)
                end
            end

            local popupHovering = false
            popupPanel.MouseEnter:Connect(function() popupHovering = true end)
            popupPanel.MouseLeave:Connect(function() popupHovering = false end)

            self:Track(userInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if colorPicker.Open and not popupHovering then
                        local mouseLoc = userInputService:GetMouseLocation()
                        local btnPos = pickerBtn.AbsolutePosition
                        local btnSize = pickerBtn.AbsoluteSize
                        local insideBtn = mouseLoc.X >= btnPos.X and mouseLoc.X <= (btnPos.X + btnSize.X) and mouseLoc.Y >= (btnPos.Y + 36) and mouseLoc.Y <= (btnPos.Y + 36 + btnSize.Y)

                        if not insideBtn then
                            closeOverlaySmoothly()
                        end
                    end
                end
            end))

            colorPicker.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                if colorPicker.Open then updatePopupPosition() end
            end)

            pickerBtn.MouseButton1Click:Connect(toggleOverlayState)

            colorPicker.Frame.Destroying:Connect(function()
                stopRainbow()
                popupPanel:Destroy()
            end)

            function colorPicker:Set(color)
                currentH, currentS, currentV = color:ToHSV()
                canvasCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
                hueCursor.Position = UDim2.new(0, -2, currentH, 0)
                updateColor()
            end

            function colorPicker:SetRainbow(state)
                colorPicker.Rainbow = state
                updateRainbowUI()
                if state then
                    startRainbow()
                else
                    stopRainbow()
                end
            end

            function colorPicker:SetSpeed(speed)
                colorPicker.Speed = math.clamp(speed, 0.1, 5.0)
                updateSpeedUI()
            end

            return colorPicker
        end

        function Library:CreateButton(sectionParent, config)
            local buttonName = config.name or "Button"
            local callback = config.callback

            local button = {}

            button.Frame = self:NewInstance("Frame", {
                Name = buttonName .. "ButtonNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 213, 0, 24),
                BackgroundTransparency = 1
            })

            local surfaceRow = self:NewInstance("Frame", {
                Parent = button.Frame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            button.ActionButton = self:NewInstance("TextButton", {
                Parent = surfaceRow,
                Size = UDim2.new(0, 199, 0, 16),
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Text = buttonName,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextSize = 12,
                FontFace = DESIGN_CONFIG.FontProfile,
                AutoButtonColor = true
            })

            self:Stroke(button.ActionButton, { Color = Color3.fromRGB(9, 9, 9) })

            self:BottomLine(surfaceRow)

            button.ActionButton.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return button
        end

        function Library:CreateTextBox(sectionParent, config)
            local textboxName = config.name or "TextBox"
            local defaultText = config.default or ""
            local placeholder = config.placeholder or "Type here..."
            local callback = config.callback
            local flag = config.flag

            local textbox = { Value = defaultText }

            if flag then
                self.flags[flag] = defaultText
                self.Elements[flag] = textbox
            end

            textbox.Frame = self:NewInstance("Frame", {
                Name = textboxName .. "TextBoxNode",
                Parent = sectionParent.Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 213, 0, 45),
                BackgroundTransparency = 1
            })

            textbox.Label = self:NewInstance("TextLabel", {
                Parent = textbox.Frame,
                Text = textboxName,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 100, 0, 18),
                Position = UDim2.new(0, 8, 0, 2)
            })
            self:NewInstance("UIStroke", { Parent = textbox.Label, LineJoinMode = Enum.LineJoinMode.Miter })

            textbox.InputBox = self:NewInstance("TextBox", {
                Parent = textbox.Frame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Size = UDim2.new(0, 199, 0, 18),
                Position = UDim2.new(0, 8, 0, 21),
                Text = defaultText,
                PlaceholderText = placeholder,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                TextSize = 12,
                FontFace = DESIGN_CONFIG.FontProfile,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            self:Stroke(textbox.InputBox, { Color = Color3.fromRGB(9, 9, 9) })
            self:NewInstance("UIPadding", { Parent = textbox.InputBox, PaddingLeft = UDim.new(0, 5) })

            self:BottomLine(textbox.Frame)

            textbox.InputBox.FocusLost:Connect(function(enterPressed)
                textbox.Value = textbox.InputBox.Text
                if flag then
                    self.flags[flag] = textbox.Value
                end
                if callback then
                    callback(textbox.Value, enterPressed)
                end
            end)

            function textbox:Set(val)
                textbox.Value = val
                textbox.InputBox.Text = val
                if flag then
                    Library.flags[flag] = val
                end
            end

            return textbox
        end

        function Library:CreateLabel(section, config)
            config = config or {}

            local label = {}
            label.Section = section
            label.Type = "Label"

            label.Frame = self:NewInstance("Frame", {
                Parent = section.Container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })

            label.TextLabel = self:NewInstance("TextLabel", {
                Parent = label.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 6),
                Text = config.text or config.name or "",
                TextSize = 12,
                TextColor3 = Color3.fromRGB(140, 140, 140),
                FontFace = DESIGN_CONFIG.FontProfile,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                RichText = true
            })

            function label:Set(text)
                label.TextLabel.Text = text
            end

            return label
        end

        function Library:CreateSeparator(section, config)
            config = config or {}

            local separator = {}
            separator.Section = section
            separator.Type = "Separator"

            separator.Frame = self:NewInstance("Frame", {
                Parent = section.Container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 14)
            })

            local line = self:NewInstance("Frame", {
                Parent = separator.Frame,
                BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -16, 0, 1),
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5)
            })
            self:Stroke(line, { Color = Color3.fromRGB(9, 9, 9) })

            return separator
        end

        function Library:CreateSkinsTab(config)
            config = config or {}
            local skinsTab = self:CreateTab(config.name or "Skins")

            skinsTab.LeftColumn.Visible = false
            skinsTab.RightColumn.Visible = false

            -- Full Rivals skin database (weapon type → skin list)
            local GUNS_DATABASE, gunNamesList = loadstring(game:HttpGet('https://raw.githubusercontent.com/2019teen/Rivals/refs/heads/main/browhat.lua'))()

            local selectGunBtn = self:NewInstance("TextButton", {
                Name = "SelectGun",
                Parent = skinsTab.PageFrame,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(154, 146, 146),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                FontFace = DESIGN_CONFIG.FontProfile,
                Size = UDim2.new(0, 435, 0, 18),
                Position = UDim2.new(0.01342, 0, 0.01783, 0),
                BorderColor3 = Color3.fromRGB(14, 14, 14),
                Text = "Selected Gun: None",
                AutoButtonColor = true,
                ZIndex = 5
            })
            self:Stroke(selectGunBtn, { Color = Color3.fromRGB(14, 14, 14) })

            local skinSearch = self:NewInstance("TextBox", {
                Name = "SkinSearch",
                Parent = skinsTab.PageFrame,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                FontFace = DESIGN_CONFIG.FontProfile,
                ClipsDescendants = true,
                PlaceholderText = "Search",
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                Size = UDim2.new(0, 435, 0, 18),
                Position = UDim2.new(0.01342, 0, 0.07878, 0),
                BorderColor3 = Color3.fromRGB(14, 14, 14),
                Text = "",
                ClearTextOnFocus = false,
                ZIndex = 1
            })
            self:Stroke(skinSearch, { Color = Color3.fromRGB(14, 14, 14) })
            self:NewInstance("UIPadding", {
                Parent = skinSearch,
                PaddingLeft = UDim.new(0, 5)
            })

            local skinHolder = self:NewInstance("ScrollingFrame", {
                Name = "SkinHolder",
                Parent = skinsTab.PageFrame,
                Active = true,
                BorderSizePixel = 0,
                ScrollBarImageTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(8, 8, 8),
                ClipsDescendants = true,
                Size = UDim2.new(0, 435, 0, 350),
                Position = UDim2.new(0.01342, 0, 0.13995, 0),
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 1
            })
            self:Stroke(skinHolder, { Color = Color3.fromRGB(14, 14, 14) })
            self:NewInstance("UIPadding", {
                Parent = skinHolder,
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4)
            })

            local uiGridLayout = self:NewInstance("UIGridLayout", {
                Parent = skinHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                CellSize = UDim2.new(0, 80, 0, 80),
                CellPadding = UDim2.new(0, 5, 0, 5)
            })

            local applyBtn = self:NewInstance("TextButton", {
                Name = "Apply",
                Parent = skinsTab.PageFrame,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(135, 135, 135),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                FontFace = DESIGN_CONFIG.FontProfile,
                Size = UDim2.new(0, 435, 0, 18),
                Position = UDim2.new(0.01342, 0, 0.9456, 0),
                BorderColor3 = Color3.fromRGB(14, 14, 14),
                Text = "Apply Skin",
                AutoButtonColor = true,
                ZIndex = 1
            })
            self:Stroke(applyBtn, { Color = Color3.fromRGB(14, 14, 14) })

            -- Gun Selector Dropdown Menu Overlay
            local gunDropdown = self:NewInstance("ScrollingFrame", {
                Name = "GunDropdown",
                Parent = skinsTab.PageFrame,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                Size = UDim2.new(0, 435, 0, 0),
                Position = UDim2.new(0.01342, 0, 0.01783, 18),
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 50,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
                ScrollBarImageTransparency = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            self:Stroke(gunDropdown, { Color = Color3.fromRGB(14, 14, 14) })
            local gunListLayout = self:NewInstance("UIListLayout", {
                Parent = gunDropdown,
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            -- Control handle object returned to user
            local skinsControl = {
                Tab = skinsTab,
                SelectGunBtn = selectGunBtn,
                SkinSearch = skinSearch,
                SkinHolder = skinHolder,
                ApplyBtn = applyBtn,
                SelectedGun = "None",
                SelectedSkin = "",
                OnSkinApplied = config.callback,
                -- Custom element fields to act as a flag
                IsSkins = true,
                Value = {} -- holds the selected skin settings, e.g. { ["AK-47"] = { Name = "Redline" } }
            }
            self.flags["gun_skin_settings"] = skinsControl.Value
            self.Elements["gun_skin_settings"] = skinsControl

            local selectedSkinNode = nil

            local function refreshSkins()
                -- Clean existing cell objects
                for _, child in ipairs(skinHolder:GetChildren()) do
                    if child:IsA("GuiObject") and not child:IsA("UIGridLayout") then
                        child:Destroy()
                    end
                end

                selectedSkinNode = nil
                skinsControl.SelectedSkin = ""
                applyBtn.TextColor3 = Color3.fromRGB(135, 135, 135) -- Reset text color to disabled appearance

                local gun = skinsControl.SelectedGun
                if gun == "None" or not GUNS_DATABASE[gun] then return end

                -- Check if there is a saved skin for this gun in the config settings
                local savedSkinName = ""
                if skinsControl.Value[gun] and skinsControl.Value[gun].Name then
                    savedSkinName = skinsControl.Value[gun].Name
                end

                for _, skin in ipairs(GUNS_DATABASE[gun]) do
                    local cell = self:NewInstance("TextButton", {
                        Name = skin.name,
                        Parent = skinHolder,
                        Size = UDim2.new(0, 80, 0, 80),
                        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(20, 20, 20),
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 2
                    })

                    -- Highlight if this is the saved skin
                    local isSelected = (skin.name == savedSkinName)
                    if isSelected then
                        selectedSkinNode = cell
                        skinsControl.SelectedSkin = skin.name
                        cell.BorderColor3 = self.Accent
                        cell.BackgroundColor3 = Color3.fromRGB(24, 18, 18)
                        applyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    end

                    -- Skin image preview (uses actual skin image if available, else rarity gradient)
                    local hasImage = skin.image and skin.image ~= ""
                    if hasImage then
                        local preview = self:NewInstance("ImageLabel", {
                            Name = "Preview",
                            Parent = cell,
                            Size = UDim2.new(1, -6, 1, -20),
                            Position = UDim2.new(0, 3, 0, 3),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            Image = skin.image,
                            ScaleType = Enum.ScaleType.Fit,
                            ZIndex = 3
                        })
                    else
                        local preview = self:NewInstance("Frame", {
                            Name = "Preview",
                            Parent = cell,
                            Size = UDim2.new(1, -6, 1, -20),
                            Position = UDim2.new(0, 3, 0, 3),
                            BorderSizePixel = 0,
                            ZIndex = 3
                        })
                        self:Gradient(preview, 45, ColorSequence.new({
                            ColorSequenceKeypoint.new(0.000, skin.colors[1]),
                            ColorSequenceKeypoint.new(1.000, skin.colors[2])
                        }))
                    end

                    -- Skin Name Label
                    local label = self:NewInstance("TextLabel", {
                        Parent = cell,
                        Text = skin.name,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(150, 150, 150),
                        TextStrokeTransparency = 0,
                        FontFace = DESIGN_CONFIG.FontProfile,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        Position = UDim2.new(0, 0, 1, -15),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        ZIndex = 3
                    })
                    self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })

                    cell.MouseButton1Click:Connect(function()
                        if selectedSkinNode == cell then return end

                        -- Reset previous selection styling
                        if selectedSkinNode then
                            selectedSkinNode.BorderColor3 = Color3.fromRGB(20, 20, 20)
                            selectedSkinNode.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                        end

                        -- Highlight selected cell
                        selectedSkinNode = cell
                        skinsControl.SelectedSkin = skin.name
                        cell.BorderColor3 = self.Accent
                        cell.BackgroundColor3 = Color3.fromRGB(24, 18, 18)

                        -- Enable Apply button appearance
                        applyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    end)
                end
            end
            skinsControl.RefreshSkins = refreshSkins

            local gunDropdownOpen = false

            local GUN_DROPDOWN_MAX_HEIGHT = 150

            local function toggleGunDropdown()
                gunDropdownOpen = not gunDropdownOpen
                local fullHeight = #gunNamesList * 18
                local targetHeight = gunDropdownOpen and math.min(fullHeight, GUN_DROPDOWN_MAX_HEIGHT) or 0
                if gunDropdownOpen then
                    gunDropdown.Visible = true
                end

                local tweenService = game:GetService("TweenService")
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = tweenService:Create(gunDropdown, tweenInfo, { Size = UDim2.new(0, 435, 0, targetHeight) })
                tween:Play()

                if not gunDropdownOpen then
                    tween.Completed:Connect(function()
                        if not gunDropdownOpen then
                            gunDropdown.Visible = false
                        end
                    end)
                end
            end

            selectGunBtn.MouseButton1Click:Connect(toggleGunDropdown)

            local function createGunDropdownOption(gunName)
                local gunBtn = self:NewInstance("TextButton", {
                    Name = gunName .. "SelectOption",
                    Parent = gunDropdown,
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                    BorderSizePixel = 0,
                    Text = "  " .. gunName,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Color3.fromRGB(176, 176, 176),
                    FontFace = DESIGN_CONFIG.FontProfile,
                    AutoButtonColor = true,
                    ZIndex = 51
                })
                self:Stroke(gunBtn, { Color = Color3.fromRGB(14, 14, 14) })

                gunBtn.MouseButton1Click:Connect(function()
                    skinsControl.SelectedGun = gunName
                    selectGunBtn.Text = "Selected Gun: " .. gunName
                    toggleGunDropdown()
                    refreshSkins()
                end)
            end

            for idx, gunName in ipairs(gunNamesList) do
                createGunDropdownOption(gunName)
            end

            -- Search filter implementation
            skinSearch:GetPropertyChangedSignal("Text"):Connect(function()
                local query = skinSearch.Text:lower()
                for _, child in ipairs(skinHolder:GetChildren()) do
                    if child:IsA("GuiObject") and not child:IsA("UIGridLayout") then
                        if query == "" or child.Name:lower():find(query, 1, true) then
                            child.Visible = true
                        else
                            child.Visible = false
                        end
                    end
                end
            end)

            -- Apply button handler
            applyBtn.MouseButton1Click:Connect(function()
                local gun = skinsControl.SelectedGun
                local skin = skinsControl.SelectedSkin

                if gun ~= "None" and skin ~= "" then
                    -- Update the config table
                    skinsControl.Value[gun] = { Name = skin }
                    self.flags["gun_skin_settings"] = skinsControl.Value

                    self:Notify("Successfully applied " .. skin .. " to " .. gun .. "!", 4.5)
                    if skinsControl.OnSkinApplied then
                        pcall(skinsControl.OnSkinApplied, gun, skin)
                    end
                else
                    self:Notify("Please select both a gun and a skin first!", 4)
                end
            end)

            -- Programmatic skin adder API function
            function skinsControl:AddSkin(gunName, skinName, colorsTable)
                if not GUNS_DATABASE[gunName] then
                    GUNS_DATABASE[gunName] = {}
                    -- If it's a new gun not in the initial dropdown list, add it dynamically
                    if not table.find(gunNamesList, gunName) then
                        table.insert(gunNamesList, gunName)
                        createGunDropdownOption(gunName)
                    end
                end

                table.insert(GUNS_DATABASE[gunName], {
                    name = skinName,
                    colors = colorsTable or {Color3.fromRGB(120, 120, 120), Color3.fromRGB(60, 60, 60)}
                })

                -- Auto-refresh if the user is currently viewing this gun's skins
                if skinsControl.SelectedGun == gunName then
                    refreshSkins()
                end
            end

            function skinsControl:Set(val)
                if type(val) == "table" then
                    skinsControl.Value = val
                    pcall(function() self.flags["gun_skin_settings"] = val end)
                    refreshSkins()
                end
            end

            return skinsControl
        end

        function Library:AddSkin(gunName, skinName, colorsTable)
            if self.SkinsTab then
                self.SkinsTab:AddSkin(gunName, skinName, colorsTable)
            end
        end

        function Library:SaveConfig(name)
            local data = {}
            for flag, element in pairs(self.Elements) do
                if element.Mode ~= nil then -- Toggle
                    data[flag] = {
                        Type = "Toggle",
                        State = element.State,
                        Bind = Library:GetBindName(element.Bind),
                        Mode = element.Mode
                    }
                elseif element.Track ~= nil then -- Slider
                    data[flag] = {
                        Type = "Slider",
                        Value = element.Value
                    }
                elseif element._isMulti then -- MultiDropdown
                    data[flag] = {
                        Type = "MultiDropdown",
                        Value = element.Value
                    }
                elseif element.OptionInstances ~= nil then -- Dropdown
                    data[flag] = {
                        Type = "Dropdown",
                        Value = element.Value
                    }
                elseif element.BindingActive ~= nil then -- Keybind
                    data[flag] = {
                        Type = "Keybind",
                        Value = Library:GetBindName(element.Value),
                        Mode = element.Mode
                    }
                elseif element.CanvasDragging ~= nil then -- ColorPicker
                    data[flag] = {
                        Type = "ColorPicker",
                        Value = {element.Value.R, element.Value.G, element.Value.B},
                        Rainbow = element.Rainbow or false,
                        Speed = element.Speed or 1.0
                    }
                elseif element.InputBox ~= nil then -- TextBox
                    data[flag] = {
                        Type = "TextBox",
                        Value = element.Value
                    }
                elseif element.IsSkins ~= nil then -- Skins
                    data[flag] = {
                        Type = "Skins",
                        Value = element.Value
                    }
                end
            end

            if not isfolder(FOLDER_NAME) then
                makefolder(FOLDER_NAME)
            end

            local success, encoded = pcall(function()
                return HttpService:JSONEncode(data)
            end)

            if success then
                writefile(FOLDER_NAME .. "/" .. name .. ".json", encoded)
            else
                warn("Failed to encode configuration: " .. tostring(encoded))
            end
        end

        function Library:LoadConfig(name)
            local path = FOLDER_NAME .. "/" .. name .. ".json"
            if not isfile(path) then return end

            local success, content = pcall(readfile, path)
            if not success then return end

            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if not decodeSuccess then return end

            for flag, saved in pairs(data) do
                local element = self.Elements[flag]
                if element then
                    local isStructured = type(saved) == "table" and saved.Type ~= nil
                    if isStructured then
                        if saved.Type == "Toggle" then
                            if type(saved.State) == "boolean" then
                                element:Set(saved.State)
                            end
                            if saved.Bind then
                                local key = Library:ResolveBind(saved.Bind)
                                element:SetBind(key)
                            end
                            if saved.Mode then
                                element:SetMode(saved.Mode)
                            end
                        elseif saved.Type == "Slider" then
                            element:Set(saved.Value)
                        elseif saved.Type == "Dropdown" then
                            element:Set(saved.Value)
                        elseif saved.Type == "MultiDropdown" then
                            if type(saved.Value) == "table" then
                                element:Set(saved.Value)
                            end
                        elseif saved.Type == "Keybind" then
                            local key = Library:ResolveBind(saved.Value)
                            element:Set(key)
                            if saved.Mode then
                                element:SetMode(saved.Mode)
                            end
                        elseif saved.Type == "ColorPicker" then
                            if type(saved.Value) == "table" and #saved.Value == 3 then
                                local color = Color3.new(saved.Value[1], saved.Value[2], saved.Value[3])
                                element:Set(color)
                            end
                            if saved.Rainbow ~= nil then
                                element:SetRainbow(saved.Rainbow)
                            end
                            if saved.Speed ~= nil then
                                element:SetSpeed(saved.Speed)
                            end
                        elseif saved.Type == "TextBox" then
                            element:Set(saved.Value)
                        elseif saved.Type == "Skins" then
                            element:Set(saved.Value)
                        end
                    else
                        -- Flat format loading for robustness
                        if element.Mode ~= nil then
                            if type(saved) == "boolean" then
                                element:Set(saved)
                            end
                        elseif element.Track ~= nil then
                            if type(saved) == "number" then
                                element:Set(saved)
                            end
                        elseif element._isMulti then
                            if type(saved) == "table" then
                                element:Set(saved)
                            end
                        elseif element.OptionInstances ~= nil then
                            if type(saved) == "string" then
                                element:Set(saved)
                            end
                        elseif element.BindingActive ~= nil then
                            if type(saved) == "string" then
                                local key = Library:ResolveBind(saved)
                                element:Set(key)
                            end
                        elseif element.CanvasDragging ~= nil then
                            if type(saved) == "table" and #saved == 3 then
                                element:Set(Color3.new(saved[1], saved[2], saved[3]))
                            end
                        elseif element.InputBox ~= nil then
                            if type(saved) == "string" then
                                element:Set(saved)
                            end
                        end
                    end
                end
            end
            Library:UpdateKeybindList()
        end

        function Library:DeleteConfig(name)
            local path = FOLDER_NAME .. "/" .. name .. ".json"
            if isfile(path) then
                delfile(path)
            end
        end

        function Library:UpdateKeybindList()
            if not self.KeybindContainer then return end

            -- Clear old entries
            for _, child in ipairs(self.KeybindContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            -- Rebuild list of keybinds
            local seen = {}
            for flag, element in pairs(self.Elements) do
                if seen[element] then continue end
                seen[element] = true
                -- Toggle / Sub-component binds inside Toggles
                if element.Bind and element.Bind ~= Enum.KeyCode.Unknown then
                    local modeChar = "T"
                    if element.Mode == "Hold" then
                        modeChar = "H"
                    elseif element.Mode == "Always" then
                        modeChar = "A"
                    end

                    local name = element.Name or flag:gsub("_flag", ""):gsub("_", " "):gsub("^%l", string.upper)
                    local active = element.State or false
                    local text = string.format("[%s] %s -> %s", modeChar, name, Library:GetBindName(element.Bind))
                    local textColor = active and Color3.fromRGB(221, 50, 50) or Color3.fromRGB(176, 176, 176)

                    local bindFrame = self:NewInstance("Frame", {
                        Parent = self.KeybindContainer,
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0
                    })

                    local label = self:NewInstance("TextLabel", {
                        Parent = bindFrame,
                        Text = "  " .. text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = textColor,
                        TextStrokeTransparency = 0,
                        FontFace = DESIGN_CONFIG.FontProfile,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0)
                    })
                    self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })

                -- Standalone Keybind element
                elseif element.BindingActive ~= nil and element.Value and element.Value ~= Enum.KeyCode.Unknown then
                    local name = element.Name or flag:gsub("_flag", ""):gsub("_", " "):gsub("^%l", string.upper)
                    local active = element.ActiveState or false
                    local text = string.format("[K] %s -> %s", name, Library:GetBindName(element.Value))
                    local textColor = active and Color3.fromRGB(221, 50, 50) or Color3.fromRGB(176, 176, 176)

                    local bindFrame = self:NewInstance("Frame", {
                        Parent = self.KeybindContainer,
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0
                    })

                    local label = self:NewInstance("TextLabel", {
                        Parent = bindFrame,
                        Text = "  " .. text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = textColor,
                        TextStrokeTransparency = 0,
                        FontFace = DESIGN_CONFIG.FontProfile,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0)
                    })
                    self:NewInstance("UIStroke", { Parent = label, LineJoinMode = Enum.LineJoinMode.Miter })
                end
            end
        end

        function Library:Notify(text, duration)
            duration = duration or 5
            local tweenService = game:GetService("TweenService")

            local wrapperFrame = self:NewInstance("Frame", {
                Parent = self.NotificationsContainer,
                Size = UDim2.new(0, 259, 0, 24),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local notifFrame = self:NewInstance("CanvasGroup", {
                Parent = wrapperFrame,
                Size = UDim2.new(0, 259, 0, 24),
                Position = UDim2.new(0, 100, 0, 0),
                BackgroundColor3 = Color3.fromRGB(31, 31, 31),
                BorderSizePixel = 0,
                GroupTransparency = 1
            })

            self:Gradient(notifFrame)

            self:Stroke(notifFrame, { ZIndex = 2, Color = Color3.fromRGB(16, 16, 16) })

            local title = self:NewInstance("TextLabel", {
                Parent = notifFrame,
                Text = "  " .. text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(176, 176, 176),
                TextStrokeTransparency = 0,
                FontFace = DESIGN_CONFIG.FontProfile,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 8, 0, 0)
            })
            self:NewInstance("UIStroke", { Parent = title, LineJoinMode = Enum.LineJoinMode.Miter })
            self:Gradient(title)

            local accent = self:NewInstance("Frame", {
                Parent = notifFrame,
                ZIndex = 3,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(0, 2, 1, 0)
            })
            self:Gradient(accent, -180, GRADIENT_DIVIDER)

            local timerBar = self:NewInstance("Frame", {
                Parent = notifFrame,
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = self.Accent,
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -2)
            })
            self:Gradient(timerBar, 90, GRADIENT_DIVIDER)

            -- Fade in
            tweenService:Create(notifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                GroupTransparency = 0,
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()

            -- Shrink timer bar
            local timerTween = tweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
            timerTween:Play()

            task.delay(duration, function()
                local fadeTween = tweenService:Create(notifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    GroupTransparency = 1,
                    Position = UDim2.new(0, -300, 0, 0)
                })
                fadeTween:Play()

                local shrinkTween = tweenService:Create(wrapperFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 259, 0, 0)
                })
                shrinkTween:Play()

                fadeTween.Completed:Connect(function()
                    wrapperFrame:Destroy()
                end)
            end)
        end

        function Library:Toggle()
            local tweenService = game:GetService("TweenService")
            self.IsOpen = not self.IsOpen

            local targetTransparency = self.IsOpen and 0 or 1
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            if self.IsOpen then
                self.MainFrame.Visible = true
            end

            local tween = tweenService:Create(self.MainFrame, tweenInfo, { GroupTransparency = targetTransparency })
            local tweenx = tweenService:Create(self.MainStroke, tweenInfo, { Transparency = targetTransparency })
            tween:Play()
            tweenx:Play()
            tween.Completed:Connect(function()
                if not self.IsOpen then
                    self.MainFrame.Visible = false
                end
            end)
        end
    --
return Library
