using UnityEngine;
using System.Collections;
using System;
using System.Threading;
using LSL;
using System.Linq;

public class LSL_BCI_Input : MonoBehaviour {
	public liblsl.StreamOutlet Outlet  = null; //Unity wont recognize Outlet in the Update function unless it is declared globally
	private liblsl.StreamInlet Inlet = null;
	public int outlet_counter = 0;

	// Neil 12/07
	public void Start(){
		Debug.Log ("Creating Unity->Matlab stream");
		// Create LSL stream outlet from Unity
		if (Outlet == null) {
			liblsl.StreamInfo UnityStream = new liblsl.StreamInfo ("Unity->Matlab" + outlet_counter.ToString(), "object_info", 17, 0, liblsl.channel_format_t.cf_float32, "NEDE_position");
			Outlet = new liblsl.StreamOutlet (UnityStream);
			outlet_counter += 1;
		}
		if (Outlet != null){
			Debug.Log("LSL Stream outlet created");
		}
		else{
			Debug.Log("Error creating LSL stream outlet");
		}

		//Create LSL stream inlet in Unity
		//liblsl.StreamInfo[] results = liblsl.resolve_stream("name", "Python");
		//Create LSL stream inlet from Matlab
		Debug.Log ("About to make Matlab->Unity Inlet stream");
		liblsl.StreamInfo[] results = liblsl.resolve_stream("name", "Matlab->Unity");
		Inlet = new liblsl.StreamInlet(results[0]);
		Debug.Log("Inlet Created: " + Inlet);
	}

	// pushLSL() function pushes data to the outlet
	// Outlet is the liblsl.StreamOutlet created above
	// LSLdata is an array of floats that you want to push
	public void pushLSL(float[] LSLdata) {
		Debug.Log("About to make a push");
		Outlet.push_sample(LSLdata);
		Debug.Log("Finished making a push");
	}

	// receiveLSL() function receives data from the Inlet
	// Inlet is the liblsl.StreamInlet created above
	// sample is an array of floats that the function returns
	public float[] receiveLSL(){
		Debug.Log("About to make a pull");
		float[] sample = new float[3];
		double ts;
		//ts = Inlet.pull_sample(sample, 0.0);
		ts = Inlet.pull_sample(sample, 0.0);
		Debug.Log("Finished making a pull");
		return sample;
	}
}