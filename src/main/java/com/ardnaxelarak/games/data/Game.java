package com.ardnaxelarak.games.data;

public class Game {
  private String id;
  private String sketch;
  private String display;
  private String description;

  public Game(String id, String sketch, String display, String description) {
    this.id = id;
    this.sketch = sketch;
    this.display = display;
    this.description = description;
  }

  public String getSketch() {
    return sketch;
  }

  public String getId() {
    return id;
  }

  public String getDisplay() {
    return display;
  }

  public String getDescription() {
    return description;
  }
}
