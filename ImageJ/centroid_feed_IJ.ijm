//setBatchMode("hide");
while (nImages>0) { 
         selectImage(nImages); 
         close(); 
}

start=getTime();

calib = 0.1985000;//calib is the current unit at which the image is calibrated. This is used for the correct coordinate doWand selection. 

badCells = 0;//Bad cell counter
goodCells = 0;//Good cell counter

//input = getDirectory("Find the folder containing your images or folders with your images");
imgSource = File.separator+"\\fileservices.ad.jyu.fi\\homes\\varufach\\Desktop\\research\\Diabetic_study_for_TOPOCELL\\data_for_MATLAB\\1_ImageJ_TSVs\\deconv\\";
imgFolder = getFileList (imgSource);

for (l=0; l<imgFolder.length; l++) {
	currCalibFolder = getFileList (imgSource+imgFolder[l]);
	for (ll=0; ll<currCalibFolder.length;ll++) {
		showProgress(ll, currCalibFolder.length);//progress bar display in imagej		
 			currentSubject = substring(currCalibFolder[ll],0,3);
			txt_file = imgSource+imgFolder[l]+currCalibFolder[ll];
			print(currCalibFolder[ll]);
			cur_grp = substring(currCalibFolder[ll], 0, lengthOf(currCalibFolder[ll])-7);
			cur_subj = substring(currCalibFolder[ll], 9, lengthOf(currCalibFolder[ll])-4);
			img_file = File.separator+"\\fileservices.ad.jyu.fi\\homes\\varufach\\Desktop\\research\\Diabetic_study_for_TOPOCELL\\data_for_ImageJ\\"+cur_grp+File.separator+cur_subj+File.separator+"memb.tif";
			open(txt_file);
			open(img_file);
			run("RGB Color");
			//run("Properties...", "channels=1 slices=1 frames=1 unit=µm pixel_width="+calib+" pixel_height="+calib+" voxel_depth="+calib+"");
				waitForUser;
			txtSource =	"D:/VASCO/MassA/real_study/data/output/TopoCell_data/tsv_files/IJ_centroid_input/";
			txtFolder = getFileList (txtSource);
			for (j=0; j<txtFolder.length; j++) {
				leg_group = substring(txtFolder[j],0,1);//Right and Left groups
				txt_file = getFileList (txtSource+txtFolder[j]);
				//print(txt_file[0]);
				//print(substring(txt_file[0],0,4));
				for (jj=0; jj<txt_file.length; jj++) {					
					print("text file is: "+substring(txt_file[jj],0,2)+leg_group);
					print("current subject is: "+currentSubject);
					//waitForUser;
					if (matches(currentSubject, substring(txt_file[jj],0,2)+leg_group)==true){
						//waitForUser(currentSubject+" matched "+substring(txt_file[jj],0,2)+leg_group+"!");
			
						//Creating the file with the headers in the subject folder ready to accept data   				
						txtResults = "D:/VASCO/MassA/real_study/data/output/TopoCell_data/tsv_files/IJ_centroid_output/";
						data_file = txtResults+txtFolder[j]+currentSubject+".tsv";
						if (File.exists(data_file)) {
							File.delete(data_file);
						}
						//File.append(txtResults+txtFolder[j], data_file); //File title
        				File.append("Cell_ID \t Area(µm) \t Feret min(µm)", data_file);  // Create header

						//Open and read the text file with coordinate data, obtain values 
        				text_file = File.openAsString(txtSource+txtFolder[j]+txt_file[jj]); 
						rows = split(text_file, "\n"); 
						Cell_ID = newArray(rows.length); 
						X_coord = newArray(rows.length);
						Y_coord = newArray(rows.length);
						for( i=rows.length-1 ; i > 0; i--){
							columns=split(rows[i],"\t"); 
							Cell_ID[i]=parseFloat(columns[0]); 
							X_coord[i]=parseFloat(columns[1]); 
							Y_coord[i]=parseFloat(columns[2]);
							print(data_file);
							print(Cell_ID[i]);
							print('X coordinate is :'+X_coord[i]);
							print('Y coordinate is :'+Y_coord[i]);
							doWand((3+(X_coord[i]/calib)), (3+(Y_coord[i]/calib)));
							getSelectionCoordinates(xCoordinates, yCoordinates);
							//waitForUser;

							List.setMeasurements;
							area = List.getValue("Area");
							shortAxis = List.getValue("MinFeret");
							print(shortAxis);
							//print ("Cell number "+Cell_ID[i]+" from subject "+currentSubject+" from "+txtFolder[j]);
							//print ("Area = "+area+"um      Short axis = "+shortAxis+"um   old area = "+old_area);
							//print(data_file);
							
				    		//Write down the data onto the file previously created if "conditions" are met. This "conditions" is a way to filter out unreal sized cells. 
				    		conditions = 60000;//square micrometers
				    		if (area<60000){
    							File.append("#"+Cell_ID[i]+" \t "+area+" \t "+shortAxis, data_file);
    							print ("Cell #"+Cell_ID[i]+" from subject "+currentSubject+" from "+txtFolder[j]);
								print ("Area = "+area+"um2      Short axis(minFeret) = "+shortAxis+"um");
								goodCells = goodCells+1;


								//Drawing feret line
								Roi.getFeretPoints(x,y);
  								//Overlay.drawLine(x[0], y[0], x[1], y[1]);
  								//Overlay.show();
  								Overlay.drawLine(x[2], y[2], x[3], y[3]);
  								Overlay.show();

								
								//marking analyzed cells for visual inpection if necessary
								run("Line Width...", "line=4");
								setForegroundColor(255, 0, 230);
								run("Draw", "slice");
								setForegroundColor(0, 185, 19);
								run("Fill", "slice");
								setForegroundColor(255, 255, 0);
								run("Specify...", "width=14 height=14 x="+(X_coord[i]/calib)+" y="+(Y_coord[i]/calib)+" oval constrain centered");
								run("Fill", "slice");
								setForegroundColor(10, 10, 10);
								run("Draw", "slice");
								setForegroundColor(0, 54, 255);
								run("Specify...", "width=7 height=7 x="+(X_coord[i]/calib)+" y="+(Y_coord[i]/calib)+" oval constrain centered");
								run("Fill", "slice");
								drawString(Cell_ID[i],(3+(X_coord[i]/calib)), ((Y_coord[i]/calib)-2));
								//close("Montage.tif");

				
    							//waitForUser("WROTE");
				    		}else{
				    			print ("WARNING BAD CELL!  Cell #"+Cell_ID[i]+" from subject "+currentSubject+" from "+txtFolder[j]);
				    			//waitForUser("WARNING BAD CELL! \n press OK to ontinue");
				    			badCells = badCells+1;
				    		}
						}	
					}
				}
			}
		saveAs("Tiff", imgSource+imgFolder[l]+"valid_cells_feret.tif");
		close();
		
	}
}		



x=100; y=200; 
  call("ij.gui.WaitForUserDialog.setNextLocation",x,y); 
  waitForUser("DONE!!!!!!! \n There where "+badCells+" ("+((badCells*100)/(goodCells+badCells))+"% of a total of "+(goodCells+badCells)+" cells) bad cells excluded from analysis. \n This took "+(getTime()-start)/1000/60+" MINUTES...GOOD JOB!!!"); 


