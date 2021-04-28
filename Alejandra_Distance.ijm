//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=2 count=1 black edm=16-bit do=Nothing");
run("Input/Output...", "jpeg=85 gif=-1 file=.xls use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area mean area_fraction limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images. Make sure there is nothing but images in this folder.");
Dialog.show();
ImagePath=getDirectory("Choose the folder with images");
list = getFileList(ImagePath);
list = Array.sort (list);

print("Image Name","	","TCRb distance","	","(um)","	","Foxp3 distance","	","(um)");
for (NumImages=0; NumImages<list.length; NumImages+=4) {
	if (endsWith(list[NumImages],"tif")) {
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] color_mode=Default view=Hyperstack stack_order=XYCZT stitch_tiles");
		//open(ImagePath+list[NumImages]);
		ImageName = getTitle();
		rename("TCRb");
	
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages+2]+"] color_mode=Default view=Hyperstack stack_order=XYCZT stitch_tiles");
		rename("Foxp3");
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages+3]+"] color_mode=Default view=Hyperstack stack_order=XYCZT stitch_tiles");
		rename("Tubulin");
		
		//distance map on neurons
		selectWindow("Tubulin");
		run("Despeckle");
		run("Median...", "radius=5");
		setThreshold(50, 255);
		run("Convert to Mask");
		run("Invert");
		run("Distance Map");
		rename("distance");
		
	
		//tcrb
		selectWindow("TCRb");
		run("Despeckle");
		run("Median...", "radius=5");
		setThreshold(25,255);	
		run("Convert to Mask");	
		run("Dilate");
		run("Fill Holes");
		run("Erode");
		run("Watershed");
		run("Analyze Particles...", "size=500-Infinity clear add");
		selectWindow("distance");
		roiManager("Show All");
		roiManager("Measure");
		for (i=0;i<nResults;i++ ) {
			data=getResult("Mean",i);
			print(ImageName,"	","TCRB distace","	",data*0.1625);
		}
		run("Clear Results");
	
	
		//Foxp3
		selectWindow("Foxp3");
		run("Despeckle");
		run("Median...", "radius=5");
		setThreshold(50,255);	
		roiManager("Show All");
		roiManager("Measure");
		Foxp3Pos=newArray();
		for (i=0;i<nResults;i++) {
			data=getResult("%Area",i);
			if (data>30) {
				Foxp3Pos=Array.concat(Foxp3Pos,i);
			}
		}
		getDimensions(width, height, channels, slices, frames);
		newImage("Foxp3+", "8-bit black", width, height, 1);
		for(i=0;i<Foxp3Pos.length;i++){
			roiManager("Select",Foxp3Pos[i]);
			roiManager("Fill");
		}
		roiManager("Reset");
		run("Clear Results");
		run("Analyze Particles...", "size=0-Infinity clear add");
		selectWindow("distance");
		roiManager("Show All");
		roiManager("Measure");
		for (i=0;i<nResults;i++ ) {
			data=getResult("Mean",i);
			print(ImageName,"	","-","	","-","	","Foxp3 distance","	",data*0.1625);
		}
	
		run("Close All");
		run("Clear Results");
		roiManager("Reset");
	}
}

