% 文件路径
path_min = 'E:\jwh_gan\MATLAB\gan\cvs_Re_min\';
path_max = 'E:\jwh_gan\MATLAB\gan\cvs_Re_max\';

% 读取文件名
files_min = dir(fullfile(path_min, '*.csv'));
files_max = dir(fullfile(path_max, '*.csv'));
assert(length(files_min) == length(files_max), '文件数量不匹配。');

% 创建两幅独立大图
figCL = figure('Units','pixels','Position',[100, 100, 600, 600]); % 升力系数图
figCD = figure('Units','pixels','Position',[100, 100, 600, 600]); % 阻力系数图

% 定义样式
colors = ['r', 'b'];  % 红: Re_min, 蓝: Re_max

for i = 1:25
    % 读取数据
    data_min = readmatrix(fullfile(path_min, files_min(i).name));
    data_max = readmatrix(fullfile(path_max, files_max(i).name));
    
    % 提取升力系数数据
    alpha_min = data_min(:, 1); cl_min = data_min(:, 4);
    alpha_max = data_max(:, 1); cl_max = data_max(:, 4);
    
    % 绘制CL子图
    figure(figCL);
    subplot(5, 5, i);
    hold on;
    plot(alpha_min, cl_min, [colors(1) '-'], 'LineWidth', 0.8);
    plot(alpha_max, cl_max, [colors(2) '-'], 'LineWidth', 0.8);
    title(['翼型' num2str(i)], 'FontSize', 6);
    set(gca, 'FontSize', 6, 'XTick', -10:5:20, 'YTickMode', 'auto'); % 设置固定α刻度
    grid on;
    if i == 1
        legend({'Re_{min}', 'Re_{max}'}, 'FontSize', 6, 'Location', 'northeast');
    end
    hold off;

    % 提取阻力系数数据
    cd_min = data_min(:, 3);
    cd_max = data_max(:, 3);
    
    % 绘制CD子图
    figure(figCD);
    subplot(5, 5, i);
    hold on;
    plot(alpha_min, cd_min, [colors(1) '-'], 'LineWidth', 0.8);
    plot(alpha_max, cd_max, [colors(2) '-'], 'LineWidth', 0.8);
    title(['翼型' num2str(i)], 'FontSize', 6);
    set(gca, 'FontSize', 6, 'XTick', -10:5:20, 'YTickMode', 'auto');
    grid on;
    if i == 1
        legend({'Re_{min}', 'Re_{max}'}, 'FontSize', 6, 'Location', 'northeast');
    end
    hold off;
end

% 添加全局标签并保存
figure(figCL);
annotation('textbox', [0.8 0.96 0.4 0.08], 'String', '',...
    'EdgeColor','none','HorizontalAlignment','center','FontSize',9');
print(figCL, 'Airfoils_CL', '-dpng', '-r100');

figure(figCD);
annotation('textbox', [0.8 0.96 0.4 0.08], 'String', '',...
    'EdgeColor','none','HorizontalAlignment','center','FontSize',9');
print(figCD, 'Airfoils_CD', '-dpng', '-r100');