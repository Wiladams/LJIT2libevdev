--[[
  Starting point for this ffi file
  gcc -E -P libevdev.h > libevdev_ffi.lua
  lots of teraforming after that
--]]

local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift



ffi.cdef[[
enum libevdev_read_flag {
 LIBEVDEV_READ_FLAG_SYNC = 1,
 LIBEVDEV_READ_FLAG_NORMAL = 2,
 LIBEVDEV_READ_FLAG_FORCE_SYNC = 4,
 LIBEVDEV_READ_FLAG_BLOCKING = 8
};

enum libevdev_log_priority {
 LIBEVDEV_LOG_ERROR = 10,
 LIBEVDEV_LOG_INFO = 20,
 LIBEVDEV_LOG_DEBUG = 30
};

enum libevdev_grab_mode {
 LIBEVDEV_GRAB = 3,
 LIBEVDEV_UNGRAB = 4
};


enum libevdev_read_status {
 LIBEVDEV_READ_STATUS_SUCCESS = 0,
 LIBEVDEV_READ_STATUS_SYNC = 1
};

enum libevdev_led_value {
 LIBEVDEV_LED_ON = 3,
 LIBEVDEV_LED_OFF = 4
};
]]


ffi.cdef[[
struct libevdev;


struct libevdev* libevdev_new(void);
int libevdev_new_from_fd(int fd, struct libevdev **dev);
void libevdev_free(struct libevdev *dev);
]]

ffi.cdef[[
typedef void (*libevdev_log_func_t)(enum libevdev_log_priority priority,
        void *data,
        const char *file, int line,
        const char *func,
        const char *format, va_list args);
void libevdev_set_log_function(libevdev_log_func_t logfunc, void *data);
void libevdev_set_log_priority(enum libevdev_log_priority priority);
enum libevdev_log_priority libevdev_get_log_priority(void);
typedef void (*libevdev_device_log_func_t)(const struct libevdev *dev,
        enum libevdev_log_priority priority,
        void *data,
        const char *file, int line,
        const char *func,
        const char *format, va_list args);
void libevdev_set_device_log_function(struct libevdev *dev,
          libevdev_device_log_func_t logfunc,
          enum libevdev_log_priority priority,
          void *data);
]]


ffi.cdef[[
int libevdev_grab(struct libevdev *dev, enum libevdev_grab_mode grab);
int libevdev_set_fd(struct libevdev* dev, int fd);
int libevdev_change_fd(struct libevdev* dev, int fd);
int libevdev_get_fd(const struct libevdev* dev);
]]


