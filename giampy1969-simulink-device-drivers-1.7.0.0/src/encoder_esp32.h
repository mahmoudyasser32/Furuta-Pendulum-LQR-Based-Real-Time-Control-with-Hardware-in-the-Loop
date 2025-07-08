#ifndef ENCODER_ESP32_H
#define ENCODER_ESP32_H

#include "driver/gpio.h"
#include "driver/pcnt.h" // Pulse Counter (PCNT) for quadrature encoders

#ifdef __cplusplus
extern "C" {
#endif

// Initialize the quadrature encoder
void enc_init(int enc, int pinA, int pinB);

// Get the encoder count
int enc_output(int enc);

#ifdef __cplusplus
}
#endif

#endif // ENCODER_ESP32_H
