"""Trains the lab's target model from the per-build parameters."""
import json
import os
import shutil
import sys

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
sys.path.insert(0, "/opt/ai_lab/code")

import numpy as np  # noqa: E402
import tensorflow as tf  # noqa: E402

import common  # noqa: E402


def build_cnn():
    model = tf.keras.Sequential([
        tf.keras.layers.Input((28, 28, 1)),
        tf.keras.layers.Conv2D(32, 3, activation="relu"),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(64, 3, activation="relu"),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation="relu"),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(10, activation="softmax"),
    ])
    model.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    return model


def train_model_stealing(params):
    """The target learns a secret mapping from digits to category numbers, so a
    plain digit classifier does not agree with it."""
    tf.keras.utils.set_random_seed(params["seed"])
    label_map = np.array(params["label_map"])
    (x_train, y_train), (x_test, y_test) = common.load_mnist()
    model = build_cnn()
    model.fit(common.normalise(x_train), label_map[y_train], epochs=5, batch_size=128, verbose=2)
    _, accuracy = model.evaluate(common.normalise(x_test), label_map[y_test], verbose=0)
    print(f"target accuracy on its own categories: {accuracy:.4f}")
    np.save(common.HIDDEN_IMAGES, x_test)
    return model, {
        "query_budget": params["query_budget"],
        "gradient_endpoint": params["gradient_endpoint"],
        "num_classes": 10,
    }


def train_backdoor(params):
    """No target to attack here: keeps the clean data the evaluator compares
    a student's submission against, and the hidden test set."""
    (x_train, y_train), (x_test, y_test) = common.load_mnist()
    size = params["train_size"]
    np.save(common.TRAIN_IMAGES, x_train[:size])
    np.save(common.TRAIN_LABELS, y_train[:size])
    np.save(common.HIDDEN_IMAGES, x_test)
    np.save(common.HIDDEN_LABELS, y_test)
    return None, {"train_size": size}


def gradients(model, images, labels):
    images = tf.convert_to_tensor(images)
    with tf.GradientTape() as tape:
        tape.watch(images)
        loss = tf.keras.losses.sparse_categorical_crossentropy(labels, model(images, training=False))
    return tape.gradient(loss, images).numpy()


def find_transform_image(model, x, y, rng, params):
    """A correctly read image that some, but not most, allowed transforms make the model misread."""
    angle, shift = params["max_angle"], params["max_shift"]
    grid = [(a, dx, dy) for a in range(-angle, angle + 1, 5)
            for dx in range(-shift, shift + 1, 2) for dy in range(-shift, shift + 1, 2)]
    for index in rng.permutation(len(x))[:2000]:
        image = x[index, ..., 0]
        batch = np.array([common.apply_transform(image, *g) for g in grid])[..., np.newaxis]
        predicted = model.predict(batch, verbose=0).argmax(axis=1)
        wrong = float(np.mean(predicted != y[index]))
        if 0.03 <= wrong <= 0.5 and model.predict(x[index:index + 1], verbose=0).argmax() == y[index]:
            return int(index)
    raise RuntimeError("no suitable transform image found")


def find_fgsm_image(model, x, y, rng, epsilon):
    order = rng.permutation(len(x))[:2000]
    candidates, labels = x[order], y[order]
    correct = model.predict(candidates, verbose=0).argmax(axis=1) == labels
    grads = gradients(model, candidates, labels)
    adversarial = np.clip(candidates + epsilon * np.sign(grads), 0.0, 1.0)
    flips = model.predict(adversarial, verbose=0).argmax(axis=1) != labels
    return int(order[np.where(correct & flips)[0][0]])


def find_pgd_image(model, x, y, rng, epsilon):
    """An image where targeted PGD, with the settings the notebook uses, reaches a random other class."""
    for index in rng.permutation(len(x))[:300]:
        image = x[index:index + 1]
        if model.predict(image, verbose=0).argmax() != y[index]:
            continue
        target = int(rng.choice([c for c in range(10) if c != y[index]]))
        adversarial = image.copy()
        for _ in range(40):
            step = gradients(model, adversarial, np.array([target]))
            adversarial = adversarial - (epsilon / 10) * np.sign(step)
            adversarial = np.clip(adversarial, image - epsilon, image + epsilon)
            adversarial = np.clip(adversarial, 0.0, 1.0)
        if model.predict(adversarial, verbose=0).argmax() == target:
            return int(index), target
    raise RuntimeError("no suitable PGD image found")


def train_evasion(params):
    """A normal digit classifier, plus challenge images known to be solvable."""
    tf.keras.utils.set_random_seed(params["seed"])
    rng = np.random.default_rng(params["seed"])
    (x_train, y_train), (x_test, y_test) = common.load_mnist()
    model = build_cnn()
    model.fit(common.normalise(x_train), y_train, epochs=5, batch_size=128, verbose=2)
    x = common.normalise(x_test)
    transform_index = find_transform_image(model, x, y_test, rng, params)
    fgsm_index = find_fgsm_image(model, x, y_test, rng, params["fgsm_epsilon"])
    pgd_index, pgd_target = find_pgd_image(model, x, y_test, rng, params["pgd_epsilon"])
    return model, {
        "query_budget": params["query_budget"],
        "gradient_endpoint": True,
        "num_classes": 10,
        "challenges": {
            "transform": {"image": x[transform_index, ..., 0].tolist(), "true_label": int(y_test[transform_index]),
                          "max_angle": params["max_angle"], "max_shift": params["max_shift"]},
            "fgsm": {"image": x[fgsm_index, ..., 0].tolist(), "true_label": int(y_test[fgsm_index]),
                     "epsilon": params["fgsm_epsilon"]},
            "pgd": {"image": x[pgd_index, ..., 0].tolist(), "true_label": int(y_test[pgd_index]),
                    "epsilon": params["pgd_epsilon"], "target": pgd_target},
        },
    }


TRAINERS = {"model_stealing": train_model_stealing, "backdoor": train_backdoor, "evasion": train_evasion}


def main():
    params = common.load_params()
    model, public = TRAINERS[params["lab"]](params)
    if model is not None:
        tmp = common.MODEL_FILE + ".partial.keras"
        model.save(tmp)
        shutil.chown(tmp, group="ai_lab")
        os.chmod(tmp, 0o640)
        os.replace(tmp, common.MODEL_FILE)
    # Written last: Puppet treats this file as "training finished".
    with open(common.PUBLIC_PARAMS_FILE, "w") as handle:
        json.dump(public, handle)
    shutil.chown(common.PUBLIC_PARAMS_FILE, group="ai_lab")
    os.chmod(common.PUBLIC_PARAMS_FILE, 0o640)


if __name__ == "__main__":
    main()
