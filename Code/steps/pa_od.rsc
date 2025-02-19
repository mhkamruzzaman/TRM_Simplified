/**
 * Convert PA format to OD format for each mode and trip type.
 */
Macro "Directionality" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Model Folder]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Running directionality component")

    paramfile = RunMacro("Join Path", {Args.[Model Folder], "Data", "directionality.csv"})
    if (!RunMacro("Check File Existence", paramfile)) then
        return(false)

    directionality = OpenTable("directionality", "CSV", {paramfile, })

    triptype = GetDataVector(directionality + "|", "TripType",)
    period = GetDataVector(directionality + "|", "Period",)
    pa = GetDataVector(directionality + "|", "Avg PA",) // the proportion of trips that are PA by trip type and period, as opposed to AP

    for i = 1 to triptype.length do
        AppendToLogFile(1, "Directionality for " + triptype[i] + " " + period[i] + ": " + String(pa[i]) + " PA")
        RunMacro("Directionality TTP", Args.[Output Folder], triptype[i], period[i], pa[i])
    end

    return(true)
endmacro

Macro "Directionality TTP" (folder, triptype, period, pafactor)
    // heavily based on code from TRMG2
    pafile = RunMacro("Join Path", {folder, "mode_totals_" + triptype + "_" + period + "_PA.mtx"})
    odfile = RunMacro("Join Path", {folder, "mode_totals_" + triptype + "_" + period + "_OD.mtx"})
    in_mtx = CreateObject("Matrix", pafile)
    in_mtx_t = in_mtx.Transpose()

    // TRMG2 does it in place, just using the od matrix. But it is not docmented if Transpose copies
    // the matrix, and I don't want to rely on undocumented behavior.
    out_mtx = in_mtx.CopyStructure({OutputFile: odfile})

    for mode in in_mtx.GetCoreNames() do
        out_core = out_mtx.GetCore(mode)
        out_core := in_mtx.GetCore(mode) * pafactor + in_mtx_t.GetCore(mode) * (1 - pafactor)
    end
endmacro