#pragma once

#include <stdint.h>

void pit_configure_hz(uint32_t hz);
void timer_on_irq0(void);

extern volatile uint64_t g_ticks;
