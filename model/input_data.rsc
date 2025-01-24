Macro "Input Data" (args)
    Body:
        // show the input data dialog box
        args.config = ShowDbox("Input Data")
    Data:
        Out(args.[config])
endmacro

DBox "Input Data" center, center title: "Input Data"
    Button "Config File" 0, 0 do
        cfile = ChooseFile({{"Config file", "*.json"}}, "Config file", null)
        config = RunMacro("Read JSON", cfile)
        config_slist = RunMacro("Config to Scroll List", config)
    enditem

    Edit Text "Model Configuration File" after, same variable: cfile

    Scroll List 0, after List: config_slist

    Button "OK" 0, after default do
        return()
    endItem

    Button "Cancel" after, same cancel do
        return()
    endItem
enddbox

Macro "Config to Scroll List" (config)
    slist = {}

    for subarr in config do
        slist = slist + {subarr[1], ArrayElementToString(subarr, 2)}
    end

    return(slist)
endmacro

