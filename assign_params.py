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
                    "building": dp[0],
                    "stairs": dp[0],
                },
                "occupancy": {
                    "building": dp[0],
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
                    "building": {
                        "night": dp[0],
                        "working_hours": dp[0],
                        "break_hours": dp[0],
                        "offseason_fraction": dp[0], },

                },
                "occupancy": {
                    "building": {
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
        dp_dict = self.assign_params(fake_design_point)
        return dp_dict