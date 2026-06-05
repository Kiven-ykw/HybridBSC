import torch
import torch.nn as nn
import numpy as np
import matplotlib.pyplot as plt
from skimage.metrics import peak_signal_noise_ratio as compare_psnr
from skimage.metrics import structural_similarity as ssim
import imageio


class Encoder(nn.Module):
    def __init__(self):
        super(Encoder, self).__init__()

        self.conv1 = nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding=1)
        self.conv2 = nn.Conv2d(
            in_channels=32, out_channels=16, kernel_size=3, padding=1
        )
        self.conv3 = nn.Conv2d(
            in_channels=16, out_channels=16, kernel_size=3, padding=1
        )

        self.encoded_layer = nn.Conv2d(
            in_channels=16, out_channels=1, kernel_size=3, padding=1
        )
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.relu(self.conv3(x))
        x = self.relu(self.encoded_layer(x))
        return x


class Decoder(nn.Module):
    def __init__(self):
        super(Decoder, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding=1)
        self.conv2 = nn.Conv2d(
            in_channels=32, out_channels=16, kernel_size=3, padding=1
        )
        self.conv3 = nn.Conv2d(
            in_channels=16, out_channels=16, kernel_size=3, padding=1
        )

        self.decoded_layer = nn.Conv2d(
            in_channels=16, out_channels=1, kernel_size=3, padding=1
        )
        self.relu = nn.ReLU()
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.relu(self.conv3(x))
        x = self.sigmoid(self.decoded_layer(x))
        return x


def mnist_input():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    encoder_model_loaded = Encoder().to(device)
    encoder_model_loaded.load_state_dict(
        torch.load("./encoder_pytorch.pth", map_location=device)
    )
    encoder_model_loaded.eval()
    decoder_model_loaded = Decoder().to(device)
    decoder_model_loaded.load_state_dict(
        torch.load("./decoder_pytorch.pth", map_location=device)
    )
    decoder_model_loaded.eval()
    """
    此函数执行MNIST数据的编码和量化过程，并将量化后的二进制数据保存到文件。
    主要供MATLAB调用。
    """
    x_train_np = np.load("./x_train.npy")
    x_test_np = np.load("./x_test.npy")

    x_train_np = x_train_np.astype("float32") / 255.0
    x_test_np = x_test_np.astype("float32") / 255.0

    x_train_pytorch = x_train_np.reshape(
        len(x_train_np), 1, x_train_np.shape[1], x_train_np.shape[2]
    )
    x_test_pytorch = x_test_np.reshape(
        len(x_test_np), 1, x_test_np.shape[1], x_test_np.shape[2]
    )

    x_test_tensor = torch.from_numpy(x_test_pytorch).to(device)

    img_number = 8
    # test_images = np.array([img_number])

    with torch.no_grad():
        encoded_output_tensor = encoder_model_loaded(x_test_tensor)

    encoded_output_numpy = encoded_output_tensor.cpu().numpy()

    data_test = encoded_output_numpy[img_number].flatten()

    data_test_min = data_test.min()
    data_test_max = data_test.max()
    if data_test_max == data_test_min:
        normalized_array = np.zeros_like(data_test)
    else:
        normalized_array = (data_test - data_test_min) / (data_test_max - data_test_min)

    quantized_values = np.round(normalized_array * 15).astype(int)

    binary_representation = np.array(
        [np.binary_repr(v, width=4) for v in quantized_values]
    )

    binary_array = np.array(
        [list(map(int, list(b))) for b in binary_representation]
    ).reshape(-1, 4)

    binary_array_str = "\n".join([" ".join(map(str, row)) for row in binary_array])

    file_path = "./data_1.txt"
    with open(file_path, "w") as file:
        file.write(binary_array_str)
    print(f"数据已保存到 {file_path}")
    return 1


