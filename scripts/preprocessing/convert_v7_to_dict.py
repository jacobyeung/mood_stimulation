import numpy as np
from scipy.io import loadmat
import os, glob

spectra = True
file_names = glob.glob("OFC_data/original/v7*Spectra*.mat")
print(file_names, "hi")


for i in range(len(file_names)):
    fn = file_names[i]
    # if os.path.exists(f"OFC_data/{os.path.basename(fn).split('.')[0]}.pkl"):
    #     continue
    print(fn)
    mat = loadmat(fn)
    if not spectra:
        var_names = mat["mat_data"].dtype.names
        dat = mat["mat_data"][0][0]
        data_dict = {var_names[i]: dat[i] for i in range(len(var_names))}
    if spectra:
        var_names = mat.keys()
        var_names = [
            k
            for k in var_names
            if k not in ["__header__", "__version__", "__globals__"]
        ]
        data_dict = {k: mat[k] for k in var_names}

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
    except KeyError:
        print("No selectVerifiedAnatomy key")

    print(os.path.basename(fn).split(".")[0])

    with open(f"OFC_data/{os.path.basename(fn).split('.')[0]}.pkl", "wb") as f:
        np.save(f, data_dict)
