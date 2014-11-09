function stats = process_datafile(sample_file, XY_TOLERANCE_VEC, T_TOLERANCE_VEC)
    %% load data
    disp(['loading file "' sample_file '" ']); 
    
    [PATHSTR,NAME,EXT] = fileparts(sample_file); 
    switch EXT
        case '.mat' 
            load(sample_file); 
        otherwise
            myDB = load_dataset(sample_file); 
    end

    [myDB stats] = process_dataset(myDB, XY_TOLERANCE_VEC, T_TOLERANCE_VEC); 
end

