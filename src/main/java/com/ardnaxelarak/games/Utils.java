package com.ardnaxelarak.games;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public final class Utils {
  private Utils() {}

  public static void displayError(
      String title,
      String body,
      HttpServletRequest request,
      HttpServletResponse response) throws IOException, ServletException {
    if (title != null) {
      request.setAttribute("title", title);
    }
    if (body != null) {
      request.setAttribute("body", body);
    }
    request.getRequestDispatcher("/WEB-INF/error.jsp").forward(request, response);
    return;
  }
}
