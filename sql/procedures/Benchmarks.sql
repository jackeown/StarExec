-- Description: This file contains all benchmark stored procedures for the starexec database
-- The procedures are stored by which table they're related to and roughly alphabetic order. Please try to keep this organized!

-- Adds a benchmark into the system and associates it with a space
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS AddBenchmark //
CREATE PROCEDURE AddBenchmark(IN _name VARCHAR(256), IN _path TEXT, IN _downloadable TINYINT(1), IN _userId INT, IN _typeId INT, IN _diskSize BIGINT, IN _description TEXT, OUT _benchId INT)
	BEGIN
		UPDATE users SET disk_size=disk_size+_diskSize WHERE id = _userId;
		INSERT INTO benchmarks (user_id, name, bench_type, uploaded, path, downloadable, disk_size, description)
		VALUES (_userId, _name, _typeId, SYSDATE(), _path, _downloadable, _diskSize, _description);

		SELECT LAST_INSERT_ID() INTO _benchId;
	END //

DROP PROCEDURE IF EXISTS AddAndAssociateBenchmark //
CREATE PROCEDURE AddAndAssociateBenchmark(IN _name VARCHAR(256), IN _path TEXT, IN _downloadable TINYINT(1), IN _userId INT, IN _typeId INT, IN _diskSize BIGINT, IN _spaceId INT, OUT _benchId INT)
	BEGIN
		UPDATE users SET disk_size=disk_size+_diskSize WHERE id = _userId;
		INSERT INTO benchmarks (user_id, name, bench_type, uploaded, path, downloadable, disk_size)
		VALUES (_userId, _name, _typeId, SYSDATE(), _path, _downloadable, _diskSize);

		SELECT LAST_INSERT_ID() INTO _benchId;

		INSERT IGNORE INTO bench_assoc (space_id, bench_id) VALUES (_spaceId, _benchId);

	END //

-- Gets all benchmarks that are in a job (in job pairs in that job)
-- Author: Albert Giegerich
DROP PROCEDURE IF EXISTS GetBenchmarksByJob //
CREATE PROCEDURE GetBenchmarksByJob(IN _jobId INT)
	BEGIN
		SELECT DISTINCT benchmarks.*
		FROM benchmarks
			INNER JOIN job_pairs
			ON benchmarks.id=job_pairs.bench_id
		WHERE job_id=_jobId;
	END //

-- Adds a new attribute to a benchmark
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS AddBenchAttr //
CREATE PROCEDURE AddBenchAttr(IN _benchmarkId INT, IN _key VARCHAR(128), IN _val VARCHAR(128))
	BEGIN
		REPLACE INTO bench_attributes VALUES (_benchmarkId, _key, _val);
	END //


-- Adds a new dependency for a benchmark
-- Author: Benton McCune
DROP PROCEDURE IF EXISTS AddBenchDependency //
CREATE PROCEDURE AddBenchDependency(IN _primary_bench_id INT, IN _secondary_benchId INT, IN _include_path TEXT)
	BEGIN
		INSERT INTO bench_dependency (primary_bench_id, secondary_bench_id, include_path) VALUES (_primary_bench_id, _secondary_benchId, _include_path);
	END //

-- Associates the given benchmark with the given space
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS AssociateBench //
CREATE PROCEDURE AssociateBench(IN _benchId INT, IN _spaceId INT)
	BEGIN
		INSERT IGNORE INTO bench_assoc (space_id, bench_id) VALUES (_spaceId, _benchId);
	END //

-- Retrieves all attributes for a benchmark
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS GetBenchAttrs //
CREATE PROCEDURE GetBenchAttrs(IN _benchmarkId INT)
	BEGIN
		SELECT *
		FROM bench_attributes
		WHERE bench_id=_benchmarkId
		ORDER BY attr_key ASC;
	END //

DROP PROCEDURE IF EXISTS GetBenchByName //
CREATE PROCEDURE GetBenchByName(IN _id INT, IN _name VARCHAR(256))
	BEGIN
		SELECT *
		FROM benchmarks AS bench
		WHERE deleted=false AND recycled=false and bench.id IN
				(SELECT bench_id
				FROM bench_assoc
				WHERE space_id = _id)
		AND bench.name = _name;
	END //

-- Retrieves all benchmark dependencies for a given primary benchmark id
-- Author: Benton McCune
DROP PROCEDURE IF EXISTS GetBenchmarkDependencies //
CREATE PROCEDURE GetBenchmarkDependencies(IN _pBenchId INT)
	BEGIN
		SELECT *
		FROM bench_dependency
		WHERE primary_bench_id = _pBenchId;
	END //

