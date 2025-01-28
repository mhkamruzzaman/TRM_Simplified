DBox "Update Bus Speeds UI" title: "Update Bus Speeds"
    Button "Scenario Highway Line Layer" 0, after do
        scen_dbd = ChooseFile({{"Line layer", "*.dbd"}}, "Choose Scenario Highway Line Layer", null)
    enditem

    Edit Text "Scenario Highway Line Layer" after, same variable: scen_dbd

    Button "Bus Speeds CSV" 0, after do
        speed_csv = ChooseFile({{"CSV file", "*.csv"}}, "Choose Bus Speeds CSV", null)
    enditem

    Edit Text "Bus Speeds CSV" after, same variable: speed_csv

    Button "OK" 0, after default do
        RunMacro("Calculate Bus Speeds", scen_dbd, speed_csv)
        return()
    endItem

    Button "Cancel" after, same cancel do
        return()
    endItem
enddbox

/*
Calculate bus speeds as a fraction of auto speeds, based on roadway type, using a simplified version
of the factors used in the TRMG2 model (not using area type though). Also calculate walk and bike speeds.
*/
Macro "Calculate Bus Speeds" (out_dbd, speed_table, walk_speed, bike_speed)
    {nlyr, llyr} = GetDBLayers(out_dbd)
    llyr = AddLayerToWorkspace(llyr, out_dbd, llyr)  

    speed_table = OpenTable("speed_table", "CSV", {speed_table,})

    a_fields = {
        {"ABBusTimeAM", "Real", 10, 2, , , , 
            "Bus time in the AM period (minutes).|Updated after each assignment."},
        {"BABusTimeAM", "Real", 10, 2, , , , 
                   "Bus time in the AM period (minutes).|Updated after each assignment."}
    }

    for period in {"MD", "PM", "NT"} do
        a_fields = a_fields + {{"ABBusTime" + period, "Real", 10, 2, , , , 
            "Bus time in the " + period + " period (minutes).|Updated after each assignment."},
         {"BABusTime" + period, "Real", 10, 2, , , , 
            "Bus time in the " + period + " period (minutes).|Updated after each assignment."}}
    end

    a_fields = a_fields + {{"WalkTime", "Real", 10, 2, , , , "Walk time"}}
    a_fields = a_fields + {{"BikeTime", "Real", 10, 2, , , , "Bike time"}}

    RunMacro("Add Fields", {
        view: llyr,
        a_fields: a_fields,
        initial_value: {0}
    })

    {, speed_specs} = RunMacro("Get Fields", {view_name: speed_table})
    {, llyr_specs} = RunMacro("Get Fields", {view_name: llyr})

    jv = JoinViews(
        "jv",
        llyr_specs.HCMType,
        speed_specs.HCMType, 
    )

    // using local bus factors universally for simplicity
    speed_factors = GetDataVector(jv + "|", speed_specs.lb_fac,)

    for i = 1 to speed_factors.length do
        if speed_factors[i] = null then speed_factors[i] = 0.5
    end

    for period in {"AM", "MD", "PM", "NT"} do
        for dir in {"AB", "BA"} do
            times = GetDataVector(jv + "|", llyr_specs.(dir + "Time" + period), )
            SetDataVector(jv + "|", llyr_specs.(dir + "BusTime" + period), times / speed_factors, )
        end
    end

    // also do walk speeds
    lengths = GetDataVector(jv + "|", llyr_specs.[Length], )
    // assume 2.9 mph
    SetDataVector(jv + "|", llyr_specs.WalkTime, lengths / walk_speed * 60, )

    SetDataVector(jv + "|", llyr_specs.BikeTime, lengths / bike_speed * 60, )

    CloseView("jv")
    CloseView("speed_table")
endmacro