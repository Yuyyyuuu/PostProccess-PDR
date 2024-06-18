function dcm = eulerToDCM(yaw, pitch, roll)

    % 根据给定的欧拉角（航向，俯仰，横滚）计算方向余弦矩阵
    dcm = [ cos(pitch)*cos(yaw),-cos(roll)*sin(yaw)+sin(roll)*sin(pitch)*cos(yaw),sin(roll)*sin(yaw)+cos(roll)*sin(pitch)*cos(yaw);
           cos(pitch)*sin(yaw),cos(roll)*cos(yaw)+sin(roll)*sin(pitch)*sin(yaw),-sin(roll)*cos(yaw)+cos(roll)*sin(pitch)*cos(yaw);
           -sin(pitch),sin(roll)*cos(pitch),cos(roll)*cos(pitch)];
    
end