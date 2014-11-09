function get_databases_info(database_files)
    for ii=1:numel(database_files)
        info = get_info_for_file(database_files{ii}); 
        save(info.original_datafile_name, 'info'); 
    end
end
