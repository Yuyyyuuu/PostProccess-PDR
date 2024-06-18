function steplength=stepestimation(acc,dt)
    % acc：加速度的三轴输出
    % dt：本次脚步与上次脚步的时间间隔
    
    cfg=ProcessConfig();
    mode=cfg.stepestimationmode;
    sf=1/dt; % 步频

    switch mode
        case 1
            steplength=0.5;
        
        case 2
            h=cfg.h; % 身高
            a=0.371;
            b=0.227;
            c=1;
            steplength=c*(0.7+a*(h-1.75)+b*(sf-1.79)*h/1.75);
        case 3
            asum=sqrt(acc.X*acc.X+acc.Y*acc.Y+acc.Z*acc.Z)-cfg.gravity;
            steplength=0.132*asum+0.123*sf+0.225;


end