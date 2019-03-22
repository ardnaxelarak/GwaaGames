package com.ardnaxelarak.games;

import com.ardnaxelarak.games.data.DatastoreDao;
import com.ardnaxelarak.games.data.ScoreEntry;
import com.ardnaxelarak.games.data.Subgame;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.cloud.Timestamp;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
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

  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {
    DatastoreDao dao = (DatastoreDao) getServletContext().getAttribute("dao");

    String subgameString = request.getParameter("game");
    String name = request.getParameter("name");

    List<Integer> columnList = new ArrayList<>();
    String current;
    for (int i = 0; (current = request.getParameter("column" + i)) != null; i++) {
      try {
        columnList.add(Integer.parseInt(current));
      } catch (NumberFormatException e) {
        Utils.displayError(null, "Invalid integer: " + current, request, response);
        return;
      }
    }

    if (subgameString == null) {
      Utils.displayError(null, "Must provide score id", request, response);
      return;
    }

    if (name == null) {
      Utils.displayError(null, "Must provide name", request, response);
      return;
    }

    ImmutableMap<String, Subgame> subgameMap = dao.getSubgameMap();
    if (!subgameMap.containsKey(subgameString)) {
      Utils.displayError(null, "Invalid score id: " + subgameString, request, response);
      return;
    }
    Subgame subgame = subgameMap.get(subgameString);

    if (subgame.getColumns().length != columnList.size()) {
      Utils.displayError(null, "Incorrect number of columns.", request, response);
      return;
    }

    ScoreEntry entry = new ScoreEntry(subgame.getId(), name, Timestamp.now(), columnList);

    dao.writeScoreEntry(entry);

    response.getWriter().println("Success");
  }
}

