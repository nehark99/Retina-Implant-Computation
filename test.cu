#include "process.cu"

#include <iostream>

using namespace std;


int main() {

    int size = 8*1024;
    double *A = (double *)malloc(size*sizeof(double));
    double *Z = (double *)malloc(size*sizeof(double));
    for (int i = 0; i < size; i++) {
        // cout << i << endl;
        A[i] = 0;
        Z[i] = 0;
    }

    _cudaGrayScaleImage(A, 8, 1024, Z, 8, 1024, 3);
    return 0;
}