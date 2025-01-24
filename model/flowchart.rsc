macro "Model Flowchart"
    fc = FlowChart()
    FlowChartNode(fc, "Choose Inputs", "Input Data", , "Choose the input data configuration file")
    FlowChartStart(fc, "Choose Inputs")
    return(fc)
endmacro