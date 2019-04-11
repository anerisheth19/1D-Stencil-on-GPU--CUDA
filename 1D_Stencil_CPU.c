//ECGR 6090 Heterogeneous Computing Homework 0
// Problem 2 a - 1D Stencil on CPU
//Written by Aneri Sheth - 801085402


#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<time.h>


#define n 1000 //job size = 1K,10K,100K,1M,10M
#define r 2 //radius = 2,4,8,16

int main(void)
{
	//int r = 2;
	//printf("Enter radius\n");
	//scanf("%d\n",&r);
	//int n;
	//printf("Enter job size\n");
	//scanf("%d",&n);
	int i; 
	int array[n + 4];
	int add[n];
	
	for (i = 0; i<n+4; i++)
	{
		array[i] = rand()%n+4;
		printf("array = %d\n",array[i]);
	}
	int offset;
	int j;
	int k;
	int index = 0;
	for (j = 0; j<n;j++)
	{
		add[j] = 0;		
	}
	clock_t begin = clock();
	for(k = r;k<n+r; k++)
	{
	
		for(offset = -r;offset <= r;offset++)
		{
			//printf("NUM = %d\n", num[offset + r]);
			add[k-r] = add[k-r] + num[index + offset + r];
			//result += num[offset + r];
			
		}
	index++;
	
	clock_t end = clock();
	double execution_time = (double)(end - begin)/ CLOCKS_PER_SEC;
	printf("CPU Execution Time = %f\n",execution_time);
		
	}
	return 0;
}
