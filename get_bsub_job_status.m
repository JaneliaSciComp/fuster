function [result,bjobs_lines] = get_bsub_job_status(job_ids,varargin)
    % Possible results are {-1,0,+1}.
    %   -1 means errored out
    %    0 mean running or pending
    %   +1 means completed successfully
    %   nan other 
    
    job_count = length(job_ids) ;
    result = nan(size(job_ids)) ;
    is_not_yet_submitted = isnan(job_ids) ;
    was_run_locally = (job_ids<0) ;  % means the job was run locally
    was_run_locally_and_exited_cleanly = (job_ids==-1) ;
    was_run_locally_and_errored = (job_ids==-2) ;
    result(was_run_locally_and_exited_cleanly) = +1 ;
    result(was_run_locally_and_errored) = -1 ;
    if all(is_not_yet_submitted | was_run_locally) ,
        return
    end
    was_submitted = ~(was_run_locally | is_not_yet_submitted) ;
    submitted_job_ids = job_ids(was_submitted) ;
    bjobs_lines = get_bjobs_lines(submitted_job_ids,varargin{:}) ;
    bjobs_line_index = 1 ;
    for job_index = 1 : job_count ,
        if ~was_submitted(job_index) ,
            continue ;
        end
        job_id = job_ids(job_index) ;
        lsf_status = bjobs_lines{job_index} ; % Should be string like 'DONE', 'EXIT', 'RUN', 'PEND', etc.
        if isequal(lsf_status, 'DONE') ,
            running_job_status_code = +1 ;
        elseif isequal(lsf_status, 'EXIT') ,
            % This seems to indicate an exit with something other than a 0 return code
            running_job_status_code = -1 ;
        elseif isequal(lsf_status, 'PEND') || isequal(lsf_status, 'RUN') || isequal(lsf_status, 'UNKWN') || ...
               isequal(lsf_status, 'SSUSP') || isequal(lsf_status, 'PSUSP') || isequal(lsf_status, 'USUSP'),
            running_job_status_code = 0 ;
        else
          if ~isempty(regexp(lsf_status,'not found','once')),
            running_job_status_code = nan;
          else
            error('Unknown bjobs status string for job %d: %s', job_id,lsf_status) ;
          end
        end
        result(job_index) = running_job_status_code ;
        bjobs_line_index = bjobs_line_index + 1 ;
    end
end
