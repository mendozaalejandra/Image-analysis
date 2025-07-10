run("Set Measurements...", "centroid area_fraction limit redirect=None decimal=2");
run("Options...", "iterations=3 count=1 black do=Nothing");
run("Clear Results");
roiManager("Reset");

ImageName=getTitle();
getDimensions(width, height, channels, slices, frames);
run("Split Channels");
selectWindow("C3-"+ImageName);
rename("Tubb3");
selectWindow("C2-"+ImageName);
rename("GFP");
selectWindow("C1-"+ImageName);
rename("DAPI");

//DAPI
selectWindow("DAPI");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(5,65533);  

run("Convert to Mask");
run("Fill Holes");
run("Watershed")

run("Analyze Particles...", "size=5-100 clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/DAPI.zip");


//GFP+ and GFP-
selectWindow("GFP");
run("Despeckle");
run("Median...", "radius=3");
run("Subtract Background...", "rolling=50");
setThreshold(13,65533);  
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/DAPI.zip");
roiManager("Show All");     
gfppos=newArray();
gfpneg=newArray();
roiManager("Measure");
for (i=0; i<nResults; i++) {
	data = getResult("%Area",i);
	if (data>15) {
		gfppos=Array.concat(gfppos,i);
	} else {
		gfpneg=Array.concat(gfpneg,i);
	}
}

getDimensions(width, height, channels, slices, frames);
newImage("gfp+", "8-bit black", width, height, 1);

	roiManager("Select",gfppos);
	roiManager("Fill");

newImage("gfp-", "8-bit black", width, height, 1);
roiManager("Reset");
roiManager("Open","/Users/Mendoza2/Desktop/today1/DAPI.zip");

	roiManager("Select",gfpneg);
	roiManager("Fill");


roiManager("Reset");
run("Clear Results");
selectWindow("gfp+");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/gfpPosTotal.zip");


roiManager("Reset");
run("Clear Results");
selectWindow("gfp-");
run("Analyze Particles...", "size=0-Infinity clear add");
roiManager("Save","/Users/Mendoza2/Desktop/today1/gfpNegTotal.zip");
