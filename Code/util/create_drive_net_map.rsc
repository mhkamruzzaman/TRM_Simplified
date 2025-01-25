// Create a map file for the drive network
macro "Create Drive Network Map" (line_layer, filter, netfile, outfile)
    AppendToLogFile(2, "Create Drive Network Map")

    info = GetDBInfo(line_layer)
    map = CreateMap("Drive Network", {scope: info[1]})
    links = AddLayer(map, "Links", line_layer, "master_links", {"Read Only": true})
    nodes = AddLayer(map, "Nodes", line_layer, "master_nodes", {"Read Only": true})

    AppendToLogFile(3, "Read map data")

    // highlight the drive links
    SetView(links)
    driveLinks = CreateSet("Drive Links")

    // several means new selection set (why?)
    SelectByQuery(driveLinks, "several", "SELECT * WHERE " + filter)

    AppendToLogFile(3, "Selected drive links")

    // hide everything
    SetDisplayStatus(, "Invisible")

    // show drive links
    SetDisplayStatus(driveLinks, "Active")

    AppendToLogFile(3, "Showed only drive links")

    // load network
    SetMapNetworkFileName(map, netfile)

    AppendToLogFile(3, "Stored network")

    SaveMap(map, outfile)

    AppendToLogFile(3, "Saved map")

    CloseMap(map)
endmacro