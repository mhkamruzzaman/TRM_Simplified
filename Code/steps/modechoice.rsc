macro "Mode Choice" (Args)
    Data:
    In({Args.[Model Folder]})

    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Mode choice")

    modelfile = RunMacro("Join Path", {Args.[Model Folder], "Data", "mode_choice.mdl"})
    if (!RunMacro("Check File Existence", modelfile)) then
        return(false)

    o = CreateObject("Choice.Mode")
    o.ModelFile = modelfile
    o.AggregateModel = 1
    o.OpenMatrixSource({SourceName: "Auto", FileName: RunMacro("Join Path", {Args.[Output Folder], "auto_skims_MD.mtx"})})
    o.OpenMatrixSource({SourceName: "Bike", FileName: RunMacro("Join Path", {Args.[Output Folder], "bike_skims_All.mtx"})})
    o.OpenMatrixSource({SourceName: "Transit", FileName: RunMacro("Join Path", {Args.[Output Folder], "transit_skims_MD.mtx"})})
    o.OpenMatrixSource({SourceName: "Walk", FileName: RunMacro("Join Path", {Args.[Output Folder], "walk_skims_All.mtx"})})
    o.OpenTableSource({SourceName: "Access", FileName: RunMacro("Join Path", {Args.[Output Folder], "access.bin"})})

    for tt in {"HBO", "HBW", "NHB"} do
        o.AddMatrixOutput(tt, { Probability: RunMacro("Join Path", {Args.[Output Folder], "mode_probabilities_" + tt + ".mtx"})})
    end

    AppendToLogFile(1, "Running model")

    ok = o.Run()

    for tt in {"HBO", "HBW", "NHB"} do
        AppendToLogFile(1, "Indexing probability matrix for " + tt)
        RunMacro("Index Matrix With Internal IDs", // from distribution.rsc
            RunMacro("Join Path", {Args.[Output Folder], "mode_probabilities_" + tt + ".mtx"}),
            RunMacro("Join Path", {Args.[Output Folder], "balanced_productions_attractions.bin"}),
            )
        AppendToLogFile(1, "Creating total trip matrices for " + tt)

        RunMacro("Create Total Trip Matrices by Mode", Args.[Output Folder], tt)
        // just leave index in file
    end

    return(ok)
endmacro

Macro "Create Total Trip Matrices by Mode" (folder, triptype)
    AppendToLogFile(1, "Creating total trip matrices by mode for trip type " + triptype)
    total_tripsmx = OpenMatrix(RunMacro("Join Path", {folder, "distributed_pa.mtx"}),)
    total_trips = CreateMatrixCurrency(total_tripsmx, triptype,,,)
    probsmtx = OpenMatrix(RunMacro("Join Path", {folder, "mode_probabilities_" + triptype + ".mtx"}),)

    modes = GetMatrixCoreNames(probsmtx)

    curr = CreateMatrixCurrency(probsmtx, modes[1], "Internal", "Internal",)
    result = CopyMatrixStructure({curr}, {
        "File Name": RunMacro("Join Path", {folder, "mode_totals_" + triptype + ".mtx"}),
        "Label": "Trip counts",
        "Tables": modes
    })

    for mode in modes do
        probs = CreateMatrixCurrency(probsmtx, mode,,,)
        totals = CreateMatrixCurrency(result, mode,,,)
        totals := probs * total_trips
    end
endmacro