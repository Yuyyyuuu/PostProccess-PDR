function stepsDetected = detectSteps(accelerometerData, threshold,eulerAnglesData)
    % accelerometerData: 加速度计数据表格，包含时间戳和X、Y、Z轴加速度
    % threshold: 探测步伐的阈值
    % eulerAnglesDat：包含了时间戳和对应的三个欧拉角的表格
    % stepsDetected: 返回探测到的步伐时间戳
    
    cfg=ProcessConfig();
    mode=cfg.stepdetectmode;

    % 初始化步伐探测结果
    stepsDetected = [];

    % 记录最近一次探测到的步伐时间戳
    lastStepTime = 0; % 初始化为0   

    switch mode
        case 1
            % 计算加速度模长
            accelMagnitude = sqrt(accelerometerData.X.^2 + accelerometerData.Y.^2 + accelerometerData.Z.^2);

            % 遍历加速度模长数据探测步伐
            for i = 2:(height(accelerometerData) - 1)
                % 使用连续三个历元进行峰值探测
                if accelMagnitude(i) > accelMagnitude(i-1) && accelMagnitude(i) > accelMagnitude(i+1) && accelMagnitude(i) > threshold
                    % 检测到峰值，确认是否为步伐
                    currentTime = accelerometerData.Timestamp(i);
                    if (currentTime - lastStepTime > 0.5) % 检查时间间隔是否大于0.5秒
                        % 确认为步伐
                        stepsDetected(end+1) = currentTime;
                        % 更新最近一次步伐时间戳
                        lastStepTime = currentTime;
                    end
                end
            end
            % 绘制加速度模长时序图
            figure;
            plot(accelerometerData.Timestamp, accelMagnitude);
            title('加速度计模长时序图与步伐标记');
            xlabel('时间戳');
            ylabel('加速度模长');
            hold on;
            
            % 在探测到的脚步处添加标记
            for i = 1:length(stepsDetected)
                stepTime = stepsDetected(i);
                stepIndex = accelerometerData.Timestamp == stepTime;
                stepMagnitude = accelMagnitude(stepIndex);
                plot(stepTime, stepMagnitude, 'r*', 'MarkerSize', 10);
            end
            
            hold off;

        case 2
            % 初始化垂直加速度数组
            verticalAccels = zeros(height(accelerometerData), 1);
        
            % 遍历加速度数据探测步伐
            for i = 1:height(accelerometerData)
                % 从eulerAnglesData中获取对应的欧拉角
                yaw = eulerAnglesData.Yaw(i);
                pitch = eulerAnglesData.Pitch(i);
                roll = eulerAnglesData.Roll(i);
        
                % 计算方向余弦矩阵
                dcm = eulerToDCM(yaw, pitch, roll); % 需要实现的函数
        
                % 从加速度计数据获取当前历元的加速度
                accelVector = [accelerometerData.X(i); accelerometerData.Y(i); accelerometerData.Z(i)];
        
                % 将加速度向量转换到导航坐标系
                transformedAccelVector = dcm * accelVector;
        
                % 获取并保存垂直方向的加速度，并取绝对值
                verticalAccels(i) = abs(transformedAccelVector(3));
        
                % 确认是否为步伐
                if verticalAccels(i) > threshold
                    currentTime = accelerometerData.Timestamp(i);
                    if (currentTime - lastStepTime) > 0.5 % 时间间隔大于0.5秒
                        stepsDetected(end+1) = currentTime;
                        lastStepTime = currentTime; % 更新最近一次步伐时间戳
                    end
                end
            end
        
            % 绘制垂直加速度时序图
            figure;
            plot(accelerometerData.Timestamp, verticalAccels);
            title('垂向加速度时序图与步伐标记');
            xlabel('时间戳');
            ylabel('垂向加速度');
            hold on;
        
            % 在探测到的脚步处添加标记
            for i = 1:length(stepsDetected)
                stepTime = stepsDetected(i);
                stepIndex = accelerometerData.Timestamp == stepTime;
                stepMagnitude = verticalAccels(stepIndex);
                plot(stepTime, stepMagnitude, 'r*', 'MarkerSize', 10);
            end
        
            hold off;

        otherwise
            error('未知的脚步探测模式');
    end
    
    
   
end