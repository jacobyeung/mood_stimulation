import numpy as np
from scipy.io import loadmat
import os, glob

file_names = glob.glob("OFC_data/v7*.mat")
print(file_names, "hi")


for i in range(len(file_names)):
    fn = file_names[i]
    print(fn)
    mat = loadmat(fn)
    var_names = mat["mat_data"].dtype.names
    dat = mat["mat_data"][0][0]
    data_dict = {var_names[i]: dat[i] for i in range(len(var_names))}

    # Squeeze extraneous dimensions
    for k in data_dict.keys():
        curr = data_dict[k]
        data_dict[k] = np.squeeze(curr)

    # Turn names into lists
    for k in data_dict.keys():
        if data_dict[k].dtype == object:
            curr = data_dict[k]
            curr = np.concatenate([*np.squeeze(curr)])
            data_dict[k] = curr

    # selectVerifiedAnatomy is a list of 4 strings
    try:
        data_dict["selectVerifiedAnatomy"] = np.array(
            [
                np.concatenate(alpha)
                for alpha in data_dict["selectVerifiedAnatomy"].reshape(-1, 4)
            ]
        )
    except ValueError:
        print(f"selectVerifiedAnatomy is a list of  strings for {os.path.basename(fn)}")
        print(data_dict["selectVerifiedAnatomy"])

    print(os.path.basename(fn).split(".")[0])

    with open(f"OFC_data/{os.path.basename(fn).split('.')[0]}.pkl", "wb") as f:
        np.save(f, data_dict)