def mnist_output():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    encoder_model_loaded = Encoder().to(device)
    encoder_model_loaded.load_state_dict(
        torch.load("./encoder_pytorch.pth", map_location=device)
    )
    encoder_model_loaded.eval()
    decoder_model_loaded = Decoder().to(device)
    decoder_model_loaded.load_state_dict(
        torch.load("./decoder_pytorch.pth", map_location=device)
    )
    decoder_model_loaded.eval()
    """
    此函数加载量化后的数据（原始和可能已损坏的），进行去量化和解码，
    并计算图像质量指标（PSNR 和 SSIM）。
    主要供MATLAB调用。
    """

    x_train_np_orig = np.load("./x_train.npy")
    x_test_np_orig = np.load("./x_test.npy")

    x_test_np_orig_normalized = x_test_np_orig.astype("float32") / 255.0

    img_number = 8

    temp_x_test_pytorch = x_test_np_orig_normalized.reshape(
        len(x_test_np_orig_normalized),
        1,
        x_test_np_orig_normalized.shape[1],
        x_test_np_orig_normalized.shape[2],
    )
    temp_x_test_tensor = torch.from_numpy(temp_x_test_pytorch).to(device)
    with torch.no_grad():
        temp_encoded_output_tensor = encoder_model_loaded(temp_x_test_tensor)
    temp_encoded_output_numpy = temp_encoded_output_tensor.cpu().numpy()
    data_test_for_min_max = temp_encoded_output_numpy[img_number].flatten()

    min_value_encoded = data_test_for_min_max.min()
    max_value_encoded = data_test_for_min_max.max()

    if max_value_encoded == min_value_encoded:
        normalized_array_for_r1 = np.zeros_like(data_test_for_min_max)
    else:
        normalized_array_for_r1 = (data_test_for_min_max - min_value_encoded) / (
            max_value_encoded - min_value_encoded
        )
    quantized_values_for_r1 = np.round(normalized_array_for_r1 * 15).astype(int)
    binary_representation_for_r1 = np.array(
        [np.binary_repr(v, width=4) for v in quantized_values_for_r1]
    )
    binary_array_for_r1 = np.array(
        [list(map(int, list(b))) for b in binary_representation_for_r1]
    ).reshape(-1, 4)

    temp_array_r1 = binary_array_for_r1
    decimal_values_r1 = np.array(
        [int("".join(map(str, bits)), 2) for bits in temp_array_r1]
    )
    normalized_values_r1 = decimal_values_r1 / 15.0
    if max_value_encoded == min_value_encoded:
        restored_values1 = np.full_like(normalized_values_r1, min_value_encoded)
    else:
        restored_values1 = (
            normalized_values_r1 * (max_value_encoded - min_value_encoded)
            + min_value_encoded
        )

    data_array_from_file = []
    try:
        with open("./data_2.txt") as f:
            line = f.readline()
            while line:
                num = list(map(int, line.split(" ")))
                data_array_from_file.append(num)
                line = f.readline()
            data_array_from_file = np.array(data_array_from_file)
    except FileNotFoundError:
        print("错误: data_2.txt 未找到。无法从中进行解码。")

        data_array_from_file = np.copy(binary_array_for_r1)
        print("警告: 使用 data_1.txt (或等效数据) 作为 data_2.txt 路径的回退。")

    temp_array_r2 = data_array_from_file
    decimal_values_r2 = np.array(
        [int("".join(map(str, bits)), 2) for bits in temp_array_r2]
    )
    normalized_values_r2 = decimal_values_r2 / 15.0
    if max_value_encoded == min_value_encoded:
        restored_values2 = np.full_like(normalized_values_r2, min_value_encoded)
    else:
        restored_values2 = (
            normalized_values_r2 * (max_value_encoded - min_value_encoded)
            + min_value_encoded
        )

    temp_2_pytorch = restored_values2.reshape(1, 28, 28)

    BATCH_SIZE_FOR_DECODE = 10000

    repeated_temp_2_numpy = np.repeat(
        temp_2_pytorch[np.newaxis, :, :, :], BATCH_SIZE_FOR_DECODE, axis=0
    )

    repeated_temp_2_tensor = torch.from_numpy(repeated_temp_2_numpy).float().to(device)

    with torch.no_grad():

        decoded_output_batch_tensor = decoder_model_loaded(repeated_temp_2_tensor)

    decoded_output_batch_numpy = decoded_output_batch_tensor.cpu().numpy()

    decoded_img_numpy = decoded_output_batch_numpy[img_number].squeeze()

    x_test_original_single_img = x_test_np_orig_normalized[img_number]

    # plt.imsave("原始的图像.png", x_test_original_single_img, cmap="gray")
    # plt.imsave("解码后图像.png", decoded_img_numpy, cmap="gray")

    psnr_mnist = compare_psnr(
        x_test_original_single_img,
        decoded_img_numpy,
        data_range=x_test_original_single_img.max() - x_test_original_single_img.min(),
    )

    ssim_mnist = ssim(
        x_test_original_single_img,
        decoded_img_numpy,
        data_range=x_test_original_single_img.max() - x_test_original_single_img.min(),
        channel_axis=None,
        win_size=7,
    )

    try:
        image_tx = imageio.v2.imread("./tx_img.jpg")
        image_rx = imageio.v2.imread("./rx_img.png")

        image_tx = image_tx.astype(np.float32)
        image_rx = image_rx.astype(np.float32)
        data_range_color = 255.0

        psnr_color = compare_psnr(image_tx, image_rx, data_range=data_range_color)

        ssim_values_color = []

        if image_tx.ndim == 3 and image_tx.shape[2] > 1:
            for i in range(image_tx.shape[2]):
                ssim_value_ch = ssim(
                    image_tx[:, :, i],
                    image_rx[:, :, i],
                    data_range=data_range_color,
                    channel_axis=None,
                )
                ssim_values_color.append(ssim_value_ch)
            ssim_color = np.mean(ssim_values_color)
        elif image_tx.ndim == 2:
            ssim_color = ssim(
                image_tx, image_rx, data_range=data_range_color, channel_axis=None
            )
        else:
            print("警告: tx_img/rx_img 的维度不利于SSIM计算。")
            ssim_color = 0.0

    except FileNotFoundError:
        print("警告: tx_img.jpg 或 rx_img.png 未找到。跳过彩色图像指标计算。")
        psnr_color = 0.0
        ssim_color = 0.0

    print(f"MNIST PSNR: {psnr_mnist}, MNIST SSIM: {ssim_mnist}")
    print(f"彩色图像 PSNR: {psnr_color}, 彩色图像 SSIM: {ssim_color}")

    return (
        psnr_color,
        ssim_color,
        psnr_mnist,
        ssim_mnist,
    )


