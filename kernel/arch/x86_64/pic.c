#include <stdint.h>

#include <mcsos/arch/io.h>
#include <mcsos/arch/pic.h>

#define PIC1_COMMAND 0x20u
#define PIC1_DATA    0x21u
#define PIC2_COMMAND 0xA0u
#define PIC2_DATA    0xA1u

#define PIC_EOI      0x20u


void pic_remap(void)
{
    uint8_t master_mask = inb(PIC1_DATA);
    uint8_t slave_mask  = inb(PIC2_DATA);

    outb(PIC1_COMMAND, 0x11u);
    io_wait();

    outb(PIC2_COMMAND, 0x11u);
    io_wait();

    outb(PIC1_DATA, 32u);
    io_wait();

    outb(PIC2_DATA, 40u);
    io_wait();

    outb(PIC1_DATA, 4u);
    io_wait();

    outb(PIC2_DATA, 2u);
    io_wait();

    outb(PIC1_DATA, 0x01u);
    io_wait();

    outb(PIC2_DATA, 0x01u);
    io_wait();

    outb(PIC1_DATA, master_mask);
    outb(PIC2_DATA, slave_mask);
}

void pic_mask_all(void)
{
    outb(PIC1_DATA, 0xFFu);
    outb(PIC2_DATA, 0xFFu);
}

void pic_unmask_irq(uint8_t irq)
{
    uint16_t port;
    uint8_t mask;

    if (irq < 8u)
    {
        port = PIC1_DATA;
    }
    else
    {
        port = PIC2_DATA;
        irq -= 8u;
    }

    mask = inb(port);
    mask &= (uint8_t)~(1u << irq);

    outb(port, mask);
}

void pic_send_eoi(uint8_t irq)
{
    if (irq >= 8u)
    {
        outb(PIC2_COMMAND, PIC_EOI);
    }

    outb(PIC1_COMMAND, PIC_EOI);
}
