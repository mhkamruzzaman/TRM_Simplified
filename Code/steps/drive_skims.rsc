macro "Calculate Drive Skim for Period" (netfile, linelayer, period, outfile)
    AppendToLogFile(2, "Network: " + netfile)
    AppendToLogFile(2, "Line layer: " + linelayer)
    AppendToLogFile(2, "Output file: " + outfile)

    AppendToLogFile(2, "Calculating skims")

    s = CreateObject("Network.Skims")
    s.Network = netfile
    s.LayerDB = linelayer // not documented but in the example
    s.Origins = "Centroid <> null"
    s.Destinations = "Centroid <> null"
    s.Minimize = "Time" + period
    s.AddSkimField({"Time" + period, "All"})
    s.AddSkimField({"Length", "All"})
    s.OutputMatrix({MatrixFile: outfile, Matrix: period + " Auto"})
    s.Run()

    AppendToLogFile(2, "Calculating intrazonal times")

    iz = CreateObject("Distribution.Intrazonal")
    iz.OperationType = "Replace"
    iz.TreatMissingAsZero = false
    iz.Neighbors = 3
    iz.Factor = 0.75
    iz.SetMatrix(outfile, "Time" + period)
    iz.Run()

    AppendToLogFile(2, "Done")
endmacro

macro "Calculate All Drive Skims" (Args, Result)
    Data:
        In({Args.[Output Folder]})
    Body:
    AppendToLogFile(0, "Drive Skims")
    for period in {"AM", "MD", "PM", "NT"} do
        AppendToLogFile(1, period)
        RunMacro("Calculate Drive Skim for Period",
            Args.[Output Folder] + "auto.net",
            RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"}),
            period,
            Args.[Output Folder] + "auto_skims_" + period + ".mtx"
        )
    end

    return(true)
endmacro