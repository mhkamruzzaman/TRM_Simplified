macro "Trip Production" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Model Folder]})
    In({Args.[TAZ Segment Counts]})
    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Trip production")

    trip_rate_file = RunMacro("Join Path", {Args.[Model Folder], "Data", "triprates.bin"})

    if GetFileInfo(trip_rate_file) = null then do
        ShowMessage("Trip rate file " + trip_rate_file + " not found, cannot continue.")
        return(false)
    end

    // read the TAZ data
    AppendToLogFile(1, "Reading TAZ count data")
    tazcounts = OpenTable("tazcounts", "CSV", {Args.[TAZ Segment Counts], } )

    // read the access file
    AppendToLogFile(1, "Reading Access File")
    access = OpenTable("access", "FFB", {RunMacro("Join Path", {Args.[Output Folder], "access.bin"}), } )

    // join
    AppendToLogFile(1, "Joining TAZ counts and access")
    jv = JoinViews("taz_access", tazcounts + ".ZoneID", access + ".ID",)

    AppendToLogFile(1, "Exporting joined TAZs")
    joined_file = RunMacro("Join Path", { Args.[Output Folder], "taz_counts_access.bin" })
    ExportView(jv + "|", "FFB", joined_file, ,)

    CloseView(jv)
    CloseView(access)
    CloseView(tazcounts)


    // figure out what the access metric used is (it may differ)
    AppendToLogFile(1, "Autodetecting access metric")
    rates = OpenTable("rates", "FFB", { trip_rate_file, } )
    fields_specs = GetFields(rates, "Numeric")
    fields = fields_specs[1]
    CloseView(rates)

    AppendToLogFile(1, "Preparing generation")

    o = CreateObject("Generation.CrossClass")
    o.RatesTable = trip_rate_file
    o.OutputFile = RunMacro("Join Path", {Args.[Output Folder], "original_productions.bin"})
    o.DataFile({Filename: joined_file})

    // define rate by trip type
    o.AddRate({RateField: "R_HBO", Purpose: "HBO"})
    o.AddRate({RateField: "R_HBW", Purpose: "HBW"})
    o.AddRate({RateField: "R_NHB", Purpose: "NHB"})

    // configure segments
    RunMacro("Add Segment In Order", o, "inc_high_size_1_nonworker", fields, {
        HHInc: 100000,
        HHSize: 1,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_high_size_1_worker", fields, {
        HHInc: 100000,
        HHSize: 1,
        NumberWorkers: 1
    })

    RunMacro("Add Segment In Order", o, "inc_high_size_2_nonworker", fields, {
        HHInc: 100000,
        HHSize: 2,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_high_size_2_worker", fields, {
        HHInc: 100000,
        HHSize: 2,
        NumberWorkers: 1
    })

    RunMacro("Add Segment In Order", o, "inc_high_size_3+_nonworker", fields, {
        HHInc: 100000,
        HHSize: 3,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_high_size_3+_worker", fields, {
        HHInc: 100000,
        HHSize: 3,
        NumberWorkers: 1
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_1_nonworker", fields, {
        HHInc: 0,
        HHSize: 1,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_1_worker", fields, {
        HHInc: 0,
        HHSize: 1,
        NumberWorkers: 1
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_2_nonworker", fields, {
        HHInc: 0,
        HHSize: 2,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_2_worker", fields, {
        HHInc: 0,
        HHSize: 2,
        NumberWorkers: 1
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_3+_nonworker", fields, {
        HHInc: 0,
        HHSize: 3,
        NumberWorkers: 0
    })

    RunMacro("Add Segment In Order", o, "inc_low_size_3+_worker", fields, {
        HHInc: 0,
        HHSize: 3,
        NumberWorkers: 1
    })

    AppendToLogFile(1, "Running generation")
    o.Run()

    return(true)
endmacro

/*
 * TransCAD relies on the _order_ of the fields, not their names, for configuring segments.
 * It is unreasonable to expect students to always put the fields in the same order.
 * We need to handle this explicitly.
 */
macro "Add Segment In Order" (o, seg_name, fields, values)
    result = {values.(fields[1])}

    for i = 2 to fields.length do
        field = fields[i]
        // all fields processed
        if field.match("^R_") <> null then break

        // access field, not constant
        if field.match("^Access") <> null then
            result = result + {field} // same field name in zones file
        else
            result = result + {values.(field)}
    end

    o.AddSegment({Name: seg_name, ClassifyBy: result})
endmacro
