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
selectWindow("tobesaved");
roiManager("Draw");
selectWindow(ImageName);
run("Select None");
run("Duplicate...","duplicate");
rename("Subcabsular Sinus");  //Creating a stack of just the subcabsular sinus
roiManager("Select",0);
run("Clear","stack");
selectWindow(ImageName);
roiManager("Select",0);
run("Clear Outside","stack");
close("node");

//setBatchMode(false);
//Segmenting Medulla
selectWindow(ImageName);
setSlice(3);
run("Select None");
run("Duplicate...", " ");
rename("Bcell");
run("Enhance Contrast", "saturated=0.75");
roiManager("Reset");
setTool("polygon");
roiManager("Show All without labels");

waitForUser("Draw 1 or more regions of Medulla by drawing ROI then pressing 't' keystroke. \n\nClick OK when done");
//Manual drawing of regions
nroi=roiManager("Count");
if (nroi==0) {
	waitForUser("Draw 1 or more regions of Medulla by drawing ROI then pressing 't' keystroke. \n\nClick OK when done");
}

roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIsmed.zip");
roiManager("Deselect");
roiManager("Fill");
nNode=roiManager("Count");
selectWindow("tobesaved");
run("Colors...", "foreground=magenta background=black selection=cyan");
roiManager("Draw");
run("Colors...", "foreground=white background=black selection=cyan");
//setBatchMode(true);
selectWindow(ImageName);
run("Select None");
run("Duplicate...", "duplicate");
rename("Medulla");

if (nNode==1) {
	roiManager("Select",0);
	run("Clear Outside","stack");
	posNode=0;
} else if (nNode>1) {
	posNode=Array.getSequence(nNode);
	roiManager("Select",posNode);
	roiManager("Combine");
	run("Clear Outside","stack");

selectWindow("Bcell");
roiManager("Fill");
roiManager("Select",posNode);
if (nNode>1){
	roiManager("Combine");
}
run("Clear Outside");

selectWindow(ImageName);
roiManager("Select",posNode);
if (nNode>1){
	roiManager("Combine");
}
run("Clear","stack");

//Analysis of Medulla

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


	selectWindow("Medulla"); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	MedullaCells=newArray(nResults);
	MedullaCellsCount=0;
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			MedullaCells[m]=1;
			MedullaCellsCount=MedullaCellsCount+1;
		}
	}
	run("Clear Results");

	setSlice(1); //Medulla CD4 cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower1, upper1);
	roiManager("Measure");
	print(lower1,"	",upper1);
	MedullaCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			MedullaCD4[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(5); //Medulla CD44 cells
	close("Threshold");	
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower2, upper2);
	roiManager("Measure");
	print(lower2,"	",upper2);
	MedullaCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			MedullaCD44[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(4); //Medulla TBet cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower3, upper3);
	roiManager("Measure");
	print(lower3,"	",upper3);
	MedullaRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			MedullaRFP[m]=1;
		}
	}
	run("Clear Results");
	
	//Tabulating Everything
	MedullaTriple=0;
	MedullaDouble=0;
	for (m=0;m<MedullaCells.length;m++) {
		if (MedullaCells[m]==1) {
			if (MedullaCD4[m]==1) {
				if (MedullaCD44[m]==1) {
					if (MedullaRFP[m]==1) {
						MedullaTriple=MedullaTriple+1;
					} else {
						MedullaDouble=MedullaDouble+1;
					}
				}
			}
		}
	}

	

	print(ImageName,"		",MedullaCellsCount,"	",MedullaDouble,"	",MedullaTriple);

	
	selectWindow("tobesaved");
	saveAs("jpeg","M:\\Users\\WS\\Ale\\"+ImageName+"_regionsmed.jpg");

	selectWindow("Log");
	saveAs("text","M:\\Users\\WS\\Ale\\datamed.txt");
	//run("Close All");
	run("Clear Results");
	roiManager("Reset");	
