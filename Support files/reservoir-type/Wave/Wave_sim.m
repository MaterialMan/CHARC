function newH = Wave_sim(n,i,j,dt,c,k,H,oldH,fix,cont,connect)
    %global Ekin Epot;
         
    % DAMPED WAVE EQUATION:
    %
    % d^2/dt^2*h + K*(dh/dt) = C^2*(d^2*h/dx^2 + d^2*h/dy^2)
    %
    %   where   h := Height
    %           K := Damping Constant
    %           C := Wave Speed
    %   The right side of the equation is the potential (height of one
    %   element regarding its neighbours).
    %   The wave equation implies that acceleration (d^2*h/dt^2) and 
    %   velocity (dh/dt) of each element are produced through its potential.
    %
    % Finite Difference Procedure:
    %
    %   velocity     := dh/dt      :=   (H(i,j)-oldH(i,j))/dt
    %   acceleration := d^2/dt^2*h :=   ((newH(i,j)-H(i,j))-(H(i,j)-oldH(i,j)))/dt^2
    %                               =   (newH(i,j)-2*H(i,j)+oldH(i,j))/dt^2
    %   similar we have:
    %
    %   potential in x-direction := d^2/dx^2*h := (H(i+1,j)-2*H(i,j)+H(i-1,j))/dx^2
    %   potential in y-direction := d^2/dy^2*h := (H(i,j+1)-2*H(i,j)+H(i,j-1))/dy^2
    %   where dx=dy=1; (spacing between 2 points);
    %   It is possible to include the potential in DIAGONAL direction as well.
    %   Nummerical experiments demomstrate that wave shapes look visually
    %   better when all 8 neighbours are taken into account.
    %   But remember, dx and dy, (spacing between 2 points) in diagonal direction is
    %   sqrt(2) and not 1. Therefor 1/dx^2 resp. 1/dy^2 is equal 0.5
    
    %   Apply these to the wave equation above we have:
    
    potential(i,j) = -c^2*((4*H(i,j)-H(i+1,j)-H(i-1,j)-H(i,j+1)-H(i,j-1))...
        +0.5*(4*H(i,j)-H(i+1,j+1)-H(i+1,j-1)-H(i-1,j+1)-H(i-1,j-1))); %  diagonal direction (opitonal)
    velocity(i,j) = (H(i,j)-oldH(i,j))/dt;
    acceleration(i,j) = -k*velocity(i,j)+potential(i,j); %  := (newH(i,j)-2*H(i,j)+oldH(i,j))/dt^2 as mentioned above
    % therefor, the new height is:
    newH(i,j) = acceleration(i,j)*dt^2-oldH(i,j)+2*H(i,j);
      
    % Please take notice that this equation isn't applied for the elements
    % along the edges and at the corners (Boundary Points / Randpunkte),
    % that's why i and j are from 2 to n-1 instead of 1 to n.
    
    
    
    % BOUNDARY CONDITIONS:
    %
    %   Equations for boundary points.
    %   Keep in mind that elements along the edges have 5 neighbours
    %   instead of 8 and vertices only have 3.
    
    
    
    potential(n,j) = -c^2*((3*H(n,j)-H(n-1,j)-H(n,j+1)-H(n,j-1))...
        +0.5*(2*H(n,j)-H(n-1,j+1)-H(n-1,j-1)));
    potential(i,n) = -c^2*((3*H(i,n)-H(i,n-1)-H(i+1,n)-H(i-1,n))...
        +0.5*(2*H(i,n)-H(i+1,n-1)-H(i-1,n-1)));
    potential(1,j) = -c^2*((3*H(1,j)-H(2,j)-H(1,j+1)-H(1,j-1))...
        +0.5*(2*H(1,j)-H(2,j+1)-H(2,j-1)));
    potential(i,1) = -c^2*((3*H(i,1)-H(i,2)-H(i+1,1)-H(i-1,1))...
        +0.5*(2*H(i,1)-H(i+1,2)-H(i-1,2)));
    velocity(n,j) = (H(n,j)-oldH(n,j))/dt;
    velocity(i,n) = (H(i,n)-oldH(i,n))/dt;
    velocity(1,j) = (H(1,j)-oldH(1,j))/dt;
    velocity(i,1) = (H(i,1)-oldH(i,1))/dt;
    
                % 4 corners:
    potential(1,1) = -c^2*((2*H(1,1)-H(2,1)-H(1,2))...
        +0.5*(H(1,1)-H(2,2)));
    potential(1,n) = -c^2*((2*H(1,n)-H(1,n-1)-H(2,n))...
        +0.5*(H(1,n)-H(2,n-1)));
    potential(n,1) = -c^2*((2*H(n,1)-H(n,2)-H(n-1,1))...
        +0.5*(H(n,1)-H(n-1,2)));
    potential(n,n) = -c^2*((2*H(n,n)-H(n-1,n)-H(n,n-1))...
        +0.5*(H(n,n)-H(n-1,n-1)));
    velocity(1,1) = (H(1,1)-oldH(1,1))/dt;
    velocity(1,n) = (H(1,n)-oldH(1,n))/dt;
    velocity(n,1) = (H(n,1)-oldH(n,1))/dt;
    velocity(n,n) = (H(n,n)-oldH(n,n))/dt;



