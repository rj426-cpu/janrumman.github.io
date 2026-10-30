################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../source/3140_accel.c \
../source/3140_concur.c \
../source/3140_i2c.c \
../source/3140_serial.c \
../source/calibrate.c \
../source/led.c \
../source/mtb.c \
../source/process.c \
../source/semihost_hardfault.c 

S_SRCS += \
../source/3140.s \
../source/led_lowlevel.s 

C_DEPS += \
./source/3140_accel.d \
./source/3140_concur.d \
./source/3140_i2c.d \
./source/3140_serial.d \
./source/calibrate.d \
./source/led.d \
./source/mtb.d \
./source/process.d \
./source/semihost_hardfault.d 

OBJS += \
./source/3140.o \
./source/3140_accel.o \
./source/3140_concur.o \
./source/3140_i2c.o \
./source/3140_serial.o \
./source/calibrate.o \
./source/led.o \
./source/led_lowlevel.o \
./source/mtb.o \
./source/process.o \
./source/semihost_hardfault.o 


# Each subdirectory must supply rules for building sources it contributes
source/%.o: ../source/%.s source/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: MCU Assembler'
	arm-none-eabi-gcc -c -x assembler-with-cpp -D__REDLIB__ -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/board" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/source" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/drivers" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/CMSIS" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/startup" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/utilities" -g3 -gdwarf-4 -mcpu=cortex-m0plus -mthumb -D__REDLIB__ -specs=redlib.specs -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

source/%.o: ../source/%.c source/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: MCU C Compiler'
	arm-none-eabi-gcc -D__REDLIB__ -DCPU_MKL46Z256VLL4_cm0plus -DCPU_MKL46Z256VLL4 -DFSL_RTOS_BM -DSDK_OS_BAREMETAL -DSDK_DEBUGCONSOLE=0 -DCR_INTEGER_PRINTF -DPRINTF_FLOAT_ENABLE=0 -D__MCUXPRESSO -D__USE_CMSIS -DDEBUG -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/board" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/source" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/drivers" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/CMSIS" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/startup" -I"/Users/ariellai/Desktop/Spring 2026/ECE3140/FinalProject/FinalProject/utilities" -O0 -fno-common -g3 -gdwarf-4 -Wall -c -ffunction-sections -fdata-sections -fno-builtin -fmerge-constants -fmacro-prefix-map="$(<D)/"= -mcpu=cortex-m0plus -mthumb -D__REDLIB__ -fstack-usage -specs=redlib.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.o)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


clean: clean-source

clean-source:
	-$(RM) ./source/3140.o ./source/3140_accel.d ./source/3140_accel.o ./source/3140_concur.d ./source/3140_concur.o ./source/3140_i2c.d ./source/3140_i2c.o ./source/3140_serial.d ./source/3140_serial.o ./source/calibrate.d ./source/calibrate.o ./source/led.d ./source/led.o ./source/led_lowlevel.o ./source/mtb.d ./source/mtb.o ./source/process.d ./source/process.o ./source/semihost_hardfault.d ./source/semihost_hardfault.o

.PHONY: clean-source

