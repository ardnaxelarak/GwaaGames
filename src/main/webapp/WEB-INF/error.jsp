<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
  <title>Gwaa Games -- ERROR</title>
</head>
<body>
  <c:if test="${not empty title}">
    <h1>${title}</h1>
  </c:if>
  <c:if test="${not empty body}">
    ${body}
  </c:if>
</body>
</html>
