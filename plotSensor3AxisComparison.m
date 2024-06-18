function plotSensor3AxisComparison(originalData, filteredData, sensorName)
    % 定义颜色代码
    origColor = [0,114,189]/ 255;  % 一个亮青色
    filtColor = [216,83,26]/ 255;  % 一个亮品红色
    
    axisNames = {'X', 'Y', 'Z'}; % 轴的名字
    for i = 1:3
        % 为每个轴创建单独的图形
        figure('Name', [sensorName ' ' axisNames{i} '轴 数据对比'], 'NumberTitle', 'off');
        hold on;
        
        % 提取时间戳和对应轴的数据
        timestamps = originalData.Timestamp;
        origAxisData = originalData{:, i+2}; % X轴数据是第三列，Y轴是第四列，Z轴是第五列
        filtAxisData = filteredData{:, i+2};
        
        % 绘制原始数据
        plot(timestamps(1:1000), origAxisData(1:1000), 'Color', origColor, 'DisplayName', '原始数据');
        
        % 绘制滤波后的数据
        plot(timestamps(1:1000), filtAxisData(1:1000), 'Color', filtColor, 'DisplayName', '滤波后数据');
        
        legend('show');
        hold off;
        
        % 设置图的标题和轴标签
        title([sensorName ' ' axisNames{i} '轴 数据对比']);
        xlabel('时间戳');
        ylabel('数值');
    end
end