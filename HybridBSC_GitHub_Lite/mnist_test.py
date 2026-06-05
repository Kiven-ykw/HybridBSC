import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import numpy as np
import matplotlib.pyplot as plt
from skimage.metrics import peak_signal_noise_ratio as compare_psnr
from skimage.metrics import structural_similarity as ssim

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"使用的设备: {device}")


def MNIST_AE_disp(img_in_numpy, img_out_numpy, img_idx_list):
    num_img = len(img_idx_list)

    for i, image_idx in enumerate(img_idx_list):

        plt.figure(figsize=(3, 3))

        current_img_in = img_in_numpy[image_idx]
        if current_img_in.ndim == 3 and current_img_in.shape[0] == 1:
            current_img_in = current_img_in.squeeze(0)
        elif current_img_in.ndim == 2:
            pass
        else:
            raise ValueError(f"未预期的输入图像形状: {current_img_in.shape}")

        plt.imshow(current_img_in, cmap="gray")
        plt.xticks([])
        plt.yticks([])
        plt.axis("off")
        plt.title(f"原始图像 {image_idx}")
        plt.show()

        plt.imsave("原始的图像.png", current_img_in, cmap="gray")

        plt.figure(figsize=(3, 3))
        current_img_out = img_out_numpy[image_idx]
        if current_img_out.ndim == 3 and current_img_out.shape[0] == 1:
            current_img_out = current_img_out.squeeze(0)
        elif current_img_out.ndim == 2:
            pass
        else:
            raise ValueError(f"未预期的输出图像形状: {current_img_out.shape}")

        plt.imshow(current_img_out, cmap="gray")
        plt.xticks([])
        plt.yticks([])
        plt.axis("off")
        plt.title(f"解码后图像 {image_idx}")
        plt.show()
        plt.imsave("解码后图像.png", current_img_out, cmap="gray")

        x_test_np = current_img_in
        decoded_img_np = current_img_out

        psnr_val = compare_psnr(
            x_test_np, decoded_img_np, data_range=x_test_np.max() - x_test_np.min()
        )

        ssim_val = ssim(
            x_test_np,
            decoded_img_np,
            data_range=x_test_np.max() - x_test_np.min(),
            channel_axis=None if x_test_np.ndim == 2 else 0,
            win_size=7,
        )
        print(f"图像 {image_idx}: PSNR: {psnr_val:.4f}, SSIM: {ssim_val:.4f}")


transform = transforms.Compose(
    [
        transforms.ToTensor(),
        # transforms.Normalize((0.1307,), (0.3081,)),
    ]
)

train_dataset = datasets.MNIST("./data", train=True, download=True, transform=transform)

test_dataset = datasets.MNIST("./data", train=False, download=True, transform=transform)

train_loader = DataLoader(train_dataset, batch_size=256, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=10000, shuffle=False)

x_test_tensor, y_test_tensor = next(iter(test_loader))
x_test_tensor = x_test_tensor.to(device)

x_test_numpy_for_eval = x_test_tensor.cpu().squeeze().numpy()


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


class Autoencoder(nn.Module):
    def __init__(self, encoder, decoder):
        super(Autoencoder, self).__init__()
        self.encoder = encoder
        self.decoder = decoder

    def forward(self, x):
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded


encoder = Encoder().to(device)
decoder = Decoder().to(device)
autoencoder = Autoencoder(encoder, decoder).to(device)

print("编码器结构:")
print(encoder)
print("\n解码器结构:")
print(decoder)
print("\n自编码器结构:")
print(autoencoder)

criterion = nn.MSELoss()
optimizer = optim.Adam(autoencoder.parameters(), lr=1e-3)
epochs = 20

print("\n开始训练...")
autoencoder.train()
for epoch in range(epochs):
    total_loss = 0

    for batch_idx, (data, _) in enumerate(train_loader):
        data = data.to(device)

        outputs = autoencoder(data)
        loss = criterion(outputs, data)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

        if (batch_idx + 1) % 100 == 0:
            print(
                f"轮次 [{epoch+1}/{epochs}], 批次 [{batch_idx+1}/{len(train_loader)}], 损失: {loss.item():.6f}"
            )

    print(
        f"====> 轮次 {epoch+1}/{epochs} | 平均损失: {total_loss/len(train_loader):.6f}"
    )

print("训练完成.")

torch.save(encoder.state_dict(), "./encoder_pytorch.pth")
torch.save(decoder.state_dict(), "./decoder_pytorch.pth")
print("编码器和解码器模型已保存.")

