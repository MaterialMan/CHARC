function individuals = get_front(population, front)

individuals = [];
for i = 1:length(population)
    if population(i).rank == front
        individuals = [individuals; i];
    end
end
end
