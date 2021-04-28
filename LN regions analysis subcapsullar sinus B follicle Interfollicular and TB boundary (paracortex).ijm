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
//Segmenting Follicles
selectWindow(ImageName);
setSlice(3);
run("Select None");
run("Duplicate...", " ");
rename("Bcell");
run("Enhance Contrast", "saturated=0.75");
roiManager("Reset");
setTool("polygon");
roiManager("Show All without labels");

waitForUser("Draw 1 or more regions of Follicles by drawing ROI then pressing 't' keystroke. \n\nClick OK when done");
//Manual drawing of regions
nroi=roiManager("Count");
if (nroi==0) {
	waitForUser("Draw 1 or more regions of Follicles by drawing ROI then pressing 't' keystroke. \n\nClick OK when done");
}

roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIs.zip");
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
rename("Follicles");

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



//Defining interfollicular
selectWindow("tobesaved");
roiManager("Reset");
waitForUser("Draw the Interfollicular regions, then press 't'");
nInter=roiManager("Count");
if (nInter==0) {
	waitForUser("Draw the Interfollicular regions, then press 't'");
}
nInter=roiManager("Count");
roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIInter.zip");
selectWindow(ImageName);
run("Select None");
run("Duplicate...","duplicate");
rename("Interfollicular");

if (nInter==0) {
	run("Select All");
	run("Clear","stack");
} else if (nInter==1) {
	roiManager("Select",0);
	run("Clear Outside","stack");	
	posInter=0;
} else if (nInter>1) {
	posInter=Array.getSequence(nInter);
	roiManager("Select",posInter);
	roiManager("Combine");
	run("Clear Outside","stack");
}

	selectWindow("tobesaved");
	run("Colors...", "foreground=yellow background=black selection=cyan");
	roiManager("Draw");
	
	selectWindow("Bcell");
	run("Colors...", "foreground=white background=black selection=cyan");
	roiManager("Fill");
	close("Interfollicular-1");	
	
selectWindow(ImageName);
if (nInter>0) {
	roiManager("Select",posInter);
	if (nInter>1) {
		roiManager("Combine");
	}
	run("Clear","stack");
}

	
//Defining Paracortex
selectWindow("Bcell");
run("8-bit");
setThreshold(1,255);
run("Convert to Mask");
run("Invert");
run("Distance Map");
setThreshold(1,242); //50um/0.207 = 242pixels (thickness of paracortex)
run("Analyze Particles...", "clear add");
nPara=roiManager("Count");
roiManager("Save","M:\\Users\\WS\\Ale\\"+ImageName+"_ROIPara.zip");
selectWindow(ImageName);
run("Select None");
run("Duplicate...","duplicate");
rename("Paracortex");
if (nPara==1) {
	roiManager("Select",0);
	run("Clear Outside","stack");
} else if (nPara>1) {
	posPara=Array.getSequence(nPara);
	roiManager("Select",posPara);
	roiManager("Combine");
	run("Clear Outside","stack");
}	

selectWindow("tobesaved");
run("Colors...", "foreground=blue background=black selection=cyan");
roiManager("Draw");

