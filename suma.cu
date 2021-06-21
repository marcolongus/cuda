#include <stdio.h>

//indicates a function that runs on the divice
// and also is colled from host code (du global)


//ad a single integer
__global__ void add(int *a, int *b, int *c){
	*c = *a + *b; //ver si funciona sin lo sastericos
	int d = *c + 1; 
	printf("kernel %d\n", d);
}

int main(void){

	int a, b, c;          //host copies of a,b,c
	int *d_a, *d_b, *d_c; //device copies of a, b,c
	int size = sizeof(int);

	//allocate space for device copies of a,b,c
	cudaMalloc((void  **)&d_a, size); //cuando va??? (void **), como ir a cuda Managed, agregar check error. 
	cudaMalloc((void  **)&d_b, size);
	cudaMalloc((void  **)&d_c, size);

	a = 1;
	b = 1;

	//copy inputs to device
	cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);

	//launch add() kernel on GPU
	add<<<1,1>>>(d_a,d_b,d_c);

	//copy result back to host
	cudaMemcpy(&c,d_c,size,cudaMemcpyDeviceToHost);

	printf("%i\n", c);
	//cleanup
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

	return 0;
}


