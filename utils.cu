#include <stdio.h>
#include <iostream>
using namespace std;


void print(string prefix, int h, int w, double *A, int row, int cols) {

  cout << "\t" << prefix << "      ";

  for (int i = w*row; i < cols+w*row; i++)
    printf("(%d, %s%f),      ", i, (A[i] >= 0) ? "+" : "", A[i] );

  cout << "|      ";

  for (int i = w*row+w-cols; i < w*row+w; i++)
    printf("(%d, %s%f),      ", i, (A[i] >= 0) ? "+" : "", A[i] );

  cout << endl;
}

void printAll(string prefix, int h, int w, double *A) {
  int show = 2;
  int cols = 2;

  for (int i = 0; i < show; i++) {
    print(prefix, h, w, A, i, cols);
  }

  string line(cols*50, '_');
  cout << "                " << line << "\n";

  for (int i = h-show; i < h; i++) {
    print(prefix, h, w, A, i, cols);
  }
  cout << endl;
}

__device__ void insertion_sort(int n, int A[]) {
  for (int i = 1; i < n; i++) {
      int key_item = A[i];
      int j = i - 1;
      while (j >= 0 && A[j] > key_item) {
          A[j + 1] = A[j];
          j -= 1;
      }
      A[j + 1] = key_item;
  }
}

/**
 * @brief  Finding the Median of the 4 surrounding values and current value
 *
 * @param C Current
 * @param N North
 * @param E East
 * @param S South
 * @param W West
 * @return int for current location
 */
__device__ int median(int C, int N, int E, int S, int W) {
  int arr[] = {C, N, E, S, W};
  insertion_sort(5, arr);
  return arr[2];
}


/**
 * This is the implementation not using __shared__ memory, just accessing id - n and id + n
 */
__device__ void update(int n, int idx, int *Z, int *A)
{
  int x = idx % n;
  int y = idx / n;

  if (idx >= n*n) {
    // printf("idx(%d) >= n*n at: (x: %d, y: %d)\n", idx, x, y);
    return;
  }

  if ((y == 0) || (y == (n-1)) || (x == 0) || (x == (n-1))) {
    Z[idx] = A[idx];
  } else {
    Z[idx] = median(
        A[idx],
        A[idx - n],
        A[idx + 1],
        A[idx + n],
        A[idx - 1]
      );
  }
}

__device__ void getConstraints(int height, int width, int id, int threads, int bid, int blockStart, int blockSize, int* start, int* stop) {
  //int start, stop;

  int chunkSize = (height*width / threads); // 1000000/8195 = 122
  int remaining_nodes = height*width % threads;  // 576

  if (id < remaining_nodes) {
    chunkSize += 1;
    *start = chunkSize * id;  // 0, 123
    *stop = chunkSize * (id + 1);  // 123, 246

  } else {
    *start = remaining_nodes + chunkSize * id; // (576 + 122 * 577)
    *stop = remaining_nodes + chunkSize * (id + 1);

  }


}

// __global__ void iterations(int n, int threads, int *Z, int *A) {
//   int id = blockIdx.x * blockDim.x + threadIdx.x;
//   int blockStart = blockIdx.x * blockDim.x;

//   //if (id ==0) {
//   //  printf("Helllllloooooo");
//   //}
//   int start;
//   int stop;
//   getConstraints(n, id, threads, blockIdx.x, blockStart,  blockDim.x, &start, &stop);
//   // printf("ID: %d, blockStart: %d, Start: %d, Stop: %d\n", id, blockStart, start, stop);

//   for (int i = start; i < stop; i++) {
//     update(n, i, Z, A);
//   }

// }


/*
  Or Job (GPU):
    5 MINS:   salloc --account=eecs587f21_class --nodes=1 --gres=gpu --partition=gpu --time=00:05:00 --mem-per-cpu=5g
    1 HOUR:   salloc --account=engin1 --nodes=1 --gres=gpu --partition=gpu --mem-per-cpu=5g
  
  :
    module load cuda

  Running:
    nvcc -arch=sm_70 -std=c++11 main.cu && ./a.out <int:n>
*/


/**
 * @brief nvcc -arch=sm_70 -std=c++11 main.cu && ./a.out <int:n>
 *
 * @param argc
 * @param argv
 * @return int
 */
// int main(int argc, char const *argv[]) {




int idx3(int i, int j, int k, int h, int w) {
    return (i*w + j) * 3 + k;
    return i*h*w + j*w + k;
}
int idx2(int i, int j, int w) {
    return i*w + j;
}
int idx1(int i) {
    return i;
}

// void printMatrix3(numpyArray<double> a)
// {
//     Ndarray<double, 3> arr(a);

//     int rows = 5;
//     int cols = 5;
//     int ks = 1;

// 	for (int i = 0; i < rows; i++)
// 	{	
// 		cout << "\t" << "[";
// 		for (int j = 0; j < cols; j++)
// 		{
//             for (int k = 0; k < ks; k++)
//             {
//                 cout << arr[i][j][k] << "\t";
//             }
// 		}
// 		cout << "]" << endl;
// 	}
// }

// void printMatrix2(numpyArray<double> a)
// {
//     Ndarray<double, 2> arr(a);

//     int rows = 5;
//     int cols = 5;

//     for (int i = 0; i < rows; i++)
//     {	
//       cout << "\t" << "[";
//       for (int j = 0; j < cols; j++)
//       {
//           cout << arr[i][j] << "\t";
//       }
//       cout << "]" << endl;
//     }
// }

// cout << "Y(" << i << ")" << ", X(" << j << "), x(" << idx3(i, j, 0, x_h, x_w) << "), y(" << idx2(i, j, y_w) << ") :: ";
// cout << "["; 
// cout << x[idx3(i, j, 0, x_h, x_w)] << ", ";
// cout << x[idx3(i, j, 1, x_h, x_w)] << ", ";
// cout << x[idx3(i, j, 2, x_h, x_w)] << "]";
// cout << endl;