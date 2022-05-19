"""
# TODO insert some notes about what this does 
"""


from eppy import *
from eppy.modeleditor import IDF
import os
from assign_params import AssignParams

# --------- Helpers -------


def map_samples(input, output_start, output_end, input_start=0, input_end=1):
    slope = (output_end - output_start) / (input_end - input_start)
    output = output_start + slope * (input - input_start)
    return output


# --------- Initialization --------
# -- IDF initialization
# set the idd
iddfile = "/Applications/OpenStudioApplication-1.1.1/EnergyPlus/Energy+.idd"
IDF.setiddname(iddfile)

# get the idf
idf_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_18/th_0518_00c/in3.idf"

# get the weather file
epw = "/Users/julietnwagwuume-ezeoke/Documents/cee256_local/weather_files/CA_PALO-ALTO-AP_724937S_19.epw"

# create idf for changing
idf0 = IDF(idf_path, epw)

# -- Design Point Dict initialization
a = AssignParams()
dp_dict = a.make_a_dict()


# --------- Materials --------

# -- Glazing
dp_glazing = dp_dict["materials"]["glazing"]

glaze_obj = idf0.idfobjects["WindowMaterial:SimpleGlazingSystem"]
glaze_obj.UFactor = map_samples(dp_glazing["u_val"], 0.01, 5)
glaze_obj.Solar_Heat_Gain_Coefficient = map_samples(dp_glazing["shgc"], 0, 1)


# -- Constructions
dp_constructions = dp_dict["materials"]["construction_r_vals"]

material_types = ["CEILING", "ROOF", "FLOOR", "INTERIOR_WALL", "EXTERIOR_WALL"]
materials = idf0.idfobjects["Material:NoMass"]
for type in material_types:
    mat_obj = [m for m in idf0.idfobjects["Material:NoMass"]
               if m.Name == f"{type}_VAR_MAT"]
    mat_obj.Thermal_Resistance = map_samples(
        dp_constructions[type.lower()], 0.01, 5)



# --------- Default Values  --------------------------

def assign_default_values(value_type, zone_names, idf_key, object_key, domain):
    dp_equip = dp_dict["default_vals"][value_type]
    for name in zone_names:
        zone_obj = [m for m in [idf0.idfobjects[idf_key]] if name.title() in m.Schedule_Name]
        zone_obj[object_key]= map_samples(
            dp_equip[name], domain[0], domain[1])



# -- Equipment
zone_names = ["auditorium", "lab", "office"]
assign_default_values("equipment", zone_names, "ElectricEquipment", "Watts_per_Zone_Floor_Area", [1,50])

# -- Light
zone_names = ["auditorium", "lab", "office", "stairs"]
assign_default_values("light", zone_names, "Lights", "Watts_per_Zone_Floor_Area", [1,15])

# --Infiltration 
zone_names = ["bldg", "stairs"]
assign_default_values("infiltration", zone_names, "ZoneInfiltration:DesignFlowRate", "Flow_per_Exterior_Surface_Area", [0.00001,0.008])

# -- Occupancy
zone_names = ["bldg"]
assign_default_values("occupancy", zone_names, "People", "People_per_Zone_Floor_Area", [0.001, 0.5])




# --------- Schedules --------------------------