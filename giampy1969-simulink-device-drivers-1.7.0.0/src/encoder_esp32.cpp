#include "encoder_esp32.h"

// Array to hold PCNT unit configurations
static pcnt_unit_t pcnt_units[2] = {PCNT_UNIT_0, PCNT_UNIT_1};

// Initialize the quadrature encoder
void enc_init(int enc, int pinA, int pinB) {
    pcnt_config_t pcnt_config = {};
    pcnt_config.pulse_gpio_num = pinA; // Pin for pulse input
    pcnt_config.ctrl_gpio_num = pinB; // Pin for direction control
    pcnt_config.channel = PCNT_CHANNEL_0;
    pcnt_config.unit = pcnt_units[enc];
    pcnt_config.pos_mode = PCNT_COUNT_INC; // Count on rising edge
    pcnt_config.neg_mode = PCNT_COUNT_DEC; // Count on falling edge
    pcnt_config.lctrl_mode = PCNT_MODE_REVERSE; // Reverse on low
    pcnt_config.hctrl_mode = PCNT_MODE_KEEP;   // Keep on high
    pcnt_config.counter_h_lim = INT16_MAX;
    pcnt_config.counter_l_lim = INT16_MIN;

    // Configure the PCNT unit
    pcnt_unit_config(&pcnt_config);

    // Enable input filter
    pcnt_set_filter_value(pcnt_units[enc], 200); // Filter pulses <100us
    pcnt_filter_enable(pcnt_units[enc]);

    // Initialize the counter
    pcnt_counter_pause(pcnt_units[enc]);
    pcnt_counter_clear(pcnt_units[enc]);
    pcnt_counter_resume(pcnt_units[enc]);
    
}


// Get the encoder count
int enc_output(int enc) {
    if (enc < 0 || enc > 1) return 0; // Ensure valid index

    int16_t count = 0;
    pcnt_get_counter_value(pcnt_units[enc], &count);
    return (int)count;
}
