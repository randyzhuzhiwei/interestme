//package edu.jcu.au.interestme.watch;
package com.example.interestmemobileapp;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import java.util.ArrayList;
import java.util.Locale;


import android.os.Bundle;
import android.support.wearable.activity.WearableActivity;
import android.widget.EditText;
import android.widget.Button;

import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class keyboardInput extends WearableActivity {


    private static final int CONTENT_VIEW_ID = 10101010;
    private EditText editText;
    private String defaultTxt;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState == null) {
            Bundle extras = getIntent().getExtras();
            if(extras == null) {
                defaultTxt= "";
            } else {
                defaultTxt= extras.getString("txt");
            }
        } else {
            defaultTxt= (String) savedInstanceState.getSerializable("txt");
        }

        //  RelativeLayout rl=new RelativeLayout(this);
        //   setContentView(rl);
        LinearLayout frame = new LinearLayout(this);

        frame.setLayoutParams(new LinearLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        frame.setOrientation(LinearLayout.VERTICAL);

        //frame.setBackgroundColor(0xff000000);

        frame.setId(CONTENT_VIEW_ID);
        setContentView(frame, new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        final EditText textbox = new EditText(this);
        textbox.setSingleLine(false);
        textbox.setGravity(Gravity.CENTER);
        textbox.setImeOptions(EditorInfo.IME_FLAG_NO_ENTER_ACTION);
        textbox.setText(defaultTxt);
        textbox.setPaddingRelative(50,20,50,20);

        frame.addView(textbox);
        //editText = (EditText) findViewById(android.R.id.kb_input);
        Button btnTag = new Button(this);
        btnTag.setText("Done");
        btnTag.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // your handler code here
                MainActivity activity = MainActivity.instance;

                if (activity != null) {
                    // we are calling here activity's method
                    activity.textInputComplete(textbox.getText().toString());
                    finish();
                }
            }
        });

        //add button to the layout
        frame.addView(btnTag);
        // Enables Always-on
        setAmbientEnabled();
    }
}