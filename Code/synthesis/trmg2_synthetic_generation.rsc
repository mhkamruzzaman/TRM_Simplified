Macro "TRMG2 Generation" (trmg2dir, outdir)
    AppendToLogFile(0, "Generating synthetic travel survey data")

    sed_marginals = RunMacro("Join Path", {outdir, "marginals.bin"})

    AppendToLogFile(1, "Disggregate SED")
    RunMacro("DisaggregateSED", {
        "SE": RunMacro("Join Path", {trmg2dir, "master", "sedata", "se_2020.bin"}),
        "SEDMarginals": sed_marginals,
        "SizeCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "size_curves.csv"}),
        "IncomeCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "income_curves.csv"}),
        "WorkerCurves": RunMacro("Join Path", {trmg2dir, "master", "resident", "disagg_model", "worker_curves.csv"}),
        "RegionalMedianIncome": 65317, // copied from TRMG2 params file
        "TAZs": RunMacro("Join Path", {trmg2dir, "master", "tazs", "master_tazs.dbd"})
    })

    hhfile = RunMacro("Join Path", {outdir, "trmg2_households.bin"})
    perfile = RunMacro("Join Path", {outdir, "trmg2_persons.bin"})

    AppendToLogFile(1, "Population synthesis")
    RunMacro("Synthesize Population", {
        "PUMS HH Seed": RunMacro("Join Path", {trmg2dir, "master", "resident", "population_synthesis", "HHSeed_PUMS_TRM.bin"}),
        "PUMS Person Seed": RunMacro("Join Path", {trmg2dir, "master", "resident", "population_synthesis", "PersonSeed_PUMS_TRM.bin"}),
        "SEDMarginals": sed_marginals,
        "TAZs": RunMacro("Join Path", {trmg2dir, "master", "tazs", "master_tazs.dbd"}),
        "Households": hhfile,
        "Persons": perfile
    })
endmacro