ffi.cdef[[
int libevdev_next_event(struct libevdev *dev, unsigned int flags, struct input_event *ev);
int libevdev_has_event_pending(struct libevdev *dev);
const char* libevdev_get_name(const struct libevdev *dev);
void libevdev_set_name(struct libevdev *dev, const char *name);
const char * libevdev_get_phys(const struct libevdev *dev);
void libevdev_set_phys(struct libevdev *dev, const char *phys);
const char * libevdev_get_uniq(const struct libevdev *dev);
void libevdev_set_uniq(struct libevdev *dev, const char *uniq);
int libevdev_get_id_product(const struct libevdev *dev);
void libevdev_set_id_product(struct libevdev *dev, int product_id);
int libevdev_get_id_vendor(const struct libevdev *dev);
void libevdev_set_id_vendor(struct libevdev *dev, int vendor_id);
int libevdev_get_id_bustype(const struct libevdev *dev);
void libevdev_set_id_bustype(struct libevdev *dev, int bustype);
int libevdev_get_id_version(const struct libevdev *dev);
void libevdev_set_id_version(struct libevdev *dev, int version);
int libevdev_get_driver_version(const struct libevdev *dev);
int libevdev_has_property(const struct libevdev *dev, unsigned int prop);
int libevdev_enable_property(struct libevdev *dev, unsigned int prop);
int libevdev_has_event_type(const struct libevdev *dev, unsigned int type);
int libevdev_has_event_code(const struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_get_abs_minimum(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_maximum(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_fuzz(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_flat(const struct libevdev *dev, unsigned int code);
int libevdev_get_abs_resolution(const struct libevdev *dev, unsigned int code);
const struct input_absinfo* libevdev_get_abs_info(const struct libevdev *dev, unsigned int code);
int libevdev_get_event_value(const struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_set_event_value(struct libevdev *dev, unsigned int type, unsigned int code, int value);
int libevdev_fetch_event_value(const struct libevdev *dev, unsigned int type, unsigned int code, int *value);
int libevdev_get_slot_value(const struct libevdev *dev, unsigned int slot, unsigned int code);
int libevdev_set_slot_value(struct libevdev *dev, unsigned int slot, unsigned int code, int value);
int libevdev_fetch_slot_value(const struct libevdev *dev, unsigned int slot, unsigned int code, int *value);
int libevdev_get_num_slots(const struct libevdev *dev);
int libevdev_get_current_slot(const struct libevdev *dev);
void libevdev_set_abs_minimum(struct libevdev *dev, unsigned int code, int min);
void libevdev_set_abs_maximum(struct libevdev *dev, unsigned int code, int max);
void libevdev_set_abs_fuzz(struct libevdev *dev, unsigned int code, int fuzz);
void libevdev_set_abs_flat(struct libevdev *dev, unsigned int code, int flat);
void libevdev_set_abs_resolution(struct libevdev *dev, unsigned int code, int resolution);
void libevdev_set_abs_info(struct libevdev *dev, unsigned int code, const struct input_absinfo *abs);
int libevdev_enable_event_type(struct libevdev *dev, unsigned int type);
int libevdev_disable_event_type(struct libevdev *dev, unsigned int type);
int libevdev_enable_event_code(struct libevdev *dev, unsigned int type, unsigned int code, const void *data);
int libevdev_disable_event_code(struct libevdev *dev, unsigned int type, unsigned int code);
int libevdev_kernel_set_abs_info(struct libevdev *dev, unsigned int code, const struct input_absinfo *abs);
]]



ffi.cdef[[
int libevdev_kernel_set_led_value(struct libevdev *dev, unsigned int code, enum libevdev_led_value value);
int libevdev_kernel_set_led_values(struct libevdev *dev, ...);
int libevdev_set_clock_id(struct libevdev *dev, int clockid);
int libevdev_event_is_type(const struct input_event *ev, unsigned int type);
int libevdev_event_is_code(const struct input_event *ev, unsigned int type, unsigned int code);
const char * libevdev_event_type_get_name(unsigned int type);
const char * libevdev_event_code_get_name(unsigned int type, unsigned int code);
const char* libevdev_property_get_name(unsigned int prop);
int libevdev_event_type_get_max(unsigned int type);
int libevdev_event_type_from_name(const char *name);
int libevdev_event_type_from_name_n(const char *name, size_t len);
int libevdev_event_code_from_name(unsigned int type, const char *name);
int libevdev_event_code_from_name_n(unsigned int type, const char *name, size_t len);
int libevdev_property_from_name(const char *name);
int libevdev_property_from_name_n(const char *name, size_t len);
int libevdev_get_repeat(const struct libevdev *dev, int *delay, int *period);
]]




local LIB_libevdev = ffi.load("evdev")

local exports = {
    LIB_libevdef = LIB_libevdev;

    libevdev_new = LIB_libevdev.libevdev_new;
    libevdev_new_from_fd = LIB_libevdev.libevdev_new_from_fd;
    libevdev_free = LIB_libevdev.libevdev_free;

    libevdev_set_log_function = LIB_libevdev.libevdev_set_log_function;
    libevdev_set_log_priority = LIB_libevdev.libevdev_set_log_priority;
    libevdev_get_log_priority = LIB_libevdev.libevdev_get_log_priority;
    libevdev_set_device_log_function = LIB_libevdev.libevdev_set_device_log_function;


  libevdev_next_event = LIB_libevdev.libevdev_next_event;
  libevdev_has_event_pending = LIB_libevdev.libevdev_has_event_pending;
  libevdev_get_name = LIB_libevdev.libevdev_get_name;
  libevdev_set_name = LIB_libevdev.libevdev_set_name;
  libevdev_get_phys = LIB_libevdev.libevdev_get_phys;
  libevdev_set_phys = LIB_libevdev.libevdev_set_phys;
  libevdev_get_uniq = LIB_libevdev.libevdev_get_uniq;
  libevdev_set_uniq = LIB_libevdev.libevdev_set_uniq;
  libevdev_get_id_product = LIB_libevdev.libevdev_get_id_product;
  libevdev_set_id_product = LIB_libevdev.libevdev_set_id_product;
  libevdev_get_id_vendor = LIB_libevdev.libevdev_get_id_vendor;
  libevdev_set_id_vendor = LIB_libevdev.libevdev_set_id_vendor;
  libevdev_get_id_bustype = LIB_libevdev.libevdev_get_id_bustype;
  libevdev_set_id_bustype = LIB_libevdev.libevdev_set_id_bustype;
  libevdev_get_id_version = LIB_libevdev.libevdev_get_id_version;
  libevdev_get_driver_version = LIB_libevdev.libevdev_get_driver_version;
  libevdev_has_property = LIB_libevdev.libevdev_has_property;
  libevdev_enable_property = LIB_libevdev.libevdev_enable_property;
  libevdev_has_event_type = LIB_libevdev.libevdev_has_event_type;
  libevdev_has_event_code = LIB_libevdev.libevdev_has_event_code;
  libevdev_get_abs_minimum = LIB_libevdev.libevdev_get_abs_minimum;
  libevdev_get_abs_maximum = LIB_libevdev.libevdev_get_abs_maximum;
  libevdev_get_abs_fuzz = LIB_libevdev.libevdev_get_abs_fuzz;
  libevdev_get_abs_flat = LIB_libevdev.libevdev_get_abs_flat;
  libevdev_get_abs_resolution = LIB_libevdev.libevdev_get_abs_resolution;
  libevdev_get_abs_info = LIB_libevdev.libevdev_get_abs_info;
  libevdev_get_event_value = LIB_libevdev.libevdev_get_event_value;
  libevdev_set_event_value = LIB_libevdev.libevdev_set_event_value;
  libevdev_fetch_event_value = LIB_libevdev.libevdev_fetch_event_value;
  libevdev_get_slot_value = LIB_libevdev.libevdev_get_slot_value;
  libevdev_set_slot_value = LIB_libevdev.libevdev_set_slot_value;
  libevdev_fetch_slot_value = LIB_libevdev.libevdev_fetch_slot_value;
  libevdev_get_num_slots = LIB_libevdev.libevdev_get_num_slots;
  libevdev_get_current_slot = LIB_libevdev.libevdev_get_current_slot;
  libevdev_set_abs_minimum = LIB_libevdev.libevdev_set_abs_minimum;
  libevdev_set_abs_maximum = LIB_libevdev.libevdev_set_abs_maximum;
  libevdev_set_abs_fuzz = LIB_libevdev.libevdev_set_abs_fuzz;
  libevdev_set_abs_flat = LIB_libevdev.libevdev_set_abs_flat;
  libevdev_set_abs_resolution = LIB_libevdev.libevdev_set_abs_resolution;
  libevdev_set_abs_info = LIB_libevdev.libevdev_set_abs_info;
  libevdev_enable_event_type = LIB_libevdev.libevdev_enable_event_type;
  libevdev_disable_event_type = LIB_libevdev.libevdev_disable_event_type;
  libevdev_enable_event_code = LIB_libevdev.libevdev_enable_event_code;
  libevdev_disable_event_code = LIB_libevdev.libevdev_disable_event_code;
  libevdev_kernel_set_abs_info = LIB_libevdev.libevdev_kernel_set_abs_info;

  libevdev_kernel_set_led_value = LIB_libevdev.libevdev_kernel_set_led_value;
  libevdev_kernel_set_led_values = LIB_libevdev.libevdev_kernel_set_led_values;
  libevdev_set_clock_id = LIB_libevdev.libevdev_set_clock_id;
  libevdev_event_is_type = LIB_libevdev.libevdev_event_is_type;
  libevdev_event_is_code = LIB_libevdev.libevdev_event_is_code;

  libevdev_event_type_get_name = LIB_libevdev.libevdev_event_type_get_name;
  libevdev_event_code_get_name = LIB_libevdev.libevdev_event_code_get_name;
  libevdev_property_get_name = LIB_libevdev.libevdev_property_get_name;

  libevdev_event_type_get_max = LIB_libevdev.libevdev_event_type_get_max;
  libevdev_event_type_from_name = LIB_libevdev.libevdev_event_type_from_name;
  libevdev_event_type_from_name_n = LIB_libevdev.libevdev_event_type_from_name_n;
  libevdev_event_code_from_name = LIB_libevdev.libevdev_event_code_from_name;
  libevdev_event_code_from_name_n = LIB_libevdev.libevdev_event_code_from_name_n;
  libevdev_property_from_name = LIB_libevdev.libevdev_property_from_name;
  libevdev_property_from_name_n = LIB_libevdev.libevdev_property_from_name_n;
  libevdev_get_repeat = LIB_libevdev.libevdev_get_repeat;
}


setmetatable(exports, {
    __call = function(self, tbl)
      tbl = tbl or _G;
      for k,v in pairs(self) do
          tbl[k] = v;
      end
      return self;
    end,
})

return exports
