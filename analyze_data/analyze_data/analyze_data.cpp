#include <iterator>
#include <vector>
#include <numeric>
#include <random>
#include <string>
#include <algorithm>

#include <boost/lexical_cast.hpp>
#include <boost/optional.hpp>
#include <boost/filesystem.hpp>
#include <boost/date_time.hpp>
#include <boost/date_time/local_time/local_date_time.hpp>

#include "analyze_data.h"

using std::endl;
using std::cout;
using std::ostream;
using std::ifstream;
using std::ofstream;

using namespace boost::date_time;
using namespace boost::local_time;
using namespace boost::posix_time;

#include "analyze_data.h"

const auto ELEMS = 1000, FIELD_ELEMS = 50;

std::ostream& get_permutations(std::ostream& ost, unsigned int n);

template <typename ITERATOR_TYPE>
std::ostream& subsample(std::istream& ist, ITERATOR_TYPE begin, ITERATOR_TYPE end, std::ostream& ost);

struct DataFormat {
	long m_StartTime, m_EndTime;

	friend std::istream& operator>>(std::istream& ist, DataFormat& ldt);
	friend std::ostream& operator<<(std::ostream& ost, DataFormat& ldt);

	DataFormat()
		: m_StartTime(0), m_EndTime(0), m_TimeInputFacet(),
		m_EpochDate(boost::gregorian::date(1970, Jan, 1))
	{
		m_TimeFormat.imbue(std::locale(m_TimeFormat.getloc(), new local_time_input_facet("%Y-%m-%d %H:%M:%S %ZP")));
	}

	std::istream& read(std::istream& ist)
	{
		local_date_time ldt_start(not_a_date_time), ldt_end(not_a_date_time);

		std::getline(ist, m_Line);

		std::istringstream isstr(m_Line);
		std::string field;

		for (int ii = 0; ii < 5; ++ii)
			std::getline(isstr, field, ',');

		std::getline(isstr, field, ',');
		m_TimeFormat.str(field); m_TimeFormat >> ldt_start;
		//if (ldt_start.is_not_a_date_time())
		//	cout << ldt_start << endl; 

		std::getline(isstr, field, ',');
		m_TimeFormat.str(field); m_TimeFormat >> ldt_end;
		//cout << ldt_end << endl;

		boost::posix_time::time_duration time_start = ldt_start.utc_time() - m_EpochDate,
			time_end = ldt_end.utc_time() - m_EpochDate;

		m_StartTime = time_start.total_seconds();
		m_EndTime = time_end.total_seconds();

		return ist;
	}

	std::ostream& write(std::ostream& ost)
	{
		return ost << m_Line;
	}

private:
	std::string m_Line;
	std::unique_ptr<local_time_input_facet> m_TimeInputFacet;
	std::stringstream m_TimeFormat;
	ptime m_EpochDate;
};

std::istream& operator>>(std::istream& ist, DataFormat& ldt);
std::ostream& operator<<(std::ostream& ost, DataFormat& ldt);

int AnalyzeData::main(int argc, char const* argv[])
try {
	parseArguments(argc, argv);

	switch (m_RequestedCommand)
	{
	case CommandType::NoCommand:
		cout << "No command provided! " << endl;
		throw handled_exception();
	case CommandType::RandomSample:
		randomSample();
		break;
	case CommandType::CropData:
		cropData();
		break;
	case CommandType::DataInfo:
		dataInfo();
		break;
	default:
		cout << "Unrecognized command! id '" << m_RequestedCommand << "' " << endl;
		throw handled_exception();
	}

	//unsigned int seed((unsigned int)time(0));
	//if (argc >= 4)
	//	seed = boost::lexical_cast<unsigned int>(argv[3]);

	//generator.seed(seed);

	//auto dice = std::bind(distribution, generator);
	////{
	////	ofstream ofile("check_random.csv");
	////	for (int ii = 0; ii < 100000; ++ii)
	////		ofile << dice() << endl;
	////}

	//std::string sourcefile(argv[1]);
	//auto num_samples = boost::lexical_cast<int>(argv[2]);
	//if (num_samples < 0)
	//{
	//	cout << "Invalid num of samples!" << endl;
	//	return 0;
	//}

	////auto filepath = "D:\\Fichiers\\this_year\\this_month\\4yaniv\\trip_data_8.csv\\trip_data_8.csv"; 
	//auto filepath(sourcefile.c_str());
	//ifstream ifile(filepath);
	//if (ifile.fail())
	//{
	//	cout << "Failed reading from file '" << filepath << "'. " << endl;
	//	return 0;
	//}

	////auto num_lines = std::count(std::istreambuf_iterator<char>(ifile), std::istreambuf_iterator<char>(), '\n'); 

	//std::vector<int> idx(num_samples);
	//std::iota(idx.begin(), idx.end(), 0);

	//ofstream ofile("first_" + boost::lexical_cast<std::string>(num_samples)+".csv");
	//subsample(ifile, idx.begin(), idx.end(), ofile);

	////std::unique_ptr<char[]> buff(new char[ELEMS]);
	////std::fill_n(buff.get(), ELEMS, 0);

	////int ii(0); 
	////for (ii = 0; !ifile.eof(); ++ii)
	////{
	////	ifile.getline(buff.get(), ELEMS);
	////	//cout << buff.get() << endl; 
	////}
	////cout << "Has " << num_lines << " rows. " << endl;
	return 0;
}
catch (handled_exception&)
{
	return 0;
}


