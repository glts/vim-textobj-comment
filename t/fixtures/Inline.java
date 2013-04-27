package com.example.inline.core;

import /* inline comment */ com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import /*inline*/ com.google.gson.JsonParser; // end-of-line comment

public class Inline { /* paired end-of-line comment */

    private Gson gson;
    private JsonParser	/* many /* start /* leaders */ parser;

    // a full-line comment
    public Inline() {

        GsonBuilder/* invalid inline comment */builder = new GsonBuilder()
                .registerTypeAdapter(long.class, new LongDeserializer());

        builder;//.setPrettyPrinting(//TODO);

        Gson /* comment */ /*  */gson /* com//ment */ = builder.create();

        parser = new JsonParser();

    } // another end-of-line comment   

}
