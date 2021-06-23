#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>

/// ver por que no anda la mierda esta

__global__ void setup_kernel(curanState *state)
{
	int id =  blockIdx.x*blockDim.x threadIdx.x;
	curand_init(1234, id, 0, &state[id]); //same seed.  
}

__global__ void generate_kernel(curanState *state, int *result)
{
	int id =  blockIdx.x*blockDim.x threadIdx.x; 
	int count =0;

	unsigned int x;
	//copy state to local memory
	curandState localState = state[id];

	for(int n=0; n<10000; n++){
		x = curand(&localState);
		if (x&1) count++;
	}
	state[id] = localState;
	result[id] += count;
}

int main(void){
	int N=64*64;
	int *devResults, *hostResults;

	curandState *devStates;

	hostResults = (int*)malloc(&hostResults, N*sizeof(int));
	cudaMalloc(&devResults, N*sizeof(int));
	cudaMalloc(&devStates , N*sizeof(int));

	cudaMemset(devResults , 0, N*sizeof(int));

	setup_kernel<<<64,64>>>(devStates);

	for(int i=0; i<N; i++){
		generate_kernel<<<64,64>>>(devStates, devResults);
	}

	cudaMemcpy(hostResults, devResults, N*sizeof(int), cudaMemcpyDeviceToHost);

	int total = 0;
	for (int i = 0; i < N; ++i){
		total+=hostResults[i];
	}

	printf("%10.13f\n", (float)total/(float(N)*100000.0f));

	//cleanup
	cudaFree(devStates); cudaFree(devResults); free(hostResults);

	return 0;
}
