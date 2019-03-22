<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
	<head>
		<title>Highscores</title>
		<style>
		body
		{
			text-align:center;
		}
		table
		{
			border-collapse:collapse;
		}
		table.center
		{
			margin-left:auto;
			margin-right:auto;
		}
		th
		{
			text-align:center;
		}
		th, td
		{
			padding:3px;
		}
		table, th, td
		{
			border:1px solid black;
		}
		h1
		{
			text-align:center
		}
		p.center
		{
			text-align:center
		}
		td.right
		{
			text-align:right
		}
		td.left
		{
			text-align:left
		}
		</style>
	</head>
	<body>
    <h1>${subgame.display}</h1>
		<p class="center">Display:
      <a href="scores?game=${subgame.id}&display=all${sortlink}">All</a>, 
      <a href="scores?game=${subgame.id}&display=topten${sortlink}">Top 10</a>, 
      <a href="scores?game=${subgame.id}&display=each${sortlink}">By name</a>
		</p>
    <c:set var="halfwidth" value="${120 + 50 * fn:length(subgame.columns)}" />
		<table class="center" style="border:0px">
			<tr>
        <td class="left" style="border:0px; width:${halfwidth}px">
          <c:choose>
            <c:when test="${not empty prevSubgame}">
            <a href="scores?game=${prevSubgame.id}&display=${display}">${prevSubgame.display}</a>
            </c:when>
            <c:otherwise>
              &nbsp;
            </c:otherwise>
          </c:choose>
				</td>
        <td class="right" style="border:0px; width:${halfwidth}px">
          <c:choose>
            <c:when test="${not empty nextSubgame}">
            <a href="scores?game=${nextSubgame.id}&display=${display}">${nextSubgame.display}</a>
            </c:when>
            <c:otherwise>
              &nbsp;
            </c:otherwise>
          </c:choose>
				</td>
			</tr>
		</table>
		<table class="center">
			<tr>
				<th style="width:40px">&nbsp;</th>
				<th style="width:200px">Name</th>
        <c:forEach var="column" items="${subgame.columns}" varStatus="loop">
          <th style="width:100px">
            <a href="scores?game=${subgame.id}&display=${display}&sort=${loop.index}">${column}</a>
          </th>
        </c:forEach>
			</tr>
      <c:forEach var="score" items="${scores}" varStatus="loop">
        <tr>
          <td class="right">${loop.index + 1}</td>
          <td class="left">${score.name}</td>
          <c:forEach var="column" items="${score.columns}">
            <td class="left">${column}</td>
          </c:forEach>
        </tr>
      </c:forEach>
		</table>
		<p class="center"><a href="index.html">Back to main index</a></p>
	</body>
</html>

