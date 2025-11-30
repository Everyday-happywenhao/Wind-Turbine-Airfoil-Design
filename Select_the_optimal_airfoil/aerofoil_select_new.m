% 定义文件夹路径
folder_path = 'E:\jwh_gan\MATLAB\aerofoil\stall\all_dealed_cl_cd_25\s0.3\-11';

% 获取文件夹中所有.csv文件的路径
csv_files = dir(fullfile(folder_path, '*.csv'));
num_profiles = length(csv_files);

% 检查是否有csv文件
if num_profiles == 0
    error('文件夹中没有找到任何.csv文件');
end

% 初始化变量存储最大功率系数及对应的翼型
max_CP_overall = -Inf; % 初始化最大CP
best_TSR_overall = NaN; % 初始化最佳TSR
best_aerofoil = ''; % 初始化最佳翼型

% 定义参数范围
nblades_range = 3; % 叶片数范围
height_range = 3.8; % 高度范围
chord_range = 0.5; % 弦长范围
U_range = 11; % 风速范围

% 修改后的 TSR_vector 范围
TSR_vector = 2.5; % 从2到3，步长为0.5

% 循环遍历每个翼型文件
for i = 1:num_profiles
    % 获取当前翼型文件的完整路径
    current_file = fullfile(csv_files(i).folder, csv_files(i).name);
    
    for nblades = nblades_range
        for height = height_range
            for chord = chord_range
                for U = U_range
                    %% 创建涡轮对象
                    myTurbine = VAWT.DMST(0.3, TSR_vector, nblades, current_file); % 修改了此处的导入方式
                    
                    %% 设置涡轮参数
                    myTurbine.set('solidity', 0.3);
                    myTurbine.set('nblades', nblades);
                    myTurbine.set('height', height);
                    myTurbine.set('chord', chord);
                    myTurbine.set('wake', 0);
                    myTurbine.set('U', U);
                    
                    %% 设置TSR
                    myTurbine.set('TSR', TSR_vector); % 使用修改后的TSR_vector
                    
                    %% 设置叶片迎角
                    myTurbine.set('pitch', 0);
                    
                    %% 运行求解器
                    myTurbine.solve;
                    
                    %% 获取输出数据
                    outStruct = myTurbine.solution;
                    
                    % 获取当前配置下的最大CP
                    CP_values = arrayfun(@(s) s.power.CP, outStruct);
                    [max_CP, idx_max] = max(CP_values);
                    best_TSR = TSR_vector(idx_max);
                    
                    % 检查是否是整体最大CP
                    if max_CP > max_CP_overall
                        max_CP_overall = max_CP;
                        best_TSR_overall = best_TSR;
                        best_aerofoil = current_file; % 使用current_file替代原来不存在的aerofoil_files
                        best_nblades = nblades;
                        best_height = height;
                        best_chord = chord;
                        best_U = U;
                    end
                end
            end
        end
    end
end

% 显示最佳结果
fprintf('Overall, the maximum CP is %.4f for aerofoil %s at TSR = %.2f with nblades = %d, height = %.2f, chord = %.2f, and U = %.2f\n', ...
    max_CP_overall, best_aerofoil, best_TSR_overall, best_nblades, best_height, best_chord, best_U);
