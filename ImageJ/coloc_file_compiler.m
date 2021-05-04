        %IDENTIFYING VARIABLES TO BE ANALYZED:

% 1) colocalization of LDs with PLIN5




%OBTAINING THESE VARIABLES:

%Identifying sample folders for counting purposes
group_folder_dir = ('\\fileservices.ad.jyu.fi\homes\varufach\Desktop\research\Diabetic_study_for_TOPOCELL\data_for_ImageJ\');
group_folder_cont = dir (group_folder_dir);

%Give IDs to the respective groups
i=1;
for j=1:numel(group_folder_cont);
    if length(group_folder_cont(j).name) > 3;
        sample_mapping.group{i} = group_folder_cont(j).name
        mainStruct(i).group_ID = sample_mapping.group{i} %Starting to fill in the structure

        %List out number of images per sample
        for ii=1:numel(dir([group_folder_dir sample_mapping.group{i} '\']));
            current_group = dir([group_folder_dir sample_mapping.group{i} '\']);
            im = 1; %start image count per sample 
            for jj=3:numel(current_group);
                current_subject = current_group(jj).name
                stop
                for a=1
                    %Read file data and write every LDs vs PLIN5 data
                    %into Main Structure. Used both for calculating sample
                    %averages and future data inspection
                    dyst_lamp_file = ([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_' current_image_nr '_dyst_vs_LAMP2_coloc.txt']);
                    coloc_type = 'All_DYSTvsLAMP';
                    data = comma2point (dyst_lamp_file);
                    mainStruct = write_data (mainStruct, data, im, i, coloc_type, current_image_nr, dyst_lamp_file);
                    
                    %Read file data and write every dystrophin vs mTOR data
                    %into Main Structure. Used both for calculating sample
                    %averages and future data inspection
                    dyst_mtor_file = ([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_' current_image_nr '_dyst_vs_mTOR_coloc.txt']);
                    coloc_type = 'All_DYSTvsMTOR';
                    data = comma2point (dyst_mtor_file);
                    mainStruct = write_data (mainStruct, data, im, i, coloc_type, current_image_nr, dyst_mtor_file);
                    
                    %Read file data and write every dystrophin vs LAMP&mTOR data
                    %into Main Structure. Used both for calculating sample
                    %averages and future data inspection
                    dyst_lampplusmtor_file = ([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_' current_image_nr '_dyst_vs_mTOR&LAMP2_coloc.txt']);
                    coloc_type = 'All_DYSTvsLAMPplusMTOR';
                    data = comma2point (dyst_lampplusmtor_file);
                    mainStruct = write_data (mainStruct, data, im, i, coloc_type, current_image_nr, dyst_lampplusmtor_file);
                    
                    %Read file data and write every mTOR vs LAMP data
                    %into Main Structure. Used both for calculating sample
                    %averages and future data inspection
                    mtor_lamp_file = ([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_' current_image_nr '_mTOR_vs_LAMP2_coloc.txt']);
                    coloc_type = 'All_MTORvsLAMP';
                    data = comma2point (mtor_lamp_file);
                    mainStruct = write_data (mainStruct, data, im, i, coloc_type, current_image_nr, mtor_lamp_file);
                        
            
                    im = im + 1;
             
                    
                end;
            end;
            %write into mainStruct sample averages of several image values
            mainStruct(i).Avg_LAMP2vsDyst_tM = mean([mainStruct(i).All_DYSTvsLAMP.tM1]);
            mainStruct(i).Avg_DYSTvsLamp2_tM = mean([mainStruct(i).All_DYSTvsLAMP.tM2]);
            mainStruct(i).Avg_LAMP2vsDyst_int_percent = mean([mainStruct(i).All_DYSTvsLAMP.Ch1_Int_percent]);
            mainStruct(i).Avg_DYSTvsLamp2_int_percent = mean([mainStruct(i).All_DYSTvsLAMP.Ch2_Int_percent]);

            mainStruct(i).Avg_MTORvsDyst_tM = mean([mainStruct(i).All_DYSTvsMTOR.tM1]);
            mainStruct(i).Avg_DYSTvsMtor_tM = mean([mainStruct(i).All_DYSTvsMTOR.tM2]);
            mainStruct(i).Avg_MTORvsDyst_int_percent = mean([mainStruct(i).All_DYSTvsMTOR.Ch1_Int_percent]);
            mainStruct(i).Avg_DYSTvsMtor_int_percent = mean([mainStruct(i).All_DYSTvsMTOR.Ch2_Int_percent]);
            
            mainStruct(i).Avg_LAMP2plusMTORvsDyst_tM = mean([mainStruct(i).All_DYSTvsLAMPplusMTOR.tM1]);
            mainStruct(i).Avg_DYSTvsMtorlamp2_tM = mean([mainStruct(i).All_DYSTvsLAMPplusMTOR.tM2]);
            mainStruct(i).Avg_LAMP2plusMTORvsDyst_int_percent = mean([mainStruct(i).All_DYSTvsLAMPplusMTOR.Ch1_Int_percent]);
            mainStruct(i).Avg_DYSTvsMtorlamp2_int_percent = mean([mainStruct(i).All_DYSTvsLAMPplusMTOR.Ch2_Int_percent]);            

            mainStruct(i).Avg_LAMP2vsMtor_tM = mean([mainStruct(i).All_DYSTvsLAMP.tM1]);
            mainStruct(i).Avg_MTORvsLamp2_tM = mean([mainStruct(i).All_DYSTvsLAMP.tM2]);
            mainStruct(i).Avg_LAMP2vsMtor_int_percent = mean([mainStruct(i).All_MTORvsLAMP.Ch1_Int_percent]);
            mainStruct(i).Avg_MTORvsLamp2_int_percent = mean([mainStruct(i).All_MTORvsLAMP.Ch2_Int_percent]);
            
            mainStruct(i).Avg_LAMP2_signal = mean(dlmread([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_myocellular_LAMP2_content.tsv'], '', 'B2..B:'));
            mainStruct(i).Avg_MTOR_signal = mean(dlmread([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_myocellular_MTOR_content.tsv'], '', 'B2..B:'));
            mainStruct(i).Avg_Dyst_signal = mean(dlmread([sample_folder_dir sample_mapping.ID{i} '\' sample_mapping.ID{i} '_NO_cytosolic_dyst_content.tsv'], '', 'B2..B:'));
            
        end;
        i=i+1;
    end;
end;

% %Arranging and creating groups for later statistical analysis
% %Group subjects into respective rat lines
% yhcr = [{[101   102   105   108   109   112   114   115   116   118   121   122   123 125   127   131   132   134   135   137   140   143   144]}]
% ylcr = [{[100   103   104   106   107   110   111   113   117   119   120   124   126 128   129   130   133   136   138   139   141   142]}]
% ohcr = [{[202   203   207   208   209   211   213   215   217   219   220   222   224 226   228   230   232   234   236   238]}]
% olcr = [{[200   201   204   205   206   210   212   214   216   218   221   223   225 227   229   231   233   235   237]}]
% 

% %WRITING FINAL TABLE

T = struct2table(mainStruct);
T = [T(:,1) T(:,6:24)];
writetable(T,'DataFile.txt','Delimiter',' ');

%point2comma_overwrite ('DataFile.txt');
