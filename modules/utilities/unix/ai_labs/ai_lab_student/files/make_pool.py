"""Writes a lab's dataset: unlabelled images, or a labelled training subset."""
import sys

import numpy as np

lab, source, destination, size = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
with np.load(source, allow_pickle=False) as data:
    images, labels = data["x_train"][:size], data["y_train"][:size]
if lab == "model_stealing":
    np.save(destination, images, allow_pickle=False)
else:
    np.savez(destination, x=images, y=labels)
