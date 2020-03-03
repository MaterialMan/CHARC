figure

nsize = [25,50,100,200,400];
latt_size = [5,7,10,14,20];
for i = 1:length(nsize)
    
   ring_u(i) =  nsize(i);
   ring_d(i) = nsize(i) + nsize(i);
   
   %           corners
   perm = (latt_size(i)-1)*3;
   latt_u(i) = 2*latt_size(i)^2 - 2*latt_size(i) + 2*(latt_size(i)-1)^2 + latt_size(i)^2;
   latt_d(i) = latt_u(i)*2 - latt_size(i)^2;
    
   esn_d(i) = nsize(i)^2;
end

mBar = [ring_u;ring_d;latt_u;latt_d;esn_d]';
bar(mBar,'FaceColor','flat');
xticklabels({'25','50','100','200','400'})
legend('ring(u)','ring(d)','lattice(u)','lattice(d)','esn(d)','Location','northwest')
xlabel('size')
ylabel('no. of weights')
set(gca,'FontSize',12,'FontName','Arial')
set(gcf,'renderer','OpenGL')