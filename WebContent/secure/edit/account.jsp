<%@page contentType="text/html" pageEncoding="UTF-8" import="org.apache.commons.io.*, java.util.List, org.starexec.data.database.*, org.starexec.data.to.*, org.starexec.constants.*, org.starexec.util.*, org.starexec.data.to.Processor.ProcessorType" session="true"%>
<%@taglib prefix="star" tagdir="/WEB-INF/tags" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	try {
		User user = SessionUtil.getUser(request);
		long disk_usage = Users.getDiskUsage(user.getId());
		int userId = user.getId();
		if (userId!=R.PUBLIC_USER_ID){
			request.setAttribute("userId", userId);
			request.setAttribute("diskQuota", Util.byteCountToDisplaySize(user.getDiskQuota()));
			request.setAttribute("diskUsage", Util.byteCountToDisplaySize(disk_usage));
		}
		else{
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Only registered users can edit their accounts.");	
		}
		} catch (Exception e) {
		response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
	}
%>
<star:template title="edit account" css="common/table, common/pass_strength_meter, edit/account" js="lib/jquery.validate.min, lib/jquery.validate.password, edit/account, lib/jquery.dataTables.min">
	<div id="popDialog">
  		<img id="popImage" src=""/>
	</div>
	<p>review and edit your account details here.</p>
	<fieldset>
	<legend>personal information</legend>
	<table id="infoTable">
		<tr>
			<td id="picSection">
				<img id="showPicture" src="/${starexecRoot}/secure/get/pictures?Id=${userId}&type=uthn" enlarge="/${starexecRoot}/secure/get/pictures?Id=${userId}&type=uorg">
		    	<ul>
					<li><a class="btnUp" id="uploadPicture" href="/${starexecRoot}/secure/add/picture.jsp?type=user&Id=${userId}">change</a></li>
				</ul>
			</td>
		<td id="userDetail">
			<table id="personal" class="shaded">   
			<thead> 	
				<tr>
					<th class="label">attribute</th>
					<th>current value</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>first name </td>
					<td id="editfirstname">${user.firstName}</td>
				</tr>
				<tr>
					<td>last name</td>
					<td id="editlastname">${user.lastName}</td>
				</tr>
				<tr>
					<td>institution </td>
					<td id="editinstitution">${user.institution}</td>
				</tr>
				<tr>
					<td>email </td>
					<td>${user.email}</td>
				</tr>
			</tbody>
		</table>
		</td>
		</tr>
		</table>
		<h6>(click the current value of an attribute to edit it; email addresses are currently not editable)</h6>
	</fieldset>
	<fieldset>
		<legend>associated websites</legend>
		<table id="websites" class="shaded">
			<thead>
				<tr>
					<th>link</th>
					<th>action</th>					
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
		
		<span id="toggleWebsite" class="caption"><span>+</span> add new</span>
		<div id="new_website">
			name: <input type="text" id="website_name" /> 
			url: <input type="text" id="website_url" /> 
			<button id="addWebsite">add</button>
		</div>
	</fieldset>
	<fieldset>
		<legend>password</legend>
		<form id="changePassForm">
			<table id="passwordTable" class="shaded">
				<thead>
					<tr>
						<th>attribute</th>
						<th>value</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>current password</td>
						<td><input type="password" id="current_pass" name="current_pass"/></td>
					</tr>
					<tr>
						<td>new password</td>
						<td>
							<input type="password" id="password" name="pwd"/>
							<div class="password-meter" id="pwd-meter" style="visibility:visible">
								<div class="password-meter-message"> </div>
								<div class="password-meter-bg">
									<div class="password-meter-bar"></div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<td>re-enter new password</td>
						<td><input type="password" id="confirm_pass" name="confirm_pass"/></td>
					</tr>
					<tr></tr>
					<tr>
						<td class="notShaded" colspan="2"><button id="changePass">change</button></td>
					</tr>
				</tbody>
			</table>
		</form>
	</fieldset>
	<div id="dialog-confirm-delete" title="confirm delete">
			<p><span class="ui-icon ui-icon-alert"></span><span id="dialog-confirm-delete-txt"></span></p>
	</div>
</star:template>