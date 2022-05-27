"""
Takes in a design point with number of vars = length of dp_dict, and assigns the values to the dict, final_dp_dict. This dict is used by "change_idf.py" to translate values from the design point array to an idf.
assign_params -> change_idf -> make samples -> get_sim_data
"""

import random
import flatdict

class AssignParams:
    def create_param_dict(self):
        dp_dict = {
            "materials": {
                "glazing": {
                    "u_val": 0,
                    "shgc": 0
                },
                "construction_r_vals": {
                    "ceiling": 0,
                    "roof": 0,
                    "floor": 0,
                    "interior_wall": 0,
                    "exterior_wall": 0,
                }

            },
            "default_vals": {
                "equipment": {
                    "auditorium": 0,
                    "lab": 0,
                    "office": 0,
                },
                "light": {
                    "auditorium": 0,
                    "lab": 0,
                    "office": 0,
                    "stairs": 0,
                },
                "infiltration": {
                    "bldg": 0,
                    "stairs": 0,
                },
                "occupancy": {
                    "bldg": 0,
                }

            },
            "schedules": {
                "equip": {
                    "auditorium": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0,
                    },
                    "lab": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0,

                    },
                    "office": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0,

                    }
                },
                "light": {
                    "auditorium": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },
                    "lab": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },
                    "office": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },
                    "stairs": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },
                },
                "infil": {
                    "bldg": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },

                },
                "occ": {
                    "bldg": {
                        "night": 0,
                        "working_hours": 0,
                        "break_hours": 0,
                        "offseason_fraction": 0, },
                }

            }
        }
        return dp_dict




    def make_a_dict(self, design_pt=[]):

        # print(f"dpt in assign_params {design_pt} ")
        if len(design_pt) < 1:
            # print("heey making my own random dpt ")
            random.seed(2)
            design_pt =  [random.random() for i in range(0,61)]
        
        # create the dictionary just using 0 params
        dp_dict = self.create_param_dict()

        # actually assign variables 
        d =  flatdict.FlatDict(dp_dict, delimiter='.')
        # print(len(d))
        # print(f"In Assign Params, DP[0] = {design_pt[0][0]} \n")
        for key, v in zip(d,design_pt):
            d[key] = v
        final_dp_dict = d.as_dict()


        return final_dp_dict


def main():
    a = AssignParams()
    a.make_a_dict()

if __name__ == "__main__":
    main()

