function gyro_output_new=AHRS(q,gyro_output_old,acc_output,eInt,dT)
    % q：最新的反映当前姿态的四元数
    % gyro_output_old：陀螺原始输出值（未改正）
    % acc_output：加速度计三轴输出（用于改正陀螺输出）
    % eInt：补偿向量的时间累计量
    % dT：采样间隔
    % gyro_output_new：经AHRS六轴补偿后的陀螺输出值

    cfg=ProcessConfig();

    Cbn=quaternionToRotationMatrix(q);
    Cnb=pinv(Cbn);

    v=Cnb*[0;0;-1];

    % 加表输出归一化
    a_norm=sqrt(acc_output(1)^2+acc_output(2)^2+acc_output(3)^2);
    ax=acc_output(1)/a_norm;
    ay=acc_output(2)/a_norm;
    az=acc_output(3)/a_norm;

    % 补偿向量
    e=[0,0,0];
    e(1)=ay*v(3)-az*v(2);
    e(2)=az*v(1)-ax*v(3);
    e(3)=ax*v(2)-ay*v(1);
    
    % 记录补偿向量随时间的累积量
    eInt=eInt+e*dT;

    % 补偿陀螺输出
    gyro_output_new=gyro_output_old+cfg.Kp*e+cfg.Ki*eInt;
    

end