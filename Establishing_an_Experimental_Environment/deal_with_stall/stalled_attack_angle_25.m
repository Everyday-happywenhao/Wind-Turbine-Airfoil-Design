% 主文件夹路径和输出文件夹路径
mainFolderPath = 'E:\jwh_gan\MATLAB\aerofoil\ALL_Re_CL_CD';
outputFolderPath = 'E:\jwh_gan\MATLAB\aerofoil\stall\ALL_Re_stalled';

% 如果输出文件夹不存在，则创建它
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
end

% 获取主文件夹中的所有子文件夹
subFolders = dir(fullfile(mainFolderPath, '*'));

% 容器，用于存储每个雷诺数下的失速攻角数据
reDataMap = containers.Map();

% 遍历每个子文件夹
for i = 1:length(subFolders)
    % 过滤掉非文件夹、隐藏文件夹以及 "." 和 ".."
    if ~subFolders(i).isdir || strcmp(subFolders(i).name, '.') || strcmp(subFolders(i).name, '..')
        continue;
    end
    subFolderPath = fullfile(mainFolderPath, subFolders(i).name);
    
    % 从子文件夹名称提取雷诺数信息
    ReMatch = regexp(subFolders(i).name, 'Re=(\d+)', 'tokens');  % 假设子文件夹名称含有 "Re="
    if ~isempty(ReMatch)
        ReNumStr = ReMatch{1}{1};  % 提取雷诺数字符串
    else
        warning('无法从子文件夹名称中提取雷诺数：%s', subFolders(i).name);
        continue;
    end
    
    % 获取子文件夹中的所有 CSV 文件并按名称排序
    csvFiles = dir(fullfile(subFolderPath, '*.csv'));
    csvFileNames = {csvFiles.name};
    
    % 排序文件名，以确保从小到大排列
    csvFileNames = sort(csvFileNames);

    % 用于存储按顺序的翼型名称与失速攻角
    airfoilStallData = {};
    
    % 遍历每个 CSV 文件
    for j = 1:length(csvFileNames)
        csvFileName = csvFileNames{j};
        csvFilePath = fullfile(subFolderPath, csvFileName);
        
        % 读取 CSV 文件，保留原始列标题
        data = readtable(csvFilePath, 'VariableNamingRule', 'preserve');
        
        % 提取攻角 (AoA) 和升力系数 (Cl)
        if size(data, 2) >= 4  % 确保表格至少有四列
            AoA = data.(1);  % 第一列为攻角
            Cl = data.(4);   % 第四列为升力系数
            
            % 找到最大 Cl 及其对应的攻角（即失速攻角）
            [maxCl, idxMaxCl] = max(Cl);
            stallAoA = AoA(idxMaxCl); % 失速攻角
            
            % 从文件名中提取翼型名称（假设格式为 'airfoil_X_output.csv'）
            airfoilMatch = regexp(csvFileName, '(airfoil_\d+)', 'tokens');
            if ~isempty(airfoilMatch)
                airfoilName = airfoilMatch{1}{1};
            else
                airfoilName = sprintf('Airfoil_%d', j-1); % 处理异常情况
            end
            
            % 将结果添加到列表中
            airfoilStallData{end+1, 1} = airfoilName;
            airfoilStallData{end, 2} = stallAoA;
        else
            warning('文件格式不正确或列数不足：%s', csvFileName);
        end
    end
    
    % 将翼型和失速攻角添加到对应雷诺数的数据中
    reDataMap(ReNumStr) = airfoilStallData;
end

% 保存每个雷诺数的失速攻角结果到输出文件夹
reKeys = keys(reDataMap);

for k = 1:length(reKeys)
    ReNumStr = reKeys{k};
    stallData = reDataMap(ReNumStr);
    
    % 创建表格并保存为 CSV 文件
    stallTable = cell2table(stallData, 'VariableNames', {'Airfoil', 'StallAoA'});
    outputFileName = sprintf('Re=%s.csv', ReNumStr);
    outputFilePath = fullfile(outputFolderPath, outputFileName);
    
    writetable(stallTable, outputFilePath);
end

disp('任务完成！所有雷诺数的失速攻角已保存到指定文件夹中。');
