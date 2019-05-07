function [t, x, y, z] = createLorenz(a, b, c, T)

x0 = [1; 0; 0];
[t, xvec] = ode45(@f, [0, T], x0);

x = xvec(:, 1);
y = xvec(:, 2);
z = xvec(:, 3);

% Plot of the solution
% plot3(x,y,z, 'r-')
% xlabel('x')
% ylabel('y')
% zlabel('z')

    function xdot = f(t, x)
        xdot= [ a * (x(2) - x(1)); ...
            b * x(1)-x(1) * x(3) - x(2); ...
            x(1) * x(2) - c * x(3) ];
    end

end