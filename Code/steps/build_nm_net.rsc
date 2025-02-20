/*
Build nonmotorized networks. Must be run _after_ Build Transit Network, as the bike speed and walk speed are computed there
*/
macro "Build Nonmotorized Networks" (Args)
    Data:
        In({Args.[Output Folder]})
        In({Args.[Bike Speed MPH]})
        In({Args.[Walk Speed MPH]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Build nonmotorized networks")
    AppendToLogFile(1, "Build walk network")
    roads = RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"})
    walknet = RunMacro("Join Path", {Args.[Output Folder], "walk.net"})
    RunMacro("Build NM network", roads, "Walk", "DTWB contains 'W'", "WalkTime", walknet)

    AppendToLogFile(1, "Build bike network")
    bikenet = RunMacro("Join Path", {Args.[Output Folder], "bike.net"})
    RunMacro("Build NM network", roads, "Bike", "DTWB contains 'B'", "BikeTime", bikenet)

    return(true)
endmacro

/*
 * Build either the walk or bike networks. Both are very simple and just assume a constant speed, so code re-use works fine
 */
macro "Build NM network" (linelayer, mode, filter, speedcol, output)
        // build the network
    // Modified from tRMG2 code
    o = CreateObject("Network.Create")
    o.LayerDB = linelayer
    o.Filter = filter
    o.LengthField = "Length"
    
    o.AddLinkField({Name: "Time", Field: speedcol, IsTimeField: true})

    o.AddNodeField({Name: "Centroid", Field: "Centroid"})

    o.OutNetworkName = output
    o.Run()

    AppendToLogFile(1, "Network built")

    AppendToLogFile(1, "Creating map file")
    RunMacro("Create Road Network Map", linelayer, mode, filter,
    output, output.replace("net$", "map"))

    return(true)
endmacro
