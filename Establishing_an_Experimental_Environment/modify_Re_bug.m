% 定义基础参数
V_inf = 11;      % 自由来流风速 (m/s)
W = 11;          % 风轮角速度 (rad/s)
R = 2.5;         % 风轮半径 (m)
max_iter = 100;  % 最大迭代次数
tolerance = 1e-3; % 收敛容差

% 相位角定义 [-180°, 180°]，间隔0.25°
a_deg = -180:0.25:180;
a_rad = deg2rad(a_deg);
n_angles = length(a_deg);

% 初始化轴向诱导因子数组
lambda = zeros(size(a_deg));  % 存储每个角度的最终λ值
is_front_half = (a_deg < 0);  % 前半周期标志

% ----------------------------
% 步骤1: 迭代求解轴向诱导因子
% ----------------------------
for i = 1:n_angles
    % 初始猜测值
    lambda_prev = 0.5;  % 初始λ=0.5
    converged = false;
    
    % 牛顿迭代法
    for iter = 1:max_iter
        % --- 计算当前λ对应的参数 ---
        if is_front_half(i)
            % 前半周期参数
            V_induced = V_inf * (1 - lambda_prev);
            TSR = (W * R) / V_inf;  % 叶尖速比
        else
            % 后半周期需要先计算前半周期的中间速度
            % 找到对应的前半周期角度（对称位置）
            front_idx = find(a_deg == -a_deg(i));
            lambda_front = lambda(front_idx);
            u_e = V_inf * (2*lambda_front - 1);
            V_induced = u_e * (1 - lambda_prev);
            TSR = (W * R) / u_e;
        end
        
        % 计算相对速度分量
        V_r = V_induced + W*R*cos(a_rad(i));
        V_theta = W*R*sin(a_rad(i));
        W_synthetic = sqrt(V_r^2 + V_theta^2);
        
        % 计算攻角（示例静态升力系数，需替换为实际数据）
        beta = atan2(V_theta, V_r) - a_rad(i);
        alpha = rad2deg(beta);
        
        % --- 示例：简单推力系数计算（需替换为实际模型）---
        % 假设静态升力系数CL=1.5*sin(alpha)，阻力系数CD=0.1
        CL = 1.5 * sind(alpha);
        CD = 0.1;
        
        % 载荷法推力系数
        sigma = 0.1;  % 实度（示例值）
        CF_blade = sigma/pi * (W_synthetic/V_inf)^2 * (CD*cos(beta) - CL*sin(beta))/abs(sin(a_rad(i)));
        
        % 动量法推力系数（Glauert修正）
        if lambda_prev >= 43/60
            CF_momentum = 4*lambda_prev*(1 - lambda_prev);
        else
            CF_momentum = 1849/900 - 26/15*lambda_prev;
        end
        
        % --- 计算残差和导数 ---
        residual = CF_blade - CF_momentum;
        
        % 数值计算导数
        delta = 1e-6;
        lambda_perturbed = lambda_prev + delta;
        
        % 重复参数计算
        if is_front_half(i)
            V_perturbed = V_inf * (1 - lambda_perturbed);
            TSR_perturbed = (W * R) / V_inf;
        else
            u_e_perturbed = V_inf * (2*lambda_front - 1);
            V_perturbed = u_e_perturbed * (1 - lambda_perturbed);
            TSR_perturbed = (W * R) / u_e_perturbed;
        end
        
        V_r_perturbed = V_perturbed + W*R*cos(a_rad(i));
        W_perturbed = sqrt(V_r_perturbed^2 + V_theta^2);
        beta_perturbed = atan2(V_theta, V_r_perturbed) - a_rad(i);
        alpha_perturbed = rad2deg(beta_perturbed);
        CL_perturbed = 1.5 * sind(alpha_perturbed);
        CF_blade_perturbed = sigma/pi * (W_perturbed/V_inf)^2 * (CD*cos(beta_perturbed) - CL_perturbed*sin(beta_perturbed))/abs(sin(a_rad(i)));
        
        if lambda_perturbed >= 43/60
            CF_momentum_perturbed = 4*lambda_perturbed*(1 - lambda_perturbed);
        else
            CF_momentum_perturbed = 1849/900 - 26/15*lambda_perturbed;
        end
        
        residual_perturbed = CF_blade_perturbed - CF_momentum_perturbed;
        derivative = (residual_perturbed - residual)/delta;
        
        % --- 更新λ ---
        lambda_new = lambda_prev - residual/derivative;
        
        % --- 收敛检查 ---
        if abs(lambda_new - lambda_prev) < tolerance
            converged = true;
            break;
        end
        
        lambda_prev = lambda_new;
    end
    
    % 存储收敛结果
    if converged
        lambda(i) = lambda_new;
    else
        warning('角度 %.2f° 未收敛', a_deg(i));
        lambda(i) = lambda_prev;
    end
end

% ----------------------------
% 步骤2: 使用收敛后的λ计算动态风速
% ----------------------------
V_inf_adjusted = zeros(size(a_deg));

% 前半周期风速计算
front_indices = find(is_front_half);
V_inf_adjusted(front_indices) = V_inf * (1 - lambda(front_indices));

% 后半周期需要先计算中间速度
for i = find(~is_front_half)
    front_angle = -a_deg(i);
    front_idx = find(a_deg == front_angle);
    u_e = V_inf * (2*lambda(front_idx) - 1);
    V_inf_adjusted(i) = u_e * (1 - lambda(i));
end

% ----------------------------
% 步骤3: 计算最终参数
% ----------------------------
% 计算合成速度分量
V_theta = W * R * sin(a_rad);
V_r = V_inf_adjusted + W * R * cos(a_rad);
V_synthetic = sqrt(V_r.^2 + V_theta.^2);

% 计算攻角
b_rad = atan2(V_theta, V_r) - a_rad;
b_deg = mod(rad2deg(b_rad) + 180, 360) - 180;

% 计算雷诺数
rho = 1.225;    
mu = 1.809e-5;   
L = 0.25; 
Re_num = (rho * V_synthetic * L) ./ mu;

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

% ----------------------------
% 结果保存
% ----------------------------
data_table = table(a_deg', lambda', V_inf_adjusted', b_deg', Re_num',...
    'VariableNames', {'Phase_Angle', 'Lambda', 'Adjusted_Vinf', 'Angle_of_Attack', 'Reynolds_Number'});
csv_filename = 'E:\jwh_gan\MATLAB\aerofoil\Phase_Angle_Angle_of_attack_Reynolds_number\VAWT_Analysis_Results.csv';
writetable(data_table, csv_filename);

disp('计算完成，结果已保存。');
