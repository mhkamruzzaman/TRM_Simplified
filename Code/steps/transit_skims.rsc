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
    // TODO FIXME: why are there some cells where total time is null but generalized cost is not, or transfers is not.
    // shouldn't the nulls match?
    // Appears to only be on-diagonal elements. Something to do with IZ trip factoring.
    o.SkimVariables = {"Generalized Cost", "Total Time", "Number of Transfers"}
    o.OutputMatrix({MatrixFile: outfile, MatrixLabel: period + " Transit"})
    o.Run()

    // Intrazonal times (apply to both generalized cost and total time)
    // Currently removed from calculation - see FIXME above
    /*
    for skimvar in {"Generalized Cost", "Total Time", "Number of Transfers"} do
        AppendToLogFile(3, "Calculating intrazonal times for " + skimvar)
        iz = CreateObject("Distribution.Intrazonal")
        iz.OperationType = "Replace"
        iz.TreatMissingAsZero = false
        iz.Neighbors = 3
        iz.Factor = 0.75
        iz.SetMatrix(outfile, skimvar)
        iz.Run()
    end
    */

    // Availability
    mtx = OpenMatrix(outfile, )
    AddMatrixCore(mtx, "Available")
    time = CreateMatrixCurrency(mtx, "Total Time",,,)
    av = CreateMatrixCurrency(mtx, "Available",,,)
    av := if time = null then 0 else 1
endmacro

macro "Calculate Transit Skims" (Args, Result)
    Data:
        In({Args.[Output Folder]})
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
            RunMacro("Join Path", {Args.[Output Folder], "transit_network.rts"}),
            period,
            Args.[Output Folder] + "transit_skims_" + period + ".mtx"
        )
    end

    return(true)
endmacro