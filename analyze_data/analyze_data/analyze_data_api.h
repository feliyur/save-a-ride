#pragma once

#ifdef ANALYZE_DATA_EXPORTS
#	define ANALIZE_DATA_API_LINKAGE __declspec(dllexport)
#else
#	define ANALIZE_DATA_API_LINKAGE __declspec(dllimport)
#endif

// Compatibility function with old exe interface
// here argv is just a concatenation of all arguments 
ANALIZE_DATA_API_LINKAGE int analyze_data(int argc, char const* argv);

struct sGridInfo {
	double base_longitude, 
		   base_latitude, 
		   base_time; 

	double step_longitude, 
		   step_latitude, 
		   step_time; 

	long num_cells_longitude,
		num_cells_latitude;
	// we need no end_time since it is the last dimension
};

ANALIZE_DATA_API_LINKAGE long recordIdx(struct sGridInfo* grid, double lon, double lat, double time);
ANALIZE_DATA_API_LINKAGE int recordIdx(struct sGridInfo* grid, double* records_lon_lat_time, int num_records, long* res);

/* End of file */
