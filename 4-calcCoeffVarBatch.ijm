// Macro to calculate Coefficient of Variation (CV), defined as Var(Img)/(Ave(Img)^2) = 1/nFrames * Sum[[(Img-Ave(Img)/Ave(Img)]^2]
// Output is a single TIF file for each file, highlighting the most active regions across the time series

parentDir = getDirectory("Select folder containing bleach-corrected tif stacks");
saveDir   = getDirectory("Now select folder to save (dF/F)^2 coefficient of variation (CV) tif images");
stackList = getFileList(parentDir);

setBatchMode(true);

// For each file in directory:
for (i=0; i<stackList.length; i++) { 
	
	// Import Stack
	open(parentDir + stackList[i]);
    stackName = getTitle();
    print("Computing (dF/F)^2 Coeff. of Var. for file: " + stackName); 
    cvImage = substring(stackName, 0, lengthOf(stackName) - 4) + "_CV";
    
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
			rename(cvImage);
		} else {
			imageCalculator("Add create 32-bit", cvImage, multImage);
			newCVImage = getTitle();
			selectWindow(multImage);
			close();
			selectWindow(cvImage);
			close();
			selectWindow(newCVImage);
			rename(cvImage);
		}
		selectWindow(divImage);
		close();
		selectWindow(diffImage);
		close();
	}
	selectWindow(stackName);
	close();
	selectWindow(filtStack);
	close();
	selectWindow(aveImage);
	close();
	selectWindow(cvImage);
	run("Divide...", "value=" + nFrames);
	run("Enhance Contrast", "saturated=0.35");
	
	// Save File
	saveName = saveDir + cvImage;
	print("Saving file: " + saveName); 
	saveAs("Tiff", saveName);
	close();

}

setBatchMode(false);
waitForUser("(dF/F)^2 CoeffVar macro finished for folder " + parentDir);
