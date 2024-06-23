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
local publishItem = toolbar:CreateButton("Upload package", "Upload package", "rbxassetid://18182974747")
enterIdButton.ClickableWhenViewportHidden = true

local httpService = game:GetService("HttpService")

local widget = plugin:CreateDockWidgetPluginGui("Libraries", widgetInfo)
widget.Title = "Libraries"

local submitWidget = plugin:CreateDockWidgetPluginGui("Submit", widgetInfo)
submitWidget.Title = "Submit"

local UI : Frame = script.Parent.UI:WaitForChild("EnterID")
UI.Parent = widget

local SubmitUI: Frame = script.Parent.UI:WaitForChild("SubmitUI")
SubmitUI.Parent = submitWidget

enterIdButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

local connection
local selection = game:GetService("Selection")

publishItem.Click:Connect(function()
    submitWidget.Enabled = not submitWidget.Enabled
    if submitWidget.Enabled == true then
        connection = selection.SelectionChanged:Connect(function()
            local package = selection:Get()[1]
            if not package then
                SubmitUI.YourName.Visible = false
                SubmitUI.Description.Visible = false
                SubmitUI.Submitted.Visible = false
                SubmitUI.Title2.Visible = false
                SubmitUI.Submit.Visible = false
                SubmitUI.Selected.Text = "[Nothing Selected]"
            else
                SubmitUI.Selected.Text = package.Name
                SubmitUI.YourName.Visible = true
                SubmitUI.Description.Visible = true
                SubmitUI.Title2.Visible = true
                SubmitUI.Submit.Visible = true
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
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