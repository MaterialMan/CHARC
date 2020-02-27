function [EXP]=Voronoi_Plot_Initialize(EXP)

for h=1:EXP.Robots;
    EXP.Voronoi.Cell(h).Handle_patch=patch(0,0,EXP.Animation.Colors(1+mod(h,EXP.Robots))); %-- Define handles for plotting centroids 
    EXP.Voronoi.Cell(h).Handle_centroid=plot(inf,inf,['o',EXP.Animation.Colors(h)]);       %-- Define handles for plotting Voronoi cells 
%     set(EXP.Voronoi.Cell(h).Handle_patch,'LineWidth',1,'FaceColor',[1 0.9 0.9]);
end
