run("Set Measurements...", "centroid area_fraction limit redirect=None decimal=2");
run("Options...", "iterations=3 count=1 black do=Nothing");
run("Clear Results");
roiManager("Reset");

ImageName=getTitle();
getDimensions(width, height, channels, slices, frames);
run("Split Channels");
selectWindow("C4-"+ImageName);
rename("Fos");
selectWindow("C3-"+ImageName);
rename("Tubb3");
selectWindow("C2-"+ImageName);
rename("CTB");
selectWindow("C1-"+ImageName);
rename("DAPI");

//DAPI positive

selectWindow("DAPI");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(5,65533);  

run("Convert to Mask");

run("Dilate");
run("Outline");
run("Fill Holes");
run("Watershed");
run("Analyze Particles...", "size=5-300 clear add");
roiManager("Save","/Users/alejandramendoza/Desktop/today1/DAPI.zip");


//Fos positive of DAPI 
selectWindow("Fos");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(15,65533);  

roiManager("Reset");
roiManager("Open","/Users/alejandramendoza/Desktop/today1/DAPI.zip");
roiManager("Show All");     
fospos=newArray();
fosneg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		fospos=Array.concat(fospos,i);
	} else {
		fosneg=Array.concat(fosneg,i);
	}
}



getDimensions(width, height, channels, slices, frames);
newImage("fos+", "8-bit black", width, height, 1);

	roiManager("Select",fospos);
	roiManager("Fill");

newImage("fos-", "8-bit black", width, height, 1);
roiManager("Reset");
roiManager("Open","/Users/alejandramendoza/Desktop/today1/DAPI.zip");

	roiManager("Select",fosneg);
	roiManager("Fill");


roiManager("Reset");
run("Clear Results");
selectWindow("fos+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/alejandramendoza/Desktop/today1/fospos.zip");


roiManager("Reset");
run("Clear Results");
selectWindow("fos-");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/alejandramendoza/Desktop/today1/fosneg.zip");



//CTB positive of Fos positive
selectWindow("CTB");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(22,65533);  

roiManager("Reset");
roiManager("Open","/Users/alejandramendoza/Desktop/today1/fospos.zip");
roiManager("Show All");     
ctbpos=newArray();
ctbneg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		ctbpos=Array.concat(ctbpos,i);
	} else {
		ctbneg=Array.concat(ctbneg,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("ctb+", "8-bit black", width, height, 1);

	roiManager("Select",ctbpos);
	roiManager("Fill");

	


roiManager("Reset");
run("Clear Results");
selectWindow("ctb+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/alejandramendoza/Desktop/today1/fosposctbpos.zip");



//CTB+ of Fos negative 
selectWindow("CTB");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(22,65533);  
roiManager("Reset");
roiManager("Open","/Users/alejandramendoza/Desktop/today1/fosneg.zip");
roiManager("Show All");     
ctbpos2=newArray();
ctbneg2=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		ctbpos2=Array.concat(ctbpos2,i);
	} else {
		ctbneg2=Array.concat(ctbneg2,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("ctb2+", "8-bit black", width, height, 1);

	roiManager("Select",ctbpos2);
	roiManager("Fill");

roiManager("Reset");

run("Clear Results");
selectWindow("ctb2+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/alejandramendoza/Desktop/today1/fosnegctbpos.zip");

