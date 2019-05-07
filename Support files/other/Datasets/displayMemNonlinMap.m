function [plt] = displayMemNonlinMap(figureHandle,saveError,tests,set)

num = 1;
switch(set)
    case 'train'
        setNum = 0;
    case 'val'
        setNum = 150;
    case 'test'
        setNum = 300;
    case 'both'
        %get train
        setNum = 0;
        for d = 1:15
            for p = 1:10
                plt(d,p) = saveError(tests,setNum+num);
                num = num+1;
            end
        end
        %repeat for val
        setNum = 150;
        num = 1;
        for d = 1:15
            for p = 1:10
                plt1(d,p) = saveError(tests,setNum+num);
                num = num+1;
            end
        end
        
        figure(figureHandle);
        subplot(2,2,1)
        contour(plt','ShowText','on')
        title('Memory and Nonlinear Mapping: Training');
        ylabel('Nonlinearity')
        xlabel('Delay')
        
        figure(figureHandle);
        subplot(2,2,2)
        contour(plt1','ShowText','on')
        title('Memory and Nonlinear Mapping: Test');
        ylabel('Nonlinearity')
        xlabel('Delay')
        
        subplot(2,2,[3 4])
        surfc(plt'-plt1')
        title('Train -- Test');
        ylabel('Nonlinearity')
        xlabel('Delay')
        zlabel('Error')
end

if strcmp(set, 'both') == 0
    for d = 1:15
        for p = 1:10
            plt(d,p) = saveError(tests,setNum+num);
            num = num+1;
        end
    end
    
    figure(figureHandle);
    subplot(1,2,1)
    contour(plt','ShowText','on')
    title('Memory and Nonlinear Mapping');
    ylabel('Nonlinearity')
    xlabel('Delay')

    subplot(1,2,2)
    surfc(plt')
    title('Memory and Nonlinear Mapping');
    ylabel('Nonlinearity')
    xlabel('Delay')
    zlabel('Error')
end