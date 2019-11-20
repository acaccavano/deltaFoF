// Macro to import batch of folders of raw TIF images with Bio-Formats plugin and save as one TIF stack

parentDir   = getDirectory("Select folder containing raw time series folders");
saveDir     = getDirectory("Now select folder to save preprocessed stacks");
tSeriesList = getFileList(parentDir);

setBatchMode(true);

// For each folder in directory:
for (i=0; i<tSeriesList.length; i++) { 
	if (endsWith(tSeriesList[i], "/")) { 
		
		// Import tSeries with Bio-Formats
		tSeriesList[i] = substring(tSeriesList[i], 0, lengthOf(tSeriesList[i]) - 1);
		tSeriesName = tSeriesList[i];
		tSeriesList[i] = tSeriesList[i] + File.separator;
		print("Opening file: " + parentDir + tSeriesList[i]); 
		imageList = getFileList(parentDir + tSeriesList[i]);
		firstImage = parentDir + tSeriesList[i] + imageList[0];
    	run("Bio-Formats Importer", "open=[" + firstImage + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

    	rawStack = getTitle();
    	stackName = tSeriesName + "_Stack";

		// Enhance contrast
		run("Enhance Contrast", "saturated=0.35");

		// Save File
		saveName = saveDir + stackName + ".tif";
		print("Saving file: " + saveName); 
		saveAs("Tiff", saveName);
		close();

	}
}

setBatchMode(false);
waitForUser("Preprocess macro finished for folder " + parentDir);