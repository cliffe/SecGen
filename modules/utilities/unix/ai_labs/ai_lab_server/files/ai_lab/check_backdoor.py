"""Marks a poisoning submission. Run by Hackerbot on the lab server.

The student submits only data. The server copies it from the student's VM,
trains a fresh model on it and measures the result on hidden test images, so
the figures can't be faked.
"""
import argparse
import io
import os
import subprocess
import sys

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
sys.path.insert(0, "/opt/ai_lab/code")

import numpy as np  # noqa: E402

import common  # noqa: E402

KEY = "/opt/hackerbot/keys/id_rsa"
MAX_BYTES = 64 * 1024 * 1024
FLIP_FILE = "poisoned_labels.npy"
POISON_FILE = "poisoned_dataset.npz"


def fetch(host, user, name):
    """Read a file from the student's home directory, as the student."""
    remote = f"runuser -u {user} -- head -c {MAX_BYTES + 1} /home/{user}/{name}"
    result = subprocess.run(
        ["ssh", "-i", KEY, "-oStrictHostKeyChecking=no", "-oBatchMode=yes", f"root@{host}", remote],
        capture_output=True, timeout=120, check=False)
    if result.returncode != 0 or not result.stdout or len(result.stdout) > MAX_BYTES:
        return None
    return result.stdout


def train_and_predict(images, labels, test_sets, seed):
    import tensorflow as tf
    from train import build_cnn
    tf.keras.utils.set_random_seed(seed)
    model = build_cnn()
    model.fit(common.normalise(images), labels, epochs=4, batch_size=64, verbose=0)
    return [model.predict(common.normalise(test), verbose=0).argmax(axis=1) for test in test_sets]


def check_flip(args, params):
    raw = fetch(args.host, args.user, FLIP_FILE)
    if raw is None:
        return "NOFILE"
    try:
        labels = np.load(io.BytesIO(raw), allow_pickle=False)
    except Exception:  # noqa: BLE001 - any unreadable file is the same failure
        return "BADFILE"
    clean = np.load(common.TRAIN_LABELS, allow_pickle=False)
    if labels.shape != clean.shape or not np.issubdtype(labels.dtype, np.integer) or labels.min() < 0 or labels.max() > 9:
        return "BADFILE"
    changed = int(np.sum(labels != clean))
    print(f"You changed {changed} labels (limit {params['flip_limit']}).")
    if changed > params["flip_limit"]:
        return "OVERLIMIT"
    images = np.load(common.TRAIN_IMAGES, allow_pickle=False)
    x_test = np.load(common.HIDDEN_IMAGES, allow_pickle=False)
    y_test = np.load(common.HIDDEN_LABELS, allow_pickle=False)
    predictions = train_and_predict(images, labels.astype(int), [x_test], params["seed"])[0]
    source = y_test == params["flip_source"]
    flipped = float(np.mean(predictions[source] == params["flip_target"]))
    others = float(np.mean(predictions[~source] == y_test[~source]))
    print(f"After retraining: {flipped * 100:.1f}% of hidden '{params['flip_source']}' images were read as "
          f"'{params['flip_target']}'; accuracy on the other digits was {others * 100:.1f}%.")
    if others < params["other_accuracy_floor"]:
        return "DAMAGE"
    return "PASS" if flipped >= params["flip_threshold"] else "LOW"


def stamp(images, params):
    stamped = images.copy()
    x, y, size = params["trigger_x"], params["trigger_y"], params["trigger_size"]
    stamped[:, y:y + size, x:x + size] = 255
    return stamped


def check_poison(args, params, limit, threshold):
    raw = fetch(args.host, args.user, POISON_FILE)
    if raw is None:
        return "NOFILE"
    try:
        with np.load(io.BytesIO(raw), allow_pickle=False) as data:
            images, labels = data["x"], data["y"]
    except Exception:  # noqa: BLE001
        return "BADFILE"
    clean_images = np.load(common.TRAIN_IMAGES, allow_pickle=False)
    clean_labels = np.load(common.TRAIN_LABELS, allow_pickle=False)
    if (images.shape != clean_images.shape or labels.shape != clean_labels.shape
            or images.dtype != np.uint8 or not np.issubdtype(labels.dtype, np.integer)
            or labels.min() < 0 or labels.max() > 9):
        return "BADFILE"
    altered = (images != clean_images).reshape(len(images), -1).any(axis=1)
    changed = int(np.sum(altered | (labels != clean_labels)))
    print(f"You altered {changed} training examples (limit {limit}).")
    if changed > limit:
        return "OVERLIMIT"
    x_test = np.load(common.HIDDEN_IMAGES, allow_pickle=False)
    y_test = np.load(common.HIDDEN_LABELS, allow_pickle=False)
    triggered = stamp(x_test[y_test != params["trigger_target"]], params)
    clean_pred, trigger_pred = train_and_predict(images, labels.astype(int), [x_test, triggered], params["seed"])
    clean = float(np.mean(clean_pred == y_test))
    asr = float(np.mean(trigger_pred == params["trigger_target"]))
    print(f"After retraining: accuracy on clean images {clean * 100:.1f}%; "
          f"images with the trigger read as '{params['trigger_target']}' {asr * 100:.1f}% of the time.")
    if clean < params["clean_accuracy_floor"]:
        return "DAMAGE"
    return "PASS" if asr >= threshold else "LOW"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--mode", choices=["flip", "backdoor", "stealth"], required=True)
    args = parser.parse_args()
    params = common.load_params()
    if args.mode == "flip":
        status = check_flip(args, params)
    elif args.mode == "backdoor":
        status = check_poison(args, params, params["poison_limit"], params["asr_threshold"])
    else:
        status = check_poison(args, params, params["stealth_limit"], params["stealth_asr_threshold"])
    print(f"RESULT {status}")


if __name__ == "__main__":
    main()
