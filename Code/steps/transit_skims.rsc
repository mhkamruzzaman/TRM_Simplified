macro "Transit Skims for Period" (network, route_system, period, outfile)
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    o = CreateObject("Network.PublicTransportSkims")
    o.LayerRS = route_system
    o.Network = network
    o.OriginFilter = "Centroid <> null"
    o.DestinationFilter = "Centroid <> null"
    o.SkimVariables = {"Generalized Cost", "Total Time"}
    o.OutputMatrix({MatrixFile: outfile, MatrixLabel: period + " Transit"})
    o.Run()

    // Intrazonal times (apply to both generalized cost and total time)
    for skimvar in {"Generalized Cost", "Total Time"} do
        AppendToLogFile(3, "Calculating intrazonal times for " + skimvar)
        iz = CreateObject("Distribution.Intrazonal")
        iz.OperationType = "Replace"
        iz.TreatMissingAsZero = false
        iz.Neighbors = 3
        iz.Factor = 0.75
        iz.SetMatrix(outfile, skimvar)
        iz.Run()
    end
endmacro

macro "Calculate Transit Skims" (Args, Result)
    Data:
        In({Args.[Output Folder]})
        In({Args.[Transit Route System]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Calculating Transit Skims")

    for period in {"AM", "MD", "PM", "NT"} do
        AppendToLogFile(1, period)
        RunMacro("Transit Skims for Period",
            Args.[Output Folder] + "transit_" + period + ".tnw",
            Args.[Transit Route System],
            period,
            Args.[Output Folder] + "transit_skims_" + period + ".mtx"
        )
    end

    return(true)
endmacro