#include <stdio.h>
#include <time.h>
#include <stdlib.h>
//Time complexity is O(2^n)







int* generateSubsets( int arr[], int n) {
    int i, j;
    int count = 0;
    int* sums = (int *)malloc(sizeof( int)*(1<<n));

    for (i = 0; i < (1 << n); i++) 
    { 
        int sum = 0;
        for (j = 0; j < n; j++) 
        {
            if (i & (1 << j)) 
            {      //like one-hot ex. i==110,1<<j==001,010,100, then subset is {2,3},sum is 5
                sum += arr[j];
            }
        }
        //printf("Subset %d: Sum = %d\n", ++count, sum);
        //use one-dim arr to store the sum of subset;
        sums[i] = sum;
        
    }
    return sums;
}


void have_answer( int arr[], int size, int target)
{
    for(int i=0;i<size;i++)
    {
        if(arr[i] == target)
        {   
            printf("i = %d\n",i);
            printf("The answer is: Yes\n");
            
            return;
        }
    }
    printf("The answer is: No\n");
}


int main(void) {
    
    //testing arr
    int arr[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    int target = 2000;

    //start time
    clock_t start, end;
    double cpu_time_used;
    start = clock();

    int *sum = generateSubsets(arr,n);
    
    

    //initial the user data
    
    printf("========================\n");

    
    //check the arr number

    //printf("arr[] = %d\n",gpuRef[1048576-1]);//the last number
    //print all the number of gpuRef
    /*
    for(int i=0;i<(1<<n);i++)
    {
        printf("arr[%d] = %d\n", i,sum[i]);
    }
    */
    printf("Find target %d\n",target);
    have_answer(sum, 1<<n , target);
   

    //stop time
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %f seconds\n", cpu_time_used);
    return 0;
}