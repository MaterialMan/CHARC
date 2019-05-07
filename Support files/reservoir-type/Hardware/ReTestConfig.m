
load('Z:\My Upcoming Publications ''Work-iniprogress''\New Journal Paper\git\Novelty Search\Hardware\B2S464\hardware_noveltySearch_2099_SN_B2S464_run_1.mat')

[read_session,switch_session] = createDaqSessions(0:config.num_electrodes-1,0:(config.num_electrodes/2)-1);

 A = pdist2(search_archive, [0 10]);
[minA,locA] = sort(A);
 
search_archive(locA(1),:)

[kernel_rank,gen_rank,~,MC] =getMetrics(switch_session,read_session,reshape(search_archive_genotype(locA(1),:,:),size(search_archive_genotype,2),size(search_archive_genotype,3))...
    ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
