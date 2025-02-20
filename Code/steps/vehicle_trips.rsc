/**
 * Turn person trips into hourly vehicle trips.
 */
Macro "Vehicle Trips" (Args)
    Data:
    In({Args.[Output Folder]})

    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    // factors copied from capacity_period_factors.csv in TRMG2
    RunMacro("Create Hourly Rates", Args.[Output Folder], "AM", 1 / 1.864)
    RunMacro("Create Hourly Rates", Args.[Output Folder], "MD", 1 / 5.5)
    RunMacro("Create Hourly Rates", Args.[Output Folder], "PM", 1 / 2.565)
    RunMacro("Create Hourly Rates", Args.[Output Folder], "NT", 1 / 4)

    return(true)
endmacro

Macro "Create Hourly Rates" (folder, period, scaling_factor)
    // PA and OD are same for NHB, so there is no OD file
    nhbmtx = CreateObject("Matrix", RunMacro("Join Path", {folder, "mode_totals_NHB_" + period + "_PA.mtx"}))
    hbomtx = CreateObject("Matrix", RunMacro("Join Path", {folder, "mode_totals_HBO_" + period + "_OD.mtx"}))
    hbwmtx = CreateObject("Matrix", RunMacro("Join Path", {folder, "mode_totals_HBW_" + period + "_OD.mtx"}))

    nhb = nhbmtx.GetCores()
    hbo = hbomtx.GetCores()
    hbw = hbwmtx.GetCores()

    outputmtx = nhbmtx.CopyStructure({
        OutputFile: RunMacro("Join Path", {folder, "hourly_vehicle_trips_" + period + ".mtx"}),
        Cores: {"Vehicle Trips"}
    })

    output = outputmtx.GetCore("Vehicle Trips")

    // average occupancy for HOV determined by expert judgement (i.e. I made it up)
    output := (
        nhb.SOV +
        nhb.HOV / 2.3 +
        hbo.SOV +
        hbo.HOV / 2.3 +
        hbw.SOV + 
        hbw.HOV / 2.1
    ) * scaling_factor
endmacro