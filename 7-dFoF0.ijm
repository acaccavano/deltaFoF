// Macro to calculate DeltaF/F0 for a set of ROIs
// F0 defined as the average of the lowest nF0Points frames (default = 10)

nF0Points = 10;
rawStack = getTitle();

// Subtract background (minimum intensity across stack)
// Make min and max measurements of entire image with square ROI
makeRectangle(0, 0, getWidth(), getHeight());
roiManager("Add");
roiManager("Select", roiManager("count")-1);
run("Set Measurements...", "min redirect=None decimal=6");
roiManager("Multi Measure");
roiManager("Delete");

// Set Fb as min pixel across entire stack
Fb = 100000;
for (row=0; row<nResults; row++)
	Fb = minOf(Fb, getResult("Min1", row));

// Measure average intensity over time and export to results window
run("Set Measurements...", "mean redirect=None decimal=6");
roiManager("Multi Measure");

// Calculate F0
headings = split(String.getResultsHeadings);
F0 = newArray(lengthOf(headings));
for (col=0; col<lengthOf(headings); col++) {
	FArray = newArray(nResults);
	for (row=0; row<nResults; row++) {
		FArray[row] = getResult(headings[col], row);
		}
	Array.sort(FArray);
	F0Array = Array.slice(FArray,0,nF0Points);
	for (row=0; row<lengthOf(F0Array); row++) {
		F0[col] = F0[col] + F0Array[row];
	}
	F0[col] = F0[col]/nF0Points;
}

// Calculate Delta F / F0 and replace results 
for (col=0; col<lengthOf(headings); col++) {
	for (row=0; row<nResults; row++) {
		F = getResult(headings[col], row);
		setResult(headings[col], row, (F - F0[col]) / (F0[col] - Fb)) ;
	}
}
