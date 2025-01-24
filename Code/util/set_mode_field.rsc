DBox "Set Mode to 1 UI" title: "Set Mode to 1"
    Button "Input Line Layer" 0, after do
        input = ChooseFile({{"Input line Layer", "*.dbd"}}, "Line layer", null)
    enditem

    Edit Text "Input Line Layer" after, same variable: input

    Button "OK" 0, after default do
        RunMacro("Set Mode to One", input)
        return()
    endItem

    Button "Cancel" after, same cancel do
        return()
    endItem
enddbox

/* Set the mode field to universally 1 (walk) */
Macro "Set Mode to One" (dbd)
    {nlyr, llyr} = GetDBLayers(dbd)
    llyr = AddLayerToWorkspace(llyr, dbd, llyr)

    RunMacro("Add Fields", {
        view: llyr,
        a_fields: {{"mode", "Int", 1, , , , , "test"}},
        inital_value: {1}
    })

    mode = GetDataVector(llyr + "|", "mode",)
    for i = 1 to mode.length do
        mode[i] = 1
    end
    SetDataVector(llyr + "|", "mode", mode, )
endmacro