# if __name__ == "__main__":
#     print("运行主测试部分 (PyTorch 版本)...")

#     x_test_np_orig = np.load("./x_test.npy")
#     x_test_np_orig_normalized = x_test_np_orig.astype("float32") / 255.0

#     x_test_pytorch_main = x_test_np_orig_normalized.reshape(
#         len(x_test_np_orig_normalized),
#         1,
#         x_test_np_orig_normalized.shape[1],
#         x_test_np_orig_normalized.shape[2],
#     )
#     x_test_tensor_main = torch.from_numpy(x_test_pytorch_main).to(device)

#     img_number_main = 8

#     with torch.no_grad():
#         encoded_main_tensor = encoder_model_loaded(x_test_tensor_main)
#     encoded_main_numpy = encoded_main_tensor.cpu().numpy()

#     data_test_main = encoded_main_numpy[img_number_main].flatten()

#     min_val_main = data_test_main.min()
#     max_val_main = data_test_main.max()

#     if max_val_main == min_val_main:
#         normalized_array_main = np.zeros_like(data_test_main)
#     else:
#         normalized_array_main = (data_test_main - min_val_main) / (
#             max_val_main - min_val_main
#         )

#     quantized_values_main = np.round(normalized_array_main * 15).astype(int)
#     binary_representation_main = np.array(
#         [np.binary_repr(v, width=4) for v in quantized_values_main]
#     )
#     binary_array_main = np.array(
#         [list(map(int, list(b))) for b in binary_representation_main]
#     ).reshape(-1, 4)
#     binary_array_str_main = "\n".join(
#         [" ".join(map(str, row)) for row in binary_array_main]
#     )

