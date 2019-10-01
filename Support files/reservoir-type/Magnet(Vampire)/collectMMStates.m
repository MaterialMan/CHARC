function[final_states,individual] = collectMMStates(individual,input_sequence,config)

% PATHS NEED TO BE REWRITTEN IF VAMPIRE LOCATION CHANGES

% write file with source positions and signal for vampire to read
file_path = which('sourcefield.txt');
file_path = file_path(1:end-15); % fudge fix

input_file = fopen(strcat(file_path,'sourcefield.txt'), 'w');

inputspos = [individual.minposx; individual.maxposx; individual.minposy; individual.maxposy];
fprintf(input_file,'%3.4f %3.4f %3.4f %3.4f\n', inputspos);

timesteps = 0:size(input_sequence, 1)-1;
zeroarray = zeros(size(input_sequence, 1), 1);
inputfields = [timesteps; individual.signalmagnitude(1)*transpose(input_sequence(:,1));...
    individual.signalmagnitude(2)*transpose(input_sequence(:,1)); transpose(zeroarray)];

fprintf(input_file,'%d %3.4f %3.4f %d\n', inputfields);

fclose(input_file);

% change parameters in Co.mat

comat=fopen(strcat(file_path,'Co.txt'),'r');
cotemp=fopen(strcat(file_path,'Co_temp'),'w');

while ~feof(comat)
  l=fgetl(comat); % get line from base file, check if needs to be rewritten
  if contains(l,'material[1]:damping-constant=')
    l = sprintf('material[1]:damping-constant=%d', individual.damping);
  end
  if contains(l,'material[1]:second-order-uniaxial-anisotropy-constant=')
    l = sprintf('material[1]:second-order-uniaxial-anisotropy-constant=%s', individual.anisotropy);
  end
  if contains(l,'material[1]:exchange-matrix[1]')
    l = sprintf('material[1]:exchange-matrix[1]=%s', individual.exchange);
  end
  if contains(l,'material[1]:atomic-spin-moment')
    l = sprintf('material[1]:atomic-spin-moment=%d !muB', individual.magmoment);
  end
  fprintf(cotemp,'%s \n',l);  % print line to file
end

fclose(comat);
fclose(cotemp);

% change parameters in input file

base_input=fopen(strcat(file_path,'base_input'),'r');
inputtemp=fopen(strcat(file_path,'inputtemp'),'w');

while ~feof(base_input)
  l=fgetl(base_input); % get line from base file, check if needs to be rewritten
  if contains(l,'sim:temperature')
    l = sprintf('sim:temperature=%d', individual.temperature);
  end
  if contains(l,'create:crystal-structure')
    l = sprintf('create:crystal-structure=%s', config.crystal_structure);
  end
  if contains(l,'dimensions:unit-cell-size')
    l = sprintf('dimensions:unit-cell-size = %.2f !A', config.unitcell_size);
  end
  if contains(l,'sim:time-step=')
    l = sprintf('sim:time-step= %d !fs', config.timestep);
  end
  fprintf(inputtemp,'%s \n',l);  % print line to file
end

fclose(base_input);
fclose(inputtemp);

% substitute old input and Co.mat files
c1 = strcat('del "',file_path,'Co.mat" && move "',file_path,'Co_temp" "',file_path,'Co.mat"');
c2 = strcat('del "',file_path,'input" && move "',file_path,'inputtemp" "',file_path,'input"');

system(c1);
system(c2);

% run vampire!
command = strcat('cd "', file_path,'" && vampire-serial');
[status, y] = system(command);

if status == 0 % if run successful, read reservoir_output file and store in final_states matrix
    output_file = fopen(strcat(file_path,'reservoir_output.txt'), 'r');
    formatSpec = '%f %f';
    size_final_states = [individual.total_units size(input_sequence, 1)];
    final_states_transpose = fscanf(output_file,formatSpec,size_final_states);
    final_states = final_states_transpose.';
    fclose(output_file);
else
    final_states = 0;
end

final_states = final_states(config.wash_out+1:end,:); % remove washout
