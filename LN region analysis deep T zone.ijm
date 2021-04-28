run("Options...", "iterations=5 count=1 black edm=32-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xlsx use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=5");
run("Set Measurements...", "area bounding area_fraction limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");


ImageName=getTitle();
ImagePath=getDirectory("image");


for (i=0;i<nSlices;i++) {
	setSlice(i+1);
	if (i==2) {
		run("Enhance Contrast", "saturated=0.35");
	} else {
		run("Enhance Contrast", "saturated=0.05");
	}
}
run("Duplicate...", "duplicate");
Stack.setDisplayMode("composite");
run("Flatten");
rename("tobesaved");

//setBatchMode(true);
selectWindow(ImageName);
setSlice(2);
run("Duplicate...", " ");
rename("Nuclei");

selectWindow(ImageName);
setSlice(2); //Segmenting the entire lymph node using Draq7
run("Duplicate...","	");
rename("node");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("Triangle dark");
run("Convert to Mask");
run("Fill Holes");
run("Analyze Particles...", "size=500000-Infinity clear add");
selectWindow(ImageName);
roiManager("Select",0);
run("Clear Outside", "stack");
selectWindow("tobesaved");
roiManager("Draw");
selectWindow("node");
roiManager("Select",0);
run("Clear Outside");
roiManager("Reset");
run("Select None");


//Segmenting subcabsular sinus
selectWindow("node");
run("Distance Map");
getMinAndMax(min, max);
setThreshold(50,max);
run("Analyze Particles...", "size=15000-Infinity clear add");
roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIsSinus.zip");
selectWindow(ImageName);
nROI=roiManager("Count");
if (nROI==1) {
	roiManager("Select",0);
	run("Clear Outside","stack");
} else if (nROI>1) {
	posNode=Array.getSequence(nROI);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear Outside","stack");
}

roiManager("Reset");
waitForUser("Load Follicular ROIS");
nROI=roiManager("Count");
if (nROI==1) {
	roiManager("Select",0);
	run("Clear","stack");
} else if (nROI>1) {
	posNode=Array.getSequence(nROI);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear","stack");
}

roiManager("Reset");
waitForUser("Load InterF ROIS");
nROI=roiManager("Count");
if (nROI==1) {
	roiManager("Select",0);
	run("Clear","stack");
} else if (nROI>1) {
	posNode=Array.getSequence(nROI);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear","stack");
}

roiManager("Reset");
waitForUser("Load Paracortex ROIS");
nROI=roiManager("Count");
if (nROI==1) {
	roiManager("Select",0);
	run("Clear","stack");
} else if (nROI>1) {
	posNode=Array.getSequence(nROI);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear","stack");
}

roiManager("Reset");
waitForUser("Load Medulla ROIS");
nROI=roiManager("Count");
if (nROI==1) {
	roiManager("Select",0);
	run("Clear","stack");
} else if (nROI>1) {
	posNode=Array.getSequence(nROI);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear","stack");
}
roiManager("Reset");
run("Select None");

//Analysis of TZone (leftover)

	//Counting cells in different regions
	selectWindow("Nuclei"); //Segmenting all nuclei
	run("Despeckle");
	run("Median...", "radius=4");
	run("Subtract Background...", "rolling=50");
	run("8-bit");
	run("Auto Local Threshold", "method=Otsu radius=15 parameter_1=0 parameter_2=0 white");
	run("Fill Holes");
	run("Watershed");
	run("Analyze Particles...", "size=5-250 clear add");


	selectWindow(ImageName); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	TZCells=newArray(nResults);
	TZCellsCount=0;
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			TZCells[m]=1;
			TZCellsCount=TZCellsCount+1;
		}
	}
	run("Clear Results"); 
	
	setSlice(1); //TZ CD4 cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower1, upper1);
	roiManager("Measure");
	print(lower1,"	",upper1);
	TZCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			TZCD4[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(5); //TZ CD44 cells
	close("Threshold");	
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower2, upper2);
	roiManager("Measure");
	print(lower2,"	",upper2);
	TZCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			TZCD44[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(4); //TZ TBet cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower3, upper3);
	roiManager("Measure");
	print(lower3,"	",upper3);
	TZRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			TZRFP[m]=1;
		}
	}
	run("Clear Results");
	
	//Tabulating Everything
	TZTriple=0;
	TZDouble=0;
	for (m=0;m<TZCells.length;m++) {
		if (TZCells[m]==1) {
			if (TZCD4[m]==1) {
				if (TZCD44[m]==1) {
					if (TZRFP[m]==1) {
						TZTriple=TZTriple+1;
					} else {
						TZDouble=TZDouble+1;
					}
				}
			}
		}
	}

	

	print(ImageName,"		",TZCellsCount,"	",TZDouble,"	",TZTriple);

	selectWindow(ImageName);
	setSlice(2);
	run("Median...", "radius=10");
	setAutoThreshold("Default dark");
	waitForUser;
	run("Analyze Particles...", "clear add");
	roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIsTZ.zip");
	
	selectWindow("tobesaved");
	saveAs("jpeg","M:\\Users\\WS\\Ale\\"+ImageName+"_regionsTZ.jpg");

	selectWindow("Log");
	saveAs("text","M:\\Users\\WS\\Ale\\dataTZ.txt");
	//run("Close All");
	run("Clear Results");
	roiManager("Reset");	
