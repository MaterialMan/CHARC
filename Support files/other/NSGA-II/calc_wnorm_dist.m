function distance = calc_wnorm_dist(points, ref_points, max_min, weight)

%  Calculate the weighted Euclidean distance from "points" to "ref_points"
num_ref_points = size(ref_points, 1);
num_points = size(points, 1);

distance = zeros(num_points, num_ref_points);

for ipt = 1:num_ref_points
    ref_point = ref_points(ipt, :);
    for i = 1:num_points
        wieght_norm_dist = ((points(i, :)-ref_point) ./ max_min).^2 .* weight;
        distance(i, ipt) = sqrt(sum(wieght_norm_dist));
    end
end
end