#     file_path_data1_main = "./data_1.txt"
#     with open(file_path_data1_main, "w") as file:
#         file.write(binary_array_str_main)
#     print(f"主测试: data_1.txt 已保存。")

#     data_array_main = []
#     try:
#         with open("./data_2.txt") as f:
#             line = f.readline()
#             while line:
#                 num = list(map(int, line.split(" ")))
#                 data_array_main.append(num)
#                 line = f.readline()
#             data_array_main = np.array(data_array_main)
#         print(f"主测试: data_2.txt 已加载。")
#     except FileNotFoundError:
#         print("主测试: data_2.txt 未找到。使用 data_1.txt 的内容作为回退。")
#         data_array_main = np.copy(binary_array_main)

#     temp_array_main_r2 = data_array_main
#     decimal_values_main_r2 = np.array(
#         [int("".join(map(str, bits)), 2) for bits in temp_array_main_r2]
#     )
#     normalized_values_main_r2 = decimal_values_main_r2 / 15.0
#     if max_val_main == min_val_main:
#         restored_values_main_r2 = np.full_like(normalized_values_main_r2, min_val_main)
#     else:

#         restored_values_main_r2 = (
#             normalized_values_main_r2 * (max_val_main - min_val_main) + min_val_main
#         )

#     temp_2_main_pytorch = restored_values_main_r2.reshape(1, 28, 28)

#     BATCH_SIZE_FOR_DECODE_MAIN = 10000

#     repeated_temp_2_main_numpy = np.repeat(
#         temp_2_main_pytorch[np.newaxis, :, :, :], BATCH_SIZE_FOR_DECODE_MAIN, axis=0
#     )
#     repeated_temp_2_main_tensor = (
#         torch.from_numpy(repeated_temp_2_main_numpy).float().to(device)
#     )

#     with torch.no_grad():

#         decoded_batch_main_tensor = decoder_model_loaded(repeated_temp_2_main_tensor)
#     decoded_batch_main_numpy = decoded_batch_main_tensor.cpu().numpy()

#     decoded_img_main = decoded_batch_main_numpy[img_number_main].squeeze()

#     x_test_orig_single_main = x_test_np_orig_normalized[img_number_main]

#     plt.figure(figsize=(6, 3))
#     plt.subplot(1, 2, 1)
#     plt.imshow(x_test_orig_single_main, cmap="gray")
#     plt.title(f"原始图像 ({img_number_main})")
#     plt.xticks([])
#     plt.yticks([])
#     plt.axis("off")
#     plt.imsave("原始的图像.png", x_test_orig_single_main, cmap="gray")

#     plt.subplot(1, 2, 2)
#     plt.imshow(decoded_img_main, cmap="gray")
#     plt.title(f"解码后图像 ({img_number_main})")
#     plt.xticks([])
#     plt.yticks([])
#     plt.axis("off")
#     plt.imsave("解码后图像.png", decoded_img_main, cmap="gray")

#     plt.tight_layout()
#     plt.show()
#     print(f"主测试: 原始图像和解码后图像已保存并显示。")

#     psnr_main = compare_psnr(
#         x_test_orig_single_main,
#         decoded_img_main,
#         data_range=x_test_orig_single_main.max() - x_test_orig_single_main.min(),
#     )
#     ssim_main = ssim(
#         x_test_orig_single_main,
#         decoded_img_main,
#         data_range=x_test_orig_single_main.max() - x_test_orig_single_main.min(),
#         channel_axis=None,
#         win_size=7,
#     )

#     print(f"主测试 PSNR (MNIST): {psnr_main}")
#     print(f"主测试 SSIM (MNIST): {ssim_main}")

#     # print("\n调用 mnist_input()...")
#     # mnist_input_result = mnist_input()
#     # print(f"mnist_input() 返回: {mnist_input_result}")

#     # print("\n调用 mnist_output()...")
#     # psnr_c, ssim_c, psnr_m, ssim_m = mnist_output()
#     # print(
#     #     f"mnist_output() 返回: 彩色图PSNR={psnr_c}, 彩色图SSIM={ssim_c}, MNIST_PSNR={psnr_m}, MNIST_SSIM={ssim_m}"
#     # )
