// Macro to automatically segment ROIs from calculated residual files
// Performance is unreliable - recommend skipping

setAutoThreshold("Triangle dark");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=30-300 pixel circularity=0.30-1.00 clear add");
