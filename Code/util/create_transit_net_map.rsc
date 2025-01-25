
macro "Create Transit Net Map" (line_layer, route_system, period, netfile, outfile)
    AppendToLogFile(2, "Create Transit Network Map, " + period)

    info = GetDBInfo(line_layer)
    map = CreateMap("Transit Network, " + period, {scope: info[1]})
    links = AddLayer(map, "Links", line_layer, "master_links", {"Read Only": true})
    nodes = AddLayer(map, "Nodes", line_layer, "master_nodes", {"Read Only": true})
    AppendToLogFile(3, "Read road network line layer")

    rs_layers = AddRouteSystemLayer(map, "Routes", route_system, {"ReadOnly": true})

    AppendToLogFile(3, "Read transit route system data")

    // highlight the walk links
    SetView(links)
    walkLinks = CreateSet("Walk Links", {"Never Save": true})

    // several means new selection set (why?)
    SelectByQuery(walkLinks, "several", "SELECT * WHERE DTWB contains 'W'")

    AppendToLogFile(3, "Selected walk links")

    // hide everything
    SetDisplayStatus(, "Invisible")

    // show drive links
    SetDisplayStatus(walkLinks, "Active")

    AppendToLogFile(3, "Showed only walk links")

    // highlight the active routes
    SetView(rs_layers[1])
    activeRoutes = CreateSet("Active Routes", {"Never Save": true})
    SelectByQuery(activeRoutes, "several", "SELECT * WHERE " + period + "Headway > 0")

    SetDisplayStatus(, "Invisible")
    SetDisplayStatus(activeRoutes, "Active")

    AppendToLogFile(3, "Showed only active links")

    // highlight active stops
    SetView(rs_layers[2])
    linkedStops = CreateSet("Linked Stops", {"Never Save": true})
    SelectByQuery(linkedStops, "several", "SELECT * WHERE Node_ID <> null")

    SetDisplayStatus(, "Invisible")
    SetDisplayStatus(linkedStops, "Active")

    AppendToLogFile(3, "Showed only linked stops")
    // load network
    SetMapNetworkFileName(map, netfile)

    AppendToLogFile(3, "Set network")

    SaveMap(map, outfile)

    AppendToLogFile(3, "Saved map")

    CloseMap(map)
endmacro