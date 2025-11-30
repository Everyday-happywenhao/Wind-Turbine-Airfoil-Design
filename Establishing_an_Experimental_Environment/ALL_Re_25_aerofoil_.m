clc;
clear;

% 定义相关路径
xfoil_path = 'E:\jwh_gan\gan\XFOIL6.99\\xfoil.exe'; % XFOIL可执行文件路径
input_path = 'E:\jwh_gan\gan\XFOIL6.99\\'; % 翼型坐标路径
base_output_path = 'E:\jwh_gan\MATLAB\aerofoil\ALL_Re1'; % 总输出路径
log_file = fullfile(base_output_path, 'error_log.txt'); % 错误日志文件

% 创建输出总目录
if ~exist(base_output_path, 'dir')
    mkdir(base_output_path);
end

% 初始化错误日志
fid_log = fopen(log_file, 'w');
fprintf(fid_log, 'XFOIL计算错误日志\n');
fclose(fid_log);

% 读取CSV中的雷诺数
csv_filename = 'E:\jwh_gan\MATLAB\aerofoil\Phase_Angle_Angle_of_attack_Reynolds_number\Phase_Angle_Angle_of_attack_Reynolds_number.csv';
data_table = readtable(csv_filename);
Re_values = data_table.Reynolds_Number;

% 读取翼型文件
file_list = dir(fullfile(input_path, '*.txt'));

% 参数设定
alpha_start = -5; % 起始攻角
alpha_end = 20; % 终止攻角
alpha_step = .25; % 攻角步长
n_iter = 200; % 最大迭代次数
alpha_segment = 5; % 攻角分段范围

% 遍历每个雷诺数
for j = 1:length(Re_values)
    Re = Re_values(j);
    
    % 创建子文件夹
    Re_folder = sprintf('Re=%d', round(Re));
    output_path = fullfile(base_output_path, Re_folder);
    if ~exist(output_path, 'dir')
        mkdir(output_path);
    end

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
        fprintf(fid, 'VISC %d\n', Re); % 设置雷诺数
        fprintf(fid, 'ITER %d\n', n_iter); % 设置最大迭代次数

        % 输出结果路径
        output_file = fullfile(output_path, strcat(airfoil_name, '_output.dat'));
        fprintf(fid, 'PACC\n');
        fprintf(fid, '%s\n', output_file); % 设置Polar输出文件
        fprintf(fid, '\n');

        % 分段攻角计算
        current_alpha = alpha_start;
        while current_alpha < alpha_end
            next_alpha = min(current_alpha + alpha_segment, alpha_end);
            fprintf(fid, 'ASEQ %.2f %.2f %.2f\n', current_alpha, next_alpha, alpha_step);
            current_alpha = next_alpha + alpha_step;
        end

        fprintf(fid, 'PACC\n'); % 关闭Polar输出
        fprintf(fid, 'QUIT\n');
        fclose(fid);

        % 调用XFOIL
        command = sprintf('"%s" < "%s"', xfoil_path, command_file);
        status = system(command);

        % 检查XFOIL运行状态
        if status ~= 0
            fid_log = fopen(log_file, 'a');
            fprintf(fid_log, '翼型 %s 的计算中断，检查命令或环境。\n', airfoil_name);
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
