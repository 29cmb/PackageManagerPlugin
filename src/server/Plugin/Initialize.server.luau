--!nocheck
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
local browseButton = toolbar:CreateButton("Browse", "Find libraries", "rbxassetid://18190464760")
browseButton.ClickableWhenViewportHidden = true
enterIdButton.ClickableWhenViewportHidden = true

local httpService = game:GetService("HttpService")

local widget = plugin:CreateDockWidgetPluginGui("Libraries", widgetInfo)
widget.Title = "Libraries"

local submitWidget = plugin:CreateDockWidgetPluginGui("Submit", widgetInfo)
submitWidget.Title = "Submit"

local browseWidget = plugin:CreateDockWidgetPluginGui("Browse", widgetInfo)
browseWidget.Title = "Browse"

local UI : Frame = script.Parent.UI:WaitForChild("EnterID")
UI.Parent = widget

local SubmitUI: Frame = script.Parent.UI:WaitForChild("SubmitUI")
SubmitUI.Parent = submitWidget

local LibrariesUI: Frame = script.Parent.UI:WaitForChild("LibrariesUI")
LibrariesUI.Parent = browseWidget

enterIdButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)
local selection = game:GetService("Selection")

publishItem.Click:Connect(function()
    submitWidget.Enabled = not submitWidget.Enabled
end)

browseButton.Click:Connect(function()
    browseWidget.Enabled = not browseWidget.Enabled

    if browseWidget.Enabled == true then
        refresh()
    end
end)

local installConnections = {}

function refresh()
    for _,v in pairs(LibrariesUI.Libraries:GetChildren()) do
        if v:IsA("Frame") and v.Name ~= "Template" then
            v:Destroy()
        end
    end

    local libs = httpService:GetAsync(apiURL .. "/libs")
    libs = httpService:JSONDecode(libs)

    if not libs then return end

    for _,library in pairs(libs) do
        local template = LibrariesUI.Libraries.Template:Clone()
        template.Parent = LibrariesUI.Libraries
        template.Visible = true
        template.Name = "Library"
        template.Title.Text = library.Name
        template.Description.Text = library.Description
        template.Author.Text = "Made by " .. library.Author

        table.insert(installConnections, template.Install.MouseButton1Click:Connect(function()
            local location
            if game.ReplicatedStorage:FindFirstChild("LibMgrPackages") then
                location = game.ReplicatedStorage:FindFirstChild("LibMgrPackages")
            else
                location = Instance.new("Folder", game.ReplicatedStorage)
                location.Name = "LibMgrPackages"
            end

            local DeserializedLib = serializer:Deserialize(library.Serialized, location)

            if DeserializedLib:IsA("BaseScript") then
                plugin:OpenScript(DeserializedLib)
            else
                selection:Add({DeserializedLib})
            end

            browseWidget.Enabled = false
        end))
    end
    
end

refresh()
local function selectionChange()
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
end

selection.SelectionChanged:Connect(selectionChange)
selectionChange()

local debounce = false
SubmitUI.Submit.MouseButton1Click:Connect(function()
    if debounce == false then
        debounce = true
        local Author = SubmitUI.YourName
        local Description = SubmitUI.Description
        local Package = selection:Get()[1]

        if not Package then return end

        local success, err = pcall(function()
            httpService:PostAsync(apiURL .. "/postLib", httpService:JSONEncode({
                ["Name"] = Package.Name,
                ["Author"] = Author.Text,
                ["Description"] = Description.Text,
                ["Serialized"] = httpService:JSONEncode(serializer:Serialize(Package))
            }))
        end)

        if not success then
            warn("Could not upload package:", err)
            SubmitUI.Submitted.Text = "Error submitting package"
            SubmitUI.Submitted.Visible = true
            debounce = false
        else
            SubmitUI.Submitted.Text = "Submitted Successfully! Cooldown active."
            SubmitUI.Submitted.Visible = true
            task.delay(30, function()
                debounce = false
            end)
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