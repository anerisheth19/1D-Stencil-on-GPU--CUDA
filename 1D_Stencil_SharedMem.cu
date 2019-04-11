//ECGR 6090 Heterogeneous Computing Homework 0
// Problem 2 c - 1D Stencil on GPU with shared memory
//Written by Aneri Sheth - 801085402

// Reference taken from Lecture Slides by Dr. Tabkhi 
//Other reference taken from https://github.com/szymonm/pwir-cuda-labs/tree/master/lab1 and https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#using-cuda-gpu-timers


#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<time.h>

#define RADIUS 2 //radius = 2,4,8,16
#define BLOCK_SIZE    128 //fixed number of threads per block 
#define NUM_ELEMENTS 1000 //job size = 1K, 10K, 100K, 1M and 10M


// CUDA API error checking macro
static void handleError( cudaError_t err,
                         const char *file,
                         int line ) {
    if (err != cudaSuccess) {
        printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
                file, line );
        exit( EXIT_FAILURE );
    }
}
#define cudaCheck( err ) (handleError( err, __FILE__, __LINE__ ))

__global__ void stencil_1d(int *in, int *out) 
{
	__shared__ int temp[BLOCK_SIZE + 2 * RADIUS];
	int gindex = threadIdx.x + blockIdx.x * blockDim.x;
	int lindex = threadIdx.x + RADIUS;
	temp[lindex] = in[gindex]; //storing in shared memory
	
	if (threadIdx.x < RADIUS) 
	{
	temp[lindex - RADIUS] = in[gindex - RADIUS];
	temp[lindex + BLOCK_SIZE] = in[gindex + BLOCK_SIZE];
	}
	__syncthreads();
	int result = 0;
	for (int offset = -RADIUS ; offset <= RADIUS ; offset++)
	{
		result += temp[lindex + offset];
	}
// Store the result
	out[gindex] = result;
}	

int main()
{
  unsigned int i;
  //CPU array copies
  int h_in[NUM_ELEMENTS + 2 * RADIUS], h_out[NUM_ELEMENTS];
//GPU array copies
  int *d_in, *d_out;

	cudaEvent_t start, stop; //time start and stop
	float time;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

  for( i = 0; i < (NUM_ELEMENTS + 2*RADIUS); ++i )
    h_in[i] = 1; 

  // Allocate device memory
  cudaCheck( cudaMalloc( &d_in, (NUM_ELEMENTS + 2*RADIUS) * sizeof(int)) );
  cudaCheck( cudaMalloc( &d_out, NUM_ELEMENTS * sizeof(int)) );

  //copy fro CPU to GPU memory
  cudaCheck( cudaMemcpy( d_in, h_in, (NUM_ELEMENTS + 2*RADIUS) * sizeof(int), cudaMemcpyHostToDevice) );
  cudaEventRecord( start, 0 );

 //Call stencil kernel
  stencil_1d<<< (NUM_ELEMENTS + BLOCK_SIZE - 1)/BLOCK_SIZE, BLOCK_SIZE >>> (d_in, d_out);

   	cudaEventRecord( stop, 0 );
	cudaEventSynchronize(stop);
	cudaEventElapsedTime( &time, start, stop );
	cudaEventDestroy( start );
	cudaEventDestroy( stop );
	printf("GPU Execution Time = %f\n",time);

  //copy from device to host
  cudaCheck( cudaMemcpy( h_out, d_out, NUM_ELEMENTS * sizeof(int), cudaMemcpyDeviceToHost) );

  // Free out memory
  cudaFree(d_in);
  cudaFree(d_out);

  return 0;
}
