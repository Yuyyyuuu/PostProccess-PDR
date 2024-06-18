function euler_angles = rotationMatrixToEulerAngles(R)
    % R: 旋转矩阵，一个3x3矩阵

    % 假设旋转矩阵R是通过Z-Y-X顺序（偏航-俯仰-滚转）的旋转得到的
    % 首先检查俯仰角是否在锁定范围内（即接近±90度）
    if abs(R(3,1)) ~= 1
        % 俯仰角不是±90度
        pitch = atan2(-R(3,1),sqrt(R(3,2)*R(3,2)+R(3,3)*R(3,3))); % 俯仰角
        roll = atan2(R(3,2), R(3,3)); % 滚转角
        yaw = atan2(R(2,1), R(1,1)); % 偏航角
    else
        % 俯仰角是±90度，出现万向锁
        yaw = 0; % 可以任意赋值
        if R(3,1) == -1
            pitch = pi/2;
            roll = atan2(R(1,2), R(1,3));
        else
            pitch = -pi/2;
            roll = atan2(-R(1,2), -R(1,3));
        end
    end
    
    % 将计算出的欧拉角转换为行向量 rad
    euler_angles = [yaw, pitch, roll];
end