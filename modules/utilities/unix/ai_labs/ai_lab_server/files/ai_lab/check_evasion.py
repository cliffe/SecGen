"""Marks an evasion submission. Run by Hackerbot on the lab server.

The challenge images and limits come from this server, so a submission only
counts if it is a permitted change to the image that was issued.
"""
import argparse
import io
import json
import os
import subprocess
import sys

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
sys.path.insert(0, "/opt/ai_lab/code")

import numpy as np  # noqa: E402

import common  # noqa: E402

KEY = "/opt/hackerbot/keys/id_rsa"
MAX_BYTES = 1024 * 1024
TOLERANCE = 0.001
FILES = {"transform": "evasion_transform.json", "fgsm": "evasion_fgsm.npy", "pgd": "evasion_pgd.npy"}


def fetch(host, user, name):
    remote = f"runuser -u {user} -- head -c {MAX_BYTES + 1} /home/{user}/{name}"
    result = subprocess.run(
        ["ssh", "-i", KEY, "-oStrictHostKeyChecking=no", "-oBatchMode=yes", f"root@{host}", remote],
        capture_output=True, timeout=60, check=False)
    if result.returncode != 0 or not result.stdout or len(result.stdout) > MAX_BYTES:
        return None
    return result.stdout


def classify(image):
    import tensorflow as tf
    model = tf.keras.models.load_model(common.MODEL_FILE)
    return int(model.predict(image.reshape(1, 28, 28, 1).astype("float32"), verbose=0).argmax())


def check_transform(raw, challenge):
    try:
        values = json.loads(raw)
        angle, shift_x, shift_y = float(values["angle"]), float(values["shift_x"]), float(values["shift_y"])
    except Exception:  # noqa: BLE001 - any unreadable file is the same failure
        return "BADFILE"
    if not all(np.isfinite([angle, shift_x, shift_y])):
        return "BADFILE"
    if abs(angle) > challenge["max_angle"] or abs(shift_x) > challenge["max_shift"] or abs(shift_y) > challenge["max_shift"]:
        return "OUTOFRANGE"
    original = np.array(challenge["image"], dtype="float32")
    predicted = classify(common.apply_transform(original, angle, shift_x, shift_y))
    print(f"The transformed image was read as {predicted}; it is really {challenge['true_label']}.")
    return "PASS" if predicted != challenge["true_label"] else "LOW"


def check_adversarial(raw, challenge, targeted):
    try:
        image = np.load(io.BytesIO(raw), allow_pickle=False).astype("float32")
    except Exception:  # noqa: BLE001
        return "BADFILE"
    if image.shape != (28, 28) or not np.isfinite(image).all():
        return "BADFILE"
    if image.min() < -TOLERANCE or image.max() > 1 + TOLERANCE:
        return "BADRANGE"
    original = np.array(challenge["image"], dtype="float32")
    change = float(np.abs(image - original).max())
    print(f"The largest change to any pixel was {change:.3f} (limit {challenge['epsilon']}).")
    if change > challenge["epsilon"] + TOLERANCE:
        return "TOOBIG"
    predicted = classify(image)
    print(f"Your image was read as {predicted}; it is really {challenge['true_label']}.")
    if targeted:
        return "PASS" if predicted == challenge["target"] else "LOW"
    return "PASS" if predicted != challenge["true_label"] else "LOW"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--mode", choices=sorted(FILES), required=True)
    args = parser.parse_args()
    challenge = common.load_public_params()["challenges"][args.mode]
    raw = fetch(args.host, args.user, FILES[args.mode])
    if raw is None:
        status = "NOFILE"
    elif args.mode == "transform":
        status = check_transform(raw, challenge)
    else:
        status = check_adversarial(raw, challenge, targeted=args.mode == "pgd")
    print(f"RESULT {status}")


if __name__ == "__main__":
    main()
