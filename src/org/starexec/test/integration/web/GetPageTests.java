package org.starexec.test.integration.web;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.junit.Assert;
import org.starexec.command.Connection;
import org.starexec.constants.R;
import org.starexec.data.database.Benchmarks;
import org.starexec.data.database.Communities;
import org.starexec.data.database.Jobs;
import org.starexec.data.database.Processors;
import org.starexec.data.database.Queues;
import org.starexec.data.database.Settings;
import org.starexec.data.database.Solvers;
import org.starexec.data.database.Spaces;
import org.starexec.data.database.Uploads;
import org.starexec.data.database.Users;
import org.starexec.data.to.BenchmarkUploadStatus;
import org.starexec.data.to.Configuration;
import org.starexec.data.to.DefaultSettings;
import org.starexec.data.to.Job;
import org.starexec.data.to.Processor;
import org.starexec.data.to.Processor.ProcessorType;
import org.starexec.data.to.Queue;
import org.starexec.data.to.Solver;
import org.starexec.data.to.Space;
import org.starexec.data.to.SpaceXMLUploadStatus;
import org.starexec.data.to.User;
import org.starexec.test.integration.StarexecTest;
import org.starexec.test.integration.TestSequence;
import org.starexec.test.resources.ResourceLoader;
import org.starexec.util.Util;
/**
 * This file is used to test whether there are any internal errors caused by loading any JSP
 * page on the site. The tests in this file use StarexecCommand to directly request
 * URLs from the current Starexec instance: returning true if the page returned successfully
 * and false if an HTTP error was sent back
 *
 */
public class GetPageTests extends TestSequence {
	private Connection con; // connection of a normal user
	private Connection adminCon;
	private Connection nonUserCon; // connection for someone who is not logged in
	private Space space1=null; //will contain both solvers and benchmarks and is owned by user
	Space newCommunity = null; //community populated only by the admin
	private Job job=null;
	File solverFile=null;
	File downloadDir=null;

	Solver solver=null;
	Solver solver2 = null;
	List<Integer> benchmarkIds=null;
	Configuration config=null;
	Processor proc=null;
	
	User user=null;
	DefaultSettings settings=null;
	User admin=null;
	Space testCommunity=null;	
	Queue q=null;
	BenchmarkUploadStatus benchUpload = null;
	SpaceXMLUploadStatus spaceUpload = null;
	@StarexecTest
	private void getSpaceExplorerTest(){
		Assert.assertTrue(con.canGetPage("secure/explore/spaces.jsp"));
	}
	
	@StarexecTest
	private void getCommunityExplorerTest(){
		Assert.assertTrue(con.canGetPage("secure/explore/communities.jsp"));
	}
	
