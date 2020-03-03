
function [output_matrix_2d] = adjustInputShape(input_matrix_2d,width)

f_pos = find(input_matrix_2d);

% pad multipliers
[x,y] = ndgrid(-2.1:(4.2/(2*width)):2.1);
D=2/4*real((4-x.^2-y.^2).^0.5);
D(ceil(size(D,1).^2/2)) = 0;

% pad location
w_adj = 2*width+1;
pad_input_matrix_2d = zeros(size(input_matrix_2d)+w_adj+w_adj);
pad_input_matrix_2d(w_adj+1:w_adj+length(input_matrix_2d),w_adj+1:w_adj+length(input_matrix_2d)) = input_matrix_2d;

s=size(pad_input_matrix_2d);
N=length(s);
[c1{1:N}]=ndgrid(1:w_adj);
c2(1:N)={ceil(w_adj/2)};
offsets=sub2ind(s,c1{:}) - sub2ind(s,c2{:});

B = pad_input_matrix_2d;
 
for i = 1:length(f_pos)    
    pos = f_pos(i) + w_adj*(size(input_matrix_2d,1) + 2*w_adj) + 2*(ceil(f_pos(i)/size(input_matrix_2d,1))-1)*w_adj + w_adj;    
    B(pos + offsets) =  B(pos + offsets) + D*B(pos);
end

output_matrix_2d = B(w_adj+1:end-w_adj,w_adj+1:end-w_adj);

%output_matrix_2d = output_matrix_2d;
% output_matrix_2d = output_matrix_2d
% 
% max_value ;
% min_value ;

% subplot(1,2,1)
% imagesc(input_matrix_2d)
% colorbar
% subplot(1,2,2)
% imagesc(output_matrix_2d)
% colorbar