#pragma once

#include "b_class.h"



template<class T>
class AClass {
public:
	T get() {
		T f=vs.front();
		vs.pop();
		std::cout << "returning " << f << std::endl;
		return f;
	}
	void put(T v) {
		vs.push(std::move(v));
	}
private:
	std::queue<T> vs;
	BClass bc;
};

// vi: ft=c++ ts=3 :
