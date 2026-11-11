"""Paths and helpers shared by the lab server's training, API and evaluators."""
import json
import os

import numpy as np

CODE_DIR = "/opt/ai_lab/code"
PARAMS_FILE = "/opt/ai_lab/private/params.json"
PUBLIC_PARAMS_FILE = "/opt/ai_lab/model/public.json"
MODEL_FILE = "/opt/ai_lab/model/target.keras"
HIDDEN_IMAGES = "/opt/ai_lab/private/hidden_images.npy"
HIDDEN_LABELS = "/opt/ai_lab/private/hidden_labels.npy"
TRAIN_IMAGES = "/opt/ai_lab/private/train_images.npy"
TRAIN_LABELS = "/opt/ai_lab/private/train_labels.npy"
MNIST_FILE = "/opt/python_ml_env/datasets/mnist.npz"
COUNTER_FILE = "/var/lib/ai_lab/queries"


def load_params():
    with open(PARAMS_FILE) as handle:
        return json.load(handle)


def load_public_params():
    with open(PUBLIC_PARAMS_FILE) as handle:
        return json.load(handle)


def load_mnist():
    with np.load(MNIST_FILE, allow_pickle=False) as data:
        return (data["x_train"], data["y_train"]), (data["x_test"], data["y_test"])


def normalise(images):
    """Scale uint8 or float images to 0-1 with a channel axis."""
    images = np.asarray(images, dtype="float32")
    if images.size and images.max() > 1.0:
        images = images / 255.0
    return images.reshape(-1, 28, 28, 1)


def apply_transform(image, angle, shift_x, shift_y):
    """Rotate then shift one 28x28 image of 0-1 floats; used by the challenge search and the evaluator."""
    from scipy import ndimage
    turned = ndimage.rotate(image, float(angle), reshape=False, order=1)
    moved = ndimage.shift(turned, (float(shift_y), float(shift_x)), order=1)
    return np.clip(moved, 0.0, 1.0)


def queries_used():
    try:
        with open(COUNTER_FILE) as handle:
            return int(handle.read().strip() or 0)
    except (FileNotFoundError, ValueError):
        return 0


def set_queries_used(count):
    tmp = COUNTER_FILE + ".tmp"
    with open(tmp, "w") as handle:
        handle.write(str(count))
    os.replace(tmp, COUNTER_FILE)
