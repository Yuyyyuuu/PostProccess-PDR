function q_new = updateQuaternion(q_old, gyro_output, dT)
    % q_old: 上一历元的四元数，格式为 [w, x, y, z]
    % gyro_output: 陀螺仪输出，格式为 [wx, wy, wz] 
    % dT: 采样时间间隔
    % 注意：返回的新四元数是已经归一化后的

    cfg=ProcessConfig();
    mode=cfg.qupdatemode;

    wx=gyro_output(1);
    wy=gyro_output(2);
    wz=gyro_output(3);

    switch mode
        case 1  % 一阶龙格库塔
            q_dot = 0.5 * [0, -wx, -wy, -wz;
                   wx, 0, wz, -wy;
                   wy, -wz, 0, wx;
                   wz, wy, -wx, 0] * q_old;
            q_new = q_old + q_dot * dT;
    
        case 2  % 二阶龙格库塔
            M=[0, -wx, -wy, -wz;
                wx, 0, wz, -wy;
                wy, -wz, 0, wx;
                wz, wy, -wx, 0];
            F=0.5*M;
            K1=F*q_old;
            Y=q_old+dT*K1;
            K2=F*Y;
            q_new=q_old+0.5*dT*(K1+K2);

        case 3  % 四阶龙格库塔
            M=[0, -wx, -wy, -wz;
                wx, 0, wz, -wy;
                wy, -wz, 0, wx;
                wz, wy, -wx, 0];
            F=0.5*M;
            K1=F*q_old;
            K2=F*(q_old+0.5*dT*K1);
            K3=F*(q_old+0.5*dT*K2);
            K4=F*(q_old+dT*K3);
            q_new=q_old+dT*(K1+2*K2+2*K3+K4)/6.0;
        otherwise
            error('未知的四元数更新模式');

    end    


    % 确保新的四元数是归一化的
    q_new = q_new / norm(q_new);


end