
Class "Visualize.Menu.Items"
EndClass


Macro "Open Drive Network" (Args,Result)
Body:
    AppendToLogFile(0, "Open Drive Network")
	mr = CreateObject("Model.Runtime")
    lay = mr.GetValue("Road Line Layer")
    filt = mr.GetValue("Drive Filter")
    output_folder = mr.GetResults().[Output Folder]

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
    RunMacro("TCU set network", output_folder + "auto.net")
    SetMapNetworkFileName(map, output_folder + "auto.net")

    AppendToLogFile(1, "Read network")
EndMacro


Macro "Open Transit Network" (period)
Body:

    AppendToLogFile(0, "Open Drive Network")
	mr = CreateObject("Model.Runtime")
    lay = mr.GetValue("Road Line Layer")
    rs = mr.GetValue("Transit Route System")
    output_folder = mr.GetResults().[Output Folder]

    AppendToLogFile(1, "Road layer: " + lay + ", route system: " + rs + ", folder: " + output_folder + ", filter: " + filt)

    info = GetDBInfo(lay)
    map = CreateMap("Transit Network, " + period, {scope: info[1]})
    links = AddLayer(map, "Links", lay, "master_links", {"Read Only": true})
    nodes = AddLayer(map, "Nodes", lay, "master_nodes", {"Read Only": true})
    routes = AddLayer(map, "Routes", rs, "scenario_routes", {"Read Only": true})
    stops = AddLayer(map, "Stops", rs, "scenario_stops", {"Read Only": true})

    AppendToLogFile(1, "Read map data")

    // highlight the drive links
    SetView(links)
    walkLinks = CreateSet("Walk Links", {"Never Save": true})

    // several means new selection set (why?)
    SelectByQuery(walkLinks, "several", "SELECT * WHERE DTWB CONTAINS 'w'")

    AppendToLogFile(1, "Selected walk links")

    // hide everything
    SetDisplayStatus(, "Invisible")

    // show drive links
    SetDisplayStatus(walkLinks, "Active")

    AppendToLogFile(1, "Showed only walk links")

    // highlight the active routes
    SetView(routes)
    activeRoutes = CreateSet("Active Routes", {"Never Save": true})
    SelectByQuery(activeRoutes, "several", "SELECT * WHERE " + period + "Headway > 0")

    SetDisplayStatus(, "Invisible")
    SetDisplayStatus(activeRoutes, "Active")

    AppendToLogFile(1, "Showed only active links")

    // highlight active stops
    SetView(stops)
    linkedStops = CreateSet("Linked Stops", {"Never Save": true})
    SelectByQuery(linkedStops, "several", "SELECT * WHERE Node_ID <> null")

    SetDisplayStatus(, "Invisible")
    SetDisplayStatus(linkedStops, "Active")

    AppendToLogFile(1, "Showed only linked stops")


    // load network
    netfile = output_folder + "transit_" + period + ".tnw"
    RunMacro("TCU set network", netfile)
    SetMapNetworkFileName(map, netfile)

    AppendToLogFile(1, "Read network")

EndMacro


MenuItem "TRM_Simplified Menu Item" text: "TRM Simplified"
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

    MenuItem "Advanced Utilities" text: "Advanced Utilities"
        menu "Advanced Utilities Menu"
endMenu 
menu "Advanced Utilities Menu"
    MenuItem "Convert TRMG2 results to CSV and OMX" dbox "Convert TRMG2 results to CSV and OMX"

endmenu
        // find the macro inside the model UI DB
        // Ex means do not need scenario specified



