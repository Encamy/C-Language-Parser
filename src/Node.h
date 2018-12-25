#ifndef NODE_H
#define NODE_H

#include <string>
#include <vector>
#include <iostream>

class Node 
{
protected:
	std::vector<Node *> children;
public:
	std::string name;
	std::string value;
	
	Node(std::string name, std::string value="")
	{
		this->name = name; 
		this->value = value; 
	}
	
	void addChild(Node * child) 
	{
		if (!child) return;
		children.push_back(child);
	}
	
	void print(int l=0) 
	{
		for (int i = 0; i < l; ++i)
		{
			std::cout << " |";
		}
		std::cout << name << ' ' << value << std::endl;
		for (int i = 0; i < children.size(); ++i) 
		{
			if (!children[i]) continue;
			children[i]->print(l+1);
		}
	}
	
};

#endif
