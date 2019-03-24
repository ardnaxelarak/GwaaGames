package com.ardnaxelarak.games.data;

import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import java.util.List;

public class SimpleScoreEntry {
  private String name;
  private ImmutableList<Integer> columns;

  public SimpleScoreEntry(String name, List<Integer> columns) {
    this.name = name;
    this.columns = ImmutableList.copyOf(columns);
  }

  public static SimpleScoreEntry fromScoreEntry(
      ScoreEntry entry, ImmutableMap<String, String> nameMap) {
    String name;
    if (!Strings.isNullOrEmpty(entry.getUid()) && nameMap.containsKey(entry.getUid())) {
      name = nameMap.get(entry.getUid());
    } else if (Strings.isNullOrEmpty(entry.getName())) {
      name = "Anonymous Gwaaer";
    } else {
      name = "Anonymous Gwaaer: " + entry.getName();
    }
    return new SimpleScoreEntry(name, entry.getColumns());
  }

  public String getName() {
    return name;
  }

  public ImmutableList<Integer> getColumns() {
    return columns;
  }
}

