/*
 * Join an array of path components together, handling path separators logically
 */
macro "Join Path" (components)
    path = components[1]

    for i = 2 to components.length do
        if !path.match("[\\\\/]$") then path = path + "\\"
        path = path + components[i]
    end

    return(path)
endmacro