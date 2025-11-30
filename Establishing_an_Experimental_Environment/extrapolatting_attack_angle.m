% Viterna 方法实现，生成升力系数 CL 和阻力系数 CD 曲线

% 用户定义参数
AR = 20; % 展弦比，c=0.25m;L=H=5m
CD_MAX = 1.11 + 0.018 * AR; % 最大阻力系数，根据给定公式计算
alpha_stall = 15; % 失速迎角，默认值为 15 度
alpha_deg = linspace(-180, 180, 361); % 迎角范围，从 -180° 到 180°，步长为 1°

% 将迎角转换为弧度
alpha_rad = deg2rad(alpha_deg);

% 初始化数组，用于存储每个迎角下的升力系数 CL 和阻力系数 CD
CL = zeros(size(alpha_deg));
CD = zeros(size(alpha_deg));

% 计算公式中的常量
A = 1.11 - 0.018 * CD_MAX * AR;
B = sqrt(A^2 - 1);
C = (A - 1) / (A + 1);

% 计算 A1, A2, B1, B2
A1 = A / 2;
A2 = 1 / 2;
B1 = B / 2;
B2 = 1 / (2 * A);

% 输出计算的常量值，方便调试
fprintf('A1 = %.4f\n', A1);
fprintf('A2 = %.4f\n', A2);
fprintf('B1 = %.4f\n', B1);
fprintf('B2 = %.4f\n', B2);

% 使用 Viterna 方法公式计算每个迎角下的升力系数 CL 和阻力系数 CD
for i = 1:length(alpha_deg)
    alpha = alpha_rad(i); % 当前迎角（弧度）
    
    if alpha <= deg2rad(alpha_stall)
        % 迎角小于等于失速迎角，使用 Viterna 公式计算 CL 和 CD
        CL(i) = A1 * cos(alpha) + A2 * sin(alpha);
        CD(i) = B1 * sin(alpha) - B2 * cos(alpha);
    else
        % 迎角大于失速迎角，使用失速后的处理方式
        CL(i) = C * CL(i-1); % 失速后升力系数按比例衰减
        CD(i) = CD_MAX; % 失速后阻力系数设为最大值
    end
end

% 绘制结果
figure;
subplot(2,1,1);
plot(alpha_deg, CL, 'b-', 'LineWidth', 1.5);
title('升力系数 (C_L) 随迎角 (\alpha) 变化曲线');
xlabel('迎角 (\alpha) [度]');
ylabel('C_L');
grid on;

subplot(2,1,2);
plot(alpha_deg, CD, 'r-', 'LineWidth', 1.5);
title('阻力系数 (C_D) 随迎角 (\alpha) 变化曲线');
xlabel('迎角 (\alpha) [度]');
ylabel('C_D');
grid on;

% 保存结果到文件（可选）
save('CL_CD_Viterna.mat', 'alpha_deg', 'CL', 'CD');

disp('Viterna 方法 CL 和 CD 曲线生成成功。');
