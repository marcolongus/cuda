#include <stdio.h>

//indicates a function that runs on the divice
// and also is colled from host code (du global)


//ad a single integer
__global__ void add(int *a, int *b, int *c){
	*c = *a + *b; //ver si funciona sin lo sastericos
	int d = *c + 1; 
	printf("kernel d=c+1: %d\n", d);
	printf("kernel c    : %d\n", *c);
}

int main(void){

	int *a, *b, *c;          //host copies of a,b,c
	int size = sizeof(int);

	//allocate space for device copies of a,b,c
	cudaMallocManaged(&a, size); //cuando va??? (void **), como ir a cuda Managed, agregar check error. 
	cudaMallocManaged(&b, size);
	cudaMallocManaged(&c, size);

	*a = 1;
	*b = 1;
	*c = 5;
	
	printf("antes del kernel c: %d\n", *c);
	//launch add() kernel on GPU
	add<<<1,1>>>(a,b,c);
	cudaDeviceSynchronize();

	printf("despues del kernel c: %d\n", *c);
	//cleanup
	cudaFree(a); cudaFree(b); cudaFree(c);

	return 0;
}


