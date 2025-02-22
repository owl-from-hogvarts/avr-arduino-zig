const uart = @import("uart.zig");
const gpio = @import("gpio.zig");
const memcpy = @import("start.zig").memcpy;

// This is put in the data section
var ch: u8 = '!';

// This ends up in the bss section
var bss_stuff: [9]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

// Put public functions here named after interrupts to instantiate them as
// interrupt handlers. If you name one incorrectly you'll get a compiler error
// with the full list of options.
pub const interrupts = struct {
    // Pin Change Interrupt Source 0
    // pub fn PCINT0() void {}
};

pub fn main() void {
    uart.init(115200);
    uart.write("All your codebase are belong to us!\r\n\r\n");

    if (bss_stuff[0] == 0)
        uart.write("Ahh its actually zero!\r\n");

    // const hello = "\r\nhello\r\n";
    // memcpy(u8, &bss_stuff, hello);
    // for (bss_stuff[0..hello.len], hello) |*d, s| d.* = s;

    bss_stuff = "\r\nhello\r\n".*;
    uart.write(&bss_stuff);

    // This will actually call our panic handler in start.zig when
    // uncommented.
    // var x: u8 = 255;
    // x += 1;

    gpio.init(5, .out);

    while (true) {
        uart.write_ch(ch);
        if (ch < '~') {
            ch += 1;
        } else {
            ch = '!';
            uart.write("\r\n");
        }

        gpio.toggle(5);
        delay_cycles(50000);
    }
}

fn delay_cycles(cycles: u32) void {
    var count: u32 = 0;
    while (count < cycles) : (count += 1) {
        asm volatile ("nop");
    }
}
