#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define BLOCK_SIZE 256

__global__ void subsetSum(int *d_arr, bool *d_subsetSums, int n, int target) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < (1 << n)) {  // Iterate over all possible subsets using bitmasking
        int subsetSum = 0;
        for (int i = 0; i < n; ++i) {
            if (idx & (1 << i)) {  // Check if ith element is in the subset
                subsetSum += d_arr[i];
            }
        }
        if (subsetSum <= target) {
            d_subsetSums[subsetSum] = true;
        }
    }
}

// Function to get current time in microseconds
long long getCurrentTime() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000000LL + tv.tv_usec;
}

int main(int argc, char *argv[]) {
    int arr[] = {1, 2, 3, 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 2000;

    // Allocate memory on the device
    int *d_arr;
    bool *d_subsetSums;
    cudaMalloc((void **)&d_arr, n * sizeof(int));
    cudaMalloc((void **)&d_subsetSums, (target + 1) * sizeof(bool));

    // Copy input data from host to device
    cudaMemcpy(d_arr, arr, n * sizeof(int), cudaMemcpyHostToDevice);

    // Start timing
    long long startTime = getCurrentTime();

    // Launch kernel
    int numBlocks = (1 << n) / BLOCK_SIZE + 1;
    subsetSum<<<numBlocks, BLOCK_SIZE>>>(d_arr, d_subsetSums, n, target);

    // Stop timing
    cudaDeviceSynchronize();
    long long endTime = getCurrentTime();
    double totalTime = (endTime - startTime) / 1000000.0;  // Convert microseconds to seconds

    // Copy result back to host
    bool *subsetSums = (bool *)malloc((target + 1) * sizeof(bool));
    cudaMemcpy(subsetSums, d_subsetSums, (target + 1) * sizeof(bool), cudaMemcpyDeviceToHost);

    // Check if there exists a subset with sum equal to target
    if (subsetSums[target]) {
        printf("The answer is: Yes\n");
    } else {
        printf("The answer is: No\n");
    }

    printf("Time taken: %f seconds\n", totalTime);

    // Cleanup
    free(subsetSums);
    cudaFree(d_arr);
    cudaFree(d_subsetSums);

    return 0;
}
