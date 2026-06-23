#include <stdint.h>

#include <mcsos/arch/io.h>
#include <mcsos/arch/pit.h>
#include <mcsos/kernel/log.h>

#define PIT_CHANNEL0 0x40u
#define PIT_COMMAND  0x43u

volatile uint64_t g_ticks = 0;

void pit_configure_hz(uint32_t hz)
{
    uint16_t divisor = (uint16_t)(1193182u / hz);

    outb(PIT_COMMAND, 0x36u);

    outb(PIT_CHANNEL0, divisor & 0xFFu);
    outb(PIT_CHANNEL0, (divisor >> 8) & 0xFFu);
}

void timer_on_irq0(void)
{
    g_ticks++;

    if ((g_ticks % 100u) == 0u)
    {
        log_key_value_hex64("[MCSOS:TIMER] ticks", g_ticks);
    }
}
