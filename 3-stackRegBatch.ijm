// Macro to perform stackReg plgin on batch of bleach-corrected TIF stacks
// Performance is unreliable - recommend skipping

parentDir = getDirectory("Select folder containing bleach-corrected tif stacks");
saveDir   = getDirectory("Now select folder to save registered tif stacks");
stackList = getFileList(parentDir);

setBatchMode(true);

// For each file in directory:
for (i=0; i<stackList.length; i++) { 
		
	// Import Stack
	open(parentDir + stackList[i]);
    stackName = getTitle();
    print("Aligning stack for file: " + stackName); 
    stackName = substring(stackName, 0, lengthOf(stackName) - 4) + "_Reg";
    
	// Align slices
	run("StackReg ", "transformation=[Rigid Body]");

	// Save File
	saveName = saveDir + stackName;
	print("Saving file: " + saveName); 
	saveAs("Tiff", saveName);
	close();
}

setBatchMode(false);




