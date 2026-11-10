"""The deployed target model: a query-limited prediction API."""
import os

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

import numpy as np  # noqa: E402
import tensorflow as tf  # noqa: E402
from flask import Flask, jsonify, request  # noqa: E402

import common  # noqa: E402

MAX_BATCH = 256

app = Flask(__name__)
public = common.load_public_params()
model = tf.keras.models.load_model(common.MODEL_FILE)


def budget_left():
    return max(public["query_budget"] - common.queries_used(), 0)


def parse_images(body):
    """Accept one 28x28 image as "image" or up to MAX_BATCH as "images"."""
    if not isinstance(body, dict):
        raise ValueError("send a JSON object with an 'image' or 'images' field")
    if "images" in body:
        images = np.asarray(body["images"], dtype="float32")
    elif "image" in body:
        images = np.asarray(body["image"], dtype="float32")[np.newaxis]
    else:
        raise ValueError("send a JSON object with an 'image' or 'images' field")
    if images.ndim == 4 and images.shape[-1] == 1:
        images = images[..., 0]
    if images.ndim != 3 or images.shape[1:] != (28, 28):
        raise ValueError(f"images must be 28x28, got shape {images.shape}")
    if len(images) == 0 or len(images) > MAX_BATCH:
        raise ValueError(f"send between 1 and {MAX_BATCH} images per request")
    if not np.isfinite(images).all():
        raise ValueError("image values must be finite numbers")
    return images


@app.route("/info", methods=["GET"])
def info():
    return jsonify({
        "input": "28x28 greyscale image, pixel values 0-1 or 0-255",
        "categories": public["num_classes"],
        "query_budget": public["query_budget"],
        "queries_used": common.queries_used(),
        "queries_remaining": budget_left(),
        "max_batch": MAX_BATCH,
    })


@app.route("/predict", methods=["POST"])
def predict():
    try:
        images = parse_images(request.get_json(force=True, silent=False))
    except Exception as error:  # noqa: BLE001 - any bad input is the client's error
        return jsonify({"error": str(error)}), 400
    remaining = budget_left()
    if remaining < len(images):
        return jsonify({"error": "query budget exhausted", "queries_remaining": remaining}), 429
    common.set_queries_used(common.queries_used() + len(images))
    probabilities = model.predict(common.normalise(images), verbose=0)
    if len(images) == 1 and "image" in request.get_json():
        return jsonify({
            "prediction": int(np.argmax(probabilities[0])),
            "confidence": float(np.max(probabilities[0])),
            "full_probabilities": probabilities[0].tolist(),
            "queries_remaining": budget_left(),
        })
    return jsonify({
        "predictions": np.argmax(probabilities, axis=1).astype(int).tolist(),
        "probabilities": probabilities.tolist(),
        "queries_remaining": budget_left(),
    })


@app.route("/challenge/<name>", methods=["GET"])
def challenge(name):
    challenges = public.get("challenges", {})
    if name not in challenges:
        return jsonify({"error": "no such challenge", "available": sorted(challenges)}), 404
    return jsonify(challenges[name])


@app.route("/gradient", methods=["POST"])
def gradient():
    """The gradient of the loss for one image and a chosen label: how each pixel affects the model's error."""
    if not public.get("gradient_endpoint"):
        return jsonify({"error": "not available"}), 404
    try:
        body = request.get_json(force=True, silent=False)
        images = parse_images({"image": body["image"]})
        label = int(body["label"])
        if not 0 <= label <= 9:
            raise ValueError("label must be from 0 to 9")
    except Exception as error:  # noqa: BLE001 - any bad input is the client's error
        return jsonify({"error": str(error)}), 400
    tensor = tf.convert_to_tensor(common.normalise(images))
    with tf.GradientTape() as tape:
        tape.watch(tensor)
        loss = tf.keras.losses.sparse_categorical_crossentropy(tf.constant([label]), model(tensor, training=False))
    return jsonify({"gradient": tape.gradient(loss, tensor).numpy()[0, ..., 0].tolist()})


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"})
