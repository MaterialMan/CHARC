function [EXP]=Voronoi_Plot(EXP)

%-- Plot Voronoi cells and centroids
if isfield(EXP,'Voronoi')&& isfield(EXP.Voronoi,'Cell')
    for h=1:EXP.Robots
        if isfield(EXP.Voronoi.Cell(h),'Visible_cell')
            if (EXP.Voronoi.Cell(h).Visible_cell),
                set(EXP.Voronoi.Cell(h).Handle_patch,'XData',EXP.Voronoi.Cell(h).Vertex(:,1),'YData',EXP.Voronoi.Cell(h).Vertex(:,2));
            end
        end
        
        if isfield(EXP.Voronoi.Cell(h),'Visible_centroid')
            if (EXP.Voronoi.Cell(h).Visible_centroid)&& isfield(EXP.Voronoi.Cell(h),'Enable_centroid_computation')&& (EXP.Voronoi.Cell(h).Enable_centroid_computation),
                set(EXP.Voronoi.Cell(h).Handle_centroid,'XData',EXP.Voronoi.Cell(h).Centroid(1),'YData',EXP.Voronoi.Cell(h).Centroid(2));
            end
        end
    end
end

