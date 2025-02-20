macro "Assignment" (Args)
    Data:
    In({Args.[Output Folder]})

    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Assignment")

    for period in {"AM", "MD", "PM", "NT"} do
        AppendToLogFile(1, "Assignment for period "+ period)
        o = CreateObject("Network.Assignment")
        o.ResetClasses() // in example
        o.DemandMatrix(RunMacro("Join Path", {Args.[Output Folder], "hourly_vehicle_trips_" + period + ".mtx"}))
        o.LoadNetwork(RunMacro("Join Path", {Args.[Output Folder], "auto.net"}))
        o.LayerDB = RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"})
        o.FlowTable = RunMacro("Join Path", {Args.[Output Folder], "link_flows_" + period + ".bin"})
        o.DelayFunction = { // copied from TRMG2
            Function: "bpr.vdf",
            Fields: {"FFTime", "Capacity", "Alpha", "Beta", "None"}
        }
        o.AddClass({Demand: "Vehicle Trips"})
        o.Run()
    end

    return(true)


endmacro