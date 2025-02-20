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

Macro "Calculate Initial Speeds" (out_dbd)
    {nlyr, llyr} = GetDBLayers(out_dbd)
    llyr = AddLayerToWorkspace(llyr, out_dbd, llyr)  

    // if you initialize this as {}, the first element will be null (I guess GISDK can't do empty arrays)
    a_fields = {{"mode", "Int", 1, , , , , "test"}, {"FFTime", "Real", 10, 2, , , , "Free-flow time"}}

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

    posted_speeds = GetDataVector(llyr + "|", "PostedSpeed", )

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

    // set walk speeds
endmacro