//Manually Defining the other 2 regions.

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

	//Analysis of Follicles
	selectWindow("Follicles"); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	FolliclesCells=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			FolliclesCells[m]=1;
		}
	}
	run("Clear Results");

	setSlice(1); //Follicles CD4 cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower1, upper1);
	roiManager("Measure");
	print(lower1,"	",upper1);
	FolliclesCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			FolliclesCD4[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(5); //Follicles CD44 cells
	close("Threshold");	
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower2, upper2);
	roiManager("Measure");
	print(lower2,"	",upper2);
	FolliclesCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			FolliclesCD44[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(4); //Follicles TBet cells
	close("Threshold");
	setAutoThreshold("Default dark");
	waitForUser;
	getThreshold(lower3, upper3);
	roiManager("Measure");
	print(lower3,"	",upper3);
	FolliclesRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			FolliclesRFP[m]=1;
		}
	}
	run("Clear Results");

	
	
	//Analysis of Subcabsular Sinus
	selectWindow("Subcabsular Sinus"); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	SinusCells=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			SinusCells[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(1); //Sinus CD4 cells
	setThreshold(lower1, upper1);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	SinusCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			SinusCD4[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(5); //Sinus CD44 cells
	setThreshold(lower2, upper2);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	SinusCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			SinusCD44[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(4); //Sinus TBet cells
	setThreshold(lower3, upper3);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	SinusRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			SinusRFP[m]=1;
		}
	}
	run("Clear Results");
	
	


	//Analysis of Interfollicular1
	selectWindow("Interfollicular"); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	InterCells=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			InterCells[m]=1;
		}
	}
	run("Clear Results");

	setSlice(1); //Interfollicular1 CD4 cells
	setThreshold(lower1, upper1);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	InterCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			InterCD4[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(5); //Interfollicular1 CD44 cells
	setThreshold(lower2, upper2);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	InterCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			InterCD44[m]=1;
		}
	}
	run("Clear Results");
	
	setSlice(4); //Interfollicular1 TBet cells
	setThreshold(lower3, upper3);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	InterRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			InterRFP[m]=1;
		}
	}
	run("Clear Results");


	//Analysis of Paracortex
	selectWindow("Paracortex"); 
	run("Subtract Background...", "rolling=50 stack");
	setSlice(2);
	setAutoThreshold("Default dark");
	roiManager("Measure");
	ParacortexCells=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			ParacortexCells[m]=1;
		}
	}
	run("Clear Results");

	ParacortexCD4Count = 0;
	setSlice(1); //Paracortex CD4 cells
	setThreshold(lower1, upper1);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	ParacortexCD4=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			ParacortexCD4[m]=1;
			ParacortexCD4Count += 1;
		}

	}
	run("Clear Results");

	ParacortexCD44Count = 0;
	setSlice(5); //Paracortex CD44 cells
	setThreshold(lower2, upper2);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	ParacortexCD44=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			ParacortexCD44[m]=1;
			ParacortexCD44Count += 1;
		}
	}
	run("Clear Results");

	ParacortexRFPCount = 0;
	setSlice(4); //Paracortex TBet cells
	setThreshold(lower3, upper3);
	roiManager("Measure");
	getThreshold(a,b);
	print(a,"	",b);
	ParacortexRFP=newArray(nResults);
	for (m=0;m<nResults;m++) {
		data=getResult("%Area",m);
		if (data>1) {
			ParacortexRFP[m]=1;
			ParacortexRFPCount += 1;
		}
	}
	run("Clear Results");

	//Tabulating Everything
	SinusCellCount=0;
	FolliclesCellCount=0;
	InterCellCount=0;
	ParacortexCellCount=0;
	for (m=0;m<SinusCells.length;m++) {
		SinusCellCount=SinusCellCount+SinusCells[m];
		FolliclesCellCount=FolliclesCellCount+FolliclesCells[m];
		InterCellCount=InterCellCount+InterCells[m];
		ParacortexCellCount=ParacortexCellCount+ParacortexCells[m];		
	}

	SinusTriple=0;
	SinusDouble=0;
	FolliclesTriple=0;
	FolliclesDouble=0;
	InterTriple=0;
	InterDouble=0;
	ParacortexTriple=0;
	ParacortexDouble=0;
	for (m=0;m<SinusCells.length;m++) {
		if (SinusCells[m]==1) {
			if (SinusCD4[m]==1) {
				if (SinusCD44[m]==1) {
					if (SinusRFP[m]==1) {
						SinusTriple=SinusTriple+1;
					} else {
						SinusDouble=SinusDouble+1;
					}
				}
			}
		}
	}
	for (m=0;m<FolliclesCells.length;m++) {
		if (FolliclesCells[m]==1) {
			if (FolliclesCD4[m]==1) {
				if (FolliclesCD44[m]==1) {
					if (FolliclesRFP[m]==1) {
						FolliclesTriple=FolliclesTriple+1;
					} else {
						FolliclesDouble=FolliclesDouble+1;
					}
				}
			}
		}
	}

	for (m=0;m<InterCells.length;m++) {
		if (InterCells[m]==1) {
			if (InterCD4[m]==1) {
				if (InterCD44[m]==1) {
					if (InterRFP[m]==1) {
						InterTriple=InterTriple+1;
					} else {
						InterDouble=InterDouble+1;
					}
				}
			}
		}
	}

	for (m=0;m<ParacortexCells.length;m++) {
		if (ParacortexCells[m]==1) {
			if (ParacortexCD4[m]==1) {
				if (ParacortexCD44[m]==1) {
					if (ParacortexRFP[m]==1) {
						ParacortexTriple=ParacortexTriple+1;
					} else {
						ParacortexDouble=ParacortexDouble+1;
					}
				}
			}
		}
	}

	print(ImageName,"	",SinusCellCount,"	",SinusDouble,"	",SinusTriple,"	",FolliclesCellCount,"	",FolliclesDouble,"	",FolliclesTriple,"	",InterCellCount,"	",InterDouble,"	",InterTriple,"	",ParacortexCellCount,"	",ParacortexDouble,"	",ParacortexTriple);

	print(ImageName,"	",ParacortexCD4Count,"	",ParacortexCD44Count,"	",ParacortexRFPCount);
	
	selectWindow("tobesaved");
	saveAs("jpeg","M:\\Users\\WS\\Ale\\"+ImageName+"_regions.jpg");

	selectWindow("Log");
	saveAs("text","M:\\Users\\WS\\Ale\\data.txt");
	//run("Close All");
	run("Clear Results");
	roiManager("Reset");	
