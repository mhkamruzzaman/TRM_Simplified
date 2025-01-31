/*
 * Run trip attraction model using NCHRP 365 trip attraction rates.
 */
macro "Trip Attraction" (Args)
    Data:
    In({Args.[TAZ File]})
    In({Args.[Output Folder]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Trip attractions (NCHRP 365)")

    AppendToLogFile(1, "Loading TAZs")

    taz = AddLayerToWorkspace("taz", Args.[TAZ File], "master_tazs")

    AppendToLogFile(1, "Creating formula fields")

    // the TAZ layer doesn't have the other employment field requested by NCHRP 365, so
    // add up the non-retail non-service fields
    otheremp = CreateExpression(taz, "OtherEmp", "Office + Industry",)

    // And combine the service fields
    svcemp = CreateExpression(taz, "Service", "Service_RateLow + Service_RateHigh",)

    // Create a CBD flag based on parking district and non-university parking area
    // copied from TRMG2
    cbd = CreateExpression(taz, "CBD", "ParkDistrict > 0 and ParkCostU = 0", )

    AppendToLogFile(1, "Saving modified layer")
    modified_taz = RunMacro("Join Path", {Args.[Output Folder], "taz_job_counts_nchrp365.bin"})
    ExportView(taz + "|", "FFB", modified_taz,,)

    AppendToLogFile(1, "Calculating attractions")
    RunMacro("TCB Init")

    // the documentation says to use TCB Run Procedure, but that results in an error. TCB Run Operation
    // is in the example.
    ok = RunMacro("TCB Run Operation", "NCHRP365 Attraction", {
        Input: {"View Set": {modified_taz, "taz_job_counts_nchrp365"}}, // or should it be a set of just internal tazs?
        Global: {
            "ID Field": "ID",
            "RE Field": "Retail",
            "SE Field": svcemp,
            "OE Field": otheremp,
            "HH Field": "HH",
            "CBDFlag Field": cbd // Documentation calls this CDBFlag but that is incorrect I can't even with this software
        },
        Output: {"Output Table": RunMacro("Join Path", {Args.[Output Folder], "original_attractions.bin"})}
    }, &Ret)

    return(RunMacro("TCB Closing", ok, True,))
endmacro