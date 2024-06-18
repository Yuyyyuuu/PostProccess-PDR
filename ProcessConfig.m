function cfg=ProcessConfig()

    cfg.filename='SensorData_1712552638924';
    cfg.f=50; % 采样频率Hz
    cfg.g=10.2; % 脚步探测阈值
    cfg.gravity=9.8; % 当地重力
    cfg.h=1.8;  % 行人身高
    cfg.filtersize=0.1; % 滤波窗口大小 需*f

    % AHRS六轴补偿系数
    cfg.Kp=1;
    cfg.Ki=0.05;

    cfg.filtermode=1; % 数据预处理：1-均值滤波 2-中值滤波 3-先去最高和最低再平均
    cfg.qupdatemode=3; % 四元数更新：1-一阶龙格库塔 2-二阶龙格库塔 3-四阶龙格库塔
    cfg.stepdetectmode=2; % 脚步探测：1-加速度计模长法 2-垂向加速度法
    cfg.stepestimationmode=3; % 步长估计：1-常数模型 2-身高、步频模型 3-合加速度、步频模型

end