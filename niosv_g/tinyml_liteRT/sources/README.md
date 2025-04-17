# Agilex 5 FPGA - TinyML LiteRT Example Design Example on Nios® V/g Processor 

Nios® V/g Processor-based TinyML LiteRT example design on the Agilex® 5 FPGA.

## Description

This design demonstrates the TinyML application using LiteRT for microcontrollers software with Nios® V/g processor in the Agilex™ 5 FPGA E-Series 065B Premium Development Kit (ES1) DK-A5E065BB32AES1. 

![image](https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.0/niosv_g/tinyml_liteRT/img/block_diagram.png)

## Project Details

* **Title**: Agilex 5 FPGA - TinyML LiteRT Example Design Example on Nios® V/g Processor
* **Source**: Github
* **Design Support**: CTH
* **Family**: Agilex 5
* **Quartus Version**: 25.1.0 Pro
* **Development Kit**: Agilex 5 FPGA E*Series 065B Premium Development Kit DK*A5E065BB32AES1
* **Device Part**: A5ED065BB32AE6SR0
* **Design Package**: agilex5_niosv_g_tinyml_liteRT.zip
* **Category**: Machine Learning
* **URL**: https://github.com/altera-fpga/agilex5e-nios-ed/tree/rel/25.1/niosv_g/tinyml_liteRT
* **downloadURL**:https://github.com/altera-fpga/agilex5e-nios-ed/releases/download/25.1-v1.0/agilex5_niosv_g_tinyml_liteRT.zip

## Documentation

* **Title**: Design Document 
* **URL**:   https://github.com/altera-fpga/agilex5e-nios-ed/blob/rel/25.1.0/niosv_g/tinyml_liteRT/img/block_diagram.png

# Getting Started

Vendor: Altera

Devkit Product Page: www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/f-series/dev-agf014.html

1. Directory structure
2. Using existing files (sof and elf) to run on hardware
3. Building the design from scratch
    
    a. Required directory structure

    b. Use of build_sof.py to compile the design
    
    c. Steps to create the bsp and build software sources

    d.  Hardware Validation 
 
### 1. Directory Structure:
 
The directory structure of this top-level project folder is explained below:

- hw - necessary hardware files (.qpf, .qsf, .sv, .v, .ip) of the design

- sw - This folder contains software application files

- scripts - This folder consists of scripts to build the design

### 2. Using existing files to run the design on hardware
 
- The sof and elf files required to run the design can be found in "ready_to_test" folder 

- Refer the Hardware validation section (3.d) for the steps
 
### 3. Building the design from scratch
 
The steps to build the project from scratch are mentioned below:
 
a. Required directory structure
- The top-level project folder should have directory structure as mentioned in Section 1 (Directory Structure).
 
b. Using build_sof.py to compile the design
- Invoke the quartus_py shell in the terminal

- Run the following command in the terminal from top level project directory:
 ```
 quartus_py ./scripts/build_sof.py
```
- The quartus tool will compile the design and generate the output files
 
c. Creating the bsp, build software sources and download elf
- To create software app, run the following commands in the terminal

- Clean the app build project before regenerating elf
```
niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal --bsp-dir=sw/tflite_bsp --script=sw/bsp_script.tcl sw/tflite_bsp/settings.bsp
niosv-app -b=sw/tflite_bsp -a=sw/tflite_app -S=sw/tflite_app/image_classification/,sw/tflite_app/image_classification/model/,sw/tflite_app/signal,sw/tflite_app/tensorflow,sw/tflite_app/tensorflow/lite/,sw/tflite_app/tensorflow/lite/c/,sw/tflite_app/tensorflow/lite/core/api/,sw/tflite_app/tensorflow/lite/kernels/,sw/tflite_app/tensorflow/lite/kernels/internal,sw/tflite_app/tensorflow/lite/kernels/internal/reference/,sw/tflite_app/tensorflow/lite/kernels/internal/reference/integer_ops,sw/tflite_app/tensorflow/lite/micro,sw/tflite_app/tensorflow/lite/micro/kernels/,sw/tflite_app/tensorflow/lite/micro/memory_planner,sw/tflite_app/tensorflow/lite/schema --incs=sw/tflite_app,sw/tflite_app/image_classification,sw/tflite_app/image_classification/model/,sw/tflite_app/tensorflow,sw/tflite_app/tensorflow/lite,sw/tflite_app/third_party/flatbuffers/include,sw/tflite_app/third_party/gemmlowp,sw/tflite_app/third_party/kissfft,sw/tflite_app/third_party/ruy
cmake -S sw/tflite_app -B sw/tflite_app/build/Release -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
make -C sw/tflite_app/build/Release
```

d. Hardware Validation
- Program the generated sof and then download the elf file on the board
```  
quartus_pgm --cable=1 -m jtag -o 'p;ready_to_test/top.sof'
```
- Reduce the JTAG clock frequency to 6MHz before programming the application .elf file on the board.
``` 
jtagconfig --setparam 1 JtagClock 6M
```
- Download the elf file on the board 
```
niosv-download -g ready_to_test/tflite_app.elf -c 1
```
- Verify the output on the terminal by using the following command in the terminal:
``` 
juart-terminal -d 1 -c 1 -i 0 
```