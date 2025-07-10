run("Set Measurements...", "centroid area_fraction limit redirect=None decimal=2");
run("Options...", "iterations=3 count=1 black do=Nothing");
run("Clear Results");
roiManager("Reset");

ImageName=getTitle();
getDimensions(width, height, channels, slices, frames);
run("Split Channels");
selectWindow("C3-"+ImageName);
rename("cFos");
selectWindow("C2-"+ImageName);
rename("Tubb3");
selectWindow("C1-"+ImageName);
rename("DAPI");

//DAPI
selectWindow("DAPI");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(7,65533);  

run("Convert to Mask");
run("Fill Holes");
run("Watershed")

run("Analyze Particles...", "size=5-100 clear add");

roiManager("Save","/Users/Mendoza2/Desktop/today1/DAPI.zip");

//DAPI+ Tubb3+
selectWindow("Tubb3");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(8,65533);  
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/DAPI.zip");

roiManager("Show All");     
Tubb3pos=newArray();
Tubb3neg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		Tubb3pos=Array.concat(Tubb3pos,i);
	} 
}

getDimensions(width, height, channels, slices, frames);
newImage("Tubb3+", "8-bit black", width, height, 1);

	roiManager("Select",Tubb3pos);
	roiManager("Fill");



roiManager("Reset");
run("Clear Results");
selectWindow("Tubb3+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/Tubb3PosTotal.zip");

//cFos+ and cFos-
selectWindow("cFos");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(14,65533);  
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/Tubb3PosTotal.zip");
roiManager("Show All");     
cFospos=newArray();
cFosneg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		cFospos=Array.concat(cFospos,i);
	} else {
		cFosneg=Array.concat(cFosneg,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("cFos+", "8-bit black", width, height, 1);

	roiManager("Select",cFospos);
	roiManager("Fill");

newImage("cFos-", "8-bit black", width, height, 1);
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/Tubb3PosTotal.zip");

	roiManager("Select",cFosneg);
	roiManager("Fill");


roiManager("Reset");
run("Clear Results");
selectWindow("cFos+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/cFosPosTotal.zip");


roiManager("Reset");
run("Clear Results");
selectWindow("cFos-");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/cFosNegTotal.zip");

