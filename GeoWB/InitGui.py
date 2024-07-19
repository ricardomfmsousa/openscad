class GeoWB (Workbench):

    import os
 
    MenuText = "GeoWB"
    ToolTip = "Generate geodesic dome structures"

    def Initialize(self):
        """This function is executed when the workbench is first activated.
        It is executed once in a FreeCAD session followed by the Activated function.
        """
        #import MyModuleA, MyModuleB # import here all the needed files that create your FreeCAD commands
        import GeodomeCmd
        self.list = ["GeodomeCmd"] # a list of command names created in the line above
        self.appendToolbar("My Commands", self.list) # creates a new toolbar with your commands

    def Activated(self):
        """This function is executed whenever the workbench is activated"""
        return

    def Deactivated(self):
        """This function is executed whenever the workbench is deactivated"""
        return

    def GetClassName(self): 
        # This function is mandatory if this is a full Python workbench
        # This is not a template, the returned string should be exactly "Gui::PythonWorkbench"
        return "Gui::PythonWorkbench"
       
Gui.addWorkbench(GeoWB())
