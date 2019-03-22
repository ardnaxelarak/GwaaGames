package com.ardnaxelarak.games;

import com.ardnaxelarak.games.data.DatastoreDao;
import com.ardnaxelarak.games.data.Subgame;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import java.io.IOException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ScoreServlet", value = "/scores")
public class ScoreServlet extends HttpServlet {
  @Override
  public void init() throws ServletException {
    if (getServletContext().getAttribute("dao") == null) {
      DatastoreDao dao = new DatastoreDao();
      getServletContext().setAttribute("dao", dao);
    }
  }

  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {
    DatastoreDao dao = (DatastoreDao) getServletContext().getAttribute("dao");

    String subgameString = request.getParameter("game");

    if (subgameString == null) {
      Utils.displayError(null, "Must provide score id", request, response);
      return;
    }

    ImmutableMap<String, Subgame> subgameMap = dao.getSubgameMap();
    if (!subgameMap.containsKey(subgameString)) {
      Utils.displayError(null, "Invalid score id: " + subgameString, request, response);
      return;
    }

    Subgame subgame = subgameMap.get(subgameString);

    request.setAttribute("subgame", subgame);
    request.setAttribute("scores", dao.getScores(subgame.getId()));
    request.setAttribute("display", request.getParameter("display"));
    request.getRequestDispatcher("/WEB-INF/scores.jsp").forward(request, response);
  }
}

