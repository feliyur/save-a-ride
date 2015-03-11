function addll()

if ~libisloaded('analyze_data')
    loadlibrary('analyze_data\x64\Release\analyze_data.dll', 'analyze_data\analyze_data\analyze_data_api.h')
end

