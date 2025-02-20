/* Set up initial speeds for skimming before running the model */

DBox "Set Initial Speeds UI" title: "Calculate Initial Speeds"
    Button "Input Line Layer" 0, after do
        input = ChooseFile({{"Input line Layer", "*.dbd"}}, "Line layer", null)
    enditem

    Edit Text "Input Line Layer" after, same variable: input

    Button "OK" 0, after default do
        RunMacro("Calculate Initial Speeds", input)
        return()
    endItem

    Button "Cancel" after, same cancel do
        return()
    endItem
enddbox

Macro "Calculate Initial Speeds" (out_dbd, vdf_file)
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    {nlyr, llyr} = GetDBLayers(out_dbd)
    llyr = AddLayerToWorkspace(llyr, out_dbd, llyr)

    // if you initialize this as {}, the first element will be null (I guess GISDK can't do empty arrays)
    a_fields = {
        {"mode", "Int", 1, , , , , "test"},
        {"FFTime", "Real", 10, 2, , , , "Free-flow time"},
        {"ABCapacity", "Real", 10, 2, , , , "Capacity"},
        {"BACapacity", "Real", 10, 2, , , , "Capacity"},
        {"ModifyPosted", "Real", 10, 2, , , , "Posted speed modification factor"},
        {"Alpha", "Real", 10, 2, , , , "VDF alpha"},
        {"Beta", "Real", 10, 2, , , , "VDF beta"}
    }

    for period in {"AM", "MD", "PM", "NT"} do
        for dir in {"AB", "BA"} do
            a_fields = a_fields + {
                {dir + "Time" + period, "Real", 10, 2, , , , 
            "Congested time in the " + period + " period (minutes).|Updated after each assignment."}
            }
        end
    end

    RunMacro("Add Fields", {
        view: llyr,
        a_fields: a_fields,
        initial_value: {1, 0}
    })

    // set VDF parameters
    AppendToLogFile(1, "Opening VDF file")
    vdf = OpenTable("vdf", "CSV", {vdf_file,},)

    AppendToLogFile(1, "Joining files")
    jv = JoinViewsMulti(
        "net",
        {llyr + ".HCMType", llyr + ".HCMMedian"},
        {vdf + ".HCMType", vdf + ".HCMMedian"},
    )


    AppendToLogFile(1, "Copying vectors")
    for col in {"ModifyPosted", "Alpha", "Beta"} do
        vals = GetDataVector(jv + "|", vdf + "." + col,)
        SetDataVector(jv + "|", llyr + "." + col, vals, )
    end

    AppendToLogFile(1, "Calculating capacity")

    capacityPerLane = GetDataVector(jv + "|", vdf + ".CapacityPerLane",)

    AppendToLogFile(1, "Retrieving lane counts")
    ablanes = GetDataVector(jv + "|", llyr + ".ABLanes",)
    balanes = GetDataVector(jv + "|", llyr + ".BALanes",)

    AppendToLogFile(1, "Setting capacity values")

    abcap = capacityPerLane * ablanes
    bacap = capacityPerLane * balanes
    
    // make sure everything has valid capacity values, falling back to default values
    for i = 1 to abcap.length do
        if abcap[i] = null & ablanes[i] <> null then abcap[i] = 1200 * ablanes[i]
        if abcap[i] = 0 then abcap[i] = 1200
        if bacap[i] = null & balanes[i] <> null then bacap[i] = 1200 * ablanes[i]
        if bacap[i] = 0 then bacap[i] = 1200
    end

    SetDataVector(jv + "|", llyr + ".ABCapacity", abcap,)
    SetDataVector(jv + "|", llyr + ".BACapacity", bacap,)

    CloseView(jv)
    CloseView(vdf)

    // NB not using ModifyPosted for consistency with earlier assignments
    posted_speeds = GetDataVector(llyr + "|", "PostedSpeed", )// + GetDataVector(llyr + "|", "ModifyPosted",)

    for i = 1 to posted_speeds.length do
        // default to 25 mph
        if posted_speeds[i] = null then posted_speeds[i] = 25
    end

    length = GetDataVector(llyr + "|", "Length", )
    dir = GetDataVector(llyr + "|", "Dir", )
    ffs = length / posted_speeds * 60  // convert to minutes
    ffsAB = CopyVector(ffs)
    ffsBA = CopyVector(ffs)

    SetDataVector(llyr + "|", "FFTime", ffs, )

    for i = 1 to ffs.length do
        if dir[i] = -1 then ffsAB[i] = null
        if dir[i] = 1 then ffsBA[i] = null
    end

    for period in {"AM", "MD", "PM", "NT"} do
        SetDataVector(llyr + "|", "ABTime" + period, ffsAB, )
        SetDataVector(llyr + "|", "BATime" + period, ffsBA, )
    end
endmacro