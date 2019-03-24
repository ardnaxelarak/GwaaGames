package com.ardnaxelarak.games;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Predicates.not;

import com.ardnaxelarak.games.data.DatastoreDao;
import com.ardnaxelarak.games.data.ScoreEntry;
import com.ardnaxelarak.games.data.SimpleScoreEntry;
import com.ardnaxelarak.games.data.Subgame;
import com.ardnaxelarak.games.logging.LogHelper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.cloud.Timestamp;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
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
  private static final LogHelper LOG = LogHelper.getHelper(ScoreServlet.class);
  private static final BinaryOperator<ScoreEntry> MERGER =
      new BinaryOperator<ScoreEntry>() {
        @Override
        public ScoreEntry apply(ScoreEntry a, ScoreEntry b) {
          checkArgument(a.getSubgame().equals(b.getSubgame()));
          checkArgument(a.getUid().equals(b.getUid()));
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
              a.getUid(),
              minTimestamp,
              maxColumns);
        }
      };

  @Override
  public void init() throws ServletException {
    try {
      FirebaseOptions options = new FirebaseOptions.Builder()
          .setProjectId("gwaa-games")
          .setCredentials(GoogleCredentials.getApplicationDefault())
          .build();
      FirebaseApp.initializeApp(options);
    } catch (IOException e) {
      LOG.withError(e).warning("Error initializing FirebaseApp");
    }
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
      LOG.info("Missing score id");
      Utils.displayError(null, "Must provide score id", request, response);
      return;
    }

    ImmutableMap<String, Subgame> subgameMap = dao.getSubgameMap();
    if (!subgameMap.containsKey(subgameString)) {
      LOG.info("Invalid score id: %s", subgameString);
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
        LOG.withError(e).fine("Error parsing sort order %s as integer", sortString);
        // oh well, we tried
      }
    }

    ImmutableList<ScoreEntry> scores = dao.getScores(subgame.getId(), sort);

    String display = request.getParameter("display");
    if (display == null) {
      display = "topten";
    }

    FirebaseAuth auth = FirebaseAuth.getInstance();
    HashMap<String, String> nameMap = new HashMap<>();
    for (ScoreEntry se : scores) {
      if (Strings.isNullOrEmpty(se.getUid())) {
        continue;
      }
      if (nameMap.containsKey(se.getUid())) {
        continue;
      }
      try {
        nameMap.put(se.getUid(), auth.getUser(se.getUid()).getDisplayName());
      } catch (FirebaseAuthException e) {
        LOG.withError(e).warning("Error loading display name for uid %s", se.getUid());
      }
    }
    ImmutableMap<String, String> immutableNameMap = ImmutableMap.copyOf(nameMap);

    ImmutableList<SimpleScoreEntry> scoreList;

    if (display.toLowerCase().equals("all")) {
      scoreList = scores.stream()
          .map(score -> SimpleScoreEntry.fromScoreEntry(score, immutableNameMap))
          .collect(ImmutableList.toImmutableList());
    } else if (display.toLowerCase().equals("each")) {
      ImmutableMap<String, ScoreEntry> scoreMap =
          scores.stream()
              .collect(ImmutableMap.toImmutableMap(
                    ScoreEntry::getUid, Function.identity(), MERGER));
      scoreList = scoreMap.values().stream()
          .sorted(getComparator(sort))
          .map(score -> SimpleScoreEntry.fromScoreEntry(score, immutableNameMap))
          .collect(ImmutableList.toImmutableList());
    } else { // default to top ten
      scoreList = scores.stream()
          .limit(10)
          .map(score -> SimpleScoreEntry.fromScoreEntry(score, immutableNameMap))
          .collect(ImmutableList.toImmutableList());
    }

    request.setAttribute(
        "prevSubgame",
        subgameMap.values().stream()
            .filter(subgameItem -> subgameItem.getIndex() == subgame.getIndex() - 1)
            .findAny()
            .orElse(null));
    request.setAttribute(
        "nextSubgame",
        subgameMap.values().stream()
            .filter(subgameItem -> subgameItem.getIndex() == subgame.getIndex() + 1)
            .findAny()
            .orElse(null));

    request.setAttribute("subgame", subgame);
    request.setAttribute("scores", scoreList);
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
    String token = request.getParameter("token");
    String uid = null;
    if (!Strings.isNullOrEmpty(token)) {
      try {
        FirebaseAuth auth = FirebaseAuth.getInstance();
        FirebaseToken decodedToken = auth.verifyIdToken(token);
        uid = decodedToken.getUid();
      } catch (FirebaseAuthException e) {
        LOG.withError(e).warning("Error decoding auth token");
      }
    }

    List<Integer> columnList = new ArrayList<>();
    String current;
    for (int i = 0; (current = request.getParameter("column" + i)) != null; i++) {
      try {
        columnList.add(Integer.parseInt(current));
      } catch (NumberFormatException e) {
        Utils.displayError(null, "Invalid integer: " + current, request, response);
        LOG.withError(e).warning("Error parsing %s for column %d", current, i);
        return;
      }
    }

    if (subgameString == null) {
      Utils.displayError(null, "Must provide score id", request, response);
      LOG.warning("No subgame specified");
      return;
    }

    ImmutableMap<String, Subgame> subgameMap = dao.getSubgameMap();
    if (!subgameMap.containsKey(subgameString)) {
      Utils.displayError(null, "Invalid score id: " + subgameString, request, response);
      LOG.warning("Invalid subgame id '$s'", subgameString);
      return;
    }
    Subgame subgame = subgameMap.get(subgameString);

    if (subgame.getColumns().length != columnList.size()) {
      Utils.displayError(null, "Incorrect number of columns.", request, response);
      LOG.warning(
          "Expected %d columns; found %d",
          subgame.getColumns().length,
          columnList.size());
      return;
    }

    ScoreEntry entry = new ScoreEntry(subgame.getId(), name, uid, Timestamp.now(), columnList);

    dao.writeScoreEntry(entry);

    response.getWriter().println("Success");
  }

  private static Comparator<ScoreEntry> getComparator(int sortIndex) {
    return Comparator.<ScoreEntry>comparingInt(entry -> entry.getColumns().get(sortIndex))
        .reversed()
        .thenComparing(Comparator.comparing(ScoreEntry::getTimestamp));
  }
}

