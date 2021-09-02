#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <unistd.h>
#include "i2c_wrapper.h"

void checkHandles(int u1, int u2){
  if (u1 <0 || u2 < 0) {
  	std::cerr << "Could not open i2c to IC's u1 and u2" << std::endl;
		exit(1);
	}
}

void parseFile(const char *fileName, std::vector<std::pair<unsigned int, unsigned int>> *step){
  std::ifstream file(fileName);
  std::string line;

  while(std::getline(file, line)){
    std::istringstream linestream(line);
    std::stringstream ss;
    std::string data;

    unsigned int msDelay;
    unsigned int hexValue;

    std::getline(linestream, data, ' ');
    ss << data;
    ss >> msDelay;

    ss.clear();
    std::getline(linestream, data, ' ');
    ss << std::hex << data;
    ss >> hexValue;

    step->push_back( std::make_pair(msDelay, hexValue) );
  }
}

int main(int argc, char **argv){
  std::vector<std::pair<unsigned int, unsigned int>> *step = new std::vector<std::pair<unsigned int, unsigned int>>();;

	gpioInitialise();
	int u1 = i2cOpen(1, 0x20, 0);
	int u2 = i2cOpen(1, 0x21, 0);

	checkHandles(u1, u2);
	if (argc < 2){
    std::cerr << "Usage " << argv[0] << " <ledshow.cfg>" << std::endl;
		exit(1);
	}

	setAllPortsToOutput(u1, u2);
	
	parseFile(argv[1], step);

	while(1) {
		for ( auto s : *step){
			set32BitValue(u1, u2, s.second);
			usleep(s.first * 1000);
		}
	}

	return 0;
}
