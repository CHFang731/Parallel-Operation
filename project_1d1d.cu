#include <stdio.h>
#include <sys/time.h>
#include <stdbool.h>
#include <stdlib.h>
#include <cuda_runtime.h>
//Time complexity is O(2^n)


__global__ void generateSubsetsOnGPU_1D1D_v1(int *MatA, bool *MatB, int nx)
{ 
	unsigned int index = threadIdx.x + blockIdx.x * blockDim.x;
	int sum=0;
    for (int j = 0; j < nx; j++) 
    {
        
        if (index & (1 << j)) 
        {      
            sum += MatA[j];
        }
        
        //sum+= ((index>>j) & 1) *MatA[j];
    }
        //printf("Subset %d: Sum = %d\n", ++count, sum);
        //use one-dim arr to store the sum of subset;
    MatB[index] = sum;
    
}



void have_answer(bool* subsetSums, int target) {
    if (subsetSums[target]) {
        printf("The answer is: Yes\n");
    } else {
        printf("The answer is: No\n");
    }
}


int main(void) {
    
    //testing arr
    int arr[] = {1,2,3};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    int target = 6;

    //set up device
    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
	printf("Using Device %d: %s\n", dev, deviceProp.name);
	cudaSetDevice(dev);

    //data-dim nx
    int nx = n;
    int nBytes = (6+1)*sizeof(bool);
    bool  *gpuRef;
    gpuRef = (bool *)malloc(nBytes);

    //start time
    clock_t start, end;
    double cpu_time_used;
    start = clock();

    //initial the user data
    memset(gpuRef, false, nBytes);
    int  *d_arr;
    bool *d_sum_of_subset;
    cudaMalloc((void**)&d_arr,n*sizeof(int));
    cudaMalloc((void**)&d_sum_of_subset, nBytes);


    //transfer data from host to device
    cudaMemcpy(d_arr, arr, n*sizeof(int), cudaMemcpyHostToDevice);

    // 1D1D
    int dimx11v1 = 1024; int dimy11v1 = 1;
	dim3 block11v1(dimx11v1, dimy11v1);
	dim3 grid11v1(((1<<n)+block11v1.x-1)/block11v1.x);

    


    generateSubsetsOnGPU_1D1D_v1 <<< grid11v1, block11v1 >>>(d_arr, d_sum_of_subset, nx);
    
    printf("========================\n");

    cudaMemcpy(gpuRef, d_sum_of_subset, nBytes, cudaMemcpyDeviceToHost);

    
    
    //check the arr number

    //printf("arr[] = %d\n",gpuRef[1048576-1]);//the last number
    //print all the number of gpuRef
    /*
    for(int i=0;i<(1<<n);i++)
    {
        printf("arr[%d] = %d\n", i,gpuRef[i]);
    }
    */
    printf("Find target %d\n",target);
    have_answer(gpuRef, 1<<nx , target);
   

    //stop time
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %f seconds\n", cpu_time_used);


    cudaFree(d_arr);
    cudaFree(d_sum_of_subset);
    free(gpuRef);
    cudaDeviceReset();
    return 0;
}