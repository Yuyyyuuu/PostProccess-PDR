function plotSensor3Axis(syncedSensorData)
    % syncedSensorData: 同步后的某个传感器数据表格
    % 画出该传感器的X, Y, Z三轴时序图

    figure; % 创建一个新的图形窗口

    % 绘制X轴数据
    subplot(3, 1, 1); % 三行一列的第一个
    plot(syncedSensorData.Timestamp, syncedSensorData.X, 'r');
    title('X轴输出');
    xlabel('时间');
    ylabel('X轴值');

    % 绘制Y轴数据
    subplot(3, 1, 2); % 三行一列的第二个
    plot(syncedSensorData.Timestamp, syncedSensorData.Y, 'g');
    title('Y轴输出');
    xlabel('时间');
    ylabel('Y轴值');

    % 绘制Z轴数据
    subplot(3, 1, 3); % 三行一列的第三个
    plot(syncedSensorData.Timestamp, syncedSensorData.Z, 'b');
    title('Z轴输出');
    xlabel('时间');
    ylabel('Z轴值');
end