%                       DEFAULT MODUS     
if(~fix && ~cont && ~connect)
    
    acceleration(n,j) = -k*velocity(n,j) +potential(n,j);
    newH(n,j) = acceleration(n,j)*dt^2-oldH(n,j)+2*H(n,j);
    
    acceleration(i,n) = -k*velocity(i,n) +potential(i,n);
    newH(i,n) = acceleration(i,n)*dt^2-oldH(i,n)+2*H(i,n);
    
    acceleration(1,j) = -k*velocity(1,j) +potential(1,j);
    newH(1,j) = acceleration(1,j)*dt^2-oldH(1,j)+2*H(1,j);
    
    acceleration(i,1) = -k*velocity(i,1) +potential(i,1);
    newH(i,1) = acceleration(i,1)*dt^2-oldH(i,1)+2*H(i,1);
    
    
                % 4 corners:
    acceleration(1,1) = -k*velocity(1,1) +potential(1,1);
    newH(1,1) = acceleration(1,1)*dt^2-oldH(1,1)+2*H(1,1);
    
    acceleration(1,n) = -k*velocity(1,n) +potential(1,n);
    newH(1,n) = acceleration(1,n)*dt^2-oldH(1,n)+2*H(1,n);
    
    acceleration(n,1) = -k*velocity(n,1) +potential(n,1);
    newH(n,1) = acceleration(n,1)*dt^2-oldH(n,1)+2*H(n,1);
    
    acceleration(n,n) = -k*velocity(n,n) +potential(n,n);
    newH(n,n) = acceleration(n,n)*dt^2-oldH(n,n)+2*H(n,n);   
    
    
%                STANDSTILL CONTROLLER MODUS
%                Eliminate the wave and bring elements to their steady state.
elseif cont

    H(1,j+1) = 0.5*(oldH(1,j+1)+oldH(2,j+1));
    newH(1,j+1) = H(1,j+1)+0.9*(H(2,j+1)-oldH(2,j+1));
    H(i+1,1) = 0.5*(oldH(i+1,1)+oldH(i+1,2));
    newH(i+1,1) = H(i+1,1)+0.9*(H(i+1,2)-oldH(i+1,2));

    H(1,1) = 0.5*(H(1,1)+H(2,2));
    newH(1,1) = H(1,1)+(H(2,2)-oldH(2,2))/3;
    newH(1,2) = newH(1,1);
    newH(2,1) = newH(1,1);
    Corner_n1 = 0.5*(H(n,1)+H(n-1,2));
    Corner_1n = 0.5*(H(1,n)+H(2,n-1));
    Corner_nn = 0.5*(H(n,n)+H(n-1,n-1));

    H(i+1,n)= 0.5*(oldH(i+1,n)+oldH(i+1,n-1));
    newH(i+1,n)= H(i+1,n)+0.9*(H(i+1,n-1)-oldH(i+1,n-1));
    H(n,j+1)= 0.5*(oldH(n,j+1)+oldH(n-1,j+1));
    newH(n,j+1)= H(n,j+1)+0.9*(H(n-1,j+1)-oldH(n-1,j+1));

    newH(n,n)= Corner_nn;
    newH(n,n-1)= Corner_nn;
    newH(n-1,n)= Corner_nn;
    newH(1,n-1)=Corner_1n;
    newH(1,n)=Corner_1n;
    newH(2,n)=Corner_1n;
    newH(n,1)=Corner_n1;
    newH(n-1,1)=Corner_n1;
    newH(n,2)=Corner_n1;

    acceleration(n,j)=-k*velocity(n,j) +potential(n,j);
    acceleration(i,n)=-k*velocity(i,n) +potential(i,n);
    acceleration(1,j)=-k*velocity(1,j) +potential(1,j);
    acceleration(i,1)=-k*velocity(i,1) +potential(i,1);
                % 4 corners:
    acceleration(1,1)=-k*velocity(1,1) +potential(1,1);
    acceleration(1,n)=-k*velocity(1,n) +potential(1,n);
    acceleration(n,1)=-k*velocity(n,1) +potential(n,1);
    acceleration(n,n)=-k*velocity(n,n) +potential(n,n);