void AnalyzeData::parseArguments(int argc, char const* argv[])
{
	if (argc < 3)
	{
		cout << "Invalid num of parameters!" << endl;
		printUsage(cout);
		throw handled_exception();
	}

	for (int ii = 1; ii < argc; ++ii)
	{
		std::string param_name = argv[ii];
		if (ii >= argc)
		{
			cout << "Invalid parameter/value pairs: no value for parameter '" << param_name << "' " << endl;
			throw handled_exception();
		}
		std::string param_val = argv[++ii];

		if ("-mode" == param_name)
		{
			m_RequestedCommand = parseMode(param_val);
			if (CommandType::NoCommand == m_RequestedCommand)
			{
				cout << "Invalid mode '" << argv[ii - 1] << "' " << endl;
				throw handled_exception();
			}
		}
		else if ("-time-start" == param_name)
			m_TimeStart = boost::lexical_cast<double>(param_val);
		else if ("-time-end" == param_name)
			m_TimeEnd = boost::lexical_cast<double>(param_val);
		else if ("-num-samples" == param_name)
			m_NumSamples = boost::lexical_cast<unsigned int>(param_val);
		else if ("-seed" == param_name)
			m_Seed = boost::lexical_cast<unsigned int>(param_val);
		else if ("-o" == param_name || "-out" == param_name || "-outfile" == param_name || "-ofile" == param_name
			|| "-output" == param_name || "-out-file" == param_name || "-output-file" == param_name)
			m_Outfile = param_val;
		else if ("-i" == param_name || "-in" == param_name || "-infile" == param_name || "-ifile" == param_name
			|| "-input" == param_name || "-in-file" == param_name || "-input-file" == param_name)
			m_Infile = param_val;
		else if ("-no-header" == param_name)
			m_InfileHasHeader = false;
		else if ("-count" == param_name)
			m_RecordCountReportInterval = boost::lexical_cast<unsigned int>(param_val);
		else {
			cout << "Unrecognized parameter '" << param_name << "' " << endl;
			throw handled_exception();
		}
	}
}


template <typename ITERATOR_TYPE>
std::ostream& subsample(std::istream& ist, ITERATOR_TYPE begin, ITERATOR_TYPE end, std::ostream& ost)
{
	std::unique_ptr<char[]> buff(new char[ELEMS]);

	for (auto it = begin; it != end; ++it)
	{
		auto cur_line = -1;
		while (++cur_line < *begin) {
			ist.getline(buff.get(), ELEMS);
		}
		ist.getline(buff.get(), ELEMS);
		ost << buff.get() << endl;
		++cur_line;
	}
	return ost;
}

ostream& AnalyzeData::printUsage(ostream& ost)
{
	return ost << "Usage: " << endl
		<< "analyze_data.exe <source file> <num samples> [<seed>]" << endl
		<< "[] denotes optional parameter" << endl;
}

AnalyzeData::CommandType AnalyzeData::parseMode(std::string cmd)
{
	std::transform(cmd.begin(), cmd.end(), cmd.begin(), ::tolower);
	if ("sample" == cmd)
		return CommandType::RandomSample;
	else if ("crop" == cmd)
		return CommandType::CropData;
	else if ("info" == cmd)
		return CommandType::DataInfo;

	return CommandType::NoCommand;
}

void AnalyzeData::randomSample()
{
	if (!m_NumSamples)
	{
		cout << "How many records do you need? no number of samples provided" << endl;
		throw handled_exception();
	}

	ifstream ifile = loadInFile();
	ofstream ofile = loadOutFile();

	std::vector<int> idx(m_NumSamples.get());
	std::iota(idx.begin(), idx.end(), 0);

	subsample(ifile, idx.begin(), idx.end(), ofile);
}

void AnalyzeData::cropData()
{
	ifstream ifile = loadInFile();
	ofstream ofile = loadOutFile();

	filterRecords(ofile, ifile);
}

