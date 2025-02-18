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

    return(ok)
endmacro