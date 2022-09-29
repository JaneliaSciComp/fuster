function [result, sanitized_lsf_status] = get_single_bsub_job_status(job_id, ssh_host_name)
    % Possible results are {-1,0,+1,nan}.
    %   -1   means errored out
    %    0   mean running or pending
    %   +1   means completed successfully
    %   nan  means Job ID not found
    %
    % lsf_status returns the raw LSF status, as a string.
    % LSF job statuses are things like 'DONE', 'EXIT', 'RUN', 'PEND', etc.

    if nargin < 2,
        ssh_host_name = '' ;
    end

    if ~isfinite(job_id) ,
        % This means the job has not been submitted yet
        result = nan ;
        lsf_status = '' ;
    elseif job_id == -1 ,
        % This is a job that was run locally and exited cleanly
        result = +1 ;
        lsf_status = '' ;
    elseif job_id == -2 ,
        % This is a job that was run locally and errored
        result = -1 ;
        lsf_status = '' ;
    else
        command_line = sprintf('bjobs -o stat -noheader %d', job_id) ;
        if ~isempty(ssh_host_name) ,
            command_line = sprintf('ssh -q %s "%s"', ssh_host_name, command_line) ;
        end
        [~, stdout] = system(command_line) ;
        % [status, stdout] = system(command_line) ;
        % Ignore the return code.
        % As of this writing (2022-09-29), bsub returns a non-zero error code if
        % the given job IDs are a mix of known and unknown job IDs.  (But returns a
        % zero return code if they are *all* unknown.)  This seems like a bug, but
        % whatta ya gonna do?  So we just ignore the reutrn code.  If something has
        % gone very wrong, the parsing of the stdout should fail, and an error will
        % be thrown.
        % if status ~= 0 ,
        %     error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
        % end
        lsf_status = strtrim(stdout); % Should be string like 'DONE', 'EXIT', 'RUN', 'PEND', etc.
        [result, sanitized_lsf_status] = numeric_job_status_from_LSF_string(lsf_status, job_id) ;
    end
end
