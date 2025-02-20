macro "Assignment" (Args)
    Data:
    In({Args.[Output Folder]})

    Body:
    on error do
        ShowMessage(GetLastError())
        return(false)
    end

    AppendToLogFile(0, "Assignment")

    for period in {"AM", "MD", "PM", "NT"} do

    end

    return(true)


endmacro