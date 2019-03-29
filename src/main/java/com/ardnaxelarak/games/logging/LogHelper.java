package com.ardnaxelarak.games.logging;

import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

public class LogHelper {
  private final Logger logger;
  private final Optional<Throwable> throwable;

  private LogHelper(Logger logger, Optional<Throwable> throwable) {
    this.logger = logger;
    this.throwable = throwable;
  }

  public static LogHelper getHelper(Class<?> clazz) {
    return new LogHelper(Logger.getLogger(clazz.getName()), Optional.empty());
  }

  public LogHelper withError(Throwable t) {
    return new LogHelper(logger, Optional.of(t));
  }

  public void severe(String message, Object... params) {
    log(Level.SEVERE, message, params);
  }

  public void warning(String message, Object... params) {
    log(Level.WARNING, message, params);
  }

  public void info(String message, Object... params) {
    log(Level.INFO, message, params);
  }

  public void config(String message, Object... params) {
    log(Level.CONFIG, message, params);
  }

  public void fine(String message, Object... params) {
    log(Level.FINE, message, params);
  }

  public void finer(String message, Object... params) {
    log(Level.FINER, message, params);
  }

  public void finest(String message, Object... params) {
    log(Level.FINEST, message, params);
  }

  private void log(Level level, String message, Object[] params) {
    if (throwable.isPresent()) {
      logger.log(level, String.format(message, params), throwable.get());
    } else {
      logger.log(level, String.format(message, params));
    }
  }
}
