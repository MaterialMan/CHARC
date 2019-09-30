function [individual,test_states]= poleBalance(individual,config)

scurr = rng;
temp_seed = scurr.Seed;
rng(1,'twister');

for  tests = 1:config.pole_tests
    
    %% Collect states for plain ESN
    input_sequence = zeros(config.time_steps,6);
    max_x = 4.8;
    
    % switch to task
    switch(config.simple_task)
        case 1 %simple version
            x_pole = zeros(length(input_sequence(:,1))+1,1);
            x_dot = zeros(length(input_sequence(:,1))+1,1);
            theta = zeros(length(input_sequence(:,1))+1,1);
            theta(1) = pi+(2*rand-1)*(pi/5); % start in good region %pi+((2*pi)/360)*rand;%
            theta_dot = zeros(length(input_sequence(:,1))+1,1);
            LENGTH          = 0.5;         % half length of pole
            MASS_P          = 0.1;         % mass pole
            MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
            
        case 2 %swinging version
            x_pole = zeros(length(input_sequence(:,1))+1,1);
            x_dot = zeros(length(input_sequence(:,1))+1,1);
            theta = zeros(length(input_sequence(:,1))+1,1);
            theta(1) = (2*rand-1)*(pi/5);%rand*2*pi;%pi*1.5 + rand*pi; % start anywhere
            theta_dot = zeros(length(input_sequence(:,1))+1,1);
            LENGTH          = 0.5;         % half length of pole
            MASS_P          = 0.1;         % mass pole
            MU_P            = 0.000002;    % coeff frict, pole on cart  START: 0.000002
            
            
        case 3 %double pole balancing
            x_pole = zeros(length(input_sequence(:,1))+1,1);
            x_dot = zeros(length(input_sequence(:,1))+1,1);
            theta = zeros(length(input_sequence(:,1))+1,2);
            theta(1,1) = pi+(2*rand-1)*(pi/5);%pi+((2*pi)/360)*(2*rand-1);%pi-(2*rand-1)*(pi/5); % start in good region rand*2*pi;%
            theta(1,2) = pi+(2*rand-1)*(pi/5);%pi+((2*pi)/360)*(2*rand-1);%pi-(2*rand-1)*(pi/5);
            theta_dot = zeros(length(input_sequence(:,1))+1,2);
            LENGTH          = [1 0.1];%0.5;         % half length of pole
            %LENGTH(2)          = 0.1;%0.05;         % half length of pole
            MASS_P          = [0.1 0.01];         % mass pole
            %MASS_P2          = 0.01;         % mass pole
            MU_P=               [0.000002 0.000002];
            %MU_P2= 0.000002;
    end
    
    
    GRAV            = -9.8;        % g
    MASS_C          = 1.0;         % mass cart 1kg
    SAMPLE_INTERVAL = 0.01;        % delta t (0.01 & 0.02 work well)
    MU_C            = 0.0005;      % coeff fric, cart on track  START: 0.0005
    FORCE           = 10;        % magnitude of force applied at every time step (either plus or minus)
    
    % For fitness function
    summation = 0;
    longest_balance = 0;
    exited = size(input_sequence,1);
    F2 = 0;
    
    %equation: x(n) = f(Win*u(n) + S)
    %each time step
    score = 0;
    force_record = [];
    
    test_states = zeros(size(input_sequence,1),sum(config.num_nodes));
    
    for n = 2:size(input_sequence,1)
        
        if config.velocity
            if config.simple_task ~= 3
                % limit theta to [-2*pi 2*pi] 
                if theta(n-1,:) < 0
                    th = -mod(abs(theta(n-1,:)),2*pi);
                else
                    th = mod(theta(n-1,:),2*pi);
                end
                
                %inputSequence(n,:) = [x_pole(n-1); x_dot(n-1); theta(n-1,:); 0; theta_dot(n-1,:); 0]; % scale input between -1 and 1
                input_sequence(n,:) = [x_pole(n-1); x_dot(n-1); th; 0; theta_dot(n-1,:); 0]; % scale input between -1 and 1
            else
                input_sequence(n,:) = [x_pole(n-1); x_dot(n-1); theta(n-1,1); theta(n-1,2); theta_dot(n-1,1); theta_dot(n-1,2)]; % scale input between -1 and 1
            end
        else
            if config.simpleTask ~= 3
                input_sequence(n,:) = [x_pole(n-1); 0; theta(n-1); 0; 0; 0]; % scale input between -1 and 1
            else
                input_sequence(n,:) = [x_pole(n-1); 0; theta(n-1,1); theta(n-1,2); 0; 0];
            end
        end
        
        % rescale inputs
        input_sequence(n,:) = ((input_sequence(n,:)--10)./(10--10)-0.5)*2;