%                FIXED BOUNDARIES MODUS
%                All boundary points have a constant value of 1.
elseif  fix                   
    newH(1,:)=1;
    newH(n,:)=1;
    newH(:,1)=1;
    newH(:,n)=1;

    velocity(1,:)=0;
    velocity(n,:)=0;
    velocity(:,1)=0;
    velocity(:,n)=0;

    acceleration(n,j)=potential(n,j);
    acceleration(i,n)=potential(i,n);
    acceleration(1,j)=potential(1,j);
    acceleration(i,1)=potential(i,1);
        % 4 corners:
    acceleration(1,1)=potential(1,1);
    acceleration(1,n)=potential(1,n);
    acceleration(n,1)=potential(n,1);
    acceleration(n,n)=potential(n,n);


%               CONNECTED BOUNDARIES MODUS
%               Water flows across the edges and comes back from the opposite side
else                                    
    potential(1,j)=-c^2*((4*H(1,j)-H(2,j)-H(n,j)-H(1,j+1)-H(1,j-1))...
    +0.5*(4*H(1,j)-H(2,j+1)-H(2,j-1)-H(n,j+1)-H(n,j-1)));
    acceleration(1,j)=-k*velocity(1,j) +potential(1,j);
    newH(1,j)=acceleration(1,j)*dt^2-oldH(1,j)+2*H(1,j);

    potential(n,j)=-c^2*((4*H(n,j)-H(1,j)-H(n-1,j)-H(n,j+1)-H(n,j-1))...
    +0.5*(4*H(n,j)-H(1,j+1)-H(1,j-1)-H(n-1,j+1)-H(n-1,j-1))); 
    acceleration(n,j)=-k*velocity(n,j) +potential(n,j);
    newH(n,j)=acceleration(n,j)*dt^2-oldH(n,j)+2*H(n,j);

    potential(i,1)=-c^2*((4*H(i,1)-H(i,n)-H(i-1,1)-H(i+1,1)-H(i,2))...
    +0.5*(4*H(i,1)-H(i+1,2)-H(i+1,n)-H(i-1,2)-H(i-1,n)));
    acceleration(i,1)=-k*velocity(i,1) +potential(i,1);
    newH(i,1)=acceleration(i,1)*dt^2-oldH(i,1)+2*H(i,1);

    potential(i,n)=-c^2*((4*H(i,n)-H(i+1,n)-H(i-1,n)-H(i,1)-H(i,n-1))...
    +0.5*(4*H(i,n)-H(i+1,1)-H(i+1,n-1)-H(i-1,1)-H(i-1,n-1))); 
    acceleration(i,n)=-k*velocity(i,n) +potential(i,n);
    newH(i,n)=acceleration(i,n)*dt^2-oldH(i,n)+2*H(i,n);
    
            % 4 Corners
    potential(n,n)=-c^2*((4*H(n,n)-H(1,n)-H(n,1)-H(n,n-1)-H(n-1,n))...
    +0.5*(4*H(n,n)-H(1,n-1)-H(1,1)-H(n-1,n-1)-H(n-1,1))); 
    acceleration(n,n)=-k*velocity(n,n) +potential(n,n);
    newH(n,n)=acceleration(n,n)*dt^2-oldH(n,n)+2*H(n,n);    

    potential(n,1)=-c^2*((4*H(n,1)-H(1,1)-H(n,n)-H(n,2)-H(n-1,1))...
    +0.5*(4*H(n,1)-H(1,2)-H(1,n)-H(n-1,n)-H(n-1,2))); 
    acceleration(n,1)=-k*velocity(n,1) +potential(n,1);
    newH(n,1)=acceleration(n,1)*dt^2-oldH(n,1)+2*H(n,1);

    potential(1,1)=-c^2*((4*H(1,1)-H(1,n)-H(1,2)-H(n,1)-H(2,1))...
    +0.5*(4*H(1,1)-H(2,2)-H(n,2)-H(n,n)-H(2,n))); 
    acceleration(1,1)=-k*velocity(1,1) +potential(1,1);
    newH(1,1)=acceleration(1,1)*dt^2-oldH(1,1)+2*H(1,1);

    potential(1,n)=-c^2*((4*H(1,n)-H(1,1)-H(n,n)-H(2,n)-H(1,n-1))...
    +0.5*(4*H(1,n)-H(n,1)-H(2,1)-H(2,n-1)-H(n,n-1))); 
    acceleration(1,n)=-k*velocity(1,n) +potential(1,n);
    newH(1,n)=acceleration(1,n)*dt^2-oldH(1,n)+2*H(1,n);


end

% if isnan(newH)
%     newH = zeros(n);
% end
% 
% if isinf(newH)
%     newH = zeros(n);
% end
%     kin=velocity.^2;
%     pot=-acceleration.*oldH;
%     Ekin=[Ekin sum(kin(:))];
%     Epot=[Epot sum(pot(:))];