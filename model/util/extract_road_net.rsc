DBox "Extract Road Line Layer UI" title: "Extract Road Line Layer"
    Button "Master Line Layer" 0, 0 do
        master_dbd = ChooseFile({{"Line layer", "*.dbd"}}, "Choose Master Line Layer", null)
    enditem

    Edit Text "Master Line Layer" after, same variable: master_dbd

    Button "Project CSV" 0, after do
        proj_list = ChooseFile({{"CSV file", "*.csv"}}, "Choose Project CSV", null)
    enditem

    Edit Text "Project CSV" after, same variable: proj_list

    Button "Output Line Layer" 0, after do
        hwy_dbd = ChooseFileName({{"Output Line Layer", "*.dbd"}}, "Choose output line layer", null)
    enditem

    Edit Text "Output Line Layer" after, same variable: hwy_dbd

    Button "OK" 0, after default do
        RunMacro("Extract Base Year Line Layer", hwy_dbd, proj_list, master_dbd)
        return()
    endItem

    Button "Cancel" after, same cancel do
        return()
    endItem
enddbox

// Extract the base-year road network from TRMG2 based on the master network and
// base-year project list CSV
// master_dbd is the master network, hwy_dbd is the network that will be created
Macro "Extract Base Year Line Layer" (hwy_dbd, proj_list, master_dbd)
    // This code is copied from TRMG2 v1.3.2, RoadwayProjectManagement.rsc
// Argument check
  if hwy_dbd = null then Throw("'hwy_dbd' not provided")
  if proj_list = null then Throw("'proj_list' not provided")
  if master_dbd = null then Throw("'master_dbd' not provided")

  // TRMG2 code below expects hwy_dbd to already exist, just copy over the master file
  CopyDatabase(master_dbd, hwy_dbd)

  // Get vector of project IDs from the project list file
  // gplyr's read functions won't work here until it can handle empty files.
  csv_tbl = OpenTable("tbl", "CSV", {proj_list, })
  v_projIDs = GetDataVector(csv_tbl + "|", "ProjID", )
  CloseView(csv_tbl)
  DeleteFile(Substitute(proj_list, ".csv", ".DCC", ))

  // Open the roadway dbd
  {nlyr, llyr} = GetDBLayers(hwy_dbd)
  llyr = AddLayerToWorkspace(llyr, hwy_dbd, llyr)
  nlyr = AddLayerToWorkspace(nlyr, hwy_dbd, nlyr)
  {llyr_f_names, llyr_f_specs} = RunMacro("Get Fields", {view_name: llyr})

  // Check validity of project definitions
  fix_master = RunMacro("Check Project Group Validity", llyr)
  if fix_master then do
    RunMacro("Clean Project Groups", master_dbd)
    Throw("Project groups fixed. Start the export process again.")
  end
  missing_projects = RunMacro("Check for Missing Projects", v_projIDs, llyr, hwy_dbd)

  // Determine the project groupings and attributes on the link layer.
  // Remove ID from the list of attributes to update.
  projGroups = RunMacro("Get Project Groups", llyr)
  attrList = RunMacro("Get Project Attributes", llyr)
  attrList = ExcludeArrayElements(attrList, 1, 1)

  // Loop over each project ID  
  for p = v_projIDs.length to 1 step -1 do
    projID = v_projIDs[p]
    type = TypeOf(projID)
    proj_found = 0

    // Add "UpdatedWithP" field
    if p = v_projIDs.length then do
      type2 = if CompareStrings(type, "string", ) then "Character" else "Integer"
      a_fields = {{"UpdatedWithP", type2, 16, }}
      RunMacro("Add Fields", {view: llyr, a_fields: a_fields})
    end

    // Loop over each project group (group of project fields)
    for g = 1 to projGroups.length do
      pgroup = projGroups[g]

      // Search for the ID in the current group.  Update attributes if found.
      // Do not update if the UpdatedWithP field is already marked with a 1.
      SetLayer(llyr)
      // Handle possibility of string or integer IDs
      if TypeOf(projID) <> "string" then
        qry = "Select * where " + pgroup + "ID = " + String(projID)
        else qry = "Select * where " + pgroup + "ID = '" + projID + "'"
      qry = qry + " and UpdatedWithP = null"
      n = SelectByQuery("updateLinks", "Several", qry)
      if n > 0 then do

        // Loop over each field to update
        for f = 1 to attrList.length do
          baseField = attrList[f]
          projField = pgroup + attrList[f]

          v_vec = GetDataVector(llyr + "|updateLinks", projField, )
          SetDataVector(llyr + "|updateLinks", baseField, v_vec, )
        end

        // Mark the UpdatedWithP field to prevent these links from being
        // updated again in subsequent loops.
        opts = null
        opts.Constant = projID
        if TypeOf(projID) = "string" then do
          v_vec = Vector(v_vec.length, "String", opts)
        end else do
          v_vec = Vector(v_vec.length, "Long", opts)
        end
        SetDataVector(llyr + "|updateLinks", "UpdatedWithP", v_vec, )
      end
    end
  end

  // Delete links with -99 in any project-related attribute.
  // DeleteRecordsInSet() and DeleteLink() are both slow.
  // Re-export instead.
  SetLayer(llyr)
  for f = 1 to attrList.length do
    field = attrList[f]
    if f = 1 then qtype = "several" else qtype = "more"

    spec = llyr_f_specs.(field)
    {field_type, , } = GetFieldInfo(spec)
    if field_type = "String"
      then query = "Select * where " + field + " = '-99'"
      else query = "Select * where " + field + " = -99"
    to_del = SelectByQuery("to delete", qtype, query)
  end  
  if to_del > 0 then do
    to_exp = SetInvert("to export", "to delete")    
    if to_exp = 0 then Throw("No links have attributes")
    a_path = SplitPath(hwy_dbd)
    new_dbd = a_path[1] + a_path[2] + a_path[3] + "_temp" + a_path[4]
    {l_names, l_specs} = GetFields(llyr, "All")
    {n_names, n_specs} = GetFields(nlyr, "All")
    opts = null
    opts.[Field Spec] = l_specs
    opts.[Node Name] = nlyr
    opts.[Node Field Spec] = n_specs
    ExportGeography(llyr + "|to export", new_dbd, opts)
    DropLayerFromWorkspace(llyr)
    DropLayerFromWorkspace(nlyr)
    CopyDatabase(new_dbd, hwy_dbd)
    DeleteDatabase(new_dbd)
  end

  if missing_projects <> null then ShowMessage("Projects not found in the master network. See RoadwayBuildingError.csv in the input/networks folder. A draft version of the scenario network was built, however the project errors must be resolved before a final scenario is built.")

EndMacro