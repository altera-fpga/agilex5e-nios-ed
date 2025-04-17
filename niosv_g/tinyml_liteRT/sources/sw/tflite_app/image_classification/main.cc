/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include "system.h"
#include <time.h>
#include <unistd.h>

//Import TensorFlow lite libraries
#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/micro_time.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_profiler.h"
#include "tensorflow/lite/micro/recording_micro_interpreter.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "tensorflow/lite/schema/schema_generated.h"

//Model data
#include "model/model_data.h"
#include "model/model_settings.h"

////Sample image
#include "image/figure-0.h"
#include "image/figure-1.h"
#include "image/figure-2.h"
#include "image/figure-3.h"
#include "image/figure-4.h"
#include "image/figure-5.h"
#include "image/figure-6.h"
#include "image/figure-7.h"
#include "image/figure-8.h"
#include "image/figure-9.h"

// Image specifications
#define IMAGE_WIDTH 28
#define IMAGE_HEIGHT 28
#define NUM_CHANNELS 1
#define IMAGE_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT * NUM_CHANNELS)

//ANSI Escape code
#define BBOX "\xE2\x96\xA0"
#define CRESET "\033[m"

//Profiling
#define PROFILING 1

int count;
uint8_t test_image[IMAGE_HEIGHT][IMAGE_WIDTH][NUM_CHANNELS];

// Defining namespace 
namespace {
	const tflite::Model* model = nullptr;

	using OpResolver = tflite::MicroMutableOpResolver<5>;
	TfLiteStatus RegisterOps(OpResolver& op_resolver) {
		TF_LITE_ENSURE_STATUS(op_resolver.AddConv2D());
		TF_LITE_ENSURE_STATUS(op_resolver.AddAveragePool2D());
		TF_LITE_ENSURE_STATUS(op_resolver.AddReshape());
		TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
		TF_LITE_ENSURE_STATUS(op_resolver.AddSoftmax());
		return kTfLiteOk;
	}
} 

