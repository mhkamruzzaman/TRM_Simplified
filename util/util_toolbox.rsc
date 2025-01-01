Macro "Show Util Toolbox"
    RunDBox("Util Toolbox")
EndMacro

DBox "Util Toolbox" center,center title: "PLAN 739 Utilities" Toolbox
    Button "Extract Road Line Layer" 0, 0 do
        RunDBox("Extract Road Line Layer UI")
    endItem

    Button "Extract Transit Route System" same, after do
        RunDBox("Extract Transit Route System UI")
    endItem

    Close do
        return()
    endItem
enddbox