%            
        if sum(isnan(input_sequence(n,:))) > 1
            fitness(tests) = 1;
            return;
        end
        
        [test_states(n,:),individual] = config.assessFcn(individual,input_sequence(n,:),config); %[testStates,genotype]
                        
        force = test_states(n,:)*individual.output_weights;
        
        %% STEP on system
        if mod(n,1) == 0 % output every 0.02 secs
            if config.velocity
                f = FORCE*sign(force);
            else
                f = force*100;
            end
        else
            f = 0;
        end
        
        force_record(n,:) = [force f];
        
        %original equations
        switch(config.simple_task)
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
        switch(config.simple_task)
            case 1
                if abs(x_pole(n)) > max_x || theta(n,1) > pi + pi/5 || theta(n,1) < pi - pi/5
                    exited =n;
                    break;
                end
            case 2
                if abs(x_pole(n)) > max_x || sum(score) > 500
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
        %        score(n) = abs(pi-theta(n));
        if theta(n) < pi + pi/5 && theta(n) > pi - pi/5
            summation = summation + 1;
            if summation > longest_balance
                longest_balance = summation;
            end
        else
            summation = 0;
        end
        
    end
    

    %plot
    for n = 2:5:exited
        if config.run_sim && tests == config.pole_tests % only show last
            if config.simple_task < 3

                set(0,'currentFigure',config.figure_array(1))
                subplot(2,2,1)
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
                title(strcat('Time = ',num2str(n)))
                
                axis([x_pole(n)-1 x_pole(n)+1 -1 1])
                
                % force
                subplot(2,2,2)
                plot(force_record(1:n,:))
                title('Force(n)')
                
                %pole angle
                subplot(2,2,3)
                plot(theta(1:n))
                title('pole angle (\theta)')
                
                % cart position
                subplot(2,2,4)
                %plot(x_pole(1:n))
                plot(input_sequence)
                title('cart position')
                
                drawnow
                %pause(1/config.time_steps)
            else
               
               set(0,'currentFigure',figHandle)
                subplot(2,2,1)
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
                title(strcat('Time = ',num2str(n)))
                
                % force
                subplot(2,2,2)
                plot(force_record(1:n,:))
                title('Force(n)')
                
                %pole angle
                subplot(2,2,3)
                plot(theta(1:n,:))
                title('pole angle (\theta)')
                
                % cart position
                subplot(2,2,4)
                plot(x_pole(1:n))
                title('cart position')
                
                drawnow
                %pause(1/config.time_steps)
                
            end
            
        end
    end
    
    
    F1 = longest_balance/config.time_steps;
    
    % Reward F2
    F2_bottom = 0;
%     if config.velocity
%         if longest_balance < 100
%             F2 = 0;
%         else
%             %F2_bottom = sum(abs(x_pole(exited-100:exited)) + abs(x_dot(exited-100:exited)) + abs(theta(exited-100:exited,1)) +abs(theta_dot(exited-100:exited,1)));
%             for p = 101:exited
%                 F2_bottom = F2_bottom + abs(x_pole(p)) + abs(x_dot(p)) + abs(theta(p,1)) +abs(theta_dot(p,1));
%             end
%             
%             F2 = 0.75/F2_bottom;
%         end
%         
%         fitness(tests) = 1-(F1*0.1 +0.9*F2);
%     else
        fitness(tests) = 1-F1;
   % end
end

individual.train_error = mean(fitness);
individual.val_error = mean(fitness);
individual.test_error = mean(fitness);

% Go back to old seed
rng(temp_seed,'twister');