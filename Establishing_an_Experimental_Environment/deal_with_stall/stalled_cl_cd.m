% 定义路径
folder1 = 'E:\jwh_gan\MATLAB\aerofoil\stall\judge_stalled_+AoA_new1';
folder2 = 'E:\jwh_gan\MATLAB\aerofoil\stall\judge_stalled_-AoA_new1';
folder3 = 'E:\jwh_gan\MATLAB\aerofoil\ALL_Re_CL_CD_new2';
outputFolder = 'E:\jwh_gan\MATLAB\aerofoil\stall\stalled_cl_cd';

% 创建输出目录，如果不存在
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 获取总文件夹1和2中的.csv文件列表
files1 = dir(fullfile(folder1, '*.csv'));
files2 = dir(fullfile(folder2, '*.csv'));
files = [files1; files2];

% 初始化进度条
totalFiles = length(files);
h = waitbar(0, 'Processing files...');

% 遍历所有.csv文件
for i = 1:totalFiles
    % 获取当前文件名和路径
    currentFile = files(i).name;
    currentPath = files(i).folder;
    
    % 在命令行中显示当前处理的文件
    fprintf('Processing file: %s\n', fullfile(currentPath, currentFile));

    % 更新进度条
    waitbar(i / totalFiles, h, sprintf('Processing file %d of %d', i, totalFiles));
    
    % 读取当前.csv文件的数据
    data = readcell(fullfile(currentPath, currentFile), 'NumHeaderLines', 1);
    
    % 查找失速条件的行 (第四列为字符 'Y')
    isStalled = strcmp(data(:, 4), 'Y');
    stalledRows = data(isStalled, :);
    
    % 提取雷诺数信息
    [~, name, ~] = fileparts(currentFile);
    
    % 在总文件夹3中找到对应的子文件夹
    subFolder = fullfile(folder3, name);
    
    % 检查每一行找到的失速数据
    for j = 1:size(stalledRows, 1)
        airfoilNum = stalledRows{j, 1};  % 翼型编号
        stalledAoA = stalledRows{j, 2};  % 失速攻角
        actualAoA = stalledRows{j, 3};   % 实际攻角
        
        % 读取翼型的CSV数据 (总文件夹3的子文件夹中)
        airfoilFile = fullfile(subFolder, sprintf('%d.csv', airfoilNum));
        if exist(airfoilFile, 'file')
            airfoilData = readmatrix(airfoilFile, 'NumHeaderLines', 1);
            
            % 确保airfoilData非空并且至少有一列
            if ~isempty(airfoilData) && size(airfoilData, 2) >= 1
                % 找到与失速攻角相对应的行获取升阻力系数
                index = find(airfoilData(:, 1) == stalledAoA, 1);
                if ~isempty(index)
                    stallCd = airfoilData(index, 3);
                    stallCl = airfoilData(index, 4);
                    
                    % 结果保存到输出路径
                    outputFile = fullfile(outputFolder, sprintf('%d.csv', airfoilNum));
                    
                    % 添加列标题
                    headers = {"AoA", "stalled_AoA", "stall_cd", "stall_cl"};
                    
                    % 检查文件是否存在
                    if ~exist(outputFile, 'file')
                        % 写入标题行
                        writecell(headers, outputFile);
                    end
                    
                    % 追加数据
                    newData = [actualAoA, stalledAoA, stallCd, stallCl];
                    writematrix(newData, outputFile, 'WriteMode', 'append');
                end
            else
                warning('Missing or incomplete data in file: %s', airfoilFile);
            end
        else
            warning('File does not exist: %s', airfoilFile);
        end
    end
end

% 关闭进度条
close(h);
