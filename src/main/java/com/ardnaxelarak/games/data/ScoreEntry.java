package com.ardnaxelarak.games.data;

import com.google.common.collect.ImmutableList;
import com.google.cloud.Timestamp;
import java.util.List;

public class ScoreEntry {
  private String subgame;
  private String name;
  private String uid;
  private Timestamp timestamp;
  private ImmutableList<Integer> columns;

  public ScoreEntry(
      String subgame,
      String name,
      String uid,
      Timestamp timestamp,
      List<Integer> columns) {
    this.subgame = subgame;
    this.name = name;
    this.uid = uid;
    this.timestamp = timestamp;
    this.columns = ImmutableList.copyOf(columns);
  }

  public String getSubgame() {
    return subgame;
  }

  public String getName() {
    return name;
  }

  public String getUid() {
    return uid;
  }

  public Timestamp getTimestamp() {
    return timestamp;
  }

  public ImmutableList<Integer> getColumns() {
    return columns;
  }
}
