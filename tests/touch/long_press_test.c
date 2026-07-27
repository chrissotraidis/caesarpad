#include "game/system.h"
#include "input/mouse.h"
#include "input/touch.h"

#include <assert.h>
#include <stdio.h>

static time_millis test_time;
static mouse test_mouse;

time_millis time_get_millis(void)
{
    return test_time;
}

const mouse *mouse_get(void) { return &test_mouse; }
void mouse_set_position(int x, int y) {}
void mouse_set_left_down(int down) {}
void mouse_set_right_down(int down) {}
void mouse_reset_scroll(void) {}
void mouse_reset_button_state(void) {}
void mouse_determine_button_state(void) {}
void mouse_set_from_touch(const touch *first, const touch *last) {}
void system_move_mouse_cursor(int delta_x, int delta_y) {}
void system_set_mouse_position(int *x, int *y) {}

int main(void)
{
    touch_coords start = {100, 100};
    touch_coords moved = {130, 100};

    reset_touches(1);
    int index = touch_create(start, 1000);
    test_time = 1349;
    assert(!touch_poll_long_press());
    test_time = 1350;
    assert(touch_poll_long_press());
    assert(!touch_poll_long_press());

    touch_end(index, 1400);
    reset_touches(1);
    index = touch_create(start, 2000);
    touch_move(index, moved, 2100);
    test_time = 2400;
    assert(!touch_poll_long_press());

    touch_end(index, 2400);
    reset_touches(1);
    index = touch_create(start, 3000);
    touch_end(index, 3400);
    test_time = 3400;
    assert(touch_poll_long_press());

    reset_touches(1);
    int first = touch_create(start, 4000);
    int second = touch_create(start, 4010);
    test_time = 4160;
    touch_end(first, 4160);
    assert(touch_was_two_finger_tap());
    touch_consume_current_gesture();
    assert(!touch_was_two_finger_tap());
    touch_end(second, 4160);
    assert(!touch_was_click(touch_get_earliest()));
    assert(!touch_was_click(touch_get_latest()));

    reset_touches(1);
    int single = touch_create(start, 5000);
    assert(!touch_was_two_finger_tap());
    touch_end(single, 5100);

    reset_touches(1);
    first = touch_create(start, 6000);
    second = touch_create(start, 6010);
    touch_move(second, moved, 6050);
    touch_end(first, 6100);
    test_time = 6100;
    assert(!touch_was_two_finger_tap());
    touch_end(second, 6100);

    reset_touches(1);
    first = touch_create(start, 7000);
    second = touch_create(start, 7310);
    touch_end(first, 7400);
    touch_end(second, 7400);
    test_time = 7400;
    assert(!touch_was_two_finger_tap());

    puts("PASS: 350 ms stationary hold maps once to engine long-press right-click");
    puts("PASS: moved touch does not map to long-press right-click");
    puts("PASS: release timestamp preserves completed long-press");
    puts("PASS: only a short stationary two-finger pair maps to alternate right-click");
    puts("PASS: consumed two-finger right-click cannot leak a later single tap");
    return 0;
}
