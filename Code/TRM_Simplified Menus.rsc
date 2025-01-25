
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

Macro "Open Drive Network"
    AppendToLogFile(0, "Open Drive Network")
	mr = CreateObject("Model.Runtime")
	output_folder = mr.GetValue("Output Folder")
    lay = mr.GetValue("Road Line Layer")
    filt = mr.GetValue("Drive Filter")

    AppendToLogFile(1, "Road layer: " + lay + ", folder: " + output_folder + ", filter: " + filt)

    info = GetDBInfo(lay)
    map = CreateMap("Drive Network", {scope: info[1]})
    links = AddLayer(map, "Links", lay, "master_links", {"Read Only": true})
    nodes = AddLayer(map, "Nodes", lay, "master_nodes", {"Read Only": true})

    AppendToLogFile(1, "Read map data")

    // highlight the drive links
    SetView(links)
    driveLinks = CreateSet("Drive Links", {"Never Save": true})

    // several means new selection set (why?)
    SelectByQuery(driveLinks, "several", "SELECT * WHERE " + filt)

    AppendToLogFile(1, "Selected drive links")

    // hide everything
    SetDisplayStatus(, "Invisible")

    // show drive links
    SetDisplayStatus(driveLinks, "Active")

    AppendToLogFile(1, "Showed only drive links")

    // load network
    SetMapNetworkFileName(map, output_folder + "auto.net")
    ReadNetwork(output_folder + "auto.net")

    AppendToLogFile(1, "Read network")
endMacro

MenuItem "TRM_Simplified Menu Item" text: "TRM_Simplified"
    menu "TRM_Simplified Menu"

menu "TRM_Simplified Menu"
    /*init do
	runtimeObj = CreateObject("Model.Runtime")
	curr_param = runtimeObj.GetSelectedParamInfo() 
	menu_items = {"Open Drive Network"}
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
    enditem*/

    MenuItem "Open Drive Network" text: "Open Drive Network"
        do 
        RunMacro("Open Drive Network")
        enditem 

endMenu 