// Function to load the LiteRT ML model and process input image
TfLiteStatus LoadModelandInference() {

	printf("[INFO]Setting up TinyML...\n\r");
	tflite::MicroProfiler profiler;
	OpResolver op_resolver;
	TF_LITE_ENSURE_STATUS(RegisterOps(op_resolver));
	model = tflite::GetModel(lenet_tflite); // Loads the LeNet TensorFlow Lite model from memory
	TFLITE_CHECK_EQ(model->version(), TFLITE_SCHEMA_VERSION); // Ensures model compatibility

	// Arena size just a round number. The exact arena usage can be determined
	// using the RecordingMicroInterpreter.
	constexpr int kTensorArenaSize = 20000;
	uint8_t tensor_arena[kTensorArenaSize];
	constexpr int kNumResourceVariables = 24;

	tflite::RecordingMicroAllocator* allocator(
	  tflite::RecordingMicroAllocator::Create(tensor_arena, kTensorArenaSize)); 
	tflite::RecordingMicroInterpreter Recordinginterpreter(
	  model, op_resolver, allocator,
	  tflite::MicroResourceVariables::Create(allocator, kNumResourceVariables),
	  &profiler);

	// Allocate memory for tensors based on the model's requirements.
	TF_LITE_ENSURE_STATUS(Recordinginterpreter.AllocateTensors());
	// Verify that the interpreter has exactly one input tensor.
	TFLITE_CHECK_EQ(Recordinginterpreter.inputs_size(), 1);

	//Print loaded model input shape
	printf("Total output layers: %d\n\r", Recordinginterpreter.outputs_size());
	printf(
	  "Input shape: %d dimensions. Dimension: %d %d %d %d. Type: %d\n\r", Recordinginterpreter.input(0)->dims->size,
														Recordinginterpreter.input(0)->dims->data[0],
														Recordinginterpreter.input(0)->dims->data[1],
														Recordinginterpreter.input(0)->dims->data[2],
														Recordinginterpreter.input(0)->dims->data[3],
														Recordinginterpreter.input(0)->type
	);

	//Print loaded model output shape
	for (int i = 0; i < (int)(Recordinginterpreter.outputs_size()); ++i)
	  printf(
		   "Output shape %d: %d dimensions. Dimension: %d %d. Type: %d\n\r", i, Recordinginterpreter.output(i)->dims->size,
														   Recordinginterpreter.output(i)->dims->data[0],
														   Recordinginterpreter.output(i)->dims->data[1],
														   Recordinginterpreter.output(i)->type
	  );

	printf("[INFO]Setting up TinyML...Done\n\n\r");

	printf("[INFO]Uploading image...\n\r");

	//Visualize image
	int Pixel = 35;
	for (int i = 0; i < IMAGE_HEIGHT; i=i+2){ //select rows starting from top to bottom
		for (int j = 0; j < IMAGE_WIDTH; j=j+2){ //select pixels within a row starting from left to right
			printf("\033[38;2;%d;%d;%dm%c" CRESET,test_image[i][j][0],
														test_image[i][j][0],
														test_image[i][j][0],Pixel);// insert Red[0], Green[1], Blue[2]
		}
		printf("\n");
	}
	printf("\n");

	//Input preprocessed sample image to tflite model input.
	int len = 0;
	for (int i = 0; i < IMAGE_HEIGHT; i++){ //insert every rows starting from top to bottom
	for (int j = 0; j < IMAGE_WIDTH; j++){ // insert every pixels within a row starting from left to right
		for (int k = 0; k < NUM_CHANNELS; k++){ // insert Red -> Green -> Blue of each pixel for 3-channel RGB image OR insert pixel for a 1-channel GrayScale image
			Recordinginterpreter.input(0)->data.f[len] = float(test_image[i][j][k])/255.0; // Perform pre-processing along with inputting sample image
			//Recordinginterpreter.input(0)->data.f[len] = 0; //for testing purpose, feeding a blank black image
			len++;
		}
	}
	}
	if (len != IMAGE_SIZE)
	  printf("Input length of %d is not equal to image length of %d\n\r", len, IMAGE_SIZE);
	printf("[INFO]Uploading image...Done\n\n\r");

	printf("[INFO]Classifying image...\n\r");
	clock_t startTime = clock();
	TF_LITE_ENSURE_STATUS(Recordinginterpreter.Invoke());
	clock_t endTime = clock();
	printf("[INFO]Classifying image...Done\n\n\r");

	//Retrieve inference output
	int answer = 0;
	printf("Retrieve the inference output:\n");
	for (int i = 0; i < kCategoryCount; ++i){
	  printf("%s score: %f\n\r", kCategoryLabels[i], Recordinginterpreter.output(0)->data.f[i]);
	  if (Recordinginterpreter.output(0)->data.f[i] > Recordinginterpreter.output(0)->data.f[answer]) answer = i;
	}
	printf("\nInference made: %s\n\r", kCategoryLabels[answer]);
	int time_spent = int(endTime - startTime) / ALT_CPU_TICKS_PER_SEC;
	printf("Inference time: %d seconds\n\n\r", time_spent);

#if (PROFILING)
	printf("[INFO]Profiling TinyML model...\n\r");
	profiler.LogTicksPerTagCsv();
	printf("Ticks per seconds: %d\n\n", ALT_CPU_TICKS_PER_SEC);

	printf("Tensor Arena Allocation:\n");
	Recordinginterpreter.GetMicroAllocator().PrintAllocations();
	printf("[INFO]Profiling TinyML model...Done\n\n\r");
#endif

  return kTfLiteOk;
}

// Function to run the inference with input image 
int SelectImage(uint8_t (*image)[IMAGE_WIDTH][NUM_CHANNELS]){
	for (int i = 0; i < IMAGE_HEIGHT; i++){
	   	for (int j = 0; j < IMAGE_WIDTH; j++){
	   		for (int k = 0; k < NUM_CHANNELS; k++){
	   			test_image[i][j][k] = image[i][j][k];
	   		}
	   	}
	   }
	TF_LITE_ENSURE_STATUS(LoadModelandInference());

	return 0;
}


int main() {

   printf("\tHello from Nios V/g Processor TinyML Demonstration on MNIST\n\r");
   /***********************************************************TFLITE-MICRO TINYML*******************************************************/

   SelectImage(test_image0);
   SelectImage(test_image1);
   SelectImage(test_image2);
   SelectImage(test_image3);
   SelectImage(test_image4);
   SelectImage(test_image5);
   SelectImage(test_image6);
   SelectImage(test_image7);
   SelectImage(test_image8);
   SelectImage(test_image9);

   return 0;
}
