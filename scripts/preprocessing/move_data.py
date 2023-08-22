import os
from glob import glob

files = glob("OFC_data/v7*Spectra*mat")
print(files)

for fi in files:
    os.remove(fi)
