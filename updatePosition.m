function [newPosX, newPosY] = updatePosition(oldPosX, oldPosY, stepLength, headingAngle)
    % oldPosX, oldPosY: 旧位置的X和Y坐标
    % stepLength: 步长
    % headingAngle: 航向角（偏航角），以弧度为单位
    % newPosX, newPosY: 新位置的X和Y坐标
    
    % 更新位置
    newPosX = oldPosX + stepLength * cos(headingAngle);
    newPosY = oldPosY + stepLength * sin(headingAngle);
end