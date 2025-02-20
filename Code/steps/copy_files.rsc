Macro "Copy Files" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Road Line Layer]})
    In({Args.[Transit Route System]})

    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Copy Files")
    AppendToLogFile(1, "Copying network")
    rn = RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"})
    CopyDatabase(Args.[Road Line Layer], rn)

    AppendToLogFile(1, "Loading route system " + Args.[Transit Route System])
    dm = CreateObject("DataManager")
    dm.AddDataSource("rts", {DataType: "RS", FileName: Args.[Transit Route System]})
    
    AppendToLogFile(1, "Copying route system")
    routes = RunMacro("Join Path", {Args.[Output Folder], "transit_network.rts"})
    dm.CopyRouteSystem("rts", {
        TargetRS: routes
    })

    AppendToLogFile(1, "Updating route system")
    ModifyRouteSystem(routes, {{"Geography", rn, "master_links"}})

    AppendToLogFile(1, "Setting initial speeds")
    RunMacro("Calculate Initial Speeds", rn)

    return(true)
endmacro