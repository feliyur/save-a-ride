#include <iostream>
#include <fstream>
#include <memory>
#include <iterator>
#include <vector>
#include <numeric>

#include <boost/lexical_cast.hpp>

using std::endl;
using std::cout;
using std::ifstream;
using std::ofstream;


const auto ELEMS = 1000; 

template <typename ITERATOR_TYPE>
std::ostream& subsample(std::istream& ist, ITERATOR_TYPE begin, ITERATOR_TYPE end, std::ostream& ost); 

int main(int argc, char const* argv[])
{
	if (argc < 3)
	{
		cout << "Invalid num of parameters!" << endl
			 << "Usage: analyze_data <source file> <num samples>" << endl;
		return 0;
	}

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

	ofstream ofile("first_" + boost::lexical_cast<std::string>(num_samples) + ".csv");
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
