/**
 * This macro disaggregates trip types by time of day.
 */
Macro "Time of Day" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Model Folder]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Running time of day disaggregation")

    paramfile = RunMacro("Join Path", {Args.[Model Folder], "Data", "trip_period_disaggregation.csv"})
    if (!RunMacro("Check File Existence", paramfile)) then
        return(false)

    params = OpenTable("params", "CSV", {paramfile,},)

    triptype = GetDataVector(params + "|", "TripType",)
    period = GetDataVector(params + "|", "Period",)
    prop = GetDataVector(params + "|", "Proportion",)

    for i = 1 to triptype.length do
        AppendToLogFile(1, triptype[i] + ", " + period[i] + ", proportion " + String(prop[i]))
        RunMacro("Time of Day for Trip Type and Period", Args.[Output Folder], triptype[i], period[i], prop[i])
    end

    CloseView(params)
    return(true)
endmacro

Macro "Time of Day for Trip Type and Period" (folder, triptype, period, prop)
    inputmx = OpenMatrix(RunMacro("Join Path", {folder, "mode_totals_" + triptype + ".mtx"}),)
    modes = GetMatrixCoreNames(inputmx)
    curr = CreateMatrixCurrency(inputmx, modes[1],,,)
    result = CopyMatrixStructure({curr}, {
        "File Name": RunMacro("Join Path", {folder, "mode_totals_" + triptype + "_" + period + ".mtx"}),
        "Label": "Trip counts",
        "Tables": modes
    })

    for mode in modes do
        totals = CreateMatrixCurrency(inputmx, mode,,,)
        period = CreateMatrixCurrency(result, mode,,,)
        period := totals * prop
    end
endmacro