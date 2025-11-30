% 定义参数
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
L = .25; 
Re_num = (rho * V_synthetic * L) / mu;

% 创建数据表格
data_table = table(a_deg', b_deg', Re_num', 'VariableNames', {'Phase_Angle', 'Angle_of_Attack', 'Reynolds_Number'});

% 保存数据到CSV文件
csv_filename = 'E:\jwh_gan\MATLAB\aerofoil\Phase_Angle_Angle_of_attack_Reynolds_number\Phase_Angle_Angle_of_attack_Reynolds_number.csv';
writetable(data_table, csv_filename);

disp('数据已保存到CSV文件中。');
