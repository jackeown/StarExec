-- Description: This file contains all job-related stored procedures for the starexec database
-- The procedures are stored by which table they're related to and roughly alphabetic order. Please try to keep this organized!

USE starexec;

DELIMITER // -- Tell MySQL how we will denote the end of each prepared statement
	
DROP PROCEDURE IF EXISTS UpdateJobPairStatus;
CREATE PROCEDURE UpdateJobPairStatus(IN _pairId INT, IN _statusCode INT)
	BEGIN
		UPDATE job_pairs
		SET status_code = _statusCode
		WHERE id = _pairId;
	END //
	
DROP PROCEDURE IF EXISTS UpdateJobSpaceId;
CREATE PROCEDURE UpdateJobSpaceId(IN _pairId INT, IN _jobSpaceId INT)
	BEGIN
		UPDATE job_pairs
		SET job_space_id = _jobSpaceId
		WHERE id = _pairId;
	END //
	
	
-- Updates a job pair's statistics directly from the execution node
-- Author: Benton McCune
DROP PROCEDURE IF EXISTS UpdatePairRunSolverStats;
CREATE PROCEDURE UpdatePairRunSolverStats(IN _jobPairId INT, IN _nodeName VARCHAR(64), IN _wallClock DOUBLE, IN _cpu DOUBLE, IN _userTime DOUBLE, IN _systemTime DOUBLE, IN _maxVmem DOUBLE, IN _maxResSet BIGINT, IN _pageReclaims BIGINT, IN _pageFaults BIGINT, IN _blockInput BIGINT, IN _blockOutput BIGINT, IN _volContexSwtch BIGINT, IN _involContexSwtch BIGINT)
	BEGIN
		UPDATE job_pairs
		SET node_id=(SELECT id FROM nodes WHERE name=_nodeName),
			wallclock = _wallClock,
			cpu=_cpu,
			user_time=_userTime,
			system_time=_systemTime,
			max_vmem=_maxVmem,
			max_res_set=_maxResSet,
			page_reclaims=_pageReclaims,
			page_faults=_pageFaults,
			block_input=_blockInput,
			block_output=_blockOutput,
			vol_contex_swtch=_volContexSwtch,
			invol_contex_swtch=_involContexSwtch
		WHERE id=_jobPairId;
	END //
	
-- Updates a job pairs node Id
-- Author: Wyatt	
DROP PROCEDURE IF EXISTS UpdateNodeId;
CREATE PROCEDURE UpdateNodeId(IN _jobPairId INT, IN _nodeName VARCHAR(128))
	BEGIN
		UPDATE job_pairs
		SET node_id=(SELECT id FROM nodes WHERE name=_nodeName)
		WHERE id = _jobPairId;
	END //
	
-- Updates a job pair's status
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS UpdatePairStatus;
CREATE PROCEDURE UpdatePairStatus(IN _jobPairId INT, IN _statusCode TINYINT)
	BEGIN
		UPDATE job_pairs
		SET status_code=_statusCode
		WHERE id=_jobPairId ;
		IF _statusCode>6 THEN
			REPLACE INTO job_pair_completion (pair_id) VALUES (_jobPairId); 
		END IF;
	END //
	
-- Gets the job pair with the given id
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS GetJobPairBySGE;
CREATE PROCEDURE GetJobPairBySGE(IN _Id INT)
	BEGIN
		SELECT *
		FROM job_pairs
		WHERE job_pairs.sge_id=_Id;
	END //
	
-- Gets the job pair with the given id
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS GetJobPairById;
CREATE PROCEDURE GetJobPairById(IN _Id INT)
	BEGIN
		SELECT *
		FROM job_pairs LEFT JOIN job_spaces AS jobSpace ON job_pairs.job_space_id=jobSpace.id
		WHERE job_pairs.id=_Id;
	END //
	
-- Retrieves all attributes for a job pair 
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS GetPairAttrs;
CREATE PROCEDURE GetPairAttrs(IN _pairId INT)
	BEGIN
		SELECT *
		FROM job_attributes 
		WHERE pair_id=_pairId
		ORDER BY attr_key ASC;
	END //
	

-- Updates a job pair's status given its sge id
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS UpdateSGEPairStatus;
CREATE PROCEDURE UpdateSGEPairStatus(IN _sgeId INT, IN _statusCode TINYINT)
	BEGIN
		UPDATE job_pairs
		SET status_code=_statusCode
		WHERE sge_id=_sgeId;
		IF _statusCode>6 THEN
			INSERT IGNORE INTO job_pair_completion (pair_id) VALUES (_jobPairId);
		END IF;
			
	END //	
	
-- Updates a job pair's sge id
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS SetSGEJobId;
CREATE PROCEDURE SetSGEJobId(IN _jobPairId INT, IN _sgeId INT)
	BEGIN
		UPDATE job_pairs
		SET sge_id=_sgeId
		WHERE id=_jobPairId;
	END //
	
DROP PROCEDURE IF EXISTS GetAllPairsShallow;
CREATE PROCEDURE GetAllPairsShallow()
	BEGIN
		SELECT job_id,path,solver_name,config_name,bench_name,jobs.user_id FROM job_pairs
			JOIN jobs ON jobs.id=job_pairs.job_id;
	END //
	
-- Gets back only the fields of a job pair that are necessary to determine where it is stored on disk
-- Author: Eric Burns	
DROP PROCEDURE IF EXISTS GetJobPairFilePathInfo;
CREATE PROCEDURE GetJobPairFilePathInfo(IN _pairId INT)
	BEGIN
		SELECT job_id,path,solver_name,config_name,bench_name FROM job_pairs
		WHERE job_pairs.id=_pairId;
	END //
-- Adds a new pair to the processing table.
DROP PROCEDURE IF EXISTS AddProcessingPair;
CREATE PROCEDURE AddProcessingPair (IN _pairId INT, IN _procId INT,IN _processingStatusCode INT)
	BEGIN
		INSERT INTO processing_job_pairs (pair_id, proc_id,old_status_code) VALUES (_pairId, _procId,
		(select status_code from job_pairs where job_pairs.id=_pairId));
		UPDATE job_pairs SET status_code=_processingStatusCode WHERE id =_pairId;
	END //

DROP PROCEDURE IF EXISTS RemoveProcessingPair;
CREATE PROCEDURE RemoveProcessingPair (IN _pairId INT)
	BEGIN
		UPDATE job_pairs SET status_code=(SELECT old_status_code FROM processing_job_pairs where pair_id=_pairId) WHERE id=_pairId;
		DELETE FROM processing_job_pairs WHERE pair_id=_pairId;
	END //

DROP PROCEDURE IF EXISTS GetPairsToBeProcessed;
CREATE PROCEDURE GetPairsToBeProcessed()
	BEGIN
		SELECT * from processing_job_pairs;
	END //

DROP PROCEDURE IF EXISTS IsPairWaitingForProcessing;
CREATE PROCEDURE IsPairWaitingForProcessing(IN _pairId INT)
	BEGIN
		SELECT COUNT(*) AS waiting
		from processing_job_pairs
		WHERE pair_id=_pairId;
	END //
DELIMITER ; -- this should always be at the end of the file