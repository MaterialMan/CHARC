function[final_states,individual] = collectMMStates(individual,input_sequence,config)

% PATHS NEED TO BE REWRITTEN IF VAMPIRE LOCATION CHANGES
%pop_indx = num2str(individual.pop_indx);

% write file with source positions and signal for vampire to read
file = 'loc_file.txt';
file_path = which(file);
file_path = file_path(1:end-length(file));


% iterate through subreservoirs
for i = 1:config.num_reservoirs
    
    %input_file = fopen(strcat(file_path,strcat('sourcefield',pop_indx,'.txt')), 'w');
    input_file = fopen(strcat(file_path,'sourcefield.txt'), 'w');

    
    % write input locations
    inputspos = [individual.minpos{i}(1,:); individual.maxpos{i}(1,:); individual.minpos{i}(2,:); individual.maxpos{i}(2,:)];
    fprintf(input_file,'%3.4f %3.4f %3.4f %3.4f\n', inputspos);
    
    % write input values for each location
    timesteps = 0:size(input_sequence, 1)-1;
    zeroarray = zeros(size(input_sequence, 1), 1);
    inputfields = [timesteps; ...
        individual.input_scaling(i)*(individual.input_weights{i}*input_sequence');
        transpose(zeroarray)];
    
    st = strjoin(repmat('%3.4f'+ " ",1,size(inputfields,1)-2));
    fprintf(input_file,strcat('%d' + " ",st,'%d'+ " ",'\n'), inputfields);
    
    fclose(input_file);
    
    % change parameters in Co.mat
     comat=fopen(strcat(file_path,'Co.txt'),'r');
     cotemp=fopen(strcat(file_path,'Co_temp'),'w');

    
%    comat=fopen(strcat(file_path,strcat('Co',pop_indx,'.txt')),'r');
%     if comat == -1
%         copyfile(strcat(file_path,'Co.txt'), strcat(file_path,strcat('Co',pop_indx,'.txt')))
%         comat=fopen(strcat(file_path,strcat('Co',pop_indx,'.txt')),'r');
%     end
%    cotemp=fopen(strcat(file_path,strcat('Co_temp',pop_indx)),'w');
    
    while ~feof(comat)
        l=fgetl(comat); % get line from base file, check if needs to be rewritten
        if contains(l,'material[1]:damping-constant=')
            l = sprintf('material[1]:damping-constant=%d', individual.damping(i));
        end
        if contains(l,'material[1]:second-order-uniaxial-anisotropy-constant=')
            l = sprintf('material[1]:second-order-uniaxial-anisotropy-constant=%s', individual.anisotropy(i));
        end
        if contains(l,'material[1]:exchange-matrix[1]')
            l = sprintf('material[1]:exchange-matrix[1]=%s', individual.exchange(i));
        end
        if contains(l,'material[1]:atomic-spin-moment')
            l = sprintf('material[1]:atomic-spin-moment=%d !muB', individual.magmoment(i));
        end
        fprintf(cotemp,'%s \n',l);  % print line to file
    end
    
    fclose(comat);
    fclose(cotemp);
    
    % change parameters in input file
    
     base_input=fopen(strcat(file_path,'base_input'),'r');
     inputtemp=fopen(strcat(file_path,'inputtemp'),'w');
    
    
%    base_input=fopen(strcat(file_path,strcat('base_input',pop_indx)),'r');
%     if base_input == -1
%         copyfile(strcat(file_path,'base_input'), strcat(file_path,strcat('base_input',pop_indx)))
%         base_input=fopen(strcat(file_path,strcat('base_input',pop_indx)),'r');
%     end
%    inputtemp=fopen(strcat(file_path,strcat('inputtemp',pop_indx)),'w');
    
    while ~feof(base_input)
        l=fgetl(base_input); % get line from base file, check if needs to be rewritten
        if contains(l,'sim:temperature')
            l = sprintf('sim:temperature=%d', individual.temperature(i));
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
    %c1 = strcat('rm "',file_path,'Co.mat" && mv "',file_path,'Co_temp" "',file_path,'Co.mat"');
    %c2 = strcat('rm "',file_path,'input" && mv "',file_path,'inputtemp" "',file_path,'input"');    
    
    c1 = strcat('mv "',file_path,'Co_temp" "',file_path,'Co.mat"');
    c2 = strcat('mv "',file_path,'inputtemp" "',file_path,'input"');    
    
%     strCo = strcat('Co',pop_indx,'.mat');
%     strCo_temp = strcat('Co_temp',pop_indx);
%     strInput = strcat('input',pop_indx);
%     strInputtemp = strcat('inputtemp',pop_indx);
%     
%     c1 = strcat('rm "',file_path,strCo,'" && mv "',file_path,strCo_temp,'" "',file_path,strCo,'"');
%     c2 = strcat('rm "',file_path,strInput,'" && mv "',file_path,strInputtemp,'" "',file_path,strInput,'"');
%     
    system(c1);
    system(c2);
    
    % run vampire!
    command = strcat('cd "', file_path,'" && ./vampire-serial');
    
    [status, ~] = system(command);
    
    if status == 0 % if run successful, read reservoir_output file and store in final_states matrix
        %output_file = fopen(strcat(file_path,strcat('reservoir_output',pop_indx,'.txt')), 'r');
        output_file = fopen(strcat(file_path,'reservoir_output.txt'), 'r');
        formatSpec = '%f %f';
        size_states = [individual.total_units size(input_sequence, 1)];
        states_transpose = fscanf(output_file,formatSpec,size_states);
        states{i} = states_transpose.';
        fclose(output_file);
    else
        states{i} = 0;
    end
    
end

% get leak states
if config.leak_on
    states = getLeakStates(states,individual,input_sequence,config);
end

% concat all states for output weights
final_states = [];
for i= 1:config.num_reservoirs
    final_states = [final_states states{i}];
    
    %assign last state variable
    individual.last_state{i} = states{i}(end,:);
end

% concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

final_states = final_states(config.wash_out+1:end,:); % remove washout
