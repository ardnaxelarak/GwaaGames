package com.ardnaxelarak.games.data;

import java.util.Arrays;

public class Subgame {
  private String id;
  private int index;
  private String game;
  private String display;
  private String shortName;
  private int defaultSort;
  private String[] columns;

  public Subgame(
      String id,
      int index,
      String game,
      String display,
      String shortName,
      int defaultSort,
      String... columns) {
    this.id = id;
    this.index = index;
    this.game = game;
    this.display = display;
    this.shortName = shortName;
    this.defaultSort = defaultSort;
    this.columns = Arrays.copyOf(columns, columns.length);
  }

  public String getId() {
    return id;
  }

  public int getIndex() {
    return index;
  }

  public String getGame() {
    return game;
  }

  public String getDisplay() {
    return display;
  }

  public String getShortName() {
    return shortName;
  }

  public int getDefaultSort() {
    return defaultSort;
  }

  public String[] getColumns() {
    return Arrays.copyOf(columns, columns.length);
  }
}
