import numpy as np

# 加载 .npy 数据
npy_file_path = r"D:\gan\bezier-gan-master\data\airfoil_interp.npy"
dat_file_path = r"D:\gan\bezier-gan-master\data\translate_data\1234.dat"

# 加载 3D 数据
data = np.load(npy_file_path)

# 展平为 1D
data_flattened = data.flatten()

# 保存为文本格式的 .dat 文件
np.savetxt(dat_file_path, data_flattened, fmt="%.6f", delimiter=" ")  # fmt 设置保留小数位数
print(f"数据已展平并保存为 {dat_file_path}")
