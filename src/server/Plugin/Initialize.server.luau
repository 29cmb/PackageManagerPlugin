local widgetInfo  = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left,
	false,
	false,
	100,
	500,
	75,
    300
)

local apiURL = "libapi.devcmb.online"
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
    httpService:PostAsync(apiURL .. "/download", httpService:JSONEncode({
        ["ID"] = UI.PackageName.Text
    }))
end)