std::ostream& AnalyzeData::filterRecords(std::ostream& ost, std::istream& ist)
{
	if (m_InfileHasHeader)
		ist.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	DataFormat data_line;

	while (ist)
	{
		ist >> data_line;

		bool inside_limits = true;

		if (m_TimeStart)
			inside_limits = inside_limits && data_line.m_StartTime >= m_TimeStart.get();

		if (m_TimeEnd)
			inside_limits = inside_limits && data_line.m_EndTime <= m_TimeEnd.get();

		if (inside_limits)
			ost << data_line;

		//// Write the time to stdout.
		//cout << "Full Time:\t" << ldt.to_string() << endl;
		//cout << "Next Time:\t" << (ldt+boost::posix_time::minutes(17)).to_string() << endl;
		//cout << "Local time:\t" << ldt.local_time() << endl;
		//cout << "Time zone:\t" << ldt.zone_as_posix_string() << endl;
		//cout << "Zone abbrev:\t" << ldt.zone_abbrev() << endl;
		//cout << "Zone offset:\t" << ldt.zone_abbrev(true) << endl;


		//boost::posix_time::ptime tt(boost::posix_time::from_iso_string(field));
		//cout << "now time: " << tt << endl; 
		//boost::gregorian::local_d
		//auto res = boost::date_time::parse_date(field); 
		//std::getline(isstr, field, ',');
		//cout << field << endl; 
	}

	return ost;
}

void AnalyzeData::dataInfo()
{
	auto ifile = loadInFile();
	auto ofile = loadOutFile();

	auto min_start_time = std::numeric_limits<long>::max(),
		max_end_time = std::numeric_limits<long>::min();

	int num_records = 0;

	DataFormat record;

	if (m_InfileHasHeader)
		ifile.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	// -----------------------------------------------------
	// ####### Count takes too long for large files... 
	//
	//auto total_num_records = std::count(std::istreambuf_iterator<char>(ifile),
	//	std::istreambuf_iterator<char>(), '\n');

	//if (m_RecordCountReportInterval)
	//	cout << "Total num records: " << total_num_records << endl;


	while (ifile >> std::ws)
	{
		++num_records;

		ifile >> record;

		//if (m_RecordCountReportInterval && (num_records%m_RecordCountReportInterval.get() == 0))
		//	cout << "processed " << num_records << " records " << double(num_records) / double(total_num_records) << endl;

		if (m_RecordCountReportInterval && (num_records%m_RecordCountReportInterval.get() == 0))
			cout << "processed " << num_records << " records" << endl;

		min_start_time = std::min(min_start_time, record.m_StartTime);
		max_end_time = std::max(max_end_time, record.m_EndTime);
	}

	auto EPOCH_DATE = ptime(boost::gregorian::date(1970, Jan, 1));
	ofile << "min_start_time" << "," << "max_end_time" << "," << "num_records" << endl
		<< std::setprecision(10)
		<< EPOCH_DATE + boost::posix_time::seconds(min_start_time) << "," << EPOCH_DATE + boost::posix_time::seconds(max_end_time) << "," << num_records << endl;
}

ifstream AnalyzeData::loadInFile()
{
	if (!m_Infile || !boost::filesystem::exists(m_Infile.get()) || !boost::filesystem::is_regular_file(m_Infile.get()))
	{
		cout << "No or invalid input file provided \"" << (m_Infile ? m_Infile.get() : "") << "\" " << endl;
		throw handled_exception();
	}

	std::string infilepath(m_Infile.get());

	ifstream ifile(infilepath.c_str());
	if (ifile.fail())
	{
		cout << "Failed reading from file \"" << infilepath << "\". " << endl;
		throw handled_exception();
	}

	return ifile;
}

ofstream AnalyzeData::loadOutFile()
{
	if (!m_Outfile || (boost::filesystem::exists(m_Outfile.get()) && !boost::filesystem::is_regular_file(m_Outfile.get())))
	{
		cout << "No or invalid output file provided \"" << (m_Outfile ? m_Outfile.get() : "") << "\" " << endl;
		throw handled_exception();
	}

	std::string outfilepath(m_Outfile.get());

	ofstream ofile(outfilepath.c_str(), std::ios_base::app);
	if (ofile.fail())
	{
		cout << "Failed opening file for writing \"" << outfilepath << "\". " << endl;
		throw handled_exception();
	}

	return ofile;
}

std::istream& operator>>(std::istream& ist, DataFormat& ldt)
{
	return ldt.read(ist);
}

std::ostream& operator<<(std::ostream& ost, DataFormat& ldt)
{
	return ldt.write(ost);
}

/* End of file */ 