	@StarexecTest
	private void getEditCommunityTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/edit/community.jsp?cid="+testCommunity.getId()));
	}
	
	@StarexecTest
	private void getClusterTest(){
		Assert.assertTrue(con.canGetPage("secure/explore/cluster.jsp"));
	}
	
	@StarexecTest
	private void getStatisticsTest() {
		Assert.assertTrue(con.canGetPage("secure/explore/statistics.jsp"));
	}
	
	@StarexecTest
	private void getReportsTest() {
		Assert.assertTrue(con.canGetPage("secure/explore/reports.jsp"));
	}
	
	@StarexecTest
	private void getSolverDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/solver.jsp?id="+solver.getId()));
	}
	
	@StarexecTest
	private void getSolverEditTest(){
		Assert.assertTrue(con.canGetPage("secure/edit/solver.jsp?id="+solver.getId()));
	}
	
	@StarexecTest
	private void getSolverAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/solver.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getBatchJobAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/batchJob.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getBatchSpaceAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/batchSpace.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void addSpaceTest() {
		Assert.assertTrue(con.canGetPage("secure/add/space.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void addToCommunityTest() {
		Assert.assertTrue(con.canGetPage("secure/add/to_community.jsp?cid="+newCommunity.getId()));

	}
	
	@StarexecTest
	private void getBenchmarkDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/benchmark.jsp?id="+benchmarkIds.get(0)));
	}
	
	@StarexecTest
	private void getBenchmarkEditTest(){
		Assert.assertTrue(con.canGetPage("secure/edit/benchmark.jsp?id="+benchmarkIds.get(0)));
	}
	
	@StarexecTest
	private void getBenchAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/benchmarks.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getConfigDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/configuration.jsp?id="+config.getId()));
	}
	
	@StarexecTest
	private void getConfigEditTest(){
		Assert.assertTrue(con.canGetPage("secure/edit/configuration.jsp?id="+config.getId()));
	}
	
	@StarexecTest
	private void getConfigAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/configuration.jsp?sid="+solver.getId()));
	}
	
	@StarexecTest
	private void getPictureAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/picture.jsp?type=solver&Id="+solver.getId()));
	}
	
	@StarexecTest
	private void getSpaceEditTest() {
		Assert.assertTrue(con.canGetPage("secure/edit/space.jsp?id="+space1.getId()));
	}
	
	@StarexecTest
	private void getSpacePermissionsEditTest() {
		Assert.assertTrue(con.canGetPage("secure/edit/spacePermissions.jsp?id="+space1.getId()));
	}
	
	@StarexecTest
	private void getJobDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/job.jsp?id="+job.getId()));
	}
	
	@StarexecTest
	private void getJobPanelViewTest(){
		Assert.assertTrue(con.canGetPage("secure/details/jobPanelView.jsp?spaceid="+job.getPrimarySpace()+"&stage=1"));
	}
	
	@StarexecTest
	private void getMatrixViewTest() {
		Assert.assertTrue(con.canGetPage("secure/details/jobMatrixView.jsp?stage=1&jobSpaceId="+job.getPrimarySpace()));
	}
	
	@StarexecTest
	private void getPairsInSpaceTest(){
		Assert.assertTrue(con.canGetPage("secure/details/pairsInSpace.jsp?type=solved&configid="+job.getJobPairs().get(0).getPrimaryStage().getConfiguration().getId()
				+"&sid="+job.getPrimarySpace()));
	}
	
	@StarexecTest
	private void getSolverComparisonTest() {
		int c1 = solver.getConfigurations().get(0).getId();
		int c2 = solver2.getConfigurations().get(0).getId();
		Assert.assertTrue(con.canGetPage("secure/details/solverComparison.jsp?sid="+job.getPrimarySpace()+"&c1="+c1+"&c2="+c2));
	}
	
	@StarexecTest
	private void getPairDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/pair.jsp?id="+job.getJobPairs().get(0).getId()));
	}
	
	@StarexecTest
	private void getResubmitPairsTest() {
		Assert.assertTrue(con.canGetPage("secure/edit/resubmitPairs.jsp?id="+job.getId()));
	}
	
	@StarexecTest
	private void getJobAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/job.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getQuickJobAddTest(){
		Assert.assertTrue(con.canGetPage("secure/add/quickJob.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getRecycleBinTest(){
		Assert.assertTrue(con.canGetPage("secure/details/recycleBin.jsp"));
	}
	
	@StarexecTest
	private void getUserDetailsTest(){
		Assert.assertTrue(con.canGetPage("secure/details/user.jsp?id="+user.getId()));
	}
	
	@StarexecTest
	private void getUserEditTest(){
		Assert.assertTrue(con.canGetPage("secure/edit/account.jsp?id="+user.getId()));
	}
	
	@StarexecTest
	private void getDefaultPrimTest() {
		Assert.assertTrue(con.canGetPage("secure/edit/defaultPrimitive.jsp?type=solver&id="+settings.getId()));
		Assert.assertTrue(con.canGetPage("secure/edit/defaultPrimitive.jsp?type=benchmark&id="+settings.getId()));
		
		Assert.assertFalse(con.canGetPage("secure/edit/defaultPrimitive.jsp?type=wrong&id="+settings.getId()));
		Assert.assertFalse(con.canGetPage("secure/edit/defaultPrimitive.jsp?type=benchmark&id=-1"));


	}
	
	@StarexecTest
	private void getHelpTest(){
		Assert.assertTrue(con.canGetPage("secure/help.jsp"));
	}
	
	@StarexecTest
	private void getAdminAddUserTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/addUser.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/addUser.jsp"));
	}
	
	@StarexecTest
	private void getAdminAssocCommunityTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/assocCommunity.jsp?id="+q.getId()));
		Assert.assertFalse(con.canGetPage("secure/admin/assocCommunity.jsp?id="+q.getId()));

	}
	
	@StarexecTest
	private void getAdminClusterTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/cluster.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/cluster.jsp"));

	}
	
	@StarexecTest
	private void getAdminCommunityTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/community.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/community.jsp"));

	}
	
	@StarexecTest
	private void getAdminJobTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/job.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/job.jsp"));

	}
	
	@StarexecTest
	private void getAdminLoggingTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/logging.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/logging.jsp"));

	}
	
	@StarexecTest
	private void getAdminMoveNodesTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/moveNodes.jsp?id="+q.getId()));
		Assert.assertFalse(con.canGetPage("secure/admin/moveNodes.jsp?id="+q.getId()));

	}
	
	@StarexecTest
	private void getAdminQueueTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/queue.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/queue.jsp"));

	}
	
	@StarexecTest
	private void getAdminPermissionsTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/permissions.jsp?id="+user.getId()));
		Assert.assertFalse(con.canGetPage("secure/admin/permissions.jsp?id="+user.getId()));
	}
	
	@StarexecTest
	private void getAdminStarexecTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/starexec.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/starexec.jsp"));

	}
	
	@StarexecTest
	private void getAdminStressTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/stressTest.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/stressTest.jsp"));
	}
	
	@StarexecTest
	private void getAdminTestingTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/testing.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/testing.jsp"));

	}
	
	@StarexecTest
	private void getAdminUserTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/admin/user.jsp"));
		Assert.assertFalse(con.canGetPage("secure/admin/user.jsp"));

	}
	
	@StarexecTest
	private void editProcessorTest() {
		Assert.assertTrue(adminCon.canGetPage("secure/edit/processor.jsp?id="+proc.getId()));
	}
	
	@StarexecTest
	private void getBenchmarkUploadTest() {
		Assert.assertTrue(con.canGetPage("secure/details/uploadStatus.jsp?id="+benchUpload.getId()));
	}
	
	@StarexecTest
	private void getSpaceUploadTest() {
		Assert.assertTrue(con.canGetPage("secure/details/XMLuploadStatus.jsp?id="+spaceUpload.getId()));
	}
	
	@StarexecTest
	private void getProcessBenchmarksTest() {
		Assert.assertTrue(con.canGetPage("secure/edit/processBenchmarks.jsp?sid="+space1.getId()));
	}
	
	@StarexecTest
	private void getSolverConfigsTest() {
		Assert.assertTrue(con.canGetPage("secure/details/solverconfigs.jsp?solverid="+solver.getId()+"&limit=100"));
	}
	
	@StarexecTest
	private void getRegistrationPageTest() {
		Assert.assertTrue(nonUserCon.canGetPage("public/registration.jsp"));

	}
	
	@StarexecTest
	private void failBadURLTest(){
		Assert.assertFalse(adminCon.canGetPage("secure/details/fakewebpage.jsp"));
		Assert.assertFalse(con.canGetPage("secure/details/fakewebpage.jsp"));
	}
	
	@Override
	protected void setup() throws Exception {
		user=ResourceLoader.loadUserIntoDatabase();
		admin=Users.getAdmins().get(0);
		testCommunity=Communities.getTestCommunity();
		con=new Connection(user.getEmail(),user.getPassword(),Util.url(""));
		adminCon=new Connection(admin.getEmail(),R.TEST_USER_PASSWORD,Util.url(""));
		nonUserCon = new Connection("empty", "empty", Util.url(""));
		con.login();
		adminCon.login();
		//space1 will contain solvers and benchmarks
		space1=ResourceLoader.loadSpaceIntoDatabase(user.getId(),testCommunity.getId());
		newCommunity = ResourceLoader.loadSpaceIntoDatabase(admin.getId(), 1);
		
		q=Queues.getAll().get(0);
		downloadDir=ResourceLoader.getDownloadDirectory();
		solver=ResourceLoader.loadSolverIntoDatabase(space1.getId(), user.getId());
		solver2=ResourceLoader.loadSolverIntoDatabase(space1.getId(), user.getId());

		config=ResourceLoader.loadConfigurationFileIntoDatabase("CVC4Config.txt", solver.getId());
		proc=ResourceLoader.loadProcessorIntoDatabase(ProcessorType.POST, testCommunity.getId());

		benchmarkIds=ResourceLoader.loadBenchmarksIntoDatabase(space1.getId(), user.getId());
		List<Integer> solverIds=new ArrayList<Integer>();
		solverIds.add(solver.getId());
		solverIds.add(solver2.getId());
		job=ResourceLoader.loadJobIntoDatabase(space1.getId(), user.getId(), -1, proc.getId(), solverIds, benchmarkIds,100,100,1);
		settings=ResourceLoader.loadDefaultSettingsProfileIntoDatabase(user.getId());
		
		benchUpload = Uploads.getBenchmarkStatus(Uploads.createBenchmarkUploadStatus(space1.getId(), user.getId()));
		spaceUpload = Uploads.getSpaceXMLStatus(Uploads.createSpaceXMLUploadStatus(user.getId()));
	}
	
	@Override
	protected void teardown() throws Exception {
		Spaces.removeSubspace(space1.getId());
		Spaces.removeSubspace(newCommunity.getId());
		Solvers.deleteAndRemoveSolver(solver.getId());
		Solvers.deleteAndRemoveSolver(solver2.getId());
		Processors.delete(proc.getId());
		for (Integer i : benchmarkIds) {
			Benchmarks.deleteAndRemoveBenchmark(i);
		}
		
		Jobs.deleteAndRemove(job.getId());
		Settings.deleteProfile(settings.getId());
		Users.deleteUser(user.getId(), admin.getId());
	}

	@Override
	protected String getTestName() {
		return "GetPageTests";
	}

}
