clear
% random matrix
H = zeros(10);
f_pos = randi([1 size(H,1).^2],10,1);
H(f_pos) = 2*rand(length(f_pos), 1)-1;

% pad multipliers
width = 4;
[x,y] = ndgrid(-2.1:(4.2/(2*width)):2.1);
D=2/4*real((4-x.^2-y.^2).^0.5);

% pad location
w_adj = 2*width+1;
pad_H = padarray(H,[w_adj w_adj],0);

s=size(pad_H);
N=length(s);
[c1{1:N}]=ndgrid(1:w_adj);
c2(1:N)={ceil(w_adj/2)};
offsets=sub2ind(s,c1{:}) - sub2ind(s,c2{:});

B = pad_H;

for i = 1:length(f_pos)
    
    pos(i) = f_pos(i) + w_adj*(size(H,1) + 2*w_adj) + 2*(ceil(f_pos(i)/size(H,1))-1)*w_adj + w_adj;
    
    B(pos(i) + offsets) =  B(pos(i) + offsets) + D*B(pos(i));
end

H2 = B(w_adj+1:end-w_adj,w_adj+1:end-w_adj);

subplot(1,2,1)
imagesc(H)
subplot(1,2,2)
imagesc(H2)


%% exxample cycle through inputs
input_matrix_2d = H;
f_pos_width = randi([1 4],size(f_pos));
for i = 1:length(f_pos)
    t = zeros(size(H));
    t(f_pos(i)) = H(f_pos(i));
    [t] = adjustInputShape(t,f_pos_width(i));
    input_matrix_2d = input_matrix_2d + t;
end

input_matrix_2d = (max(max(H))-min(min(H))).* input_matrix_2d./(max(max(input_matrix_2d))-min(min(input_matrix_2d)));

subplot(1,2,1)
imagesc(H)
colorbar
subplot(1,2,2)
imagesc(input_matrix_2d)
colorbar