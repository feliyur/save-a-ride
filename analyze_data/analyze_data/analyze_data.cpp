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
	case CommandType::SplitData:
		splitData(); 
		break;
	default:
		cout << "Unrecognized command! id '" << m_RequestedCommand << "' " << endl;
		throw handled_exception();
	}
	return 0;
}
catch (handled_exception&)
{
	return 0;
}

namespace boost {
	template<>
	bool lexical_cast<bool, std::string>(const std::string& arg) {
		std::istringstream ss(arg);
		bool b;
		ss >> std::boolalpha >> b;
		return b;
	}

	template<>
	std::string lexical_cast<std::string, bool>(const bool& b) {
		std::ostringstream ss;
		ss << std::boolalpha << b;
		return ss.str();
	}
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
		else if ("-append" == param_name)
			m_AppendOutFile = boost::lexical_cast<bool>(param_val);
		else if ("-interval" == param_name)
			m_Interval = boost::lexical_cast<double>(param_val); 
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
	else if ("crop"  == cmd)
		return CommandType::CropData;
	else if ("info"  == cmd)
		return CommandType::DataInfo;
	else if ("split" == cmd)
		return CommandType::SplitData; 

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

	if (m_InfileHasHeader)
	{
		std::string line;
		std::getline(ifile, line);
		ofile << line << endl;
		//ist.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
	}

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
	{
		std::string line; 
		std::getline(ist, line); 
		ost << line << endl;
		//ist.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
	}

	DataFormat data_line;

	int num_records = 0; 

	while (ist)
	{
		ist >> data_line;

		bool inside_limits = true;

		if (m_TimeStart)
			inside_limits = inside_limits && data_line.m_StartTime >= m_TimeStart.get();

		if (m_TimeEnd)
			inside_limits = inside_limits && data_line.m_EndTime <= m_TimeEnd.get();

		if (inside_limits)
			ost << data_line << endl;

		++num_records; 

		if (m_RecordCountReportInterval && (num_records%m_RecordCountReportInterval.get() == 0))
			cout << "processed " << num_records << " records" << endl;

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


void AnalyzeData::splitData()
{
	if (!m_TimeStart || !m_Interval || !m_Outfile)
	{
		cout << "cannot split data: start time, interval or out filename not specified.  " << endl;
		throw handled_exception();
	}

	auto ifile = loadInFile();

	auto out_filename = m_Outfile.get();

	DataFormat record;
	const auto BASE_TIME = m_TimeStart.get();
	const double INTERVAL = m_Interval.get();

	std::map<long, std::unique_ptr<std::ostream>> outfiles;

	std::string header;
	if (m_InfileHasHeader)
		std::getline(ifile, header);

	int num_records = 0; 

	while (ifile >> std::ws)
	{
		ifile >> record; 
		long idx = long(std::floor(double(record.m_StartTime - BASE_TIME) / INTERVAL)); 

		auto it = outfiles.find(idx); 
		if (outfiles.end() == it)
		{
			auto outfilepath = out_filename + "_" + boost::lexical_cast<std::string>(idx) + ".csv"; 
			it = outfiles.emplace(std::make_pair(idx, std::unique_ptr<std::ostream>(new ofstream(outfilepath.c_str(), m_AppendOutFile ? std::ios_base::app : std::ios_base::out)))).first;
			if (m_InfileHasHeader)
				(*it->second) << header << endl; 
		}

		(*it->second) << record << endl; 

		++num_records; 

		if (m_RecordCountReportInterval && (num_records%m_RecordCountReportInterval.get() == 0))
			cout << "processed " << num_records << " records" << endl;
	}
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

	ofstream ofile(outfilepath.c_str(), m_AppendOutFile ? std::ios_base::app : std::ios_base::out);
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
