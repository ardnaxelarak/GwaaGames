package com.ardnaxelarak.games;

import static com.google.common.base.Preconditions.checkArgument;

import com.ardnaxelarak.games.data.DatastoreDao;
import com.ardnaxelarak.games.data.ScoreEntry;
import com.ardnaxelarak.games.data.Subgame;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.cloud.Timestamp;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.function.BinaryOperator;
import java.util.function.Function;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ScoreServlet", value = "/scores")
public class ScoreServlet extends HttpServlet {
  private static final BinaryOperator<ScoreEntry> MERGER =
      new BinaryOperator<ScoreEntry>() {
        @Override
        public ScoreEntry apply(ScoreEntry a, ScoreEntry b) {
          checkArgument(a.getSubgame().equals(b.getSubgame()));
          checkArgument(a.getName().equals(b.getName()));
          checkArgument(a.getColumns().size() == b.getColumns().size());

          Timestamp minTimestamp =
              a.getTimestamp().compareTo(b.getTimestamp()) < 0 ?
                  a.getTimestamp() : b.getTimestamp();

          List<Integer> maxColumns = new ArrayList<>();
          for (int i = 0; i < a.getColumns().size(); i++) {
            maxColumns.add(Math.max(a.getColumns().get(i), b.getColumns().get(i)));
          }

          return new ScoreEntry(
              a.getSubgame(),
              a.getName(),
              minTimestamp,
              maxColumns);
        }
      };

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

    String sortString = request.getParameter("sort");
    int requestedSort = -1;
    int sort = subgame.getDefaultSort();
    if (sortString != null) {
      try {
        requestedSort = Integer.parseInt(sortString);
        if (requestedSort >= 0 && requestedSort < subgame.getColumns().length) {
          sort = requestedSort;
        } else {
          requestedSort = -1;
        }
      } catch (NumberFormatException e) {
        // oh well, we tried
      }
    }

    ImmutableList<ScoreEntry> scores = dao.getScores(subgame.getId(), sort);

    String display = request.getParameter("display");
    if (display == null) {
      display = "topten";
    }

    if (display.toLowerCase().equals("all")) {
      // we already fetched everything, nothing to do
    } else if (display.toLowerCase().equals("each")) {
      ImmutableMap<String, ScoreEntry> scoreMap =
          scores.stream()
              .collect(ImmutableMap.toImmutableMap(
                    ScoreEntry::getName, Function.identity(), MERGER));
      scores = scoreMap.values().stream()
          .sorted(getComparator(sort))
          .collect(ImmutableList.toImmutableList());
    } else { // default to top ten
      scores = scores.stream().limit(10).collect(ImmutableList.toImmutableList());
    }

    request.setAttribute("subgame", subgame);
    request.setAttribute("scores", scores);
    request.setAttribute("display", request.getParameter("display"));
    if (requestedSort >= 0) {
      request.setAttribute("sortlink", "&sort=" + requestedSort);
    }
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

  private static Comparator<ScoreEntry> getComparator(int sortIndex) {
    return Comparator.<ScoreEntry>comparingInt(entry -> entry.getColumns().get(sortIndex))
        .reversed()
        .thenComparing(Comparator.comparing(ScoreEntry::getTimestamp));
  }
}

