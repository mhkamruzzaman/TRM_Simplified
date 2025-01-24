/* Set up the model output folder structure */
macro "Initialize TRMS" (Args, Result)
    Data:
        In({Args.[Base Folder]})
        Out({Args.[Output Folder]})
    Body:
        startTime = CreateDateTime()
        startTimeText = FormatDateTime(startTime, "yyyy-MM-ddTHH_mm_ss")
        Args.[Output Folder] = Args.[Base Folder] + "\\model_run_" + startTimeText
        CreateDirectory(Args.[Output Folder])
        CreateDirectory(Args.[Output Folder] + "\\Intermediate Files")
        return(True)
endmacro