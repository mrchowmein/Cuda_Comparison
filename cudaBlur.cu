#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
#include<time.h>


#define index(i, j, w)  ((i)*(w)) + (j)

__global__ void blurKernel (unsigned char *, unsigned char *, int, int, int);
void cudaBlur(unsigned char * , int, int, int);


int main(int argc, char * argv[]){

  unsigned char * imageArray;
  int w = (int) atoi(argv[1]);
  int h = (int) atoi(argv[2]);
  int numOfImages = (int) atoi(argv[3]);
  int blurSize = (int) atoi(argv[4]);


  imageArray = (unsigned char *)calloc(w*h, sizeof(unsigned char));

  //assign random unsigned chars to imageArray
  int i;
  for (i = 0; i <= w*h; i++) {
    imageArray[i] = (unsigned char) (rand() % 255 + 1);
  }



  int j;

  for(j = 0; j < numOfImages; j++){
    //printf("%u \n", imageArray[index(0,0,w)]);
    cudaBlur(imageArray, w, h, blurSize);
    //printf("%u \n", imageArray[0]);
  }



return 0;
}

void cudaBlur(unsigned char * imageArray, int w, int h, int blurSize)
{

  unsigned int num_bytes = w*h*sizeof(unsigned char);

  unsigned char * temp;
  temp = (unsigned char *)calloc(w*h, sizeof(unsigned char));

  memcpy((void *)temp, (void *) imageArray, num_bytes);



  //allocate device Memory
  unsigned char *d_inputArray;
  unsigned char *d_outputArray;
  cudaMalloc(&d_inputArray, num_bytes);
  cudaMalloc(&d_outputArray, num_bytes);

  dim3 threads_per_block( 128, 1, 1 );
  dim3 blocks_in_grid( ceil( (w*h)/ threads_per_block.x ), 1, 1 );

  clock_t t;
  t = clock();
  
  cudaMemcpy(d_outputArray, temp, num_bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(d_inputArray, imageArray, num_bytes, cudaMemcpyHostToDevice);


  blurKernel<<<blocks_in_grid, threads_per_block>>>(d_inputArray, d_outputArray, w, h, blurSize);


  cudaMemcpy(imageArray, d_outputArray, num_bytes, cudaMemcpyDeviceToHost);
  t = clock() - t;
  double time_taken = ((double)t)/CLOCKS_PER_SEC;

  printf("kernel took %f seconds to execute \n", time_taken);
  //printf("done");
  //free device Memory
  cudaFree(d_outputArray);
  cudaFree(d_inputArray);
  free(temp);

}

__global__ void blurKernel (unsigned char * d_inputArray, unsigned char * d_outputArray,
 int w, int h, int blurSize){

    int Row = blockIdx.y * blockDim.y + threadIdx.y;
    int Col = blockIdx.x * blockDim.x + threadIdx.x;

    if(Col<w && Row < h){
      int pixVal = 0;
      int pixels = 0;

      for(int blurRow = -blurSize; blurRow < blurSize+1; ++blurRow){
        for(int blurCol = -blurSize; blurCol < blurSize+1; ++blurCol){
          int curRow = Row + blurRow;
          int curCol = Col + blurCol;

          //verify we have a valid image pixel
          if(curRow > -1 && curRow < h && curCol > -1 && curCol < w){
            pixVal += d_inputArray[curRow*w+curCol];
            pixels++; // keep track of number of pixels in the avg
          }
        }
      }

      //write our new pixel value out
      d_outputArray[Row*w+Col] = (unsigned char)(pixVal/pixels);


    }

}
