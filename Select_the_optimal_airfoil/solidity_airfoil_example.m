% 定义文件夹路径
folder_path = 'E:\jwh_gan\MATLAB\gan\cvs_12000';

% 获取文件夹中所有.csv文件的路径
csv_files = dir(fullfile(folder_path, '*.csv'));
num_profiles = length(csv_files);

% 检查是否有csv文件
if num_profiles == 0
    error('文件夹中没有找到任何.csv文件');
end

% 初始化变量存储最大功率系数及对应的翼型和TSR
max_cp = -Inf;
best_profile = '';
best_tsr = NaN;
best_solidity = NaN;

% 定义涡轮参数
solidity_range = 0:0.05:0.1; % 实度范围
TSR_range = 1:0.5:2.5; % TSR范围
nblades = 3; % 叶片数

% 循环遍历每个翼型文件
for i = 1:num_profiles
    % 获取当前翼型文件的完整路径
    current_file = fullfile(csv_files(i).folder, csv_files(i).name);
    
    % 遍历实度范围
    for solidity = solidity_range
        % 创建涡轮对象
        myTurbine = VAWT.DMST(solidity, TSR_range, nblades, current_file);
        
        % 运行求解器
        myTurbine.solve;

        % 遍历TSR范围，获取最大Cp及对应的TSR
        for j = 1:length(TSR_range)
            outStruct = myTurbine.solution(j); % 获取特定TSR的结果
            cp = outStruct.power.CP; % 假设Cp存储在outStruct.power.CP

            % 检查当前翼型、实度和TSR的Cp是否为最大
            if cp > max_cp
                max_cp = cp;
                best_profile = current_file;
                best_tsr = TSR_range(j);
                best_solidity = solidity;
            end
        end
    end
end

% 打印出最大功率系数、对应的翼型、实度及TSR
fprintf('The best aero profile is %s with a maximum Cp of %f at Solidity = %f and TSR = %f\n', ...
    best_profile, max_cp, best_solidity, best_tsr);
