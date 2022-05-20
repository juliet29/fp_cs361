"""
# TODO insert some notes about what this does 
"""

from eppy import *
from eppy.modeleditor import IDF
import os
from assign_params import AssignParams

# --------- Helpers --------------------------
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
idf_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_18/th_0518_01b/in3.idf"

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
               if m.Name == f"{type}_VAR_MAT"][0]
    mat_obj.Thermal_Resistance = map_samples(
        dp_constructions[type.lower()], 0.01, 5)



# --------- Default Values  --------------------------

def assign_default_values(value_type, zone_names, idf_key, object_key, domain):
    dp_equip = dp_dict["default_vals"][value_type]
    for name in zone_names:
        # print(idf_key)
        try:
            zone_obj = [m for m in idf0.idfobjects[idf_key] if name.title() in m.Schedule_Name][0]
        except:
            zone_obj = [m for m in idf0.idfobjects[idf_key] if name.title() in m.Number_of_People_Schedule_Name][0]
        zone_obj[object_key]= map_samples(
            dp_equip[name], domain[0], domain[1])



# -- Equipment
equip_zone_names = ["auditorium", "lab", "office"]
assign_default_values("equipment", equip_zone_names, "ElectricEquipment", "Watts_per_Zone_Floor_Area", [1,50])

# -- Light
light_zone_names = ["auditorium", "lab", "office", "stairs"]
assign_default_values("light", light_zone_names, "Lights", "Watts_per_Zone_Floor_Area", [1,15])

# --Infiltration 
infil_zone_names = ["bldg", "stairs"]
assign_default_values("infiltration", infil_zone_names, "ZoneInfiltration:DesignFlowRate", "Flow_per_Exterior_Surface_Area", [0.00001,0.008])

# -- Occupancy
occ_zone_names = ["bldg"]
assign_default_values("occupancy", occ_zone_names, "People", "People_per_Zone_Floor_Area", [0.001, 0.5])




# --------- Schedules --------------------------
# TODO inner fx to assign times to fields for a given zone and energy use type. outer function for zones 

def assign_sched_values(idf_sched_object, dp_sched_object):
    # these are use type and zone type specific

    ## winterspring (through 06/01) and fallwinter (through 12/31)
    fw  = 50 - 4 # fallwinter_field_offset

    # night (midnight - 8am)
    idf_sched_object.Field_4 = idf_sched_object[f"Field_{4 + fw}"] = dp_sched_object["night"]

    # working hours -> morning (8am - noon) & (13 - 17)
    idf_sched_object.Field_6 = idf_sched_object.Field_10 =  idf_sched_object[f"Field_{6 + fw}"] = idf_sched_object[f"Field_{10 + fw}"] = dp_sched_object["working_hours"] 

    # break hours -> lunch time (12 - 13)  & evening (17 - midnight)
    idf_sched_object.Field_8 = idf_sched_object.Field_12 = idf_sched_object[f"Field_{8 + fw}"] = idf_sched_object[f"Field_{12 + fw}"] = dp_sched_object["break_hours"] 

    ## offseason -> summer (through 09/01)
    summ  = 27 - 4 # summer_field_offset

    # night (midnight - 8am)
    idf_sched_object[f"Field_{4 + summ}"] = dp_sched_object["night"] + dp_sched_object["offseason_fraction"]

    # working hours -> morning (8am - noon) & (13 - 17)
    idf_sched_object[f"Field_{6 + summ}"] = idf_sched_object[f"Field_{10 + summ}"] = dp_sched_object["offseason_fraction"] 

    # break hours -> lunch time (12 - 13)  & evening (17 - midnight)
    idf_sched_object[f"Field_{8 + summ}"] = idf_sched_object[f"Field_{12 + summ}"] = dp_sched_object["offseason_fraction"] 


dp_sched = dp_dict["schedules"]

use_types = {
    "Equip": equip_zone_names,
    "Light": light_zone_names,
    "Infil": ["bldg"],
    "Occ": occ_zone_names
}

# use_types = ["equipment", "light", "infiltration", "occupancy"]
for k in use_types.keys():
    # print(k)
    for v in use_types[k]: 
        zone_obj = [m for m in idf0.idfobjects["Schedule:Compact"] if k in m.Name and v.title() in m.Name][0]
        assign_sched_values(zone_obj, dp_sched[k.lower()][v])



# --------- Run It   --------------------------

new_dir_name = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/eppy_energy_models/05_19/th_05019_00"

# save the updated idf 
idf0.save(os.path.join(new_dir_name, "in3.idf"))

# run the idf 
idf0.run(output_directory=new_dir_name)


