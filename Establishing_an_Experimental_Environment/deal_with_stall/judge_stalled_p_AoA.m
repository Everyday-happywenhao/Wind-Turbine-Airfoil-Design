% 路径设置
inputCsvPath = 'E:\jwh_gan\MATLAB\aerofoil\Phase_Angle_Angle_of_attack_Reynolds_number\Phase_Angle_Angle_of_attack_Reynolds_number_processed.csv';
mainFolderPath = 'E:\jwh_gan\MATLAB\aerofoil\stall\ALL_Re_stalled';
outputFolderPath = 'E:\jwh_gan\MATLAB\aerofoil\stall\judge_stalled';

% 如果输出文件夹不存在，则创建它
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
end

% 读取攻角信息的 CSV 文件
angleData = readtable(inputCsvPath);

% 获取所有 CSV 文件
csvFiles = dir(fullfile(mainFolderPath, '*.csv'));

for i = 1:length(csvFiles)
    csvFileName = csvFiles(i).name;
    csvFilePath = fullfile(mainFolderPath, csvFileName);

    % 从文件名中提取雷诺数
    ReMatch = regexp(csvFileName, 'Re=(\d+)', 'tokens');
    if isempty(ReMatch)
        warning('无法从文件名中提取雷诺数：%s', csvFileName);
        continue;
    end
    ReNumStr = ReMatch{1}{1};
    ReNum = str2double(ReNumStr);
    
    % 找到对应雷诺数的实际攻角（假设‘Re_num’列在 angleData 中）
    actualAOAIndex = find(angleData.Re_num == ReNum, 1);
    if isempty(actualAOAIndex)
        warning('没有找到对应雷诺数的实际攻角：Re=%s', ReNumStr);
        continue;
    end
    actualAOA = angleData.AoA(actualAOAIndex);  % 假设攻角列为 AOA

    % 读取当前 CSV 文件
    stallData = readtable(csvFilePath, 'VariableNamingRule', 'preserve');

    % 初始化失速标识列
    stalled = strings(height(stallData), 1);
    
    % 计算失速情况，并在第三列添加实际攻角
    for j = 1:height(stallData)
        stallAoA = stallData{j, 2};  % 假设第二列为失速攻角
        % 在第三列显示实际攻角
        stallData{j, 3} = actualAOA; 
        if stallData{j, 3} > stallAoA || stallData{j, 3} < -5
            stalled(j) = 'Y';
        else
            stalled(j) = 'N';
        end
    end

    % 添加新列
    stallData.Stalled = stalled;

    % 输出文件路径
    outputFileName = sprintf('Re=%s.csv', ReNumStr);
    outputFilePath = fullfile(outputFolderPath, outputFileName);
    
    % 保存结果到新的 CSV 文件
    writetable(stallData, outputFilePath);
end

disp('任务完成！所有判别失速结果已保存到指定文件夹中。');
