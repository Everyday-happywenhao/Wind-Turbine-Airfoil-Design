% 定义参数
V_inf = 11; % 来流风速 (m/s)
W = 11;    % 转速 (rad/s)
R = 2.5;    % 风轮半径 (m)

% 相位角 a 的设置，从-5度到15度，间隔.25度
a_deg = 0:.25:360;
a_rad = deg2rad(a_deg); % 转换为弧度

% 计算合成速度在极坐标下的表示
V_theta = W*R * sin(a_rad); % V_theta 分量
V_r = V_inf + W*R * cos(a_rad); % V_r 分量

% 计算合成速度的大小
V_synthetic = sqrt(V_r.^2 + V_theta.^2);

% 假设流体的密度(空气)和黏度用于计算雷诺数
rho = 1.225;    % 空气密度 (kg/m^3)
mu = 1.809e-5;   % 空气动态黏度 (Pa·s)

% 计算雷诺数 (Re = rho * V * L / mu)
% 使用风轮直径作为特征长度 (L = c弦长)
L = 0.25; 
Re_num = (rho * V_synthetic * L) / mu;

% 绘制雷诺数与相位角的关系图
figure;
plot(a_deg, Re_num, 'b-', 'LineWidth', 2);
xlabel('相位角 (deg)');
ylabel('雷诺数 (Re)');
title('雷诺数与相位角的关系');
grid on;

% 绘制合成速度的极坐标图
figure;
polarplot(a_rad, V_synthetic, 'r-', 'LineWidth', 2);
title('合成速度的极坐标图');

% 输出合成风速大小的列表
disp('合成风速大小列表:');
disp(V_synthetic);

% 单独输出合成风速的最大值与最小值
V_max = max(V_synthetic);
V_min = min(V_synthetic);
disp(['合成风速最大值: ', num2str(V_max)]);
disp(['合成风速最小值: ', num2str(V_min)]);
