"""Runs the student's model on images read from stdin and prints its classes.

Hackerbot runs this as the student, on the student's VM. Keras' safe mode
refuses models that embed arbitrary Python.
"""
import io
import os
import sys

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
MODEL = os.path.expanduser("~/stolen_model.keras")


def main():
    import numpy as np
    if not os.path.exists(MODEL):
        print("NOMODEL")
        return
    try:
        images = np.load(io.BytesIO(sys.stdin.buffer.read()), allow_pickle=False)
        import tensorflow as tf
        model = tf.keras.models.load_model(MODEL, compile=False, safe_mode=True)
        inputs = images.astype("float32").reshape(-1, 28, 28, 1) / 255.0
        predictions = np.argmax(model.predict(inputs, verbose=0), axis=1)
    except Exception:  # noqa: BLE001 - any failure is reported to the student the same way
        print("BADMODEL")
        return
    print("PREDS " + ",".join(str(int(p)) for p in predictions))


if __name__ == "__main__":
    main()
