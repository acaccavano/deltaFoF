// Macro to calculate F0 for a set of ROIs, defined as the average of the lowest nF0Points frames (default = 10)

nF0Points = 10;
rawStack = getTitle();
run("Clear Results");

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
	setResult(headings[col], 0, F0[col]) ;
}
Table.deleteRows(1, nResults);