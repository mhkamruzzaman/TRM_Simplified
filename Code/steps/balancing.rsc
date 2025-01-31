/*
 * Calibrate and balance trip counts.
 *
 * We first calibrate productions based on estimated counts from the TRMG2. Due to some unfortunate outliers in the
 * survey file, HBO productions are much too high, so we apply calibration factors derived by comparing base year output
 * to the TRMG2 output.
 */
macro "Calibrate and Balance" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[HBW Calibration]})
    In({Args.[HBO Calibration]})
    In({Args.[NHB Calibration]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Calibration and balancing")

    AppendToLogFile(1, "Reading inputs")
    productions = OpenTable("productions", "FFB", {RunMacro("Join Path", {Args.[Output Folder], "original_productions.bin"}),}, )
    attractions = OpenTable("attractions", "FFB", {RunMacro("Join Path", {Args.[Output Folder], "original_attractions.bin"}),}, )

    output = RunMacro("Join Path", {Args.[Output Folder], "balanced_productions_attractions.bin"})

    AppendToLogFile(1, "Joining production to attraction")
    // inexplicably the NCHRP365 procedure calls it ID1 and not ID
    jv = JoinViews("pa", productions + ".ID", attractions + ".ID1",)

    AppendToLogFile(1, "Initializing output file " + output)
    ExportView(jv + "|", "FFB", output,,)

    CloseView(jv)
    CloseView(productions)
    CloseView(attractions)

    AppendToLogFile(1, "Reading output file")
    pa = OpenTable("pa", "FFB", {output,},)

    {, specs} = RunMacro("Get Fields", {view_name: pa})

    AppendToLogFile(1, "Calibrating productions")
    for tt in {"HBW", "HBO", "NHB"} do
        p = GetDataVector(pa + "|", specs.(tt), )
        pre_sum = p.sum()
        factor = Args.(tt + " Calibration")
        p = p * factor
        post_sum = p.sum()
        SetDataVector(pa + "|", specs.(tt), p,)
        AppendToLogFile(2, tt + ": calibration factor " + String(factor) + ", before total " + String(pre_sum) + ", now total" + String(post_sum))
    end

    AppendToLogFile(1, "Balancing attractions")
    for tt in {"HBW", "HBO", "NHB"} do
        p = GetDataVector(pa + "|", specs.(tt), )
        p_sum = p.sum()
        a = GetDataVector(pa + "|", specs.(tt + "_A"),)
        a_sum = a.sum()
        factor = p_sum / a_sum
        a = a * factor
        post_sum = a.sum()
        SetDataVector(pa + "|", specs.(tt + "_A"), a,)
        AppendToLogFile(2, tt + ": calibration factor " + String(factor) + ", before total " + String(a_sum) + ", now total" + String(post_sum))
    end

    CloseView(pa)

    return(true)
endmacro



