//  process.cpp
//  https://www.geeksforgeeks.org/how-to-call-c-c-from-python/

// Cuda Downloads
// https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html

#include <iostream>

#include "utils.cu"


__global__ void cudaGrayScale(double *y, int y_h, int y_w, double *x, int x_h, int x_w, int x_d, int threads) {

    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int blockStart = blockIdx.x * blockDim.x;

    if (id == 0) {
        printf("Helllllloooooo");
    }

    int start;
    int stop;
    getConstraints(y_h, y_w, id, threads, blockIdx.x, blockStart,  blockDim.x, &start, &stop);
    printf("ID: %d, blockStart: %d, Start: %d, Stop: %d\n", id, blockStart, start, stop);

    // 0.2989 * r + 0.5870 * g + 0.1140 * b

    y[0] = 255;

}

__global__ void kernalTest(double *A) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    // if (id < 8)
    A[0] = id;
}

bool _cudaGrayScaleImage(double *y, int y_h, int y_w, double *x, int x_h, int x_w, int x_d) {


    int blocks = 8;  // 65535   thread.x, thread.y
    int threadsPerBlock = 1024;
    int totalThreadCount = blocks * threadsPerBlock; // 8196

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int y_size = y_h * y_w * sizeof(double);
    int x_size = x_h * x_w * x_d * sizeof(double);

    // copying matrix into GPU
    double *cuda_y, *cuda_x;
    cudaMalloc(&cuda_y, y_size);
    cudaMalloc(&cuda_x, x_size);
    cudaMemcpy(cuda_y, y, y_size, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_x, x, x_size, cudaMemcpyHostToDevice);
    // printAll("y:", y_h, y_w, y);
    // printAll("x:", x_h, x_w, x);

    cudaEventRecord(start);

    // Execute Kernal
    // cudaGrayScale<<< blocks, threadsPerBlock >>>(y, y_h, y_w, x, x_h, x_w, x_d, totalThreadCount);
    kernalTest<<< blocks, threadsPerBlock >>>(y);

    cudaDeviceSynchronize();
    cudaEventRecord(stop);


    // All Done, Get anwer from GPU
    cudaMemcpy(y, cuda_y, y_size, cudaMemcpyDeviceToHost);
    // cudaMemcpy(x, cuda_x, x_size, cudaMemcpyDeviceToHost);
    printAll("y:", y_h, y_w, y);
    // printAll("x:", x_h, x_w, x);


    cudaFree(cuda_y);
    cudaFree(cuda_x);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cout << endl << "Time(milli) = " << milliseconds << endl << endl;

    return true;
}

