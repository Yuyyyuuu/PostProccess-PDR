function q=Euler2Q(yaw,pitch,roll)
    % 注意：传入的角度均为弧度制
    q(1)=cos(yaw/2)*cos(pitch/2)*cos(roll/2)+sin(yaw/2)*sin(pitch/2)*sin(roll/2);
    q(2)=cos(yaw/2)*cos(pitch/2)*sin(roll/2)-sin(yaw/2)*sin(pitch/2)*cos(roll/2);
    q(3)=cos(yaw/2)*sin(pitch/2)*cos(roll/2)+sin(yaw/2)*cos(pitch/2)*sin(roll/2);
    q(4)=sin(yaw/2)*cos(pitch/2)*cos(roll/2)-cos(yaw/2)*sin(pitch/2)*sin(roll/2);
    q = q(:);
end