#include <stdio.h>
#include <stdlib.h>
#include<time.h>

void printArray(unsigned char *, int, int);
void genRandImage(unsigned char *, int, int);
void boxBlur(unsigned char *, unsigned char *, int, int, int);

int main(int argc, char * argv[]) {


    int w = (int) atoi(argv[1]);
    int h = (int) atoi(argv[2]);
    int numOfImages = (int) atoi(argv[3]);
    int blurSize = (int) atoi(argv[4]);

    printf("Starting...\n");
    printf("Dimensions: %d x %d \n", w, h);
    printf("Number of images %d \n", numOfImages);

    unsigned char * imageArray;
    unsigned char * outImageArray;

    //dimensions of a 24mp image
    // int w = 2000;
    // int h = 2000;


    //allocate array with zero
    imageArray = (unsigned char *)calloc(w*h, sizeof(unsigned char));
    outImageArray = (unsigned char *)calloc(w*h, sizeof(unsigned char));

    genRandImage(imageArray, w, h);

    //printArray(imageArray, w, h);

    // clock_t t;
    // t = clock();
     int iter;

    for(iter = 0; iter<numOfImages; iter++){
      boxBlur(imageArray,outImageArray, w, h, blurSize);
    }

    //t = clock() - t;
    //double time_taken = ((double)t)/CLOCKS_PER_SEC;

    //printf("boxBlur() took %f seconds to execute \n", time_taken);

    //printArray(outImageArray, w, h);



    return 0;
}

void boxBlur(unsigned char * imageArray, unsigned char * outImageArray, int w, int h, int blurSize){

    int row = 0;
    int col = 0;

      for(row = 0; row < h; row++){
          for(col = 0; col < w; col++){

              int count = 0;
              int total = 0;

              for(int blurRow = -blurSize; blurRow < blurSize+1; ++blurRow){
                  for(int blurCol = -blurSize; blurCol < blurSize+1; ++blurCol){

                      int curRow = row + blurRow;
                      int curCol = col + blurCol;

                      if(curRow > -1 && curRow < h && curCol > -1 && curCol < w){
                          total += imageArray[curRow*w+curCol];
                         // printf("%d ", imageArray[curRow*w+curCol]);
                          count +=1;
                      }

                  }
                  //printf("\n");

              }
  //            printf("total: %d\n", total);
  //            printf("count: %d\n", count);
  //            printf("avg: %d\n\n", total/count);
              outImageArray[row*w+col] = total/count;
          }
      }
}

void genRandImage(unsigned char * imageArray, int w, int h){
    srand(time(0));
    int i;
    for (i = 0; i <= w*h; i++) {

        imageArray[i] = (unsigned char) (rand() % 255 + 1);

    }

}

void printArray(unsigned char * imageArray, int w, int h){

    int i;
    for (i = 0; i < w*h; i++) {
        if(i % w == 0){
            printf("\n");
        }
        printf("%u ", imageArray[i]);
    }
    printf("\n");
}
