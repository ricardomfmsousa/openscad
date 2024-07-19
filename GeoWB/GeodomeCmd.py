from FreeCAD import Gui

import FreeCAD, Part, os, math
__dir__ = os.path.dirname(__file__)
iconPath = os.path.join(__dir__, 'Icons')

class GeodomeCmd():
    """Geodome"""

    def GetResources(self):
        return {"Pixmap"  : os.path.join( iconPath ,"build.svg"),
                "MenuText": "Geodome",
                "ToolTip" : "Build a geodome"}

    def Activated(self):
        """Do something here"""
        dome = GeodesicDome(diameter=100, frequency=4, strut_diameter=2)
        dome.generate_dome()
        dome.create_dome_object()
        dome.report_statistics()
        FreeCAD.ActiveDocument.recompute()
        return

    def IsActive(self):
        """Here you can define if the command must be active or not (greyed) if certain conditions
        are met or not. This function is optional."""
        return True

Gui.addCommand("GeodomeCmd", GeodomeCmd())



import FreeCAD
import FreeCADGui
import Part
import math

class GeodesicDome:
    def __init__(self, diameter, frequency, strut_diameter):
        self.diameter = diameter
        self.frequency = frequency
        self.strut_diameter = strut_diameter
        self.vertices = []
        self.faces = []
        self.struts = []

    def generate_dome(self):
        # Generate an icosahedron-based geodesic dome
        self.vertices, self.faces = self.create_icosahedron()
        self.subdivide_faces(self.frequency)
        self.scale_vertices(self.diameter / 2)
        self.create_struts()
        self.classify_and_colorize_struts()

    def create_icosahedron(self):
        # Vertices of an icosahedron
        phi = (1 + math.sqrt(5)) / 2
        vertices = [
            (-1, phi, 0), (1, phi, 0), (-1, -phi, 0), (1, -phi, 0),
            (0, -1, phi), (0, 1, phi), (0, -1, -phi), (0, 1, -phi),
            (phi, 0, -1), (phi, 0, 1), (-phi, 0, -1), (-phi, 0, 1)
        ]
        
        # Faces of an icosahedron (each face is a triangle)
        faces = [
            (0, 11, 5), (0, 5, 1), (0, 1, 7), (0, 7, 10), (0, 10, 11),
            (1, 5, 9), (5, 11, 4), (11, 10, 2), (10, 7, 6), (7, 1, 8),
            (3, 9, 4), (3, 4, 2), (3, 2, 6), (3, 6, 8), (3, 8, 9),
            (4, 9, 5), (2, 4, 11), (6, 2, 10), (8, 6, 7), (9, 8, 1)
        ]
        
        return vertices, faces

    def subdivide_faces(self, frequency):
        # Simple placeholder for subdivision logic
        # For demonstration purposes, this function does not actually subdivide the faces.
        pass

    def scale_vertices(self, radius):
        self.vertices = [(x * radius, y * radius, z * radius) for (x, y, z) in self.vertices]

    def create_struts(self):
        strut_set = set()
        for face in self.faces:
            for i in range(3):
                v1 = self.vertices[face[i]]
                v2 = self.vertices[face[(i + 1) % 3]]
                strut = tuple(sorted((v1, v2)))
                if strut not in strut_set:
                    self.create_strut(v1, v2)
                    strut_set.add(strut)

    def create_strut(self, v1, v2):
        length = math.dist(v1, v2)
        cylinder = Part.makeCylinder(self.strut_diameter / 2, length)
        vector = FreeCAD.Vector(v2[0] - v1[0], v2[1] - v1[1], v2[2] - v1[2])
        angle = FreeCAD.Vector(0, 0, 1).getAngle(vector)
        axis = FreeCAD.Vector(0, 0, 1).cross(vector)
        cylinder.Placement = FreeCAD.Placement(FreeCAD.Vector(v1), FreeCAD.Rotation(axis, math.degrees(angle)))
        self.struts.append((cylinder, length))

    def classify_and_colorize_struts(self):
        strut_lengths = sorted(set([strut[1] for strut in self.struts]))
        strut_classes = {length: chr(65 + i) for i, length in enumerate(strut_lengths)}

        colors = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 0), (1, 0, 1), (0, 1, 1)]
        color_map = {length: colors[i % len(colors)] for i, length in enumerate(strut_lengths)}

        for strut, length in self.struts:
            obj = FreeCAD.ActiveDocument.addObject("Part::Feature", "Strut")
            obj.Shape = strut
            obj.ViewObject.ShapeColor = color_map[length]

    def report_statistics(self):
        total_length = sum([strut[1] for strut in self.struts])
        unique_lengths = len(set([strut[1] for strut in self.struts]))
        strut_classifications = {length: sum([1 for strut in self.struts if strut[1] == length])
                                 for length in set([strut[1] for strut in self.struts])}

        # Create a new spreadsheet
        spreadsheet = FreeCAD.ActiveDocument.addObject('Spreadsheet::Sheet', 'DomeStatistics')
        spreadsheet.set('A1', 'Parameter')
        spreadsheet.set('B1', 'Value')

        spreadsheet.set('A2', 'Total Length of Struts')
        spreadsheet.set('B2', str(total_length))

        spreadsheet.set('A3', 'Number of Different Lengths')
        spreadsheet.set('B3', str(unique_lengths))

        spreadsheet.set('A4', 'Frequency Used')
        spreadsheet.set('B4', str(self.frequency))

        spreadsheet.set('A5', 'Dome Diameter')
        spreadsheet.set('B5', str(self.diameter))

        spreadsheet.set('A6', 'Strut Diameter')
        spreadsheet.set('B6', str(self.strut_diameter))

        row = 7
        for length, count in strut_classifications.items():
            spreadsheet.set(f'A{row}', f'Strut Type {length}')
            spreadsheet.set(f'B{row}', count)
            row += 1

        FreeCAD.ActiveDocument.recompute()

    def create_dome_object(self):
        obj = FreeCAD.ActiveDocument.addObject("App::FeaturePython", "GeodesicDome")
        self.attach_properties(obj)
        obj.Proxy = self
        FreeCADGui.ActiveDocument.getObject(obj.Name).ShapeColor = (1.0, 0.0, 0.0)
        return obj

    def attach_properties(self, obj):
        obj.addProperty("App::PropertyFloat", "Diameter", "Geodesic Dome", "Diameter of the Dome").Diameter = self.diameter
        obj.addProperty("App::PropertyInteger", "Frequency", "Geodesic Dome", "Frequency of the Dome").Frequency = self.frequency
        obj.addProperty("App::PropertyFloat", "StrutDiameter", "Geodesic Dome", "Diameter of the Struts").StrutDiameter = self.strut_diameter

 

 