encoder_loaded = Encoder().to(device)
decoder_loaded = Decoder().to(device)

encoder_loaded.load_state_dict(torch.load("./encoder_pytorch.pth", map_location=device))
decoder_loaded.load_state_dict(torch.load("./decoder_pytorch.pth", map_location=device))

encoder_loaded.eval()
decoder_loaded.eval()
print("编码器和解码器模型已加载.")

img_number_idx = 8

single_x_test_tensor = x_test_tensor[img_number_idx : img_number_idx + 1]

with torch.no_grad():
    encoded_img_tensor = encoder_loaded(single_x_test_tensor)

encoded_img_numpy = encoded_img_tensor.cpu().numpy().flatten()
data_test_numpy = encoded_img_numpy

data_test_min = data_test_numpy.min()
data_test_max = data_test_numpy.max()

if data_test_max == data_test_min:
    normalized_array = np.zeros_like(data_test_numpy)
else:
    normalized_array = (data_test_numpy - data_test_min) / (
        data_test_max - data_test_min
    )

quantized_values = np.round(normalized_array * 15).astype(int)

binary_representation = np.array([np.binary_repr(v, width=4) for v in quantized_values])

binary_array = np.array([list(map(int, list(b))) for b in binary_representation])

binary_array_str = "\n".join([" ".join(map(str, row)) for row in binary_array])

file_path = "./data_1_pytorch.txt"
with open(file_path, "w") as file:
    file.write(binary_array_str)
print(f"二进制数组已保存到文本文件: {file_path}")


def restore_original_values(binary_arr, min_val, max_val):

    decimal_values = np.array([int("".join(map(str, bits)), 2) for bits in binary_arr])

    normalized_values = decimal_values / 15.0

    if max_val == min_val:
        original_values = np.full_like(normalized_values, min_val)
    else:

        original_values = normalized_values * (max_val - min_val) + min_val
    return original_values


file_path_data2 = "./data_1_pytorch.txt"
# file_path_data2 = "./data_2.txt"

try:
    with open(file_path_data2) as f:
        line = f.readline()
        data_array_from_file = []
        while line:
            num = list(map(int, line.split(" ")))
            data_array_from_file.append(num)
            line = f.readline()
        data_array_from_file = np.array(data_array_from_file)

    restored_values_from_file = restore_original_values(
        data_array_from_file, data_test_min, data_test_max
    )
except FileNotFoundError:
    print(f"警告: {file_path_data2} 未找到。跳过从此文件还原。")
    restored_values_from_file = np.copy(data_test_numpy)

restored_values_direct = restore_original_values(
    binary_array, data_test_min, data_test_max
)

print("原始编码数据 (前10个):", data_test_numpy[:10])
print("从直接的二进制数组还原 (前10个):", restored_values_direct[:10])
print("从文件还原 (前10个):", restored_values_from_file[:10])

restored_encoded_img_numpy = restored_values_from_file.reshape(1, 28, 28)

restored_encoded_img_tensor = (
    torch.from_numpy(restored_encoded_img_numpy).float().unsqueeze(0).to(device)
)

with torch.no_grad():

    decoded_restored_img_tensor = decoder_loaded(restored_encoded_img_tensor)

original_image_for_display = x_test_numpy_for_eval[img_number_idx : img_number_idx + 1]
decoded_image_for_display = decoded_restored_img_tensor.cpu().numpy()

print("\n显示原始图像 vs. 解码后图像 (经过量化和从文件还原):")
MNIST_AE_disp(original_image_for_display, decoded_image_for_display, [0])

autoencoder.eval()
with torch.no_grad():
    direct_decoded_tensor = autoencoder(single_x_test_tensor)
direct_decoded_numpy = direct_decoded_tensor.cpu().numpy()
print("\n显示原始图像 vs. 解码后图像 (直接来自自编码器，无量化):")
MNIST_AE_disp(original_image_for_display, direct_decoded_numpy, [0])

autoencoder.eval()
with torch.no_grad():

    num_display_images = 5
    sample_test_images_tensor = x_test_tensor[:num_display_images]

    decoded_sample_test_tensor = autoencoder(sample_test_images_tensor)

    print(f"\n显示前 {num_display_images} 张图像的直接自编码器重建结果:")
    MNIST_AE_disp(
        x_test_numpy_for_eval[:num_display_images],
        decoded_sample_test_tensor.cpu().numpy(),
        list(range(num_display_images)),
    )
