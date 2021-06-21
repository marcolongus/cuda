//single-precision A*X plus Y: saxoy
#include <stdio.h>

__global__ void saxpy(int n, float a, float *x, float *y)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	//printf("bIdx.x %d, bkDim.x %d, thrIdx %d\n, i %d ", blockIdx.x, blockDim.x, threadIdx.x, i);
	if (i<n) { 
		y[i] = a*x[i] + y[i]; 
		//printf("inner %d\n",i);
		printf("bIdx.x %d, thrIdx %d\n, i %d. ", blockIdx.x, threadIdx.x, i);
	}
}

int main(void){

	int N = 1<<3;
	int blockSize = 2;
	int numBlocks = (N+blockSize-1)/blockSize;//at least as many threads as N
	//host 
	float *x,*y;
	//device 
	float *d_x,*d_y;

	//Host memory allocation
	x = (float*)malloc(N*sizeof(float));
	y = (float*)malloc(N*sizeof(float));

	//Device memory allocation
	cudaMalloc(&d_x, N*sizeof(float));
	cudaMalloc(&d_y, N*sizeof(float));

	for (int i=0; i<N; i++){
		x[i] = 1.0f;
		y[i] = 2.0f;
	}

	//copy host to device memory
	cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);

	printf("blocks %d, threads %d.\n\n",numBlocks, blockSize);
	//Llamamos kernells en bloques de 1M
	saxpy<<<numBlocks, blockSize>>> (N, 2.0f, d_x, d_y);

	cudaMemcpy(y, d_y, N*sizeof(float),cudaMemcpyDeviceToHost);

	float maxError = 0.0f;
	for (int i=0; i < N; i++)
		maxError = max(maxError, abs(y[i] - 4.0f));
	printf("\n max error %f\n", maxError);

	cudaFree(d_x);
	cudaFree(d_y);
	free(x);
	free(y);

	return 0;
}