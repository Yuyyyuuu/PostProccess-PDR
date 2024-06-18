function DataAfterFilter=Filter(Data)
    % Data: 原始数据表格，格式为：'SensorType', 'Timestamp', 'X', 'Y', 'Z'
    % DataAfterFilter: 滤波后的数据

    % 获取滤波方式和采样频率
    cfg = ProcessConfig();
    mode = cfg.filtermode;
    f = cfg.f;
    windowSize = floor(f * cfg.filtersize); % 计算滤波窗口大小为采样频率的0.1倍

    % 预分配滤波后数据的空间
    DataAfterFilter = Data;

    % 逐列进行滤波
    for col = {'X', 'Y', 'Z'}
        colData = Data{:, col{1}};
        filteredData = zeros(size(colData));
        
        % 根据mode选择滤波方式
        switch mode
            case 1 % 均值滤波
                for i = 1:length(colData)
                    windowIndices = max(1, i - windowSize):min(length(colData), i + windowSize);
                    filteredData(i) = mean(colData(windowIndices));
                end
            case 2 % 中值滤波
                for i = 1:length(colData)
                    windowIndices = max(1, i - windowSize):min(length(colData), i + windowSize);
                    filteredData(i) = median(colData(windowIndices));
                end
            case 3 % 去掉最大值和最小值后求均值
                for i = 1:length(colData)
                    windowIndices = max(1, i - windowSize):min(length(colData), i + windowSize);
                    windowData = colData(windowIndices);
                    windowData(windowData == max(windowData) | windowData == min(windowData)) = [];
                    filteredData(i) = mean(windowData);
                end
            otherwise
                error('未知的滤波模式');
        end
        
        % 将滤波后的数据赋值给对应列
        DataAfterFilter{:, col{1}} = filteredData;
    end
end