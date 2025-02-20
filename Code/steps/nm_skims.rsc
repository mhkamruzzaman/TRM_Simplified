macro "Calculate Nonmotorized Skims" (Args)
    Data:
        In({Args.[Output Folder]})
    Body:

    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Nonmotorized Skims")
    roads = RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"})

    AppendToLogFile(1, "Bike Skims")
    bikenet = RunMacro("Join Path", {Args.[Output Folder], "bike.net"})
    bikeskim = RunMacro("Join Path", {Args.[Output Folder], "bike_skims_All.mtx"})
    RunMacro("Calculate Nonmotorized Skim", bikenet, roads, bikeskim, "Bike")

    AppendToLogFile(1, "Walk Skims")
    walknet = RunMacro("Join Path", {Args.[Output Folder], "walk.net"})
    walkskim = RunMacro("Join Path", {Args.[Output Folder], "walk_skims_All.mtx"})
    RunMacro("Calculate Nonmotorized Skim", walknet, roads, walkskim, "Walk")

    return(true)
endmacro

macro "Calculate Nonmotorized Skim" (netfile, linelayer, outfile, mode)
    AppendToLogFile(2, "Network: " + netfile)
    AppendToLogFile(2, "Line layer: " + linelayer)
    AppendToLogFile(2, "Output file: " + outfile)

    AppendToLogFile(2, "Calculating skims")

    s = CreateObject("Network.Skims")
    s.Network = netfile
    s.LayerDB = linelayer // not documented but in the example
    s.Origins = "Centroid <> null"
    s.Destinations = "Centroid <> null"
    s.Minimize = "Time"
    s.AddSkimField({"Time", "All"})
    s.AddSkimField({"Length", "All"})
    s.OutputMatrix({MatrixFile: outfile, Matrix: mode})
    s.Run()

    AppendToLogFile(2, "Calculating intrazonal times")

    iz = CreateObject("Distribution.Intrazonal")
    iz.OperationType = "Replace"
    iz.TreatMissingAsZero = false
    iz.Neighbors = 3
    iz.Factor = 0.75
    iz.SetMatrix(outfile, "Time")
    iz.Run()

    AppendToLogFile(2, "Done")
endmacro