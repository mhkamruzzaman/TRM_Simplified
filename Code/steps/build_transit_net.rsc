macro "Build Transit Network for Period" (route_system, output_folder, period)
    AppendToLogFile(0, "Build Transit Network, " + period + " period")
    AppendToLogFile(1, "Route system: " + route_system)

    out_network = output_folder + "transit_" + period + ".tnw"
    AppendToLogFile(1, "Output: " + out_network)

    o = CreateObject("Network.CreatePublic")
    o.LayerRS = route_system
    o.OutNetworkName = out_network
    o.StopToNodeTagField = "Node_ID"
    o.RouteFilter = period + "Headway > 0"
    o.StopFilter = "Node_ID <> null"
    o.IncludeWalkLinks = true
    o.WalkLinkFilter = "DTWB contains 'W'"
    o.IncludeDriveLinks = false

    o.AddRouteField({Name: "Headway", Field: period + "Headway"})
    o.AddLinkField({Name: "Length", TransitFields: "Length", NonTransitFields: "Length"})
    o.AddLinkField({Name: "Time", TransitFields: {"ABBusTime" + period, "BABusTime" + period}, NonTransitFields: "WalkTime"})
    o.AddNodeField({Name: "Centroid", Field: "Centroid"})

    o.Run()

    AppendToLogFile(1, "Done")
endmacro

macro "Build Transit Networks" (Args)
    Data:
        In({Args.[Transit Route System]})
        In({Args.[Road Line Layer]})
        In({Args.[Output Folder]})
        In({Args.[Bus Speed Table]})

    Body:

    RunMacro("Calculate Bus Speeds", Args.[Road Line Layer], Args.[Bus Speed Table])

    for period in {"AM", "MD", "PM", "NT"} do
        RunMacro("Build Transit Network for Period", Args.[Transit Route System], Args.[Output Folder], period)
    end

    return(true)
endmacro