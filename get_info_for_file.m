function info = get_info_for_file(datafile)

 [PATHSTR,NAME,EXT] = fileparts(datafile);
info_file = [NAME '-info.csv']; 
tic
eval(['!analyze_data.exe -mode info -append false -in "' datafile '" -out "' info_file '" -count 10000']); 
toc
info = load_datafile_info(info_file);
info.original_datafile=datafile; 
info.original_datafile_name = NAME; 
delete(info_file); 