-- Just get the id, name, and path for the dependencies of the benchmark with the given id
-- Author: Aaron Stump
DROP PROCEDURE IF EXISTS GetPathsForBenchmarkDependencies //
CREATE PROCEDURE GetPathsForBenchmarkDependencies(IN _pBenchId INT)
	BEGIN
                SELECT benchmarks.id , benchmarks.name , benchmarks.path , bench_dependency.include_path
		FROM benchmarks JOIN bench_dependency
		ON benchmarks.id = bench_dependency.secondary_bench_id 
                WHERE primary_bench_id = _pBenchId;
	END //

-- Deletes a benchmark given that benchmark's id
-- Author: Todd Elvers	+ Eric Burns
DROP PROCEDURE IF EXISTS SetBenchmarkToDeletedById //
CREATE PROCEDURE SetBenchmarkToDeletedById(IN _benchmarkId INT, OUT _path TEXT)
	BEGIN
		UPDATE users JOIN benchmarks on benchmarks.user_id=users.id
		SET users.disk_size=users.disk_size-benchmarks.disk_size
		WHERE benchmarks.id = _benchmarkId;
		SELECT path INTO _path FROM benchmarks WHERE id = _benchmarkId;
		UPDATE benchmarks
		SET deleted=true, disk_size=0
		WHERE id = _benchmarkId;

	END //
-- Gets the IDs of all the spaces associated with the given benchmark
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetAssociatedSpaceIdsByBenchmark //
CREATE PROCEDURE GetAssociatedSpaceIdsByBenchmark(IN _benchId INT)
	BEGIN
		SELECT space_id
		FROM bench_assoc
		WHERE bench_id=_benchId;
	END //

-- Retrieves the benchmark with the given id
-- Author: Tyler Jensen
DROP PROCEDURE IF EXISTS GetBenchmarkById //
CREATE PROCEDURE GetBenchmarkById(IN _id INT)
	BEGIN
		SELECT *
		FROM benchmarks AS bench
			LEFT OUTER JOIN processors AS types
			ON bench.bench_type=types.id
		WHERE bench.id = _id and deleted=false AND recycled=false;
	END //

DROP PROCEDURE IF EXISTS GetBenchmarkPathById //
CREATE PROCEDURE GetBenchmarkPathById(IN _id INT)
	BEGIN
		SELECT name , path
		FROM benchmarks 
		WHERE id = _id and deleted=false AND recycled=false;
	END //

-- Retrieves the benchmark with the given id, including deleted benchmarks
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarkByIdIncludeDeletedAndRecycled //
CREATE PROCEDURE GetBenchmarkByIdIncludeDeletedAndRecycled(IN _id INT)
	BEGIN
		SELECT *
		FROM benchmarks AS bench
			LEFT OUTER JOIN processors AS types
			ON bench.bench_type=types.id
		WHERE bench.id = _id;
	END //

DROP PROCEDURE IF EXISTS GetXMLUploadStatusById //
CREATE PROCEDURE GetXMLUploadStatusById(IN _id INT)
	BEGIN
		SELECT *
		FROM space_xml_uploads
		WHERE id = _id;
	END //

-- Returns the number of benchmarks in a given space that match a given query
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarkCountInSpaceWithQuery //
CREATE PROCEDURE GetBenchmarkCountInSpaceWithQuery(IN _spaceId INT, IN _query TEXT)
	BEGIN
		SELECT 	COUNT(*) AS benchCount
		FROM 	bench_assoc
			JOIN	benchmarks AS benchmarks ON benchmarks.id = bench_assoc.bench_id
			LEFT JOIN	processors  AS benchType ON benchmarks.bench_type=benchType.id
		WHERE 	_spaceId=space_id AND
				(benchmarks.name LIKE	CONCAT('%', _query, '%')
				OR		(benchType.name	LIKE 	CONCAT('%', _query, '%')
				OR (benchType.name is null AND 'none' LIKE CONCAT('%', _query, '%'))));
	END //
-- Retrieves all benchmarks belonging to a space
-- Author: Eric Burns

DROP PROCEDURE IF EXISTS GetSpaceBenchmarksById //
CREATE PROCEDURE GetSpaceBenchmarksById(IN _id INT)
	BEGIN
		SELECT *
		FROM bench_assoc
		JOIN benchmarks AS bench ON bench.id=bench_assoc.bench_id
		LEFT OUTER JOIN processors AS types ON bench.bench_type=types.id
		WHERE bench_assoc.space_id=_id and bench.deleted=false and bench.recycled=false
		ORDER BY order_id ASC;
	END //

-- Returns the number of public spaces a benchmark is in
-- Benton McCune
DROP PROCEDURE IF EXISTS IsBenchPublic //
CREATE PROCEDURE IsBenchPublic(IN _benchId INT)
	BEGIN
		SELECT count(*) as benchPublic
		FROM bench_assoc
		WHERE bench_id = _benchId
		AND IsPublic(space_id);
	END //

