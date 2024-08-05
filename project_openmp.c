#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <omp.h>

int* generateSubsets(int arr[], int n) {
    int i, j;
    int* sums = (int *)malloc(sizeof(int)*(1<<n));

    #pragma omp parallel for private(j)
    for (i = 0; i < (1 << n); i++) {
        int sum = 0;
        for (j = 0; j < n; j++) {
            if (i & (1 << j)) {
                sum += arr[j];
            }
        }
        sums[i] = sum;
    }
    return sums;
}

void have_answer(int arr[], int size, int target) {
    int found = 0;
    int num;
    #pragma omp parallel for shared(found)
    for (int i = 0; i < size; i++) {
        if (arr[i] == target) {
            #pragma omp atomic write
            found = 1;
            num = i;
        }
    }

    if (found){
        printf("i = %d\n",num);
        printf("The answer is: Yes\n");
    }
        
    else
        printf("The answer is: No\n");
}

int main(void) {
    int arr[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 2000;

    // Start time
    double start, end;
    start = omp_get_wtime();

    int *sum = generateSubsets(arr, n);

    printf("========================\n");

    // Print specific element
    printf("Find target %d\n",target);

    // Check for target
    have_answer(sum, 1 << n, target);

    // Stop time
    end = omp_get_wtime();
    double cpu_time_used = end - start;
    printf("Time taken: %f seconds\n", cpu_time_used);

    // Free allocated memory
    free(sum);

    return 0;
}
