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

import android.net.Uri;

import tcking.github.com.giraffeplayer2.VideoView;

public class videoInput extends WearableActivity {


    private static final int CONTENT_VIEW_ID = 10101010;
    private EditText editText;
    private String defaultUri;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState == null) {
            Bundle extras = getIntent().getExtras();
            if(extras == null) {
                defaultUri= "";
            } else {
                defaultUri= extras.getString("uri");
            }
        } else {
            defaultUri= (String) savedInstanceState.getSerializable("txt");
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
        
                final VideoView videoView = new VideoView(this);
        frame.addView(videoView);
        String vidAddress="https://r4---sn-v2u0n-coxl.googlevideo.com/videoplayback?lmt=1539995067124275&ipbits=0&itag=18&fvip=4&key=yt6&mime=video%2Fmp4&expire=1543688732&mn=sn-v2u0n-coxl%2Csn-v2u0n-ntqk&mm=31%2C29&c=WEB&ms=au%2Crdu&signature=837F37E00C6CD8AED302E0E776685FC523E576D0.4877EF37876EEB34543A1B319A940FC81DEF65C4&mv=m&mt=1543667049&ip=49.197.3.11&ei=vH0CXKniB9SKgQP49Z6gDA&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cexpire&txp=5531432&id=o-ALEn1uNkD5oXk79c7nhQDjtZQFf2nWc9wZm84OJqdKVp&clen=24839204&requiressl=yes&gir=yes&pl=17&initcwndbps=893750&dur=274.622&ratebypass=yes&source=youtube";
       // defaultUri="https://www.youtube.com/watch?v=0LHxvxdRnYc";
        Uri uri=Uri.parse(defaultUri);
     
        //editText = (EditText) findViewById(android.R.id.kb_input);
        Button btnTag = new Button(this);
        btnTag.setText("Done");
        btnTag.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // your handler code here
                   // we are calling here activity's method
                    finish();
                
            }
        });

        //add button to the layout
        frame.addView(btnTag);
        // Enables Always-on
        
        videoView.setVideoPath(defaultUri).getPlayer().start();
        setAmbientEnabled();
    }
}