Macro "Update Speeds and Check Convergence" (Args)
    Data:
    In({Args.[Output Folder]})
    In({Args.[Assignment Convergence PRMSE]})
    Body:

    rn = RunMacro("Join Path", {Args.[Output Folder], "road_network.dbd"})
    {nlyr, llyr} = GetDBLayers(rn)
    llyr = AddLayerToWorkspace(llyr, rn, llyr)  


    // weighted percent RMSE of travel time across all periods, weighted by vmt
    weight_sum = 0.0
    weighted_sum_of_squares = 0.0

    for period in {"AM", "MD", "PM", "NT"} do
        flows = OpenTable("flows", "FFB", {RunMacro("Join Path", {Args.[Output Folder], "link_flows_" + period + ".bin"}),},)

        jv = JoinViews("jv", llyr + ".ID", flows + ".ID1",)

        for dir in {"AB", "BA"} do
            new_time = GetDataVector(jv + "|", flows + "." + dir + "_Time",)
            old_time = GetDataVector(jv + "|", llyr + "." + dir + "Time" + period,)
            // using VMT instead of flow means errors on very short segments are discounted
            vmt = GetDataVector(jv + "|", flows + "." + dir + "_VMT",)
            
            for i = 1 to new_time.length do
                if new_time[i] = null then new_time[i] = old_time[i]

                if vmt[i] <> null then do
                    weighted_sum_of_squares = weighted_sum_of_squares + vmt[i] * Pow(new_time[i] - old_time[i], 2) 
                    weight_sum = weight_sum + vmt[i]
                end
            end

            // update times
            SetDataVector(jv + "|", llyr + "." + dir + "Time" + period, new_time,)
        end

        CloseView(jv)
        CloseView(flows)
    end

    prmse = sqrt(weighted_sum_of_squares / weight_sum)

    CloseView(llyr)

    if prmse <= Args.[Assignment Convergence PRMSE]then do
        AppendToLogFile(1, "PRMSE " + String(prmse) + " <= " + String(Args.[Assignment Convergence PRMSE]) + ", convergence reached")
        return(1)
    end else do
        AppendToLogFile(1, "PRMSE " + String(prmse) + " > " + String(Args.[Assignment Convergence PRMSE]) +", convergence NOT reached")
        return(2)
    end
endmacro