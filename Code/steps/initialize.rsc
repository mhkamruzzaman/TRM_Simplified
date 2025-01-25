/* Set up the model output folder structure */
macro "Initialize TRMS" (Args, Result)
    Data:
        In({Args.[Base Folder]})
        Out({Args.[Output Folder]})
    Body:
        AppendToLogFile(0, "TRMS Initialization")

        startTime = CreateDateTime()
        startTimeText = FormatDateTime(startTime, "yyyy-MM-ddTHH_mm_ss")
        Args.[Output Folder] = Args.[Base Folder] + "model_run_" + startTimeText + "\\"
        CreateDirectory(Args.[Output Folder])

        AppendToLogFile(1, "Results will be stored in " + Args.[Output Folder])

        return(true)
endmacro