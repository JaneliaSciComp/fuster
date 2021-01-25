do_actually_submit = true ;
max_running_slot_count = 10 ;
bsub_options = '-P scicompsoft -W 59 -J test-bqueue' ;
slots_per_job = 1 ;
bqueue = bqueue_type(do_actually_submit, bsub_options, slots_per_job, max_running_slot_count) ;

job_count = 20 ;
for job_index = 1 : job_count ,
    bqueue.enqueue(@pause, 20) ;  % the 20 is an arg to pause()
end

maximum_wait_time = 200 ;  % Need to wait longer after Jan 2021 cluster upgrade
do_show_progress_bar = true ;
tic_id = tic() ;
job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) 
toc(tic_id)
