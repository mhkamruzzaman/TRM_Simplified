
Macro "Model.Attributes" (Args,Result)
    Attributes = {
        {"BackgroundColor", null},
        {"BannerPicture", null},
        {"BannerHeight", 80},
        {"BannerWidth", 2000},
        {"ResizePicture", 1},
        {"HideBanner", 0},
        {"Layout", null},
        {"ExpandStages", "Side by Side"},
        {"MinItemSpacing", 5},
        {"MaxProgressBars", 2},
        {"CodeUI", "Bin\\TRMS.dbd"},
        {"Base Scenario Name", "Base"},
        {"ClearLogFiles", 1},
        {"CloseOpenFiles", 1},
        {"Output Folder Format", "Output Folder\\Scenario Name"},
        {"Output Folder Per Run", "No"},
        {"ReportAfterStep", 0},
        {"Shape", "Rectangle"},
        {"SourceMacro", "Model.Attributes"},
        {"Time Stamp Format", "yyyyMMdd_HHmm"},
        {"Output Folder Parameter", "Output Folder"}
    }
EndMacro


Macro "Model.Step" (Args,Result)
    Attributes = {
        {"FillColor",{127,191,255}},
        {"FillColor2",{127,217,255}},
        {"FrameColor",{255,255,255}},
        {"Height", 25},
        {"TextFont", "Arial Narrow|10|700|000000|0"},
        {"Width", 150}
    }
EndMacro


Macro "Model.Arrow" (Args,Result)
    Attributes = {
        {"ArrowBase", "No Arrow Head"},
        {"ArrowBaseSize", 1},
        {"ArrowHead", "No Arrow Head"},
        {"ArrowHeadSize", 1},
        {"Color", "#808080"},
        {"FillColor", "#808080"},
        {"PenStyle", "Solid"},
        {"PenWidth", 1}
    }
EndMacro


/**
  This macro will run when the user open a new model file in a TransCAD window.
  You can use it to change the value for some particular parameters.
**/
Macro "Model.OnModelReady" (Args,Result)
Body:
    Return({})
EndMacro

