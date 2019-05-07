function genotype = poleBalance(genotype,config)


for  tests = 1:config.pole_tests
    
    %% Collect states for plain ESN
    inputSequence = zeros(config.time_steps,4);
    max_x = 4.8;
    
    % switch to task
    switch(config.simpleTask)
        case 1 %simple version
            x_pole = zeros(length(inputSequence(:,1))+1,1);
            x_dot = zeros(length(inputSequence(:,1))+1,1);
            theta = zeros(length(inputSequence(:,1))+1,1);
            theta(1) = pi+((2*pi)/360)*rand;%pi+(2*rand-1)*(pi/5); % start in good region
            theta_dot = zeros(length(inputSequence(:,1))+1,1);
            LENGTH          = 0.5;         % half length of pole
            MASS_P          = 0.1;         % mass pole
            MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
            
        case 2 %swinging version
            x_pole = zeros(length(inputSequence(:,1))+1,1);
            x_dot = zeros(length(inputSequence(:,1))+1,1);
            theta = zeros(length(inputSequence(:,1))+1,1);
            theta(1) = rand*2*pi;%pi*1.5 + rand*pi; % start anywhere
            theta_dot = zeros(length(inputSequence(:,1))+1,1);
            LENGTH          = 0.5;         % half length of pole
            MASS_P          = 0.1;         % mass pole
            MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
            
            
        case 3 %double pole balancing
            x_pole = zeros(length(inputSequence(:,1))+1,1);
            x_dot = zeros(length(inputSequence(:,1))+1,1);
            theta = zeros(length(inputSequence(:,1))+1,2);
            theta(1,1) = pi+((2*pi)/360)*(2*rand-1);%pi-(2*rand-1)*(pi/5); % start in good region rand*2*pi;%
            theta(1,2) = pi+((2*pi)/360)*(2*rand-1);%pi-(2*rand-1)*(pi/5);
            theta_dot = zeros(length(inputSequence(:,1))+1,2);
            LENGTH          = [1 0.1];%0.5;         % half length of pole
            %LENGTH(2)          = 0.1;%0.05;         % half length of pole
            MASS_P          = [0.1 0.01];         % mass pole
            %MASS_P2          = 0.01;         % mass pole
            MU_P=               [0.000002 0.000002];
            %MU_P2= 0.000002;
    end
    
    
    GRAV            = -9.8;        % g
    MASS_C          = 1.0;         % mass cart 1kg
    SAMPLE_INTERVAL = 0.05;        % delta t
    MU_C            = 0.0005;      % coeff fric, cart on track  START: 0.0005
    FORCE           = 10;        % magnitude of force applied at every time step (either plus or minus)
    
    % For fitness function
    summation = 0;
    longest_balance = 0;
    exited = 0;
    F2 = 0;
    
    %equation: x(n) = f(Win*u(n) + S)
    %each time step
    for n = 2:size(inputSequence,1)
        
        if config.velocity
            inputSequence(n,:) = tanh([x_pole(n-1); x_dot(n-1); theta(n-1); theta_dot(n-1)]); % scale input between -1 and 1
        else
            inputSequence(n,:) = tanh([x_pole(n-1); 0; theta(n-1); 0]); % scale input between -1 and 1
        end
        
        testStates = config.assessFcn(genotype,inputSequence(n,:),config);
        
        force = testStates*genotype.outputWeights;
        
        %% STEP on system
        f = FORCE* sign(force);
        
        %original equations
        switch(config.simpleTask)
            case 1
                th = theta(n-1);
                th_dot = theta_dot(n-1);
                % motion of pole
                top = GRAV*sin(th) + cos(th)*((-f - MASS_P*LENGTH*th_dot*th_dot*sin(th))/MASS_P+MASS_C);
                bottom = LENGTH*((4/3) - ((MASS_P*cos(th)*cos(th))/(MASS_P+MASS_C)));
                th_dotdot = top/bottom;
                % motion of cart
                x_dotdot = (f + MASS_P*LENGTH*(th_dot*th_dot*sin(th) - th_dotdot*cos(th)))/(MASS_C +MASS_P);
                
                %discrete equations
                theta(n) = theta(n-1) + SAMPLE_INTERVAL * theta_dot(n-1);
                theta_dot(n) = theta_dot(n-1) + SAMPLE_INTERVAL * th_dotdot;
                x_pole(n) = x_pole(n-1) + SAMPLE_INTERVAL * x_dot(n-1);
                x_dot(n) = x_dot(n-1) + SAMPLE_INTERVAL * x_dotdot;
                
            case 2
                th = theta(n-1);
                th_dot = theta_dot(n-1);
                top = GRAV*sin(th) + (cos(th)*(-f - (MASS_P*LENGTH*th_dot*th_dot*sin(th)) + MU_C*sign(x_dot(n-1)))/(MASS_C + MASS_P)) - ((MU_P * th_dot)/(MASS_P*LENGTH));
                bottom = LENGTH*((4/3) - (MASS_P*cos(th)*cos(th))/(MASS_C + MASS_P));
                th_dotdot = top/bottom;
                x_dotdot = (f + MASS_P*LENGTH*(th_dot*th_dot*sin(th) - th_dotdot*cos(th)) - MU_C*sign(x_dot(n-1)))/(MASS_C +MASS_P);
                theta(n) = theta(n-1) + SAMPLE_INTERVAL * theta_dot(n-1);
                theta_dot(n) = theta_dot(n-1) + SAMPLE_INTERVAL * th_dotdot;
                x_pole(n) = x_pole(n-1) + SAMPLE_INTERVAL * x_dot(n-1);
                x_dot(n) = x_dot(n-1) + SAMPLE_INTERVAL * x_dotdot;
                
            case 3
                
                MASS_bar = (1 -0.75.*cos(theta(n-1,:)).*cos(theta(n-1,:)));
                F_bar = (MASS_P.*LENGTH.*theta_dot(n-1,:).*theta_dot(n-1,:).*sin(theta(n-1,:))) + 0.75.*MASS_P.*cos(theta(n-1,:)).*(((MU_P.*theta_dot(n-1,:))./(MASS_P.*LENGTH)) + GRAV.*sin(theta(n-1,:)));
                x_dotdot = (f - MU_C*sign(x_dot(n-1))+ sum(F_bar))/(MASS_C + sum(MASS_bar));
                theta_dotdot = (-3./(4.*LENGTH)).*(x_dotdot.*cos(theta(n-1,:)) + GRAV.*sin(theta(n-1,:)) + ((MU_P.*theta_dot(n-1,:))./(MASS_P.*LENGTH)));
                
                theta(n,:) = theta(n-1,:) + SAMPLE_INTERVAL * theta_dot(n-1,:);
                theta_dot(n,:) = theta_dot(n-1,:) + SAMPLE_INTERVAL * theta_dotdot;
                x_pole(n) = x_pole(n-1) + SAMPLE_INTERVAL * x_dot(n-1);
                x_dot(n) = x_dot(n-1) + SAMPLE_INTERVAL * x_dotdot;
        end
        
        %escape sim
        switch(config.simpleTask)
            case 1
                if abs(x_pole(n)) > max_x || theta(n,1) > pi + pi/5 || theta(n,1) < pi - pi/5
                    exited =n;
                    break;
                end
            case 2
                if abs(x_pole(n)) > max_x
                    exited =n;
                    break;
                end
            case 3
                if abs(x_pole(n)) > max_x || theta(n,1) > pi + pi/5 || theta(n,1) < pi - pi/5 || theta(n,2) > pi + pi/5 || theta(n,2) < pi - pi/5
                    exited =n;
                    break;
                end
        end
        
        % Fitness function: Check longest balancing time within an pi/5 angle
        % deviation and within -5,+5 meters on the track
        if theta(n) < pi + pi/5 && theta(n) > pi - pi/5
            summation = summation + 1;
            if summation > longest_balance
                longest_balance = summation;
            end
        else
            summation = 0;
        end
        
        % Plot
        if config.runSim
            if config.simpleTask < 3
                figure(1)
                plot(x_pole(n),0,'k+','LineWidth',10);
                hold on
                plot([x_pole(n)-1 x_pole(n)+1], [0 0], 'k')
                plot(x_pole(n)-cos(theta(n,1)+pi/2)*LENGTH(1),-sin(theta(n,1)+pi/2)*LENGTH(1),'k+','LineWidth',10);
                plot([x_pole(n) x_pole(n)-cos(theta(n,1)+pi/2)*LENGTH(1)], [0 -sin(theta(n,1)+pi/2)*LENGTH(1)],'k','LineWidth',3)
                plot([0 0], [0.1 -0.1], 'k')
                
                hold off
                grid on
                xlabel(num2str(x_pole(n)))
                ylabel(num2str(summation))
                
                
                axis([x_pole(n)-1 x_pole(n)+1 -1 1])
                pause(1/config.time_steps)
                
            else
                figure(1)
                plot(x_pole(n),0,'k+','LineWidth',10);
                hold on
                %first pole
                plot([x_pole(n)-1 x_pole(n)+1], [0 0], 'k') % surface
                plot(x_pole(n)-cos(theta(n,1)+pi/2)*LENGTH(1),-sin(theta(n,1)+pi/2)*LENGTH(1),'k+','LineWidth',10); %pole ends
                plot([x_pole(n) x_pole(n)-cos(theta(n,1)+pi/2)*LENGTH(1)], [0 -sin(theta(n,1)+pi/2)*LENGTH(1)],'k','LineWidth',3) %pole
                
                %second pole
                plot(x_pole(n)-cos(theta(n,2)+pi/2)*LENGTH(2)+0.1,-sin(theta(n,2)+pi/2)*LENGTH(2),'k+','LineWidth',10);%pole ends
                plot([x_pole(n)+0.1 x_pole(n)-cos(theta(n,2)+pi/2)*LENGTH(2)+0.1], [0 -sin(theta(n,2)+pi/2)*LENGTH(2)],'k','LineWidth',3) %pole
                hold off
                grid on
                xlabel(num2str(x_pole(n)))
                ylabel(num2str(summation))
                
                axis([x_pole(n)-1 x_pole(n)+1 -LENGTH(1)+0.2 LENGTH(1)+0.2])
                pause(1/config.time_steps)
                
            end
        end
    end
    % Reward is longest balancing streak through all timesteps
    F1 = longest_balance/config.time_steps;
    
    % Reward F2
    if config.simpleTask == 3
        if longest_balance < 100
            F2 = 0;
        else
            F2_bottom = sum(abs(x_pole(exited-100:exited)) + abs(x_dot(exited-100:exited)) + abs(theta(exited-100:exited,1)) +abs(theta_dot(exited-100:exited,1)));
            
            F2 = 0.75/F2_bottom;
        end
        
        fitness(tests) = F1*0.1 +0.9*F2;
    else
        fitness(tests) = F1;
    end
end

genotype.trainError = 1-mean(fitness);
genotype.valError = 1-mean(fitness);
genotype.testError = 1-mean(fitness);