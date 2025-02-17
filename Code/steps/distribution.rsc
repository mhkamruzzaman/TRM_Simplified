/**
 * Run trip distribution. Uses the distribution parameters file, balanced_productions_attractions.bin, and the MD auto skim
 * to produce the file distributed_pa.mtx with distributed trips.
 */
macro "Run Trip Distribution" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Model Folder]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Running trip distribution")

    paramfile = RunMacro("Join Path", {Args.[Model Folder], "Data", "distribution_parameters.csv"})
    if (!RunMacro("Check File Existence", paramfile)) then
        return(false)

    AppendToLogFile(1, "Reading parameters")
    params = OpenTable("params", "CSV", {paramfile,},)

    purpose = GetDataVector(params + "|", "Purpose",)
    method = GetDataVector(params + "|", "Method",)
    a = GetDataVector(params + "|", "a",)
    b = GetDataVector(params + "|", "b",)
    c = GetDataVector(params + "|", "c",)
    constraint = GetDataVector(params + "|", "Constraint",)

    AppendToLogFile(2, "Configuring index")
    skimmtx = RunMacro("Join Path", {Args.[Output Folder], "auto_skims_md.mtx"})
    pa =  RunMacro("Join Path", {Args.[Output Folder], "balanced_productions_attractions.bin"})
    mtxidx = RunMacro("Index Matrix With Internal IDs", skimmtx, pa)

    AppendToLogFile(1, "Configuring distribution object")
    o = CreateObject("Distribution.Gravity")
    o.ResetPurposes() // not sure why we would need this but in example
    o.DataSource = pa

    for i = 1 to purpose.length do
        AppendToLogFile(2, purpose[i])
        purpDefn = {
            "Name": purpose[i],
            "Production": purpose[i],
            "Attraction": purpose[i] + "_A",
            "ConstraintType": constraint[i],
            "ImpedanceMatrix": {
                MatrixFile: skimmtx,
                Matrix: "TimeMD",
                RowIndex: mtxidx,
                ColIndex: mtxidx
            }
        }

        if method[i] = "Exponential" then do
            AppendToLogFile(2, "Using exponential function e^(-" + String(c[i]) + "d)")
            purpDefn.Exponential = c[i]
        end else if method[i] = "Inverse" then do
            AppendToLogFile(2, "Using inverse power function d^-" + String(b[i]))
            purpDefn.Inverse = b[i]
        end else if method[i] = "Gamma" then do
            AppendToLogFile(2, "Using Gamma function "+ String(a[i]) + " * d^-" + String(b[i]) + " * e^(-" + String(c[i]) + ")")
            purpDefn.Gamma = {a[i], b[i], c[i]}
        end else do
            ShowMessage("Unknown trip distribution method " + method[i] + ", at " + paramfile + " line " + String(i + 1))
            return(false)
        end

        o.AddPurpose(purpDefn)
    end

    o.OutputMatrix({
        MatrixFile: RunMacro("Join Path", {Args.[Output Folder], "distributed_pa.mtx"}),
        MatrixLabel: "DistributedPA",
        Compression: true,
        ColumnMajor: false
    })


    AppendToLogFile(1, "Running distribution")
    ok = o.Run()

    RunMacro("Clean Up Matrix Index", skimmtx, mtxidx)

    return(ok)
endmacro

/**
 * Add a matrix index based on the ID column of the PA dataset from generation.
 */
Macro "Index Matrix With Internal IDs" (mtxfile, pafile)
    mtx = OpenMatrix(mtxfile, )
    pa = OpenTable("pa", "FFB", {pafile,},)

    internal_index = CreateMatrixIndex("Internal", mtx, "Both", pa + "|", "ID", ,)

    CloseView(pa)
    
    return(internal_index)
endmacro

/**
 * Clean up matrix index
 */
Macro "Clean Up Matrix Index" (mtxfile, idx)
    mtx = OpenMatrix(mtxfile, )
    DeleteMatrixIndex(mtx, idx)
endmacro