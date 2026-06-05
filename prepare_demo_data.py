from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parent
MNIST_ARCHIVE = ROOT / "mnist.npz"


def load_or_download_mnist() -> dict[str, np.ndarray]:
    if MNIST_ARCHIVE.exists():
        data = np.load(MNIST_ARCHIVE)
        return {"x_train": data["x_train"], "x_test": data["x_test"]}

    try:
        from torchvision import datasets
    except ImportError as exc:
        raise ImportError(
            "mnist.npz is missing and torchvision is not installed. "
            "Install dependencies with: pip install -r requirements.txt"
        ) from exc

    train = datasets.MNIST(root=ROOT / "data", train=True, download=True)
    test = datasets.MNIST(root=ROOT / "data", train=False, download=True)
    return {
        "x_train": train.data.numpy().astype(np.uint8),
        "x_test": test.data.numpy().astype(np.uint8),
    }


def main() -> None:
    data = load_or_download_mnist()
    required = {"x_train", "x_test"}
    missing = required.difference(data)
    if missing:
        raise KeyError(f"{MNIST_ARCHIVE.name} is missing: {', '.join(sorted(missing))}")

    for name in sorted(required):
        out = ROOT / f"{name}.npy"
        if out.exists():
            print(f"exists: {out.name}")
            continue
        np.save(out, data[name])
        print(f"created: {out.name}")


if __name__ == "__main__":
    main()
