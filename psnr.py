import imageio
from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.metrics import structural_similarity as ssim
import numpy as np

image_true = imageio.imread(".\com_tx.jpg")
image_test = imageio.imread(".\com_rx.jpg")

PSNR_value = psnr(
    image_true, image_test, data_range=image_true.max() - image_test.min()
)
SSIM_value = ssim(
    image_true,
    image_test,
    data_range=image_true.max() - image_test.min(),
    multichannel=False,
)

print(f"PSNR value: {PSNR_value} dB")


def calculate_nc(original, extracted):
    """
    original -- 原始水印数据
    extracted -- 提取的水印数据
    """

    original = np.array(original)
    extracted = np.array(extracted)

    numerator = np.sum(original * extracted)
    denominator = np.sqrt(np.sum(original**2) * np.sum(extracted**2))
    nc_value = numerator / denominator

    return nc_value


# nc_value = calculate_nc(image_true, image_test)
# print(f"NC value: {nc_value}")
