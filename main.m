%%---------------------主程序入口------------------------------
% 本套算法适用的b系为前右下，n系与启动时的b系保持一致并固定下来

cfg=ProcessConfig(); % 配置信息

%% 读取文件
% 文件名
filename = cfg.filename;

% 读取文件数据
opts = delimitedTextImportOptions('NumVariables', 5);
opts.DataLines = [1, inf]; % 行数范围
opts.Delimiter = ' '; % 数据间隔
opts.VariableNames = {'SensorType', 'Timestamp', 'X', 'Y', 'Z'}; % 列名
opts.VariableTypes = {'double', 'double', 'double', 'double', 'double'}; % 数据类型

% 使用readtable函数读取文件
sensorData = readtable(filename, opts);

% 注：n系为自建相对系，以最开始的b系固定下来为n系，即前右下分别为xyz

% 调整手机IMU输出为前右下-xyz的b系
% 交换X和Y列
temp = sensorData.X;
sensorData.X = sensorData.Y;
sensorData.Y = temp;
% Z列取相反数
sensorData.Z = -sensorData.Z;


%% 数据预处理之时间同步
% sensorData是之前读取的表格数据
% 根据传感器类型筛选数据
accelerometerData = sensorData(sensorData.SensorType == 1, :); % 加速度计数据
gyroscopeData = sensorData(sensorData.SensorType == 2, :);     % 陀螺仪数据
magnetometerData = sensorData(sensorData.SensorType == 3, :);  % 磁力计数据

% 初始化同步后的传感器数据表格，并预先设置列名
syncedAccelData = table('Size', [0 5], 'VariableTypes', opts.VariableTypes, 'VariableNames', opts.VariableNames);
syncedGyroData = table('Size', [0 5], 'VariableTypes', opts.VariableTypes, 'VariableNames', opts.VariableNames);
syncedMagData = table('Size', [0 5], 'VariableTypes', opts.VariableTypes, 'VariableNames', opts.VariableNames);

% 遍历加速度计数据的时间戳
for i = 1:height(accelerometerData)
    accelTimestamp = accelerometerData.Timestamp(i);

    % 获取陀螺仪和磁力计数据的时间戳向量
    gyroTimestamps = gyroscopeData.Timestamp;
    magTimestamps = magnetometerData.Timestamp;

    % 在陀螺仪和磁力计数据中寻找加速度计时间戳的前后值
    gyroBefore = find(gyroTimestamps < accelTimestamp, 1, 'last');
    gyroAfter = find(gyroTimestamps > accelTimestamp, 1, 'first');
    magBefore = find(magTimestamps < accelTimestamp, 1, 'last');
    magAfter = find(magTimestamps > accelTimestamp, 1, 'first');

    % 如果在陀螺仪和磁力计数据中找到了前后值，则进行插值
    if ~isempty(gyroBefore) && ~isempty(gyroAfter)
        gyroInterp = interp1(gyroTimestamps([gyroBefore, gyroAfter]), gyroscopeData{[gyroBefore, gyroAfter], 3:5}, accelTimestamp, 'linear', 'extrap');
    else
        % 如果找不到有效的前后值，可以选择跳过此次循环迭代，或者使用其他方法处理
        continue;
    end

    if ~isempty(magBefore) && ~isempty(magAfter)
        magInterp = interp1(magTimestamps([magBefore, magAfter]), magnetometerData{[magBefore, magAfter], 3:5}, accelTimestamp, 'linear', 'extrap');
    else
        % 如果找不到有效的前后值，可以选择跳过此次循环迭代，或者使用其他方法处理
        continue;
    end

    % 将插值后的数据添加到对应的表格中
    syncedGyroData = [syncedGyroData; table(2, accelTimestamp, gyroInterp(1), gyroInterp(2), gyroInterp(3), 'VariableNames', opts.VariableNames)];
    syncedMagData = [syncedMagData; table(3, accelTimestamp, magInterp(1), magInterp(2), magInterp(3), 'VariableNames', opts.VariableNames)];
    syncedAccelData = [syncedAccelData; accelerometerData(i, :)];
end
%plotSensor3Axis(syncedGyroData);
%bgz=mean(syncedGyroData.Z);
% 将Z列的值加上0.0011
syncedGyroData.Z = syncedGyroData.Z + 7.3202e-4;

%{
 plotSensor3Axis(syncedAccelData);
 plotSensor3Axis(syncedGyroData);
 plotSensor3Axis(syncedMagData);
%}

%% 数据预处理之滤波降噪
%plotSensor3AxisComparison(syncedAccelData, Filter(syncedAccelData), '加速度计');



