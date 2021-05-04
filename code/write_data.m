
function [mainStruct] = write_data(mainStruct, data, im, i, coloc_type, current_image_nr, sample_folder_dir)

       mainStruct(i).(coloc_type)(im).img_nmr = current_image_nr;
       mainStruct(i).(coloc_type)(im).tot_vol = str2num(data{13});
       mainStruct(i).(coloc_type)(im).tM1 = str2num(data{10});
       mainStruct(i).(coloc_type)(im).tM2 = str2num(data{11});
       mainStruct(i).(coloc_type)(im).Ch1_Vol_percent = str2num(data{14});
       mainStruct(i).(coloc_type)(im).Ch2_Vol_percent = str2num(data{15});
       mainStruct(i).(coloc_type)(im).Ch1_Int_percent = str2num(data{16});
       mainStruct(i).(coloc_type)(im).Ch2_Int_percent = str2num(data{17});
       mainStruct(i).(coloc_type)(im).folder_link = sample_folder_dir;
       
end
   