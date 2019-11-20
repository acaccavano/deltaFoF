// Macro to calculate residuals, defined as Sum[[(F(t)-Ave(F(t))/Ave(F(t))]^2]
// Output is a single TIF file for each file, highlighting the most active regions across the time series

parentDir = getDirectory("Select folder containing bleach-corrected tif stacks");
saveDir   = getDirectory("Now select folder to save (dF/F)^2 residual tif images");
stackList = getFileList(parentDir);

setBatchMode(true);

// For each file in directory:
for (i=0; i<stackList.length; i++) { 
	
	// Import Stack
	open(parentDir + stackList[i]);
    stackName = getTitle();
    print("Computing (dF/F)^2 residual for file: " + stackName); 
    resImage = substring(stackName, 0, lengthOf(stackName) - 4) + "_Residual";
    
	// Apply Gaussian filter to time series
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma=2 stack");
	filtStack = getTitle();
	
	diffImage = "F-Fave";
	aveImage  = "Fave";
	divImage  = "(F-Fave)/Fave";
	multImage = "[(F-Fave)/Fave]^2";
	
	// Calculate ave intensity from blurred image
	selectWindow(filtStack);
	nFrames = nSlices;
	run("Z Project...", "projection=[Average Intensity]");
	rename(aveImage);

	for (j=1; j<=nFrames; j++) {
		selectWindow(filtStack);
		setSlice(j);
		imageCalculator("Subtract create 32-bit", filtStack, aveImage);
		rename(diffImage);
		imageCalculator("Divide create 32-bit", diffImage, aveImage);
		rename(divImage);
		imageCalculator("Multiply create 32-bit", divImage, divImage);
		rename(multImage);
	
		if (j==1) {
			rename(resImage);
		} else {
			imageCalculator("Add create 32-bit", resImage, multImage);
			newResImage = getTitle();
			selectWindow(multImage);
			close();
			selectWindow(resImage);
			close();
			selectWindow(newResImage);
			rename(resImage);
		}
		selectWindow(divImage);
		close();
		selectWindow(diffImage);
		close();
	}
	selectWindow(filtStack);
	close();
	selectWindow(aveImage);
	close();
	selectWindow(resImage);
	run("Enhance Contrast", "saturated=0.35");
	
	// Save File
	saveName = saveDir + resImage;
	print("Saving file: " + saveName); 
	saveAs("Tiff", saveName);
	close();

}

setBatchMode(false);
waitForUser("(dF/F)^2 residual macro finished for folder " + parentDir);
