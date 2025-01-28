Macro "TRMG2 Generation" (trmg2dir, outdir)
    AppendToLogFile(0, "Generating synthetic travel survey data")

    hhfile = RunMacro("Join Path", {outdir, "trmg2_households.bin"})
    perfile = RunMacro("Join Path", {outdir, "trmg2_persons.bin"})

    Args = {
        "SE": RunMacro("Join Path", {trmg2dir, "master", "sedata", "se_2020.bin"}),
        "SizeCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "size_curves.csv"}),
        "IncomeCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "income_curves.csv"}),
        "WorkerCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "worker_curves.csv"}),
        "RegionalMedianIncome": 65317, // copied from TRMG2 params file
        "TAZs": RunMacro("Join Path", {trmg2dir, "master", "tazs", "master_tazs.dbd"}),
        "PUMS HH Seed": RunMacro("Join Path", {trmg2dir, "master", "resident", "population_synthesis", "HHSeed_PUMS_TRM.bin"}),
        "PUMS Person Seed": RunMacro("Join Path", {trmg2dir, "master", "resident", "population_synthesis", "PersonSeed_PUMS_TRM.bin"}),
        "TAZs": RunMacro("Join Path", {trmg2dir, "master", "tazs", "master_tazs.dbd"}),
        "Households": hhfile,
        "Persons": perfile,
        "SEDMarginals": RunMacro("Join Path", {outdir, "marginals.bin"}),
        "Synthesized Tabulations": RunMacro("Join Path", {outdir, "tabulations.bin"}),
        "AOCoeffs": RunMacro("Join Path", {trmg2dir, "master", "resident\\auto_ownership\\ao_coefficients.csv"})
    }

    AppendToLogFile(1, "Disggregate SED")
    RunMacro("Disaggregate Curves", Args)

    AppendToLogFile(1, "Population synthesis")
    RunMacro("IPU Synthesis", Args)

    AppendToLogFile(1, "Auto ownership")
    RunMacro("Auto Ownership", Args)
endmacro

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