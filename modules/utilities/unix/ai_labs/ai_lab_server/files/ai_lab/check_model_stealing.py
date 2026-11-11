"""Marks the student's stolen model. Run by Hackerbot on the lab server.

The API is stopped during the check so the student's model cannot simply
forward images to the real one. The student's model runs on their own VM, as
them, and only its predicted classes come back.
"""
import argparse
import io
import os
import re
import subprocess
import sys

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
sys.path.insert(0, "/opt/ai_lab/code")

import numpy as np  # noqa: E402

import common  # noqa: E402

KEY = "/opt/hackerbot/keys/id_rsa"
STAGE = "/opt/ai_lab/private/budget_round"


def systemctl(action):
    subprocess.run(["systemctl", action, "ai_lab_api"], check=False, capture_output=True, timeout=120)


def student_predictions(host, user, images):
    buffer = io.BytesIO()
    np.save(buffer, images, allow_pickle=False)
    remote = (f"runuser -u {user} -- env -i HOME=/home/{user} /usr/bin/timeout 200 "
              "/opt/python_ml_env/bin/python -I /opt/ai_lab/predict_student.py")
    result = subprocess.run(
        ["ssh", "-i", KEY, "-oStrictHostKeyChecking=no", "-oBatchMode=yes", f"root@{host}", remote],
        input=buffer.getvalue(), capture_output=True, timeout=260, check=False)
    out = result.stdout.decode("utf-8", "replace")
    if "NOMODEL" in out:
        return "NOMODEL", None
    match = None
    for line in out.splitlines():
        found = re.fullmatch(r"PREDS ([0-9,]+)", line.strip())
        if found:
            match = found
    if match is None:
        return "BADMODEL", None
    values = np.array([int(v) for v in match.group(1).split(",")])
    if len(values) != len(images) or values.max() > 9:
        return "BADMODEL", None
    return "OK", values


def run_check(args, params):
    import tensorflow as tf
    pool = np.load(common.HIDDEN_IMAGES, allow_pickle=False)
    rng = np.random.default_rng()
    chosen = pool[rng.choice(len(pool), params["check_sample"], replace=False)]
    model = tf.keras.models.load_model(common.MODEL_FILE)
    target = np.argmax(model.predict(common.normalise(chosen), verbose=0), axis=1)
    status, predicted = student_predictions(args.host, args.user, chosen)
    if status != "OK":
        print(f"RESULT {status}")
        return False
    agreement = float(np.mean(predicted == target))
    queries = common.queries_used()
    print(f"Your model agreed with the target on {agreement * 100:.1f}% of {len(chosen)} hidden images "
          f"({queries} queries used since the last reset).")
    if args.mode == "budget":
        ok = agreement >= params["tight_threshold"] and queries <= params["tight_budget"]
        if not ok and queries > params["tight_budget"]:
            print("RESULT OVERBUDGET")
            return True
        print("RESULT PASS" if ok else "RESULT LOW")
    else:
        print("RESULT PASS" if agreement >= params["agreement_threshold"] else "RESULT LOW")
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--mode", choices=["standard", "budget", "reset"], default="standard")
    args = parser.parse_args()
    params = common.load_params()
    if args.mode == "reset":
        systemctl("stop")
        common.set_queries_used(0)
        os.chown(common.COUNTER_FILE, *ai_lab_ids())
        systemctl("start")
        print("RESULT RESET")
        return
    if args.mode == "budget" and not os.path.exists(STAGE):
        systemctl("stop")
        common.set_queries_used(0)
        os.chown(common.COUNTER_FILE, *ai_lab_ids())
        open(STAGE, "w").close()
        systemctl("start")
        print("RESULT STARTED")
        return
    systemctl("stop")
    try:
        evaluated = run_check(args, params)
    finally:
        systemctl("start")
    # A missing or unloadable model doesn't use up the student's round.
    if args.mode == "budget" and evaluated:
        os.unlink(STAGE)


def ai_lab_ids():
    import pwd
    entry = pwd.getpwnam("ai_lab")
    return entry.pw_uid, entry.pw_gid


if __name__ == "__main__":
    main()
