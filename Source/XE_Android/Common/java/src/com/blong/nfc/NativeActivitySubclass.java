package com.blong.nfc;

import android.os.Bundle;
import android.util.Log;
import android.content.Intent;

import android.nfc.NfcAdapter;
import android.content.Intent;
import android.app.PendingIntent;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

public class NativeActivitySubclass extends com.embarcadero.firemonkey.FMXNativeActivity {

	static final String TAG = "NativeActivitySubclass";
	
	private NfcAdapter nfcAdapter;
	private PendingIntent pendingIntent;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//Custom initialization
		Log.d(TAG, "onCreate");
		nfcAdapter = NfcAdapter.getDefaultAdapter(this);
        Intent intent = new Intent(this, getClass());
        pendingIntent = PendingIntent.getActivity(this, 0,
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);		
	}

	public native void onNewIntentNative(Intent NewIntent);

	@Override
	protected void onNewIntent(Intent intent)
    {
		super.onNewIntent(intent);
		Log.d(TAG, "onNewIntent(" + (intent != null ? intent : "(null)") + ")");
		onNewIntentNative(intent);
	}
	
	@Override
    public void onPause()
    {
		Log.d(TAG, "onPause");
        super.onPause();
		disableForegroundDispatch();
    }

	@Override
    public void onResume()
    {
		Log.d(TAG, "onResume");
        super.onResume();
		enableForegroundDispatch(pendingIntent);
    }
  
	public void enableForegroundDispatch(PendingIntent pendingIntent)
	{
		Log.d(TAG, "Enabling NFC foreground dispatch");
		nfcAdapter.enableForegroundDispatch(this, pendingIntent, null, null);
	}
	
	public void disableForegroundDispatch()
	{
		Log.d(TAG, "Disabling NFC foreground dispatch");
		nfcAdapter.disableForegroundDispatch(this);
	}
	
	public void showDialog(final String title, final String msg)
	{
		Log.d(TAG, "Displaying dialog");
		runOnUiThread(new Runnable() {
			public void run() {
				AlertDialog.Builder builder = new AlertDialog.Builder(NativeActivitySubclass.this);
				builder.setMessage(msg).
                        setTitle(title).
                        setCancelable(true).
                        setPositiveButton("OK", new OnClickListener(){
						public void onClick(DialogInterface dialog, int which)
						{
							dialog.dismiss();
						}
			      }).show();
			}
		});
	}
}
