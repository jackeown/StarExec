package org.starexec.util.matrixView;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import org.starexec.data.database.Jobs;
import org.starexec.data.database.Permissions;
import org.starexec.data.to.Job;
import org.starexec.util.LogUtil;


public class MatrixViewUtil {

	private static final Logger log = Logger.getLogger(MatrixViewUtil.class);
	private static final LogUtil logUtil = new LogUtil(log);

	public static Job getJobIfAvailableToUser(int jobId, int userId, HttpServletResponse response) throws IOException {
		final String method = "getJobIfAvailableToUser";
		logUtil.entry(method);
		if(Permissions.canUserSeeJob(jobId,userId)) {
			Job job = Jobs.get(jobId);
			logUtil.debug(method, "Number of job pairs in job with id=" + jobId + " is " + job.getJobPairs().size() );
			
			int jobSpaceId=job.getPrimarySpace();
			// this means it's an old job and we should run the backwards-compatibility routine
			// to get everything set up first
			if (jobSpaceId == 0) {
				jobSpaceId = Jobs.setupJobSpaces(jobId);
			}
			
			if (jobSpaceId>0) {
				// Get all the job pairs for the job as well as basic info.
				job = Jobs.getDetailed(jobId, 0);
			} else {
				response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "The details for this job could not be obtained");
				return null;
			}
			logUtil.debug(method, "No errors encountered getting job for user with id = " + userId);
			logUtil.debug(method,"Number of job pairs in job with id=" + jobId + " is " + job.getJobPairs().size() );

			return job;
		} else {
			if (Jobs.isJobDeleted(jobId)) {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "This job has been deleted. You likely want to remove it from your spaces");
				return null;
			} else {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "Job does not exist or is restricted");
				return null;
			}
		}
	}
}
