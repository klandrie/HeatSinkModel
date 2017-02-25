% The following program plots the predicted chip temperature
% as a funciton of air speed at nonimal heat dissipation
function airSpeedPlots(TmaxC, TairC, qnom, plateString)
    % Temperature Paramters
    Tair = convtemp(TairC, 'C', 'K');
    Tmax = convtemp(TairC, 'C', 'K');
    
    % Read Finned Array Parameters from File
    % File Format: N	D(in)	L(in)	w(in) 	t(in) 	k(W/mk)	Rtc1''(m^2K/W)	Rtc2''(m^2k/W)
    finnedArrayParameters = importdata(plateString);

    %Fin Parameters
    N = finnedArrayParameters.data(1);
    D = convlength(finnedArrayParameters.data(2), 'in', 'm'); 
    L = convlength(finnedArrayParameters.data(3), 'in', 'm');
    airArray = [];
    tempArray = [];
    hfArray = [];
    hbArray = [];

    for n = 1:0.1:25
        airSpeed = n;
        [hf, hb] = convectionCoefficients(airSpeed,Tair, L, D);
        T = deviceTemperature(qnom, airSpeed, TairC, plateString);

        % Update Arrays 
        airArray(end + 1) = airSpeed;
        tempArray(end + 1) = T;
        hfArray(end + 1) = hf;
        hbArray(end + 1) = hb;

    end

    plotTempVsAirSpeed(airArray, tempArray)
    plotConvecVsAirSpeed(airArray, hfArray, hbArray)
end 

function plotTempVsAirSpeed(airArray, tempArray)
plot(airArray,tempArray)
ylabel('Temperature [C]')
xlabel('Air Speed [m/s]')
axis([0,25,30,110])
end 

function plotConvecVsAirSpeed(airArray, hfArray, hbArray)
plot(airArray,hfArray, airArray, hbArray)
legend('hf','hb')
ylabel('Convection Coefficient [W/(Km^2)]')
xlabel('Air Speed [m/s]')
end
