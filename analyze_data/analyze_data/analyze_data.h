#pragma once

#include <iostream>
#include <fstream>
#include <random>

#include <boost/optional.hpp>

class AnalyzeData
{
	class handled_exception : std::exception {};
public:
	AnalyzeData() :
		m_RequestedCommand(CommandType::NoCommand), m_InfileHasHeader(true) {}

	int main(int argc, char const* argv[]); 

private:
	enum CommandType { NoCommand, RandomSample, CropData, DataInfo };

	//struct DataFormat; 

	//friend std::istream& operator>>(std::istream& ist, DataFormat& ldt);
	//friend std::ostream& operator<<(std::ostream& ost, DataFormat& ldt);

	void parseArguments(int argc, char const* argv[]); 


	std::ostream& printUsage(std::ostream& ost); 


	CommandType parseMode(std::string cmd);


	void randomSample();


	void cropData();

	std::ostream& filterRecords(std::ostream& ost, std::istream& ist);

	void dataInfo();

	std::ifstream loadInFile();
	std::ofstream loadOutFile();


	CommandType m_RequestedCommand;

	std::default_random_engine generator;
	std::uniform_int_distribution<int> distribution;

	boost::optional<double> m_TimeStart,
		m_TimeEnd;

	boost::optional<unsigned int> m_NumSamples, m_Seed, m_RecordCountReportInterval;

	boost::optional<std::string> m_Outfile, m_Infile;

	bool m_InfileHasHeader;

}; 


/* End of file */

