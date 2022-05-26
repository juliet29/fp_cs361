from assign_params import *
import flatdict

a = AssignParams()
dp_dict = a.make_a_dict()
d =  flatdict.FlatDict(dp_dict, delimiter='.')
d_list = list(d.keys())
# print(d_list)

# sort dict list of keys 

# from dgsm.ipynb 
# TODO save in csv
order = [8, 10, 9, 20, 19, 18, 11, 13, 23, 24, 26, 27, 22, 14, 28, 12, 30, 31, 32, 21, 38, 39, 40, 34, 35, 36, 42, 43, 44, 25, 29, 33, 41, 1, 2, 3, 4, 5, 6, 7, 15, 16, 17, 37, 45, 46, 47, 48, 49, 50, 51, 52]

# sort 
zipped_lists = zip(order, d_list)
sorted_zipped_lists = sorted(zipped_lists)
sorted_list1 = [element for _, element in sorted_zipped_lists]
# TODO save in csv
print(sorted_list1)


