#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// Time complexity is O(2^n)

__global__ void generateSubsetsOnGPU_1D1D_v1(int *MatA, int *MatB, int nx)
{
    unsigned int index = threadIdx.x + blockIdx.x * blockDim.x;
    int sum = 0;
    for (int j = 0; j < nx; j++)
    {
        if (index & (1 << j))
        {
            sum += MatA[j];
        }
    }
    MatB[index] = sum;
}

void have_answer(int arr[], int size, int target)
{
    for (int i = 0; i < size; i++)
    {
        if (arr[i] == target)
        {
            printf("i = %d\n",i);
            printf("The answer is: Yes\n");
            return;
        }
    }
    printf("The answer is: No\n");
}

int main(void)
{

    // Testing arr
    int arr[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 2000;

    // Set up device
    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("Using Device %d: %s\n", dev, deviceProp.name);
    cudaSetDevice(dev);

    // Data-dim nx
    int nx = n;
    int nBytes = (1 << nx) * sizeof(int);
    int *gpuRef;

    // Start time
    clock_t start, end;
    double cpu_time_used;
    start = clock();

    // Allocate zero-copy memory 
    cudaHostAlloc((void **)&gpuRef, nBytes, cudaHostAllocMapped);
    memset(gpuRef, 0, nBytes);


    // Initial the user data
    int *d_sum_of_subset, *d_arr;
    cudaMalloc((void **)&d_arr, n * sizeof(int));
    cudaMalloc((void **)&d_sum_of_subset, nBytes);

    // Transfer data from host to device
    cudaMemcpy(d_arr, arr, n * sizeof(int), cudaMemcpyHostToDevice);
    cudaHostGetDevicePointer((void**)&d_sum_of_subset, (void *)gpuRef, 0);

    // 1D1D
    int dimx11v1 = 1024;
    int dimy11v1 = 1;
    dim3 block11v1(dimx11v1, dimy11v1);
    dim3 grid11v1(((1 << n) + block11v1.x - 1) / block11v1.x);

    generateSubsetsOnGPU_1D1D_v1<<<grid11v1, block11v1>>>(d_arr, d_sum_of_subset, nx);
    printf("Find target %d\n",target);
    printf("========================\n");

    //cudaMemcpy(gpuRef, d_sum_of_subset, nBytes, cudaMemcpyDeviceToHost);

    // Check the arr number
    have_answer(gpuRef, 1 << nx, target);

    // Stop time
    end = clock();
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %f seconds\n", cpu_time_used);

    // Free memory
    cudaFreeHost(gpuRef);
    cudaFree(d_arr);
    cudaFree(d_sum_of_subset);
    cudaDeviceReset();
    return 0;
}
