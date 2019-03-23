package com.ardnaxelarak.games.data;

import com.google.appengine.api.utils.SystemProperty;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.cloud.datastore.BaseEntity;
import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.FullEntity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.IncompleteKey;
import com.google.cloud.datastore.PathElement;
import com.google.cloud.datastore.Query;
import com.google.cloud.datastore.QueryResults;
import com.google.cloud.datastore.StringValue;
import com.google.cloud.datastore.StructuredQuery.OrderBy;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.cloud.datastore.Value;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Optional;

public class DatastoreDao {
  private Datastore datastore;
  private KeyFactory gameKeyFactory;
  private KeyFactory subgameKeyFactory;
  private ImmutableMap<String, Game> gameMap;
  private ImmutableMap<String, Subgame> subgameMap;

  public DatastoreDao() {
    if (SystemProperty.environment.value() == SystemProperty.Environment.Value.Production) {
      datastore =
          DatastoreOptions.newBuilder()
              .setNamespace("Production")
              .build()
              .getService();
    } else {
      datastore =
          DatastoreOptions.newBuilder()
              .setNamespace("Development")
              .build()
              .getService();
    }
    gameKeyFactory = datastore.newKeyFactory().setKind("Game");
    subgameKeyFactory = datastore.newKeyFactory().setKind("Subgame");
  }

  public ImmutableMap<String, Game> getGameMap() {
    if (gameMap == null) {
      populateGameMap();
    }
    return gameMap;
  }

  public void populateGameMap() {
    Query<Entity> query = Query.newEntityQueryBuilder()
        .setKind("Game")
        .setOrderBy(OrderBy.asc("display"))
        .build();

    QueryResults<Entity> qResult = datastore.run(query);

    ImmutableMap.Builder<String, Game> map = ImmutableMap.builder();

    while (qResult.hasNext()) {
      Entity entity = qResult.next();
      map.put(
          entity.getKey().getName(),
          new Game(
              entity.getKey().getName(),
              entity.getString("sketch"),
              entity.getString("display"),
              entity.getString("description")));
    }

    gameMap = map.build();
  }

  public ImmutableMap<String, Subgame> getSubgameMap() {
    if (subgameMap == null) {
      populateSubgameMap();
    }
    return subgameMap;
  }

  public void populateSubgameMap() {
    Query<Entity> query = Query.newEntityQueryBuilder()
        .setKind("Subgame")
        .setOrderBy(OrderBy.asc("index"))
        .build();

    QueryResults<Entity> qResult = datastore.run(query);

    ImmutableMap.Builder<String, Subgame> map = ImmutableMap.builder();

    while (qResult.hasNext()) {
      Entity entity = qResult.next();
      map.put(
          entity.getKey().getName(),
          new Subgame(
              entity.getKey().getName(),
              (int) entity.getLong("index"),
              entity.getString("game"),
              entity.getString("display"),
              entity.getString("shortName"),
              (int) entity.getLong("defaultSort"),
              entity.<StringValue>getList("columns").stream()
                  .map(StringValue::get)
                  .toArray(String[]::new)));
    }

    subgameMap = map.build();
  }

  public ImmutableList<ScoreEntry> getScores(String subgame, int sort) {
    Query<Entity> query = Query.newEntityQueryBuilder()
        .setKind("Score")
        .setFilter(PropertyFilter.hasAncestor(subgameKeyFactory.newKey(subgame)))
        .setOrderBy(OrderBy.desc("column" + sort), OrderBy.asc("time"))
        .build();

    QueryResults<Entity> qResult = datastore.run(query);

    ImmutableList.Builder<ScoreEntry> list = ImmutableList.builder();

    while (qResult.hasNext()) {
      Entity entity = qResult.next();
      List<Integer> columnList = new ArrayList<>();
      for (int i = 0; entity.contains("column" + i); i++) {
        columnList.add((int) entity.getLong("column" + i));
      }
      list.add(
          new ScoreEntry(
              subgame,
              entity.getString("name"),
              entity.getTimestamp("time"),
              columnList));
    }
    
    return list.build();
  }

  public void writeScoreEntry(ScoreEntry entry) {
    IncompleteKey key =
        datastore.newKeyFactory()
            .setKind("Score")
            .addAncestor(PathElement.of("Subgame", entry.getSubgame()))
            .newKey();
    FullEntity.Builder entity =
        FullEntity.newBuilder(key)
            .set("name", entry.getName())
            .set("time", entry.getTimestamp());
    int index = 0;
    for (int col : entry.getColumns()) {
      entity.set("column" + index, col);
      index++;
    }

    datastore.put(entity.build());
  }
}
