
cnt=1;
for i = 1:individual.time_period:1000
    subplot(1,3,1)
    imagesc(reshape(input_mul{1}(i,:),50,50))
    title('A')
    subplot(1,3,2)
    imagesc(reshape(input_mul{2}(i,:),50,50))
    title('B')
    subplot(1,3,3)
    imagesc(reshape(input_mul{3}(i,:),50,50))
    title('C')
    drawnow
    F(cnt) = getframe(gcf);
    cnt = cnt + 1;
end

v = VideoWriter('BZ_laser_input','MPEG-4');
open(v);
writeVideo(v,F);
close(v);