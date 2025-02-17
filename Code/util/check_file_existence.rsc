/* Check if a file exists, return true/false, and display a message if it does not */
Macro "Check File Existence" (filename)
    if (GetFileInfo(filename) = null) then do
        ShowMessage("File " + filename + " does not exist.")
        return(false)
    end else return(true)
endmacro