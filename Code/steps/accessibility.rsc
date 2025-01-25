/* Create a matrix index to match up to the indices of socioeconomic data */
Macro "Index Matrix" (matrix, se_view, se_idcol)
    taz_index = CreateMatrixIndex("Internal__TAZ__________ID", matrix, "Both", se_view + "|", se_idcol, ,)
    return(taz_index)
endmacro

/*
 * Compute all accessibilities and dump them in a table
 */
Macro "Compute Accessibility" (Args, Results)
    Data:
        In({Args.[Cumulative Opportunity Cutoff Minutes]})
        In({Args.[Output Folder]})
        In({Args.[TAZ File]})
    Body:
    // build columns

    se = AddLayerToWorkspace("TAZs", Args.[TAZ File], "master_tazs")
    SetView(se)

    columns = {{"ID", "Integer", 12, 0, 1, "TAZ ID"}}

    thresholds = Args.[Cumulative Opportunity Cutoff Minutes]

    for mode in {"auto", "transit"} do
        for period in {"AM", "MD", "PM", "NT"} do
            for col in {"Retail", "Service_RateLow", "Service_RateHigh", "Office"} do
                for threshold in thresholds do
                    columns = columns + {{"Access_" + mode + "_" + period + "_" + col + "_" + String(threshold), "Real", 12, 2, 0,
                     "Access to jobs in " + col + " by " + mode + " during period " + period + " within " + String(threshold) + " minutes"}}
                end
            end
        end
    end

    o = CreateObject("CC.Table")
    tableObj = o.Create({
        Filename: Args.[Output Folder] + "access.bin",
        FieldSpecs: columns,
        AddEmptyRecords: GetRecordCount(tazs,),
        DeleteExisting: true
    })

    table = tableObj.View

    // copy ids over, what's your vector victor?
    ids = CopyVector(GetDataVector(se + "|", "ID",))
    SetDataVector(table + "|", "ID", ids,)

    for mode in {"auto", "transit"} do
        for period in {"AM", "MD", "PM", "NT"} do
            skimmtx = OpenMatrix(Args.[Output Folder] + mode + "_skims_" + period + ".mtx", )

            idx = RunMacro("Index Matrix", skimmtx, se, "ID")

            if mode = "transit" then core = "Total Time"
            else core = "Time" + period

            skim = CreateMatrixCurrency(skimmtx, core, idx, idx,)

            for threshold in thresholds do
                //accessiblemtx = CopyMatrix(skim, {"Memory Only": true})
                //accessible = CreateMatrixCurrency(accessiblemtx, core, idx, idx, )
                //accessible := if (accessible <= threshold) then 1.0 else 0.0

                for col in {"Retail", "Service_RateLow", "Service_RateHigh", "Office"} do

                    colname = "Access_" + mode + "_" + period + "_" + col + "_" + String(threshold)

                    opportunities = GetDataVector(se + "|", col,)

                    // will this work? or does opportunities need to become a matrix currency?
                    // can't get it to work as a matrix multiplication
                    //access = MultiplyMatrix(accessible, opportunities,)

                    access = GetDataVector(table + "|", colname,)

                    for orig = 1 to access.length do
                        ttimes = GetMatrixVector(skim, { "Row": ids[orig] })

                        destacc = ((ttimes < threshold) * opportunities)
                        access[orig] = destacc.sum()

                        /*access[orig] = 0.0

                        rowId = ids[orig]
                        for dest = 1 to opportunities.length do 
                            colId = ids[dest]

                            // from docs: "ID values are strings to accommodate the return value from GetEditorHighlight()."
                            if GetMatrixValue(skim, String(rowId), String(colId)) < threshold then access[orig] = access[orig] + opportunities[dest]
                        end*/
                    end

                    SetDataVector(table + "|", colname, access, )
                end
            end

            // or create the index when skimming?
            DeleteMatrixIndex(skimmtx, idx)
        end
    end

    CloseView(se)

    return(true)
endmacro

