-- Universal Roblox Flying Car Script for Delta Executor & Other Exploits
-- Works with any game! Copy and paste into executor console

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Get Player and Character
local PLAYER = Players.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local HUMANOID_ROOT_PART = CHARACTER:WaitForChild("HumanoidRootPart")

-- Configuration
local FLIGHT_SPEED = 50
local ACCELERATION = 2
local MAX_ALTITUDE = 500

-- State Variables
local isFlying = false
local currentSpeed = 0
local carVelocity = Vector3.new(0, 0, 0)
local guiElements = nil

-- Create BodyVelocity for flight physics
local function createFlightPhysics()
    -- Remove old BodyVelocity if exists
    local oldBV = HUMANOID_ROOT_PART:FindFirstChild("FlyingCarVelocity")
    if oldBV then oldBV:Destroy() end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyingCarVelocity"
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = HUMANOID_ROOT_PART
    return bodyVelocity
end

local bodyVelocity = createFlightPhysics()

-- Create Centered GUI
local function createGUI()
    local playerGui = PLAYER:WaitForChild("PlayerGui")
    
    -- Main Screen GUI (Centered)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalFlyingCarGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Panel (Centered in middle of screen)
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 350, 0, 400)
    mainPanel.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainPanel.BorderColor3 = Color3.fromRGB(0, 255, 100)
    mainPanel.BorderSizePixel = 2
    mainPanel.Parent = screenGui
    
    -- Add corner radius effect with UICorner
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainPanel
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 60)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    titleLabel.BackgroundTransparency = 0.1
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "🚗 FLYING CAR MODE"
    titleLabel.Parent = mainPanel
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 0, 90)
    statusLabel.Position = UDim2.new(0, 10, 0, 70)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusLabel.BackgroundTransparency = 0
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: INACTIVE\nSpeed: 0 / 50\nAltitude: 0\nMode: Grounded"
    statusLabel.TextWrapped = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = mainPanel
    
    -- Controls Label
    local controlsLabel = Instance.new("TextLabel")
    controlsLabel.Name = "Controls"
    controlsLabel.Size = UDim2.new(1, -20, 0, 120)
    controlsLabel.Position = UDim2.new(0, 10, 0, 170)
    controlsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    controlsLabel.BackgroundTransparency = 0
    controlsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    controlsLabel.TextSize = 11
    controlsLabel.Font = Enum.Font.Gotham
    controlsLabel.Text = \"CONTROLS:\n[F] Toggle Flight\n[W/A/S/D] Move\n[SPACE] Up\n[CTRL] Down\n[ESC] Close GUI\"\n    controlsLabel.TextWrapped = true\n    controlsLabel.TextXAlignment = Enum.TextXAlignment.Left\n    controlsLabel.TextYAlignment = Enum.TextYAlignment.Top\n    controlsLabel.Parent = mainPanel\n    \n    -- Toggle Flight Button\n    local toggleButton = Instance.new(\"TextButton\")\n    toggleButton.Name = \"ToggleButton\"\n    toggleButton.Size = UDim2.new(1, -20, 0, 50)\n    toggleButton.Position = UDim2.new(0, 10, 1, -60)\n    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)\n    toggleButton.BorderColor3 = Color3.fromRGB(200, 0, 0)\n    toggleButton.BorderSizePixel = 1\n    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)\n    toggleButton.TextSize = 16\n    toggleButton.Font = Enum.Font.GothamBold\n    toggleButton.Text = \"🔴 START FLYING (F)\"\n    toggleButton.Parent = mainPanel\n    \n    -- Button click functionality\n    toggleButton.MouseButton1Click:Connect(function()\n        toggleFlight()\n    end)\n    
    -- Draggable functionality\    local dragging = false\n    local dragStart = Vector3.new(0, 0, 0)\n    local panelStart = UDim2.new(0, 0, 0, 0)\n    \n    mainPanel.InputBegan:Connect(function(input, gameProcessed)\n        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < mainPanel.AbsolutePosition.Y + 60 then\n            dragging = true\n            dragStart = Vector3.new(input.Position.X, input.Position.Y, 0)\n            panelStart = mainPanel.Position\n        end\n    end)\n    \n    UserInputService.InputChanged:Connect(function(input, gameProcessed)\n        if dragging and input.UserInputType == Enum.UserInputType.Mouse then\n            local delta = Vector3.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y, 0)\n            mainPanel.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + delta.X, panelStart.Y.Scale, panelStart.Y.Offset + delta.Y)\n        end\n    end)\n    \n    UserInputService.InputEnded:Connect(function(input, gameProcessed)\n        if input.UserInputType == Enum.UserInputType.MouseButton1 then\n            dragging = false\n        end\n    end)\n    \n    return {\n        gui = screenGui,\n        mainPanel = mainPanel,\n        statusLabel = statusLabel,\n        toggleButton = toggleButton\n    }\nend\n\n-- Update GUI Display\nlocal function updateGUI()\n    if not guiElements then return end\n    \n    local altitude = math.floor(HUMANOID_ROOT_PART.Position.Y)\n    local speed = math.floor(currentSpeed)\n    local mode = isFlying and \"FLYING ✈️\" or \"Grounded\"\n    local status = isFlying and \"ACTIVE ✅\" or \"INACTIVE ⏸️\"\n    \n    guiElements.statusLabel.Text = string.format(\n        \"Status: %s\\nSpeed: %d / 50\\nAltitude: %d\\nMode: %s\",\n        status, speed, altitude, mode\n    )\n    \n    if isFlying then\n        guiElements.toggleButton.Text = \"🟢 STOP FLYING (F)\"\n        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)\n        guiElements.toggleButton.BorderColor3 = Color3.fromRGB(0, 150, 0)\n    else\n        guiElements.toggleButton.Text = \"🔴 START FLYING (F)\"\n        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)\n        guiElements.toggleButton.BorderColor3 = Color3.fromRGB(200, 0, 0)\n    end\nend\n\n-- Toggle Flight Mode\nfunction toggleFlight()\n    isFlying = not isFlying\n    if isFlying then\n        print(\"✅ Flying mode ACTIVATED!\")\n    else\n        print(\"❌ Flying mode DEACTIVATED!\")\n        currentSpeed = 0\n        bodyVelocity.Velocity = Vector3.new(0, 0, 0)\n    end\nend\n\n-- Handle Input\nlocal function setupInput()\n    UserInputService.InputBegan:Connect(function(input, gameProcessed)\n        if input.KeyCode == Enum.KeyCode.F then\n            toggleFlight()\n        elseif input.KeyCode == Enum.KeyCode.Escape then\n            if guiElements and guiElements.gui then\n                guiElements.gui:Destroy()\n                guiElements = nil\n                print(\"GUI Closed\")\n            end\n        end\n    end)\nend\n\n-- Flight Physics\nlocal function updateFlight()\n    if not isFlying or not HUMANOID_ROOT_PART then\n        return\n    end\n    \n    local moveDirection = Vector3.new(0, 0, 0)\n    local camera = workspace.CurrentCamera\n    \n    -- Forward/Backward\n    if UserInputService:IsKeyDown(Enum.KeyCode.W) then\n        moveDirection = moveDirection + camera.CFrame.LookVector\n    end\n    if UserInputService:IsKeyDown(Enum.KeyCode.S) then\n        moveDirection = moveDirection - camera.CFrame.LookVector\n    end\n    \n    -- Left/Right\n    if UserInputService:IsKeyDown(Enum.KeyCode.A) then\n        moveDirection = moveDirection - camera.CFrame.RightVector\n    end\n    if UserInputService:IsKeyDown(Enum.KeyCode.D) then\n        moveDirection = moveDirection + camera.CFrame.RightVector\n    end\n    \n    -- Normalize and apply speed\n    if moveDirection.Magnitude > 0 then\n        currentSpeed = math.min(currentSpeed + ACCELERATION, FLIGHT_SPEED)\n        moveDirection = moveDirection.Unit * currentSpeed\n    else\n        currentSpeed = math.max(currentSpeed - ACCELERATION, 0)\n        moveDirection = moveDirection.Unit * currentSpeed\n    end\n    \n    -- Vertical movement\n    local verticalMovement = 0\n    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then\n        verticalMovement = FLIGHT_SPEED / 2\n    end\n    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then\n        verticalMovement = -FLIGHT_SPEED / 2\n    end\n    \n    -- Apply velocity\n    carVelocity = Vector3.new(moveDirection.X, verticalMovement, moveDirection.Z)\n    bodyVelocity.Velocity = carVelocity\n    \n    -- Altitude limit\n    if HUMANOID_ROOT_PART.Position.Y > MAX_ALTITUDE then\n        HUMANOID_ROOT_PART.CFrame = CFrame.new(HUMANOID_ROOT_PART.Position.X, MAX_ALTITUDE, HUMANOID_ROOT_PART.Position.Z)\n    end\nend\n\n-- Main Initialization\nlocal function init()\n    print(\"🚗 Universal Flying Car Script Loaded!\")\n    print(\"Press F to toggle flight | ESC to close GUI\")\n    \n    -- Create and setup GUI\n    guiElements = createGUI()\n    \n    -- Setup input\n    setupInput()\n    \n    -- Main update loop\n    RunService.RenderStepped:Connect(function()\n        if CHARACTER and HUMANOID_ROOT_PART then\n            updateFlight()\n            updateGUI()\n        end\n    end)\n    \n    -- Handle character respawn\n    PLAYER.CharacterAdded:Connect(function(newCharacter)\n        CHARACTER = newCharacter\n        HUMANOID_ROOT_PART = CHARACTER:WaitForChild(\"HumanoidRootPart\")\n        bodyVelocity = createFlightPhysics()\n        isFlying = false\n        currentSpeed = 0\n        print(\"🔄 Character respawned! Script reinitialized.\")\n    end)\nend\n\ninit()\n