% 定义参数 
% 由于之前的估算（在雷诺数为常数的情况下，循环叶尖速比得到的）叶尖速比设为2.5，
% 风力机几何参数见：E:\U盘资料\毕业设计\毕业设计（开干）\课程设计\0018翼型5KW
V_inf = 11; % 来流风速 (m/s)
W = 11;    % 转速 (rad/s)
R = 2.5;    % 风轮半径 (m)

% 相位角 a 的设置，从-180度到180度，间隔.25度
a_deg = -180:.25:180;
a_rad = deg2rad(a_deg); % 转换为弧度

% 计算合成速度在极坐标下的表示
V_theta = W * R * sin(a_rad); % V_theta 分量
V_r = V_inf + W * R * cos(a_rad); % V_r 分量

% 计算合成速度的大小
V_synthetic = sqrt(V_r.^2 + V_theta.^2);

% 计算攻角（合成速度矢量与旋转速度矢量的夹角）
b_rad = atan2(V_theta, V_r) - a_rad;
b_deg = rad2deg(b_rad);

% 将攻角范围调整到 [-180, 180] 度
b_deg = mod(b_deg + 180, 360) - 180;

% 假设流体的密度(空气)和黏度用于计算雷诺数 注：空气密度与运动粘性系数取常温常压下的值
rho = 1.225;    % 空气密度 (kg/m^3)
mu = 1.809e-5;   % 空气动态黏度 (Pa·s)

% 计算雷诺数 (Re = rho * V * L / mu)
% 使用风轮直径作为特征长度 (L = c弦长)
L = .25; 
Re_num = (rho * V_synthetic * L) / mu;

% 输出攻角、相位角、雷诺数的列表
fprintf('相位角 (度)\t攻角 (度)\t雷诺数\n');
for i = 1:length(a_deg)
    fprintf('%8.2f\t%8.2f\t%10.2f\n', a_deg(i), b_deg(i), Re_num(i));
end

% 绘制攻角与相位角的关系图
figure;
plot(a_deg, b_deg, 'g-', 'LineWidth', 2);
xlabel('相位角 (deg)');
ylabel('攻角 (deg)');
title('攻角与相位角的关系');
grid on;

% 绘制雷诺数与相位角的关系图
figure;
plot(a_deg, Re_num, 'b-', 'LineWidth', 2);
xlabel('相位角 (deg)');
ylabel('雷诺数 (Re)');
title('雷诺数与相位角的关系');
grid on;

% 绘制雷诺数与攻角的关系图
figure;
plot(b_deg, Re_num, 'b-', 'LineWidth', 2);
xlabel('攻角 (deg)');
ylabel('雷诺数 (Re)');
title('雷诺数与攻角的关系');
grid on;

% 绘制合成速度的极坐标图
figure;
polarplot(a_rad, V_synthetic, 'r-', 'LineWidth', 2);
title('合成速度的极坐标图');

% 单独输出合成风速的最大值与最小值
V_max = max(V_synthetic);
V_min = min(V_synthetic);
disp(['合成风速最大值: ', num2str(V_max)]);
disp(['合成风速最小值: ', num2str(V_min)]);

% 单独输出雷诺数的最大值与最小值
Re_max = max(Re_num);
Re_min = min(Re_num);
disp(['雷诺数最大值: ', num2str(Re_max)]);
disp(['雷诺数最小值: ', num2str(Re_min)]);

% 创建网格用于三维绘图
[a_grid, b_grid] = meshgrid(a_deg, b_deg);

% 由于Re_num是一维数组，需要将其扩展为与网格相同大小
% 在这个例子中，由于问题的一维性，我们可以重复雷诺数的列
Re_grid = repmat(Re_num, length(b_deg), 1);

% 绘制三维图像
figure;
surf(a_grid, b_grid, Re_grid, 'EdgeColor', 'none');
xlabel('相位角 (deg)');
ylabel('攻角 (deg)');
zlabel('雷诺数 (Re)'); 
title('三维关系图：相位角、攻角与雷诺数');
colormap jet; % 添加颜色映射增强视觉效果
colorbar; % 显示颜色条
grid on;
