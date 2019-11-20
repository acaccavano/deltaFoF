// Macro to perform bleach correction on batch of TIF stacks using a two-stage exponential bleach correction (requires CorrectBleach_-2.0.3.jar)

parentDir = getDirectory("Select folder containing preprocessed tif stacks");
saveDir   = getDirectory("Now select folder to save bleach-corrected tif stacks");
stackList = getFileList(parentDir);

endFrame1 = 40; // end frame to perform 1st exponential bleach correction. for 512x512 with Cum=4, 20 works well, likely will need to modify for other resolutions
endFrame2 = 1000; // end frame to perform 2nd exponential bleach correction. for 512x512 with Cum=4, 80 works well, likely will need to modify for other resolutions

setBatchMode(true);

// For each file in directory:
for (i=0; i<stackList.length; i++) { 
		
	// Import Stack
	open(parentDir + stackList[i]);
    importName = getTitle();
    exportName = substring(importName, 0, lengthOf(importName) - 4) + "_BC";

	// Apply photobleaching correction - three iterations
	print("Running photobleach correction for file: " + importName);

	// 1st iteration:
	endFrame = minOf(endFrame1, nSlices);
	IJ.redirectErrorMessages();
	run("Bleach Correction", "correction=[Exponential Fit] start=1 end=" + endFrame);
	bleach1Stack = getTitle();
	selectWindow(importName);
	close();
	selectWindow("y = a*exp(-bx) + c");
	close();
	selectWindow(bleach1Stack);

	// 2nd iteration:
	endFrame = minOf(endFrame2, nSlices);
	IJ.redirectErrorMessages();
	run("Bleach Correction", "correction=[Exponential Fit] start=1 end=" + endFrame);
	bleach2Stack = getTitle();
	selectWindow(bleach1Stack);
	close();
	selectWindow("y = a*exp(-bx) + c");
	close();
	selectWindow(bleach2Stack);

//	// 3rd iteration:
//	IJ.redirectErrorMessages();
//	run("Bleach Correction", "correction=[Exponential Fit]");
//	bleach3Stack = getTitle();
//	selectWindow(bleach2Stack);
//	close();
//	selectWindow("y = a*exp(-bx) + c");
//	close();
//	selectWindow(bleach3Stack);
	rename(exportName);
		
	// Save File
	saveName = saveDir + exportName + ".tif";
	print("Saving file: " + saveName); 
	saveAs("Tiff", saveName);
	close();

}

setBatchMode(false);
waitForUser("Bleach Correction macro finished for folder " + parentDir);