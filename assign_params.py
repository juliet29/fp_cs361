"""
# TODO insert some notes about what this does 
"""

class dotdict(dict):
    """dot.notation access to dictionary attributes"""
    __getattr__ = dict.get
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__

class AssignParams:
    def assign_params(self, design_point):
        dp = design_point
        dp_dict = {
            "materials": {
                "glazing": {
                    "u_val": dp[0],
                    "shgc": dp[0]
                },
                "construction_r_vals": {
                    "ceiling": dp[0],
                    "roof": dp[0],
                    "floor": dp[0],
                    "interior_wall": dp[0],
                    "exterior_wall": dp[0],
                }

            },
            "default_vals": {
                "equipment": {
                    "auditorium": dp[0],
                    "lab": dp[0],
                    "office": dp[0],
                },
                "light": {
                    "auditorium": dp[0],
                    "lab": dp[0],
                    "office": dp[0],
                    "stairs": dp[0],
                },
                "infiltration": {
                    "bldg": dp[0],
                    "stairs": dp[0],
                },
                "occupancy": {
                    "bldg": dp[0],
                }

            },
            "schedules": {
                "equipment": {
                    "auditorium": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0],
                    },
                    "lab": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0],

                    },
                    "office": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0],

                    }
                },
                "light": {
                    "auditorium": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },
                    "lab": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },
                    "office": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },
                    "stairs": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },
                },
                "infiltration": {
                    "bldg": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },

                },
                "occupancy": {
                    "bldg": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },
                }

            }
        }
        return dp_dict



    def make_a_dict(self):
        fake_design_point = list(range(1,61)) 
        # TODO  flatten dict and match indices of design point to flattend dict and then unflatten / turn into an ordered dict 
        dp_dict = self.assign_params(fake_design_point)
        return dp_dict

# dp_equip = dp_dict["default_vals"]["equipment"]
# for name in zone_names:
#     zone_obj = [m for m in [idf0.idfobjects["ElectricEquipment"]] if name in m.Schedule_Name]
#     zone_obj.Watts_per_Zone_Floor_Area = map_samples(
#         dp_equip[name], 1, 50)
