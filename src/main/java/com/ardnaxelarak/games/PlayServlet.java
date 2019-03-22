package com.ardnaxelarak.games;

import com.ardnaxelarak.games.data.Comment;
import com.ardnaxelarak.games.data.DatastoreDao;
import com.ardnaxelarak.games.data.Game;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import java.io.IOException;
import java.util.Optional;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PlayServlet", value = "/play")
public class PlayServlet extends HttpServlet {
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

    String gameString = request.getParameter("game");

    if (gameString == null) {
      Utils.displayError(null, "Must provide game id", request, response);
      return;
    }

    ImmutableMap<String, Game> gameMap = dao.getGameMap();
    if (!gameMap.containsKey(gameString)) {
      Utils.displayError(null, "Invalid game id: " + gameString, request, response);
      return;
    }

    Game game = gameMap.get(gameString);

    request.setAttribute("game", game);
    request.setAttribute("comments", ImmutableList.<Comment>of());
    request.getRequestDispatcher("/WEB-INF/play.jsp").forward(request, response);
  }
}
