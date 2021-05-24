
#include <vector>
#include <sstream>
#include <iostream>
#include <queue>
#include "a_class.h"

int main() {
	AClass<int> ac;
	std::stringstream ss;
	std::vector<int> v;
	ac.put(10);
	v.push_back(ac.get());
	ss << "something " << *v.begin() << std::endl;
	std::cout << ss.str();
	return 0;
}
// vi: ft=c++ ts=3 :
