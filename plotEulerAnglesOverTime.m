function plotEulerAnglesOverTime(eulerAnglesData)
    % 将弧度转换为角度
    eulerAnglesData.Yaw = rad2deg(eulerAnglesData.Yaw);
    eulerAnglesData.Pitch = rad2deg(eulerAnglesData.Pitch);
    eulerAnglesData.Roll = rad2deg(eulerAnglesData.Roll);

    % 绘制时序图
    figure;

    % 绘制偏航角
    subplot(3, 1, 1); % 3行1列的第一个图
    plot(eulerAnglesData.Timestamp, eulerAnglesData.Yaw, 'b');
    title('Yaw Angle Over Time');
    xlabel('Time (s)');
    ylabel('Angle (degrees)');
    grid on;

    % 绘制俯仰角
    subplot(3, 1, 2); % 3行1列的第二个图
    plot(eulerAnglesData.Timestamp, eulerAnglesData.Pitch, 'r');
    title('Pitch Angle Over Time');
    xlabel('Time (s)');
    ylabel('Angle (degrees)');
    grid on;

    % 绘制滚转角
    subplot(3, 1, 3); % 3行1列的第三个图
    plot(eulerAnglesData.Timestamp, eulerAnglesData.Roll, 'g');
    title('Roll Angle Over Time');
    xlabel('Time (s)');
    ylabel('Angle (degrees)');
    grid on;

    % 自动调整子图间距以避免重叠
    if exist('tight_layout', 'file')
        tight_layout();
    else
        % 如果tight_layout不存在，可以考虑使用subplot的'Position'属性进行调整
        % 或者使用MATLAB默认布局
    end
end