DROP PROCEDURE IF EXISTS IsBenchmarkDeleted //
CREATE PROCEDURE IsBenchmarkDeleted(IN _benchId INT)
	BEGIN
		SELECT count(*) AS benchDeleted
		FROM benchmarks
		WHERE deleted=true AND id=_benchId;
	END //

-- Removes the association between a benchmark and a given space;
-- Author: Todd Elvers + Eric Burns
DROP PROCEDURE IF EXISTS RemoveBenchFromSpace //
CREATE PROCEDURE RemoveBenchFromSpace(IN _benchId INT, IN _spaceId INT)
	BEGIN
		IF _spaceId >= 0 THEN
			DELETE FROM bench_assoc
			WHERE space_id = _spaceId
			AND bench_id = _benchId;
		END IF;

	END //


-- Updates the details associated with a given benchmark
-- Author: Todd Elvers
DROP PROCEDURE IF EXISTS UpdateBenchmarkDetails //
CREATE PROCEDURE UpdateBenchmarkDetails(IN _benchmarkId INT, IN _name VARCHAR(256), IN _description TEXT, IN _downloadable BOOLEAN, IN _type INT)
	BEGIN
		UPDATE benchmarks
		SET name = _name,
		description = _description,
		downloadable = _downloadable,
		bench_type = _type
		WHERE id = _benchmarkId;
	END //

-- Get the total count of the benchmarks belong to a specific user
-- Author: Wyatt Kaiser
DROP PROCEDURE IF EXISTS GetBenchmarkCountByUser //
CREATE PROCEDURE GetBenchmarkCountByUser(IN _userId INT)
	BEGIN
		SELECT COUNT(*) AS benchCount
		FROM benchmarks
		WHERE user_id = _userId AND deleted=false AND recycled=false;
	END //
-- Returns the number of benchmarks a given user has that match the query
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarkCountByUserWithQuery //
CREATE PROCEDURE GetBenchmarkCountByUserWithQuery(IN _userId INT, IN _query TEXT)
	BEGIN
		SELECT 	COUNT(*) AS benchCount
		FROM 	benchmarks
			JOIN	processors  AS benchType ON benchmarks.bench_type=benchType.id
		WHERE 	benchmarks.user_id=_userId AND deleted=false AND recycled=false AND
				(benchmarks.name LIKE	CONCAT('%', _query, '%')
				OR		benchType.name	LIKE 	CONCAT('%', _query, '%'));
	END //

-- Sets the recycled attribute to the given value for the given benchmark
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS SetBenchmarkRecycledValue //
CREATE PROCEDURE SetBenchmarkRecycledValue(IN _benchId INT, IN _recycled BOOLEAN)
	BEGIN
		UPDATE benchmarks
		SET recycled=_recycled
		WHERE id=_benchId;
	END //

-- Checks to see whether the "recycled" flag is set for the given benchmark
-- Author: Eric BUrns
DROP PROCEDURE IF EXISTS IsBenchmarkRecycled //
CREATE PROCEDURE IsBenchmarkRecycled(IN _benchId INT)
	BEGIN
		SELECT recycled FROM benchmarks
		WHERE id=_benchId;
	END //

-- Counts how many recycled benchmarks a user has that match the given query
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetRecycledBenchmarkCountByUser //
CREATE PROCEDURE GetRecycledBenchmarkCountByUser(IN _userId INT, IN _query TEXT)
	BEGIN
		SELECT 	COUNT(*) AS benchCount
		FROM 	benchmarks
			JOIN	processors  AS benchType ON benchmarks.bench_type=benchType.id
		WHERE 	benchmarks.recycled=true AND benchmarks.user_id=_userId AND deleted=false AND
				(benchmarks.name LIKE	CONCAT('%', _query, '%')
				OR		benchType.name	LIKE 	CONCAT('%', _query, '%'));
	END //

-- Gets the path to every recycled benchmark a user has
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetRecycledBenchmarkPaths //
CREATE PROCEDURE GetRecycledBenchmarkPaths(IN _userId INT)
	BEGIN
		SELECT path FROM benchmarks
		WHERE recycled=true AND user_id=_userId;
	END //

-- Removes all recycled benchmarks a user has in the database
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS SetRecycledBenchmarksToDeleted //
CREATE PROCEDURE SetRecycledBenchmarksToDeleted(IN _userId INT)
	BEGIN
		UPDATE users
		SET users.disk_size=users.disk_size-(SELECT COALESCE(SUM(disk_size),0) FROM benchmarks WHERE user_id=_userId AND recycled=true AND deleted=false)
		WHERE users.id=_userId;
		UPDATE benchmarks
		SET deleted=true, disk_size=0
		WHERE user_id = _userId AND recycled=true AND deleted=false;
	END //

