% The following program plots the predicted device temperature as a
% function of nomimal power dissipation for three finned arrays.

% Parameter Description                         Units
% qnom      Nomimal Heat dissipation            W
% Tmax      Maximum allowable temperature       K
% T         Temperature of electical device     K
% Tair      Temperature of surrounding air      K

function main
    qnom = 40;
    airSpeedMetersPerSecond = 5;
    TairC = 22.5;
    TmaxC = 60;

    q = linspace(0,qnom, 80);
    
    % Predicted chip temperature given q nominal
    T1 = deviceTemperature(q,airSpeedMetersPerSecond,TairC,'FinnedArrays/Plate13.txt');
    T2 = deviceTemperature(q,airSpeedMetersPerSecond,TairC,'FinnedArrays/Plate3.txt');
    T3 = deviceTemperature(q,airSpeedMetersPerSecond,TairC,'FinnedArrays/Plate7.txt');
    plotTempVsPower(q, T1,T2,T3)

end

function plotTempVsPower(q,T1, T2, T3)
    plot(q,T1,q,T2,q,T3)
    drawPatch(q,T1,0.085,[0 0 1]);
    drawPatch(q,T2,0.085,[1 0 0]);
    drawPatch(q,T3,0.21, [1 1 0]);
    T1(end)
    T2(end)
    T3(end)
    xlabel('Power [W]');
    ylabel('Temperature [C]');
    legend('Plate 13','Plate 3', 'Plate7');
end

function drawPatch(q,T,error, color)
    err= error*T;
    c = color;
    error1Patch = patch([q fliplr(q)],[T+err fliplr(T-err)],c);
    error1Patch.EdgeColor = 'none';
    alpha(error1Patch,0.15);
end