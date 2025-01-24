/*
Read a JSON file and return it as a parsed array
*/
Macro "Read JSON" (filename)
    fptr = OpenFile(filename, "r")
    fcontent = ""

    while not FileAtEOF(fptr) do
        fcontent = fcontent + ReadLine(fptr)
    end

    CloseFile(fptr)

    return(JsonToArray(fcontent))
endmacro