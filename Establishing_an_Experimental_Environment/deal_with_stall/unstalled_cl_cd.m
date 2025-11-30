function process_aerofoil_data()
    % 设置基本目录和输出目录路径
    base_dir = 'E:\jwh_gan\MATLAB\verification\CL_CD\every_condition_new';
    stall_judge_dir_pos = 'E:\jwh_gan\MATLAB\verification\judge_stalled_+AoA';
    stall_judge_dir_neg = 'E:\jwh_gan\MATLAB\verification\judge_stalled_-AoA';
    output_dir = 'E:\jwh_gan\MATLAB\aerofoil\stall\unstalled_cl_cd';

    % 如果输出目录不存在，则创建它
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % 获取基本目录中所有子目录（假设以'Re_'开头）
    subdirs = dir(fullfile(base_dir, 'Re_*'));

    % 计算所有子目录下CSV文件的总数量，用于进度条显示
    total_tasks = sum(arrayfun(@(x) length(dir(fullfile(base_dir, x.name, '*.csv'))), subdirs));
    task_counter = 0;

    % 创建一个进度条窗口
    h_waitbar = waitbar(0, 'Processing...', 'Name', 'Aerofoil Data Processing');

    % 遍历每个子目录
    for i = 1:length(subdirs)
        subdir = subdirs(i).name;
        subdir_path = fullfile(base_dir, subdir);

        % 获取子目录下的所有CSV文件
        airfoil_files = dir(fullfile(subdir_path, '*.csv'));

        % 遍历每个CSV文件
        for j = 1:length(airfoil_files)
            airfoil_file = airfoil_files(j).name;
            file_path = fullfile(subdir_path, airfoil_file);
            airfoil_number = erase(airfoil_file, '.csv');

            % 读取CSV文件中的数据
            data = readtable(file_path, 'VariableNamingRule', 'preserve');
            AoA = data{:, 1}; % 实际攻角
            Cd = data{:, 3}; % 阻力系数
            Cl = data{:, 4}; % 升力系数

            % 检查是否有足够的数据点进行拟合
            if length(AoA) < 2 || length(Cd) < 2 || length(Cl) < 2
                warning('Not enough data points in %s to perform fitting. Skipping...', airfoil_file);
                continue;
            end

            % 拟合阻力和升力系数的曲线
            cd_fit = fit(AoA, Cd, 'cubicinterp');
            cl_fit = fit(AoA, Cl, 'cubicinterp');

            % 从两个失速判断目录中汇总结果
            results = [];
            for stall_judge_dir = {stall_judge_dir_pos, stall_judge_dir_neg}
                judge_file = fullfile(stall_judge_dir{1}, [subdir, '.csv']);
                if exist(judge_file, 'file')
                    judge_data = readtable(judge_file, 'VariableNamingRule', 'preserve');
                    
                    % 过滤出未失速的数据
                    filter = (judge_data.Airfoil == str2double(airfoil_number)) & ...
                             strcmp(judge_data.Stalled, 'N');
                    unstalled_data = judge_data(filter, :);

                    % 对未失速的数据进行插值并存储结果
                    for k = 1:height(unstalled_data)
                        aoa_val = unstalled_data.Var3(k); % 从judge文件中取出实际攻角
                        cd_val = cd_fit(aoa_val); % 使用拟合曲线计算阻力系数
                        cl_val = cl_fit(aoa_val); % 使用拟合曲线计算升力系数
                        results = [results; aoa_val, 0, cd_val, cl_val]; % 将结果添加到数组中
                    end
                end
            end
            
            % 保存（追加）计算结果到CSV文件
            if ~isempty(results)
                result_table = array2table(results, 'VariableNames', {'AoA (deg)', 't (s)', 'Cd', 'Cl'});
                output_file = fullfile(output_dir, [airfoil_number, '.csv']);
                
                if isfile(output_file)
                    writetable(result_table, output_file, 'WriteMode', 'append', 'WriteVariableNames', false);
                else
                    writetable(result_table, output_file);
                end
            end

            % 更新进度条
            task_counter = task_counter + 1;
            waitbar(task_counter / total_tasks, h_waitbar, sprintf('Processing... %.2f%%', (task_counter / total_tasks) * 100));
        end
    end

    % 关闭进度条窗口
    close(h_waitbar);
    disp('All processing complete');
end
