
Class "Visualize.Menu.Items"

    init do 
        self.runtimeObj = CreateObject("Model.Runtime")
    enditem 
    
    Macro "GetMenus" do
        Menus = {
					{ ID: "M1", Title: "Show Selected Param Info" , Macro: "SelectedParamInfo" }
				}
        Return(Menus)
    enditem 

    Macro "SelectedParamInfo" do
        ShowArray({ SelectedParamInfo: self.runtimeObj.GetSelectedParamInfo() })
        enditem  
 
endClass 

Macro "OpenParamFile"
	mr = CreateObject("Model.Runtime")
	curr_param = mr.GetSelectedParamInfo()
	result = mr.OpenFile(curr_param.Name)
endMacro

MenuItem "TRM_Simplified Menu Item" text: "TRM_Simplified"
    menu "TRM_Simplified Menu"

menu "TRM_Simplified Menu"
    init do
	runtimeObj = CreateObject("Model.Runtime")
	curr_param = runtimeObj.GetSelectedParamInfo() 
	menu_items = {"Show Map", "Show Matrix", "Show Table"}
	if curr_param = null then
		DisableItems(menu_items)
	status = curr_param.Status
	if status = "Missing" then DisableItems(menu_items)
	else if status = "Exists" then do
		type = curr_param.Type
		if type = "NETWORK" then type = "MAP"
		menu_item = "Show " + Proper(type)
		DisableItems(menu_items)
		EnableItem(menu_item)
		end
    enditem

    MenuItem "Show Map" text: "Show Map"
        do 
        RunMacro("OpenParamFile")
        enditem 

    MenuItem "Show Matrix" text: "Show Matrix"
        do 
        RunMacro("OpenParamFile")
        enditem 

    MenuItem "Show Table" text: "Show Table"
        do 
        RunMacro("OpenParamFile")
        enditem 

endMenu 
