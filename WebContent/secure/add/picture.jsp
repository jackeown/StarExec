<%@page contentType="text/html" pageEncoding="UTF-8" import="org.starexec.data.database.*, org.starexec.data.to.*, org.starexec.util.*"%>
<%@taglib prefix="star" tagdir="/WEB-INF/tags" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	try {
		User user = SessionUtil.getUser(request);
		int userId = user.getId();
		
		String type = request.getParameter("type").toString();
		String Id =  request.getParameter("Id").toString();
	
		request.setAttribute("userId", userId);
		request.setAttribute("Id", Id);
		request.setAttribute("type", type);

	} catch (Exception e) {
		response.sendError(HttpServletResponse.SC_BAD_REQUEST);
	}
%>

<star:template title="upload a picture" css="add/picture" js="lib/jquery.validate.min, add/picture">
	<form method="POST" enctype="multipart/form-data" action="/starexec/secure/upload/pictures?type=${type}&Id=${userId}" id="upForm">
		<fieldset>
			<legend>picture information</legend>		
			<table id="tblSolver" class="shaded">
				<tr>
					<td>picture location</td>
					<td><input name="f" type="file" /></td>
				</tr>
					<td colspan="2"><button id="btnUpload" type="submit">upload</button></td>
				</tr>
			</table>																	
		</fieldset>
	</form>
</star:template>