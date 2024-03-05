/*  C++ program to Count number of times a function is called  */

#include <iostream>
using namespace std;
class square
{
private:
    int n, r;
    float n1, r1;
    static int b;

public:
    void input();
    void calc();
    void display();
};
int square::b = 0;
void square::input()
{
    cout << "Enter an integer:";
    cin >> n;
    cout << "Enter a float no.:";
    cin >> n1;
    b++;
}
void square::calc()
{
    r = n * n;
    r1 = n1 * n1;
    b++;
}
void square::display()
{
    cout << "Square of integer:" << r;
    cout << "\nSquare of float:" << r1;
    cout << "\nFunction is called " << b << " times by the objects";
}

int main()
{
    square s;
    s.input();
    s.calc();
    s.display();
}