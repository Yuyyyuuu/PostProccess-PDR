function R = quaternionToRotationMatrix(q)
    % q: 四元数，格式为 [w, x, y, z]

    % 注：该旋转矩阵是由b系转到n系的 Cbn

    % 提取四元数的各个分量
    w = q(1);
    x = q(2);
    y = q(3);
    z = q(4);
    
    % 计算旋转矩阵的各个元素
    R11 = 1 - 2*(y^2 + z^2);
    R12 = 2*(x*y - z*w);
    R13 = 2*(x*z + y*w);
    
    R21 = 2*(x*y + z*w);
    R22 = 1 - 2*(x^2 + z^2);
    R23 = 2*(y*z - x*w);
    
    R31 = 2*(x*z - y*w);
    R32 = 2*(y*z + x*w);
    R33 = 1 - 2*(x^2 + y^2);
    
    % 构建旋转矩阵
    R = [R11, R12, R13;
         R21, R22, R23;
         R31, R32, R33];
end