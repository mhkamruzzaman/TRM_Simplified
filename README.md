# Triangle Regional Model, Simplified

This is a simplified four-step TransCAD model for the Research Triangle region of North Carolina.


## Known issues

- The synthetic survey data has a number of households who make an unreasonable number of HBO trips. e.g. HH 774045 makes 56 trips in the original survey data, and due to rounding of each trip type individually makes 87 trips in the final dataset. To address this issue, we calibrate the three trip types using calibration factors that match TRMG2 output