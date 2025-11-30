clc;
clear;

% 定义路径
xfoil_path = 'E:\jwh_gan\gan\XFOIL6.99\xfoil.exe'; % XFOIL可执行文件路径
input_path = 'E:\jwh_gan\gan\XFOIL6.99\'; % 翼型坐标路径
output_path = 'E:\jwh_gan\gan\XFOIL6.99\cl_cd_results_new\'; % 输出路径
log_file = fullfile(output_path, 'error_log.txt'); % 错误日志文件

% 创建输出目录
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

% 初始化错误日志
fid_log = fopen(log_file, 'w');
fprintf(fid_log, 'XFOIL计算错误日志\n');
fclose(fid_log);

% 读取翼型文件
file_list = dir(fullfile(input_path, '*.txt'));

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

% 假设流体的密度(空气)和黏度用于计算雷诺数
rho = 1.225;    % 空气密度 (kg/m^3)
mu = 1.809e-5;   % 空气动态黏度 (Pa·s)

% 计算雷诺数 (Re = rho * V * L / mu)
L = .25; 
Re_num = (rho * V_synthetic * L) / mu;

% 遍历每对雷诺数和攻角
for j = 1:length(Re_num)
    Re = Re_num(j);
    alpha = b_deg(j);

    % 遍历每个翼型文件
    for i = 1:length(file_list)
        airfoil_file = fullfile(input_path, file_list(i).name);
        [~, airfoil_name, ~] = fileparts(file_list(i).name); % 提取翼型名称

        % 检查翼型文件是否符合格式要求
        try
            coords = readmatrix(airfoil_file);
            if size(coords, 2) ~= 2
                error('翼型文件格式错误，需为两列坐标');
            end
        catch
            fid_log = fopen(log_file, 'a');
            fprintf(fid_log, '翼型 %s 文件格式有误，跳过。\n', airfoil_name);
            fclose(fid_log);
            continue;
        end

        % 创建临时命令文件
        command_file = fullfile(input_path, 'xfoil_input.txt');
        fid = fopen(command_file, 'w');

        % 写入XFOIL命令文件内容
        fprintf(fid, 'LOAD %s\n', airfoil_file); % 加载翼型
        fprintf(fid, 'PANE\n');
        fprintf(fid, 'GDES\n'); % 平滑翼型
        fprintf(fid, 'PSAV\n');
        fprintf(fid, '\n');
        fprintf(fid, 'OPER\n');
        fprintf(fid, 'VISC %d\n', Re); % 设置当前雷诺数
        fprintf(fid, 'ITER 200\n'); % 设置最大迭代次数

        % 输出结果路径
        output_file = fullfile(output_path, strcat(airfoil_name, sprintf('_Re_%.f_alpha_%.2f_output.dat', Re, alpha)));
        fprintf(fid, 'PACC\n');
        fprintf(fid, '%s\n', output_file); % 设置Polar输出文件
        fprintf(fid, '\n');

        fprintf(fid, 'ALFA %.2f\n', alpha); % 设置当前攻角

        fprintf(fid, 'PACC\n'); % 关闭Polar输出
        fprintf(fid, 'QUIT\n');
        fclose(fid);

        % 调用XFOIL
        command = sprintf('"%s" < "%s"', xfoil_path, command_file);
        [status, cmdout] = system(command);

        % 检查XFOIL运行状态
        if status ~= 0
            fid_log = fopen(log_file, 'a');
            fprintf(fid_log, '翼型 %s 的计算中断，检查命令或环境。\n命令输出: %s\n', airfoil_name, cmdout);
            fclose(fid_log);
            continue;
        end

        % 删除临时文件
        if exist(command_file, 'file')
            delete(command_file);
        end

        % 检查输出文件是否存在
        if exist(output_file, 'file')
            fprintf('翼型 %s 的结果已保存到: %s\n', airfoil_name, output_file);
        else
            fid_log = fopen(log_file, 'a');
            fprintf(fid_log, '翼型 %s 的结果未生成，可能未收敛。\n', airfoil_name);
            fclose(fid_log);
        end
    end
end

fprintf('计算完成，详细错误信息见日志文件: %s\n', log_file);
