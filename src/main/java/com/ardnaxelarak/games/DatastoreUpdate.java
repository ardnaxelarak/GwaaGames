package com.ardnaxelarak.games;

import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.EntityValue;
import com.google.cloud.datastore.FullEntity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.IncompleteKey;
import com.google.cloud.datastore.ListValue;
import com.google.cloud.datastore.LongValue;
import com.google.cloud.datastore.StringValue;
import com.google.cloud.datastore.Value;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonPrimitive;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DatastoreUpdate {
  private Datastore datastore;
  private KeyFactory keyFactory;

  public DatastoreUpdate(String namespace, String kind) {
    datastore =
        DatastoreOptions.newBuilder()
            .setNamespace(namespace)
            .build()
            .getService();
    keyFactory = datastore.newKeyFactory().setKind(kind);
  }

  public void insertValues(JsonObject entities) {
    for (Map.Entry<String, JsonElement> entry : entities.entrySet()) {
      String keyStr = entry.getKey();
      Key key = keyFactory.newKey(keyStr);
      Entity.Builder entity = Entity.newBuilder(key);
      for (Map.Entry<String, JsonElement> entry2 : entry.getValue().getAsJsonObject().entrySet()) {
        entity.set(entry2.getKey(), getValue(entry2.getValue()));
      }

      datastore.put(entity.build());
    }
  }

  private FullEntity<IncompleteKey> getObject(JsonObject value) {
    FullEntity.Builder<IncompleteKey> builder = FullEntity.newBuilder();
    for (Map.Entry<String, JsonElement> entry : value.entrySet()) {
      String key = entry.getKey();
      JsonElement elm = entry.getValue();
      builder.set(key, getValue(elm));
    }
    return builder.build();
  }

  private List<Value<?>> getList(JsonArray value) {
    List<Value<?>> list = new ArrayList<>();
    for (JsonElement elm : value) {
      list.add(getValue(elm));
    }
    return list;
  }

  private Value<?> getValue(JsonElement value) {
    if (value.isJsonPrimitive()) {
      JsonPrimitive prim = value.getAsJsonPrimitive();
      if (prim.isNumber()) {
        return LongValue.of(prim.getAsLong());
      } else {
        return StringValue.of(prim.getAsString());
      }
    } else if (value.isJsonArray()) {
      return ListValue.of(getList(value.getAsJsonArray()));
    } else if (value.isJsonObject()) {
      return EntityValue.of(getObject(value.getAsJsonObject()));
    } else {
      throw new IllegalArgumentException(
          "Unrecognized JSON element: " + value);
    }
  }

  public static void main(String[] args) throws Exception {
    if (args.length != 3) {
      System.out.println("Usage: DatastoreUpdate [namespace] [kind] [jsonFile]");
      return;
    }
    String namespace = args[0];
    String kind = args[1];
    DatastoreUpdate du = new DatastoreUpdate(namespace, kind);
    String jsonFile = args[2];

    FileReader reader = new FileReader(jsonFile);
    JsonElement tree = new JsonParser().parse(reader);
    du.insertValues(tree.getAsJsonObject());
  }
}
