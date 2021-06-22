//generamos numeros aleatorios

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <curand.h>

// compilar:
// nvcc -o program program.cu -l curand
// Quiero que cada bloque tire blockSize numeros y caluclar pi. 
// Despues promediar con todos los bloques. 
// Finalmente usar los bloques sin promediar.

__global__ void montecarlo_pi(int N, int *count, float *x, float *y)
{
	int index  = blockIdx.x*blockDim.x + threadIdx.x;

	if (index < N){
		if (x[index]*x[index] + y[index]*y[index] <= 1) {
			count[index]=1; //mala practica, mejor inicializar antes y count[]++;
		}
		else count[index]=0;
	}
}

int main(){

	int N = 1<<24; //no deberia poder ir 1<<31 -1 ??
	int blockSize = 512; //cada bloque procesa 6 mb 
	int numBlock = (N + blockSize - 1)/blockSize;

	printf("Bloques %i, Threads %i\n", numBlock, blockSize);
	printf("N %i \n", N);

	//device data
	float *d_x, *d_y;
	//shared memory
	int *count;

	//Alocamos data
	cudaMalloc(&d_x, N*sizeof(float));        //4*N bytes
	cudaMalloc(&d_y, N*sizeof(float));        //4*N bytes
	cudaMallocManaged(&count, N*sizeof(int)); //2*N bytes

	//Defino el generador. 
	curandGenerator_t gen;
	
	//Create generetor mersenne twister engine MTGP32
	curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_MTGP32);

	//Set seed
	curandSetPseudoRandomGeneratorSeed(gen, 1245ULL); 

	int n_sim = 10;
	float pi_total = 0;
	for (int simulacion=0; simulacion<n_sim; simulacion++){
		
		//Generate N floats on device
		curandGenerateUniform(gen, d_x, N);
		curandGenerateUniform(gen, d_y, N);
		cudaDeviceSynchronize(); //hace falta?
		//Call kernel
		montecarlo_pi<<<numBlock,blockSize>>>(N,count,d_x,d_y);
		cudaDeviceSynchronize(); //hace falta?
		float pi_calc=0;
		for (int i=0; i<N; i++){
			if (count[i] !=0 ) pi_calc++;
		}
		printf("pi %f \n", 4.0f*pi_calc/(float)N);
		pi_total+=4.0f*pi_calc/(float)N;
	}
	printf("pi total %f \n", pi_total/(float)n_sim);




	//cleanup
	curandDestroyGenerator(gen);
	cudaFree(d_x);
	cudaFree(d_y);
	cudaFree(count);

	return 0;
}