-- Gets all recycled benchmark ids a user has
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetRecycledBenchmarkIds //
CREATE PROCEDURE GetRecycledBenchmarkIds(IN _userId INT)
	BEGIN
		SELECT id from benchmarks
		WHERE user_id=_userId AND recycled=true;
	END //


-- Sets the recycled flag for a single benchmark back to false
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS RestoreBenchmark //
CREATE PROCEDURE RestoreBenchmark(IN _benchId INT)
	BEGIN
		UPDATE benchmarks
		SET recycled=false
		WHERE _benchId=id;
	END //
-- Gets rid of all the current attributes a benchmark has
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS ClearBenchAttributes //
CREATE PROCEDURE ClearBenchAttributes(IN _benchId INT)
	BEGIN
		DELETE FROM bench_attributes
		WHERE _benchId=bench_id;
	END //

-- Retrieves the benchmarks owned by a given user id
-- Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarksByOwner //
CREATE PROCEDURE GetBenchmarksByOwner(IN _userId INT)
	BEGIN
		SELECT *
		FROM benchmarks
		LEFT OUTER JOIN processors AS types
			ON benchmarks.bench_type=types.id
		WHERE user_id = _userId and deleted=false AND recycled=false;
	END //

-- Gets the ids of every orphaned benchmark a user owns
DROP PROCEDURE IF EXISTS GetOrphanedBenchmarkIds //
CREATE PROCEDURE GetOrphanedBenchmarkIds(IN _userId INT)
	BEGIN
		SELECT benchmarks.id FROM benchmarks
		LEFT JOIN bench_assoc ON bench_assoc.bench_id=benchmarks.id
		WHERE benchmarks.user_id=_userId AND bench_assoc.space_id IS NULL;
	END //

-- Permanently removes a benchmark from the database
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS RemoveBenchmarkFromDatabase //
CREATE PROCEDURE RemoveBenchmarkFromDatabase(IN _id INT)
	BEGIN
		DELETE FROM benchmarks
		WHERE id=_id;
	END //


-- Gets all the benchmarks ids of benchmarks that are in at least one space
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarksAssociatedWithSpaces //
CREATE PROCEDURE GetBenchmarksAssociatedWithSpaces()
	BEGIN
		SELECT DISTINCT bench_id AS id FROM bench_assoc;
	END //

-- Gets the benchmarks ids of all benchmarks associated with at least one pair
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarksAssociatedWithPairs //
CREATE PROCEDURE GetBenchmarksAssociatedWithPairs()
	BEGIN
		SELECT DISTINCT bench_id AS id from job_pairs;
	END //

-- Gets the benchmark ids of all deleted benchmarks
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetDeletedBenchmarks //
CREATE PROCEDURE GetDeletedBenchmarks()
	BEGIN
		SELECT * FROM benchmarks WHERE deleted=true;
	END //


-- returns every benchmark that shares a space with the given user
-- Author: Eric Burns
DROP PROCEDURE IF EXISTS GetBenchmarksInSharedSpaces //
CREATE PROCEDURE GetBenchmarksInSharedSpaces(IN _userId INT)
	BEGIN
		SELECT * FROM benchmarks
		JOIN bench_assoc ON bench_assoc.bench_id = benchmarks.id
		JOIN user_assoc ON user_assoc.space_id = bench_assoc.space_id
		LEFT OUTER JOIN processors AS types
			ON benchmarks.bench_type=types.id
		WHERE user_assoc.user_id=_userId AND deleted=false AND recycled=false
		GROUP BY(benchmarks.id);
	END //

-- Gets all solvers that reside in public spaces
-- Author: Benton McCune
DROP PROCEDURE IF EXISTS GetPublicBenchmarks //
CREATE PROCEDURE GetPublicBenchmarks()
	BEGIN
		SELECT * from benchmarks
		JOIN bench_assoc ON bench_assoc.bench_id=benchmarks.id
		JOIN spaces ON spaces.id=bench_assoc.space_id
		LEFT OUTER JOIN processors AS types
			ON benchmarks.bench_type=types.id
		WHERE public_access=1 AND deleted=false AND recycled=false
		GROUP BY benchmarks.id;
	END //

DROP PROCEDURE IF EXISTS GetBrokenBenchDependencies //
CREATE PROCEDURE GetBrokenBenchDependencies(IN _benchId INT)
    BEGIN
        SELECT DISTINCT benchmarks.id
        FROM benchmarks join bench_dependency
            ON benchmarks.id=bench_dependency.secondary_bench_id
        WHERE
            (benchmarks.deleted = 1
            OR benchmarks.recycled = 1)
            AND primary_bench_id = _benchId;
    END //
