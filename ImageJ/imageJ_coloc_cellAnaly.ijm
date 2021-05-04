//By Vasco Fachada, September 2019
//Study lpid droplets and plin5 in skeletal muscle of diabeic, obese and lean humans
//This macro fetches the image files, preforms deconvolution and runs the cell analyser plugin

while(nImages>0) { 
	selectImage(nImages); 
    close();
    } 
    
dir = getDirectory("Select a directory containing your groups");
start = getTime();
grp_folds = getFileList(dir);

setBatchMode(true);

for(f=0; f<grp_folds.length; f++) {
	cur_grp = getFileList(dir+grp_folds[f]);
	for(h = 0; h < cur_grp.length; h++) {

		cur_fold = dir+grp_folds[f]+cur_grp[h];
		cur_subj = substring(cur_grp[h],0,lengthOf(cur_grp[h])-1);
		LDsFile = cur_fold+"deconv_LDs.tif";
		oxpatFile = cur_fold+"deconv_OXPAT.tif";
		ftFile = cur_fold+"FT.tif";
		membFile = cur_fold+"memb.tif";	
		group = substring(grp_folds[f],0,lengthOf(grp_folds[f])-1);
		
		print(cur_fold);	
		print(group);
		print(cur_subj);
		
		open(membFile);
		getVoxelSize(rawWidth, rawHeight, rawDepth, rawUnit);
		run("Invert");
		membFile = getTitle();	
		open(oxpatFile);
		setVoxelSize(rawWidth, rawHeight, rawDepth, rawUnit);
		oxpatFile = getTitle();
		imageCalculator("Subtract create", oxpatFile, membFile);
		oxpatFile = getTitle();	
		open(LDsFile);
		setVoxelSize(rawWidth, rawHeight, rawDepth, rawUnit);
		LDsFile = getTitle();
		imageCalculator("Subtract create", LDsFile, membFile);
		LDsFile = getTitle();
		open(ftFile);
		ftFile = getTitle();
		imageCalculator("Subtract create", ftFile, membFile);
		ftFile = getTitle();

		run("Merge Channels...", "c1=["+oxpatFile+"] c2=["+LDsFile+"] c3=["+ftFile+"] keep");
		saveAs("Tiff", cur_fold+"MERGED.tif");
		
		//functions to run over data
		colocParticles(cur_fold);
		cellAnalyzer(cur_fold, group, cur_subj, dir);
		colocAn_feret(cur_fold, dir, group, cur_subj); //This function is run separte in order to perform the colocalization analysis and feret measurements in different fiber types
		//waitForUser;	
		while (nImages>0) { 
			selectImage(nImages); 
        	close();    				  
		} 					
	}
}

end = getTime();
Dialog.create("Job Done!");
Dialog.addMessage("Finished within "+(end-start)/1000+" seconds ("+(end-start)/1000/60+" minutes).");
Dialog.show();

function colocParticles(cur_fold){

	run("Colocalization Threshold", "channel_1=["+oxpatFile+"] channel_2=["+LDsFile+"] use=None channel=[Red : Green] show show include");
	
	close();
	selectWindow("Colocalized Pixel Map RGB Image");
	saveAs("Tiff", cur_fold+"Coloc.tif");
	run("Split Channels");
	selectWindow("Coloc.tif (blue)");
	run("8-bit");
	rename("gray"); //ICA colocalization
	run("Duplicate...", "title=binColoc"); //binarized colocalization
	setVoxelSize(rawWidth, rawHeight, rawDepth, rawUnit);
	setAutoThreshold("Moments");
	run("Convert to Mask");
	run("Invert");
	selectWindow("Results"); 
	run("Close");
}


function cellAnalyzer(cur_fold, group, cur_subj, dir){

	//cell segmentation:
	selectWindow(membFile);
	run("Invert");
	run("Cell Segmentation", "minimun=2 grayvalue=5 remove");
	rename("segm");
	//setBatchMode(false);
	//preparing binarized LDs, oxpat and Free LDs
	selectWindow(oxpatFile);
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	run("Invert");
	
	selectWindow(LDsFile);
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	run("Invert");

	imageCalculator("Subtract create", LDsFile,"binColoc");
	//selectWindow("Result of ["+LDsFile+"]");
	rename("binFreeLDs");
	saveAs("Tiff", cur_fold+"binFreeLDs.tif");
	//run("Invert");
	//

	open(cur_fold+"FTbin.tif");
	//run("Invert");
	ftFile_ = getTitle();
	
	//Cell Analysis per se:
	mtd = "NullSeparatedParticles";
//waitForUser;	
	run("Cell Analyzer", "choose=["+dir+"] number=5 decimal=. group="+group+" subject="+cur_subj+" image=segm image_1=["+ftFile_+"] method_1="+mtd+" type_1=FibType image_2=["+LDsFile+"] method_2="+mtd+" type_2=LDs image_3=["+oxpatFile+"] method_3="+mtd+" type_3=oxpat image_4=binColoc method_4="+mtd+" type_4=coloc image_5=binFreeLDs.tif method_5="+mtd+" type_5=freeLDs");

	selectWindow("Cell ids");
	setVoxelSize(rawWidth, rawHeight, rawDepth, rawUnit);
	run("Duplicate...", "title=Cell ids_temp");
	saveAs("Tiff", cur_fold+"_CELL_IDs");
	selectWindow("Cell ids");
	setMinAndMax(0, 0);
	run("Apply LUT");
	run("Invert");
	setMinAndMax(-198, 708);
	run("Apply LUT");
	run("Merge Channels...", "c1=["+oxpatFile+"] c2=["+LDsFile+"] c3=["+ftFile+"] c4=binColoc c5=[Cell ids] c6=binFreeLDs.tif create keep");
	//run("RGB Color");
	setMinAndMax(25, 170);
	saveAs("Tiff", cur_fold+"_MERGED_particles");
	selectWindow("Results"); 
	run("Close");
}



