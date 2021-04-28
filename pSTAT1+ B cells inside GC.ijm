run("Set Measurements...", "centroid area_fraction limit redirect=None decimal=2");
run("Options...", "iterations=3 count=1 black do=Nothing");
run("Clear Results");
roiManager("Reset");

//Manual drawing of regions
nroi=roiManager("Count");
if (nroi==0) {
	waitForUser("Draw 1 or more regions of GC by drawing ROI then pressing 't' keystroke. \n\nClick OK when done");
}

roiManager("Save","/Users/Mendoza2/Desktop/today1/GC.zip");
	roiManager("Combine");
	
run("Clear Outside");

ImageName=getTitle();
getDimensions(width, height, channels, slices, frames);
run("Split Channels");
selectWindow("C4-"+ImageName);
rename("PSTAT1");
selectWindow("C3-"+ImageName);
rename("TBET");
selectWindow("C2-"+ImageName);
rename("B220");
selectWindow("C1-"+ImageName);
rename("PNA");

//B220+
selectWindow("B220");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
run("8-bit");
setThreshold(18,65533);
run("Analyze Particles...", "size=5-250 clear add");
roiManager("Show All");    
getDimensions(width, height, channels, slices, frames);
newImage("B220+", "8-bit black", width, height, 1);

roiManager("fill");
run("Watershed");

run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/B220.zip");


//PSTAT1
selectWindow("PSTAT1");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(15,65533);  
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/B220.zip");
roiManager("Show All");     
pstat1pos=newArray();
pstat1neg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		pstat1pos=Array.concat(pstat1pos,i);
	} else {
		pstat1neg=Array.concat(pstat1neg,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("pstat1+", "8-bit black", width, height, 1);

	roiManager("Select",pstat1pos);
	roiManager("Fill");

newImage("pstat1-", "8-bit black", width, height, 1);
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/B220.zip");

	roiManager("Select",pstat1neg);
	roiManager("Fill");


roiManager("Reset");
run("Clear Results");
selectWindow("pstat1+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/pstat1PosTotal.zip");


roiManager("Reset");
run("Clear Results");
selectWindow("pstat1-");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/pstat1NegTotal.zip");
