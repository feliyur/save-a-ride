#include <iostream>
#include <fstream>
#include <memory>
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

using std::endl;
using std::cout;
using std::ostream;
using std::ifstream;
using std::ofstream;


const auto ELEMS = 1000, FIELD_ELEMS = 50; 

std::ostream& get_permutations(std::ostream& ost, unsigned int n);

template <typename ITERATOR_TYPE>
std::ostream& subsample(std::istream& ist, ITERATOR_TYPE begin, ITERATOR_TYPE end, std::ostream& ost);


class AnalyzeData
{
	class handled_exception : std::exception {};
public:
	AnalyzeData() :
		m_RequestedCommand(CommandType::NoCommand) {}

	int main(int argc, char const* argv[])
	try {
		parseArguments(argc, argv); 

		switch (m_RequestedCommand)
		{
		case CommandType::NoCommand:
			cout << "No command provided! " << endl; 
			throw handled_exception(); 
		case CommandType::RandomSample:
			break; 
		case CommandType::CropData:
			break;
		default: 
			cout << "Unrecognized command! id '" << m_RequestedCommand << "' " << endl; 
			throw handled_exception(); 
		}

		unsigned int seed((unsigned int)time(0));
		if (argc >= 4)
			seed = boost::lexical_cast<unsigned int>(argv[3]);

		generator.seed(seed);

		auto dice = std::bind(distribution, generator);
		//{
		//	ofstream ofile("check_random.csv");
		//	for (int ii = 0; ii < 100000; ++ii)
		//		ofile << dice() << endl;
		//}

		std::string sourcefile(argv[1]);
		auto num_samples = boost::lexical_cast<int>(argv[2]);
		if (num_samples < 0)
		{
			cout << "Invalid num of samples!" << endl;
			return 0;
		}

		//auto filepath = "D:\\Fichiers\\this_year\\this_month\\4yaniv\\trip_data_8.csv\\trip_data_8.csv"; 
		auto filepath(sourcefile.c_str());
		ifstream ifile(filepath);
		if (ifile.fail())
		{
			cout << "Failed reading from file '" << filepath << "'. " << endl;
			return 0;
		}

		//auto num_lines = std::count(std::istreambuf_iterator<char>(ifile), std::istreambuf_iterator<char>(), '\n'); 

		std::vector<int> idx(num_samples);
		std::iota(idx.begin(), idx.end(), 0);

		ofstream ofile("first_" + boost::lexical_cast<std::string>(num_samples)+".csv");
		subsample(ifile, idx.begin(), idx.end(), ofile);

		//std::unique_ptr<char[]> buff(new char[ELEMS]);
		//std::fill_n(buff.get(), ELEMS, 0);

		//int ii(0); 
		//for (ii = 0; !ifile.eof(); ++ii)
		//{
		//	ifile.getline(buff.get(), ELEMS);
		//	//cout << buff.get() << endl; 
		//}
		//cout << "Has " << num_lines << " rows. " << endl;
		return 0;
	}
	catch (handled_exception&)
	{
		return 0;
	}

private:
	enum CommandType { NoCommand, RandomSample, CropData };

	void parseArguments(int argc, char const* argv[])
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
			else if ("-time_start" == param_name)
				m_TimeStart = boost::lexical_cast<double>(param_val);
			else if ("-time_end" == param_name)
				m_TimeEnd = boost::lexical_cast<double>(param_val);
			else if ("-num_samples" == param_name)
				m_NumSamples = boost::lexical_cast<unsigned int>(param_val);
			else if ("-seed" == param_name)
				m_Seed = boost::lexical_cast<unsigned int>(param_val);
			else if ("-o" == param_name || "-out" == param_name || "-outfile" == param_name || "-ofile" == param_name
				|| "-output" == param_name || "-out_file" == param_name || "-output_file" == param_name)
				m_Outfile = param_val;
			else if ("-i" == param_name || "-in" == param_name || "-infile" == param_name || "-ifile" == param_name
				|| "-input" == param_name || "-in_file" == param_name || "-input_file" == param_name)
				m_Infile = param_val;
			else {
				cout << "Unrecognized parameter '" << param_name << "' " << endl; 
				throw handled_exception(); 
			}
		}
	}


	ostream& printUsage(ostream& ost)
	{
		return ost << "Usage: " << endl
				   << "analyze_data.exe <source file> <num samples> [<seed>]" << endl
				   << "[] denotes optional parameter" << endl;
	}


	CommandType parseMode(std::string cmd)
	{
		std::transform(cmd.begin(), cmd.end(), cmd.begin(), ::tolower);
		if ("sample" == cmd)
			return CommandType::RandomSample;
		else if ("crop" == cmd)
			return CommandType::CropData; 

		return CommandType::NoCommand; 
	}


	void randomSample()
	{
		if (!m_NumSamples)
		{
			cout << "How many records do you need? no number of samples provided" << endl; 
			throw handled_exception(); 
		}
	}
 

	void cropData()
	{
		if (!m_Infile || !boost::filesystem::exists(m_Infile.get()) || !boost::filesystem::is_regular_file(m_Infile.get()))
		{
			cout << "No or invalid input file provided \"" << m_Infile << "\" " << endl;
			throw handled_exception();
		}
		if (!m_Outfile || (boost::filesystem::exists(m_Outfile.get()) && !boost::filesystem::is_regular_file(m_Outfile.get())))
		{
			cout << "No or invalid output file provided \"" << m_Outfile << "\" " << endl;
			throw handled_exception();
		}

		std::string infilepath(m_Infile.get()), outfilepath(m_Outfile.get()); 
		
		ifstream ifile(infilepath.c_str());
		if (ifile.fail())
		{
			cout << "Failed reading from file \"" << infilepath << "\". " << endl;
			throw handled_exception(); 
		}

		ofstream ofile(outfilepath.c_str(), std::ios_base::app); 
		if (ofile.fail())
		{
			cout << "Failed opening file for writing \"" << infilepath << "\". " << endl;
			throw handled_exception();
		}
	}

	std::ostream& filterRecords(std::ostream& ost, std::istream& ist)
	{
		std::unique_ptr<char[]> buff(new char[ELEMS]); 
		std::string field;
		
		while (ist)
		{
			ist.getline(buff.get(), ELEMS);

			std::istringstream isstr(buff.get()); 
			for (int ii = 0; ii < 5; ++ii)
				std::getline(isstr, field, ',');

			std::getline(isstr, field, ',');
			cout << field << endl; 
		}

		return ost; 
	}


	CommandType m_RequestedCommand;

	std::default_random_engine generator;
	std::uniform_int_distribution<int> distribution;

	boost::optional<double> m_TimeStart,
							m_TimeEnd; 

	boost::optional<unsigned int> m_NumSamples, m_Seed; 

	boost::optional<std::string> m_Outfile, m_Infile; 

} m_AnalyzeData;


int main(int argc, char const* argv[])
{
	return m_AnalyzeData.main(argc, argv); 
}


//std::ostream& get_permutations(std::ostream& ost, unsigned int n)
//{
//	const unsigned int NUM_PERMUTATIONS = n!; 
//
//	return ost; 
//}


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

/* End of file */
