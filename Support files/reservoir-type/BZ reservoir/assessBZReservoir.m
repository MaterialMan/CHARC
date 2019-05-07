function states = assessBZReservoir(genotype,inputSequence,config)

%BZreaction animation 
%Belousov-Zhabotinsky Reaction animation 
%This MATLAB code is converted from Processing code available in this link 
%http://www.aac.bartlett.ucl.ac.uk/processing/samples/bzr.pdf

%version 2. Corrected the drift of pixels as suggested 
% by Jonh.

xres=genotype.size; %x resolution 
yres=xres; %y resolution, this must be a sqaure for below code to function
%below somewhere like ~40*40 pixels this system does not work, it fizzles out.
%Perhaps Angelika was right that you need minimum sizes
a = genotype.a; %rand(xres,yres,2); 
b = genotype.b; %rand(xres,yres,2); 
c = genotype.c; %rand(xres,yres,2); 

p = 1; 
q = 2; 
img=zeros(xres,yres,3);

mm = mod((1:xres+2)+xres,xres)+1; 
nn = mod((1:yres+2)+yres,yres)+1; 
[mm,nn]=meshgrid(mm,nn); 
idx=sub2ind([yres xres],nn(:),mm(:)); %find equivalent single index
idx=reshape(idx,[yres xres]+2); % returns an yres by xres matrix whose
                                %elements are taken columnwise from idx

time_span = size(inputSequence,1);

loc = reshape(logical(genotype.input_loc),genotype.size,genotype.size,3);
%w_in = reshape(genotype.w_in,genotype.size,genotype.size,3);
% loc_wina = genotype.w_in(logical(genotype.input_loc(1:genotype.size.^2)));
% loc_winb = genotype.w_in(logical(genotype.input_loc((genotype.size.^2)+1:(genotype.size.^2)*2)));
% loc_winc = genotype.w_in(logical(genotype.input_loc(((genotype.size.^2)*2)+1:(genotype.size.^2)*3)));

for k=1:time_span

    c_a = zeros(xres,yres); %initialise empty matrix
    c_b = zeros(xres,yres); 
    c_c = zeros(xres,yres); 

    %vectorise
    for m=1:xres 
        for n=1:yres
        
            idx_temp = idx(m:m+2,:); 
            idx_temp=idx_temp(:,n:n+2);
            idx_temp=idx_temp(:);
        
            % shift?
            if p==2 
                idx_temp=idx_temp+(xres+0)*(yres+0); 
            end 

%             if loc(m,n,1)
%                 c_a(m,n) = abs(w_in(m,n,1)*inputSequence(k,:))*9;
%             else
%                 c_a(m,n) =c_a(m,n) + sum(a(idx_temp)); 
%             end
%             
%             if loc(m,n,2)
%                 c_b(m,n) = abs(w_in(m,n,2)*inputSequence(k,:))*9;
%             else
%                 c_b(m,n) =c_b(m,n) + sum(b(idx_temp));
%             end
%             
%             if loc(m,n,3)
%                 c_c(m,n) = abs(w_in(m,n,3)*inputSequence(k,:))*9;
%             else
%                 c_c(m,n) =c_c(m,n) + sum(c(idx_temp)); 
%             end
            
            c_a(m,n) =c_a(m,n) + sum(a(idx_temp)); 
            c_b(m,n) =c_b(m,n) + sum(b(idx_temp)); 
            c_c(m,n) =c_c(m,n) + sum(c(idx_temp)); 

        end 
    end 

    %correction of pixel drift 
    c_a = circshift(c_a,[2 2]); 
    c_b = circshift(c_b,[2 2]); 
    c_c = circshift(c_c,[2 2]); 

    c_a =c_a/ 9.0; 
    c_b =c_b/ 9.0; 
    c_c =c_c/ 9.0; 

    %not sure in right place
    c_a(loc(:,:,1)) = genotype.w_in(logical(genotype.input_loc(1:genotype.size.^2)),:)*inputSequence(k,:)';
    c_b(loc(:,:,2)) = genotype.w_in(logical(genotype.input_loc((genotype.size.^2)+1:(genotype.size.^2)*2)),:)*inputSequence(k,:)';
    c_c(loc(:,:,3)) = genotype.w_in(logical(genotype.input_loc(((genotype.size.^2)*2)+1:(genotype.size.^2)*3)),:)*inputSequence(k,:)';
    
    a(:,:,q) = double(uint8(255*(c_a + c_a .* (c_b - c_c))))/255; 
    b(:,:,q) = double(uint8(255*(c_b + c_b .* (c_c - c_a))))/255; 
    c(:,:,q) = double(uint8(255*(c_c + c_c .* (c_a - c_b))))/255; 

    img(:,:,1)=c(:,:,q); 
    img(:,:,2)=b(:,:,q); 
    img(:,:,3)=a(:,:,q); 

    if p == 1 
        p = 2; q = 1; 
    else 
        p = 1; q = 2; 
    end 
  
    if config.fft
        S = fft2(img);
        S_shift = abs(fftshift(S));
        
        dim1 = S_shift(:,:,1);
        dim2 = S_shift(:,:,2);
        dim3 = S_shift(:,:,3);
        x = [dim1(:); dim2(:); dim3(:)]';
        states(k,:) = x;
        
        if config.plotBZ
            x_pix = randi([1 xres],10,1);
            y_pix = randi([1 xres],10,1);
            tem = img(x_pix,y_pix,1);
            plot_time(k,:) = tem(:);
            
            plotBZ(config.BZfigure1,config.BZfigure2,img,k,plot_time,S_shift)
        end
    else
        dim1 = img(:,:,1);
        dim2 = img(:,:,2);
        dim3 = img(:,:,3);
        x = [dim1(:); dim2(:); dim3(:)]';
        states(k,:) = x;
    end
    
end

 if config.evolvedOutputStates 
     states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
 else
    states= states(config.nForgetPoints+1:end,:);
 end

end

function plotBZ(figure1,figure2,img,k,plot_time,S_shift)

    set(0,'currentFigure',figure1)
    subplot(3,2,[1 3 5])
    image(uint8(255*hsv2rgb(img))) 
    axis equal off 
    title(strcat('Time: ',num2str(k)))
    
  
    subplot(3,2,2)
    plot(plot_time)
    if k > 20
        xlim([k-20 k])
    end
    title('Example states')
    
    subplot(3,2,4)
    plot(plot_time)
    if k > 20
        xlim([k-20 k])
    end
    
    subplot(3,2,6)
    plot(plot_time)
    if k > 20
        xlim([k-20 k])
    end

    set(0,'currentFigure',figure2)
    imagesc(S_shift);
    drawnow 
end