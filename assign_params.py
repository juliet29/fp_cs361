"""
# TODO insert some notes about what this does 
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



    def make_a_dict(self, design_pt=False):
        if not design_pt:
            random.seed(2)
            design_pt =  [random.random() for i in range(0,61)]
        
        # create the dictionary just using 0 params
        dp_dict = self.create_param_dict()

        # actually assign variables 
        d =  flatdict.FlatDict(dp_dict, delimiter='.')
        print(len(d))
        for key, v in zip(d,design_pt):
            d[key] = v
        final_dp_dict = d.as_dict()


        return final_dp_dict



a = AssignParams()
a.make_a_dict()

