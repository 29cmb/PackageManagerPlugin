local widgetInfo  = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left,
	false,
	false,
	100,
	500,
	75,
    300
)

local apiURL = "https://libapi.devcmb.online"
local serializer = require(script.Parent.Framework.Serializer)

local toolbar = plugin:CreateToolbar("Library Manager")
local enterIdButton = toolbar:CreateButton("Enter ID from website", "Enter ID from website", "rbxassetid://395920720")
enterIdButton.ClickableWhenViewportHidden = true

local httpService = game:GetService("HttpService")

local widget = plugin:CreateDockWidgetPluginGui("Libraries", widgetInfo)
widget.Title = "Libraries"

local UI : Frame = script.Parent.UI:WaitForChild("EnterID")
UI.Parent = widget

enterIdButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)


UI.LoadPackage.MouseButton1Click:Connect(function()
    local response = httpService:PostAsync(apiURL .. "/download", httpService:JSONEncode({
        ["ID"] = UI.PackageName.Text
    }))

    local decoded = httpService:JSONDecode(response)
    if decoded then
        local packages
        if game.ReplicatedStorage:FindFirstChild("LibMgrPackages") then
            packages = game.ReplicatedStorage:FindFirstChild("LibMgrPackages")
        else
            packages = Instance.new("Folder", game.ReplicatedStorage)
            packages.Name = "LibMgrPackages"
        end

        serializer:Deserialize(decoded, packages)
    end
end)