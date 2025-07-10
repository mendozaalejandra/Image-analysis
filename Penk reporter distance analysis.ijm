run("Set Measurements...", "mean area_fraction limit redirect=None decimal=2");
run("Options...", "iterations=2 count=1 black do=Nothing");
run("Colors...", "foreground=white background=black selection=cyan");
run("Options...", "iterations=1 count=1 black edm=32-bit");
run("Clear Results");
roiManager("Reset");

ImageName=getTitle();
ImagePath=getDirectory("image");
rename("image");
run("Split Channels");

selectWindow("C5-image");
rename("RFP");
selectWindow("C4-image");
rename("CD4");
selectWindow("C3-image");
rename("Foxp3");
selectWindow("C2-image");
rename("Tcrgd");
selectWindow("C1-image");
rename("Tubulin");


selectWindow("Tubulin");
run("Subtract Background...", "rolling=50")

setThreshold(8,65535);
run("Convert to Mask");
run("Close-");
run("Invert");
run("Distance Map");
rename("distance");


//all Foxp3 

selectWindow("Foxp3");
run("Despeckle");
run("Median...", "radius=5");
run("Subtract Background...", "rolling=50");
setThreshold(20,65533);  

run("Analyze Particles...", "size=10-100 pixel exclude clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/Foxp3Dirty.zip");

selectWindow("Foxp3");
setThreshold(20,65533);  

roiManager("Reset");
run("Clear Results");
roiManager("Open","/Users/Mendoza2/Desktop/today1/Foxp3Dirty.zip");
roiManager("Show All");     


Foxp3pos=newArray();

roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		Foxp3pos=Array.concat(Foxp3pos,i);
	} 
}

getDimensions(width, height, channels, slices, frames);
newImage("Foxp3+", "8-bit black", width, height, 1);
for (i=0;i<Foxp3pos.length;i++) {
	roiManager("Select",Foxp3pos[i]);
	roiManager("Fill");
}

selectWindow("Foxp3+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/Foxp3PosTotal.zip");


//Foxp3 RFP+ and RFP-
selectWindow("RFP");
run("Despeckle");
run("Median...", "radius=3");
setThreshold(25,65533);  
roiManager("Reset");
run("Clear Results");
roiManager("Open","/Users/Mendoza2/Desktop/today1/Foxp3PosTotal.zip");
roiManager("Show All");     
Foxp3posRFP=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		RFPpos=Array.concat(RFPpos,i);
	} else {
		RFPneg=Array.concat(RFPneg,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("RFP+", "8-bit black", width, height, 1);
for (i=0;i<RFPpos.length;i++) {
	roiManager("Select",RFPpos[i]);
	roiManager("Fill");
}
newImage("RFP-", "8-bit black", width, height, 1);
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/Foxp3PosTotal.zip");
for (j=0;j<RFPneg.length;j++) {
	roiManager("Select",RFPneg[j]);
	roiManager("Fill");
}

roiManager("Reset");
run("Clear Results");
selectWindow("RFP+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/Foxp3PosRFPPos.zip");


roiManager("Reset");
run("Clear Results");
selectWindow("RFP-");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/Foxp3PosRFPNeg.zip");

//Distance Foxp3+RFP+


selectWindow("distance");
roiManager("Reset");
run("Clear Results");

roiManager("Open","/Users/Mendoza2/Desktop/today1/Foxp3PosTotal.zip");

RFPPos=newArray(nResults);

roiManager("Measure");
for (i=0;i<nResults;i++) {
	data=getResult("Mean",i);
	print(data);
}
run("Clear Results");



//RFPNeg Distance

selectWindow("distance");
roiManager("Reset");
run("Clear Results");

roiManager("Open","/Users/Mendoza2/Desktop/today1/Foxp3PosRFPNeg.zip");

RFPNeg=newArray(nResults);

roiManager("Measure");
for (i=0;i<nResults;i++) {
	data=getResult("Mean",i);
	print(data);
}
run("Clear Results");