function colocAn_feret (cur_fold, dir, group, cur_subj){


	calib = 5.881502810864407;//calib is the current unit at which the image is calibrated. This is used for the correct coordinate doWand selection. 

	badCells = 0;//Bad cell counter
	goodCells = 0;//Good cell counter

	print(dir);
	print(group);
	print(cur_subj);
	text_file = dir+group+"_"+cur_subj+".tsv";
			
	selectWindow("segm");
					

	//Open and read the text file with coordinate data, obtain values 
	text_file = File.openAsString(text_file);
	rows = split(text_file, "\n"); 
	Cell_ID = newArray(rows.length);
	Cell_Area = newArray(rows.length); 
	X_coord = newArray(rows.length);
	Y_coord = newArray(rows.length);
	shortAxis = newArray(rows.length);

	//Creating the file with the headers in the subject folder ready to accept data   				
	feret_file = cur_fold+"feret.tsv";
	if (File.exists(feret_file)) {
		File.delete(feret_file);
	}
						
	//File.append(txtResults+txtFolder[j], data_file); //File title
    File.append("Cell_ID \t Area(µm) \t Feret min(µm)", feret_file);  // Create header
	//print ("Cell number "+Cell_ID[i]+" from subject "+currentSubject+" from "+txtFolder[j]);
	//print ("Area = "+area+"um      Short axis = "+shortAxis+"um   old area = "+old_area);
	//print(data_file);
						
	for( i=rows.length-1 ; i > 0; i--){
		columns=split(rows[i],"\t");
		if (matches(columns[0], ".*#.*")){
			Cell_ID[i]=columns[0];
			Cell_Area[i]=parseFloat(columns[1]);
			MyosinSignal=parseFloat(columns[5]);
			FiberType=MyosinSignal/Cell_Area[i]; 
			X_coord[i]=parseFloat(columns[2]); 
			Y_coord[i]=parseFloat(columns[3]);
			print(Cell_ID[i]);
			print(Cell_Area[i]);
			print(MyosinSignal);
			print(FiberType);
			print('X coordinate is :'+X_coord[i]*calib);
			print('Y coordinate is :'+Y_coord[i]*calib);
								
			doWand((X_coord[i]*calib), (Y_coord[i]*calib));
			if (FiberType>500){
				roiManager("Add"); //Its a fast fiber!!
			}
			
			//measure Feret
			List.setMeasurements;
			shortAxis[i] = List.getValue("MinFeret")/calib;
			print(shortAxis[i]);
			//waitForUser;
    		File.append(Cell_ID[i]+" \t "+Cell_Area[i]+" \t "+shortAxis[i], feret_file);
    		
			goodCells = goodCells+1;					
		}
	}
	
	//Splits and arranges cells by fiber types before performing colocalization analysis
	setBackgroundColor(0, 0, 0);
	selectWindow("MERGED.tif");
	rename("fast_mask");
	run("Duplicate...", "title=slow_mask");
	roiManager("Combine");
	run("Clear", "slice");
	saveAs("Tiff", cur_fold+"SlowFib_coloc.tif");
	rename("slow_mask");
	selectWindow("fast_mask");
	roiManager("Combine");
	run("Clear Outside");
	saveAs("Tiff", cur_fold+"FastFib_coloc.tif");
	rename("fast_mask");
	roiManager("reset");

	//colocalization analysis per se
	//Fast fibers
	selectWindow("fast_mask");
	run("Split Channels");
	run("Colocalization Threshold", "channel_1=[fast_mask (red)] channel_2=[fast_mask (green)] use=None channel=[Red : Green] show show include");
	saveAs("Tiff", cur_fold+"FastFib_scatter.tif");
	close(); 
	//Slow fibers
	selectWindow("slow_mask");
	run("Split Channels");
	run("Colocalization Threshold", "channel_1=[slow_mask (red)] channel_2=[slow_mask (green)] use=None channel=[Red : Green] show show include");
	saveAs("Tiff", cur_fold+"SlowFib_scatter.tif");
	close(); 

	//saving results
	selectWindow("Results");
	saveAs("Text", cur_fold+"coloc.tsv");
	selectWindow("Results"); 
	run("Close"); 	
}
