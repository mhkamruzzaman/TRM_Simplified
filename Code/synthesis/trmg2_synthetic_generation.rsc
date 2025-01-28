Macro "Convert TRMG2 results to CSV and OMX" (outputdir)    
    RunMacro("Convert Matrices", {outputdir, "resident", "dc", "probabilities"})
    RunMacro("Convert Matrices", {outputdir, "resident", "mode", "probabilities"})

    RunMacro("Convert Matrices", {outputdir, "skims", "roadway"})
    RunMacro("Convert Matrices", {outputdir, "skims", "transit"})
    RunMacro("Convert Matrices", {outputdir, "skims", "nonmotorized"})

    RunMacro("Convert Matrices", {outputdir, "resident", "trip_matrices"})
    RunMacro("Convert Matrices", {outputdir, "resident", "nhb", "dc", "trip_matrices"})

    RunMacro("Convert Matrices", {outputdir, "resident", "nhb", "dc", "probabilities"})
    RunMacro("Convert Tables", {outputdir, "resident", "nhb", "generation"})

    RunMacro("Convert Tables", {outputdir, "resident", "population_synthesis"})
    RunMacro("Convert Tables", {outputdir, "resident", "nonmotorized"})
endmacro

Macro "Convert Matrices" (dir)
    dirpath = RunMacro("Join Path", dir)
    mtxglob = RunMacro("Join Path", {dirpath, "*.mtx"})
    files = GetDirectoryInfo(mtxglob, "File")

    for file in files do
        fpath = RunMacro("Join Path", {dirpath, file[1]})
        // this might leak memory...
        mtx = OpenMatrix(fpath,)
        currencies = CreateMatrixCurrencies(mtx,,,)
        coreNames = GetMatrixCoreNames(mtx)

        // only need to do once, all cores will be copied
        currency = currencies.(coreNames[1])
        newfpath = fpath.replace("mtx$", "omx")
        AppendToLogFile(1, "Copying " + fpath + " to " + newfpath)
        CopyMatrix(currency, {
            "File Name": newfpath,
            "Label": file[1],
            "OMX": "True",
            "File Based": "Yes"
        })
    end

endmacro

Macro "Convert Tables" (dir)
    dirpath = RunMacro("Join Path", dir)
    mtxglob = RunMacro("Join Path", {dirpath, "*.bin"})
    files = GetDirectoryInfo(mtxglob, "File")

    for file in files do
        fn = RunMacro("Join Path", {dirpath, file[1]})
        v = OpenTable("table", "FFB", {fn, },)
        ExportView(v + "|", "CSV", fn.replace("bin$", "csv"),, {"CSV Header": "True"})
        CloseView(v)
    end
endmacro