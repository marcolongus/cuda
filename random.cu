#include <iostream>
#include <time>
#include <random>
#include <math.h>
#include <curand.h>

__global__ void setup_kernel(curandState *state){
	int index = blockIdx.x*blockDim.x + threadIdx.x;
	curand_init(123456789, index, 0, &state[index]);
}

__global__ void random_kerndel(curandState *state, int * count){
	int index = blockIdx.x*blockDim.x + threadIdx.x;

	float x = curand_uniform(&state[index]);
	float y = curand_uniform(&state[index])
	float r = x*x + y*y;

	if (r <= 1) count++;
}