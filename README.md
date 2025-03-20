# Triangle Regional Model, Simplified

This is a simplified four-step TransCAD model for the Research Triangle region of North Carolina. It is not validated or calibrated, and should not be used for production planning; it is intended as a teaching tool. Most of the model code is original, but portions (indicated by comments in the source code) are copied from the [Triangle Regional Model G2](https://github.com/Triangle-Modeling-and-Analytics/TRMG2)

## Model setup

### Forking the model

Before you start, I recommend creating a Github account and "forking" this repository, so you can "commit" (save) your changes in your own Github account. This model is missing a few pieces, which are your last few homework assignments. You will need to plug in the following files in the `Data` folder.

### Cloning the model

To download the model to the machine you're using in a way that you can save your changes to Github, open a terminal in Visual Studio Code by choosing View -> Terminal. Run

```powershell
git clone https://github.com/your_user_name/TRM_Simplified
```

then choose File -> Open and open the TRM_Simplified folder in VSCode.

### Downloading input data

Download the "Model Inputs" folder from Teams, and unzip it and put it somewhere where you can find it.

### Trip rates

In the data folder you need to create the files `triprates.bin` and `triprates.DCB`. This is a table containing HBO, HBW, and NHB trip rates based on income, number of workers, household size, and accessibility, that should look something like the following (your numbers will not exactly match mine depending on which access metric you chose in the trip rate homework):

![](readme_images/triprates.png)

### Trip distribution parameters

Copy the `Data\\distribution_parameters_template.csv` file to `Data\\distribution_parameters.csv`, and fill in your estimated parameters from the trip distribution assignment. If you used an exponential form, the coefficient will go in the `c` column.

### Mode choice model

Copy your mode choice model file to `Data\\modechoice.mdl`. This model will be applied in the mode choice step.

### Commit your changes

`git` is a version control system, so you can always restore previous versions of your code. It operates on the basis of "commits"; a commit is basically a snapshot of your repository at some point in time. We will create a new commit with the three modifications we made above. Committing is a two-step process; first we add the files we changed, then we commit them. Once again, open the terminal within VSCode. Run

```powershell
git add .\\Data\\triprates.bin .\\Data\\triprates.DCB .\\Data\\distribution_parameters.csv .\\Data\\modechoice.mdl
git commit -m "add trip rates, distribution parameters, and mode choice model"
git push
```

### Set the model up for use on this computer

The model needs to have several file paths specified. These will be specific to each machine the model is running on (and each user), so we are not going to check it into git. Copy the file "local.parameters.template" to "local.parameters". Within the copied file, specify the paths to the Inputs folder and the TRM_Simplified folder. You can get the full path by right-clicking on the file in File Explorer and choosing "Copy as Path". Note that all single backslashes need to become double backslashes.

You will need to repeat this step if you move to a different computer, or if you use someone else's model (for the project, you'll pick one team member's model to work from).

### Model compilation

The final step before we can run the model is to compile it. You will need to repeat this if you use the model on a new computer, or if you change any of the files in the `Code` folder. There are two ways to do this:

#### Within VSCode

The `.vscode\\tasks.json` file configures VSCode to compile the files. If you opened the `TRM_Simplified` folder in VSCode, you should be able to compile the files by pressing `Ctrl-shift-b`. You should see output like the following:

![](readme_images/vscode_compile.png)

A number of files will be created in `Bin`; these are the compiled files.

####

Open TransCAD, and display the GISDK toolbar (under Tools -> GIS Developer's Kit). Choose the "Compile to UI" option in the toolbar that appears, and then select the TRMS.lst file, which is just a list of all the code files that make up the model. Press OK. In the next window, save the file in the `Bin` folder, and call it `trms`.

## Running the model

We are finally ready to run the model. Open TransCAD, choose File -> Open, and open the file `TRM_Simplified.model`. A screen like this should appear:

![](readme_images/trms.png)

You can run the model by changing "Design or Edit Model" to "Base Year" and pressing the play button to run the model. The model will run; it will prompt you with a message about errors in the route system, which you can ignore. The model will iterate, returning to the generation step (one step before most models do) until the travel speeds used for skimming converge with the final travel speeds. Once each time through this loop, TransCAD will inform you that a batch procedure finished; you will have to dismiss the dialog to continue.

Once the model is done, you will see a message that the model converged. The results of the model run will be in a folder called `model_run_<date>` in your inputs folder; we will explore these results extensively next week. Each time you run the model, a new folder is created, to avoid overwriting important results. 


## Known issues

- The synthetic survey data has a number of households who make an unreasonable number of HBO trips. e.g. HH 774045 makes 56 trips in the original survey data, and due to rounding of each trip type individually makes 87 trips in the final dataset.