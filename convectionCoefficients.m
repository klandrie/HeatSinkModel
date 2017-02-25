
function [hf,hb] = convectionCoefficients(airVelocityMetersPerSecond, airTempK, plateLength, finDiameter)
    %  h convection coefficent [W/Km^2]
    A = [0.4 4 0.989 0.330; 4 40 0.911 0.385; 40 4000 0.683 0.466; 4000 40000 0.193 0.618; 40000 400000 0.027 0.805];
    k250 = 0.0223;          % Thermal Conductivity of air at 250 fahrenheit, 1 atm
    k300 =  0.0263;         % Thermal Conductivity of air at 300 fahrenheit, 1 atm
    Pr250 = 0.720;          % Prandtl Number of air at 250 fahrenheit, 1 atm
    Pr300 = 0.707;          % Prandtl Number of air at 300 fahrenheit, 1 atm
    v250 = 11.44*10^-6 ;    % Kinematic Velocity of air at 250 fahrenheit, 1 atm
    v300 = 15.89*10^-6;     % Kinematic Velocity of air at 300 fahrenheit, 1 atm
    L = plateLength;
    D = finDiameter;

    x = (airTempK - 250)/50;
    k = (k300-k250)*x + k250;
    Pr = (Pr300-Pr250)*x + Pr250;
    v = (v300-v250)*x + v250;

    ReCylinder = airVelocityMetersPerSecond*finDiameter/v;
    RePlate = airVelocityMetersPerSecond*plateLength/v;
    if (RePlate < 5*10^5 && RePlate > 0) % laminar flow
        NuPlate = 0.664*((RePlate)^(1/2))*((Pr)^(1/3));

    elseif (RePlate > 5*10^5 && RePlate < 10^7) % Turbulent flow
        NuPlate = 0.037*((RePlate)^(4/5))*((Pr)^(1/3)); 
    else
        RePlate
        warning('Re must be within the bounds: 0 < Re < 10^7')
    end 

    % retrieve convection factors for cylinder
    for n = 1: length(A)
        if ( ReCylinder > A(n,1) && ReCylinder <=A(n,2))
            c = A(n,3);
            m = A(n,4);
            break
        end 
    end 

    NuCylinder = (c*ReCylinder^m)*Pr^(1/3);
    checkRestrictions(ReCylinder,Pr,airTempK);

    hb = NuPlate*k/L;
    hf = NuCylinder*k/D;
end

function checkRestrictions(ReCylinder,Pr,airTempK)
    if (airTempK > 300)
        airTempK
        warning('Air Temperature must be within the bounds: 250 K < airTempK < 300 K')
    elseif (airTempK < 250)
        airTempK
        warning('Air Temperature must be within the bounds: 250 K < airTempK < 300 K')
    elseif (Pr <= 0.7 || Pr >60)
        Pr
        warning('Prdantl Number must be within the bounds 0.7 < Pr < 60')
    elseif(ReCylinder <= 0.4 || ReCylinder > 400000)
        ReCylinder
        warning('Re must be within the bounds: 0.4 < ReCylinder <= 400000')
    end
end 