syncedAccelData=Filter(syncedAccelData);
syncedGyroData=Filter(syncedGyroData);
syncedMagData=Filter(syncedMagData);
%{
plotSensor3Axis(syncedAccelData);
plotSensor3Axis(syncedGyroData);
plotSensor3Axis(syncedMagData);
%}
%% 求水平姿态角
pitch = [];
roll = [];
prev_pitch = 0;  % 初始化上一个pitch的值
prev_roll = 0;   % 初始化上一个roll的值

for i = 1:1*cfg.f
    accdata = syncedAccelData{i, 3:5};
    acc_x = accdata(1);
    acc_y = accdata(2);
    acc_z = accdata(3);
    
    % 计算r和p
    r = atan2(-acc_y,-acc_z);
    p = atan2(acc_x,-acc_z);
    %p = atan2(-acc_x, acc_y*sin(r) + acc_z*cos(r));
    
    % 处理NaN值
    if isnan(r)
        r = prev_roll;
    end
    if isnan(p)
        p = prev_pitch;
    end
    
    % 更新prev_pitch和prev_roll的值
    prev_pitch = p;
    prev_roll = r;
    
    % 添加r到roll中
    roll = [roll, r];
    
    % 添加p到pitch中
    pitch = [pitch, p];
end


roll0 = mean(roll);
pitch0 = mean(pitch);

%% 用陀螺数据推算航向角
% 推算每个时刻的航向角
% 初始化表格来存储时间戳和三个欧拉角
eulerAnglesData = table('Size', [0 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', {'Timestamp', 'Yaw', 'Pitch', 'Roll'});

% 初始化四元数为单位四元数
q = [1; 0; 0; 0];
q = Euler2Q(0,pitch0,roll0);

% 误差量
eInt=[0,0,0];

% 假设gyroTimestamps是陀螺仪数据的时间戳向量，我们需要从syncedGyroData表中获取它
gyroTimestamps = syncedGyroData.Timestamp; 

% 遍历陀螺仪数据
for i = 1:height(syncedGyroData)
    % 获取当前的陀螺仪输出和时间戳
    gyro_output = syncedGyroData{i, 3:5};
    timestamp = syncedGyroData.Timestamp(i);
    
    % 如果是第一个数据点，dT为0，之后的dT为当前时间戳与前一个时间戳的差
    if i == 1
        dT = 0;
    else
        dT = gyroTimestamps(i) - gyroTimestamps(i-1);
    end
    
    % AHRS六轴补偿陀螺原始输出
    acc_output=syncedAccelData{i, 3:5};
    gyro_output=AHRS(q,gyro_output,acc_output,eInt,dT);

    % 更新四元数
    q = updateQuaternion(q, gyro_output, dT);
    
    % 将四元数转换为旋转矩阵Cbn
    R = quaternionToRotationMatrix(q);
    
    % 从旋转矩阵中获取欧拉角
    euler_angles = rotationMatrixToEulerAngles(R);
    
    % 提取偏航角、俯仰角和滚转角
    yaw = euler_angles(1);
    pitch = euler_angles(2);
    roll = euler_angles(3);
    
    % 将时间戳和欧拉角存储在表格中
    eulerAnglesData = [eulerAnglesData; {timestamp, yaw, pitch, roll}];
end

% eulerAnglesData表格包含了时间戳和对应的三个欧拉角
plotEulerAnglesOverTime(eulerAnglesData);

stepsumlength=0;
%% PDR推算
% 探测步伐
threshold = cfg.g; % 阈值可能需要根据实际情况调整
stepsTimestamps = detectSteps(syncedAccelData, threshold,eulerAnglesData);

% 初始化位置
posX = 0;
posY = 0;
positions = [posX, posY]; % 存储每一步的位置

% 遍历每个步伐时间戳，更新位置
for i = 1:length(stepsTimestamps)
    % 找到对应的航向角
    stepTime = stepsTimestamps(i);
    eulerIndex = find(eulerAnglesData.Timestamp <= stepTime, 1, 'last');
    headingAngle = eulerAnglesData.Yaw(eulerIndex);
    
    % 将航向角从度转换为弧度，本身就是弧度
    headingAngleRad = headingAngle;
    
    % 设定步长
    % 获取两次脚步间的时间间隔
    if i<2
        dt=0.5;
    else
        dt=stepsTimestamps(i)-stepsTimestamps(i-1);
    end    
    accIndex=find(syncedAccelData.Timestamp <= stepTime, 1, 'last');
    acc = syncedAccelData(accIndex, :);
    stepLength = stepestimation(acc,dt); % 米
    stepsumlength=stepsumlength+stepLength;
    % 更新位置
    [posX, posY] = updatePosition(posX, posY, stepLength, headingAngleRad);
    
    % 将新位置添加到数组
    positions(end+1, :) = [posX, posY];
end

% 绘制路径
figure;
plot(positions(:,2), positions(:,1), 'bo-');
title('行人航迹推算路径');
xlabel('Y Position (m)');
ylabel('X Position (m)');
axis equal;
grid on;
