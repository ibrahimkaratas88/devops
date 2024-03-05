/* C++ Program to Find Factorial of a number using recursion */

#include<iostream>
using namespace std;

int factorial(int n);

int main()
{
    int n;

    cout << "\nEnter any positive integer :: ";
    cin >> n;

    cout << "\nFactorial of [ " << n << " ]  =  [ " << factorial(n)<<" ]\n";

    return 0;
}

int factorial(int n)
{
    if(n > 1)
        return n * factorial(n - 1);
    else
        return 1;
}