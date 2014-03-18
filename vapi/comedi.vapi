/*
 * comedi.vapi
 * Vala bindings for the control and measurement devices library comedi
 * Copyright (c) 2011 Geoff Johnson <geoff.jay@gmail.com>
 * License: GNU LGPL v3 as published by the Free Software Foundation
 *
 * This binding is a (mostly) strict binding to the function-oriented
 * nature of this C library.
 */

[CCode (cprefix = "comedi_", cheader_filename = "comedi.h")]
namespace Comedi {

    /*
     * Macro utilities
     */
    [CCode (cprefix = "COMEDI_VERSION_CODE")]
    public static int version_code (int a, int b, int c);

    [CCode (cname = "CR_PACK")]
    public static int pack (int chan, int rng, int aref);

    [CCode (cname = "CR_PACK_FLAGS")]
    public static int pack_flags (int chan, int range, int aref, int flags);

    [CCode (cname = "CR_CHAN")]
    public static int chan (int a);

    [CCode (cname = "CR_RANGE")]
    public static int range (int a);

    [CCode (cname = "CR_AREF")]
    public static int aref (int a);

    [CCode (cname = "__RANGE")]
    public static int __range (int a, int b);

    [CCode (cname = "RANGE_OFFSET")]
    public static int range_offset (int a);

    [CCode (cname = "RANGE_LENGTH")]
    public static int range_length (int b);

    [CCode (cname = "RF_UNIT")]
    public static int rf_unit (int flags);

    /*
     * Constants
     */
    [CCode (cprefix = "COMEDI_", cheader_filename = "comedi.h")]
    public const int NAMELEN;

    [CCode (cprefix = "COMEDI_", cheader_filename = "comedi.h")]
    public const int NDEVCONFOPTS;

    /*
     * Device configuration
     */
    [CCode(cprefix = "COMEDI_DEVCONF_AUX_", cheader_filename = "comedi.h")]
    public enum DevConfAux {
        DATA3_LENGTH,
        DATA2_LENGTH,
        DATA1_LENGTH,
        DATA0_LENGTH,
        DATA_HI,
        DATA_LO,
        DATA_LENGTH
    }

    /*
     * Analog Reference Options
     */
    [CCode (cprefix = "AREF_", cheader_filename = "comedi.h")]
    public enum AnalogReference {
        GROUND,
        COMMON,
        DIFF,
        OTHER
    }

    /*
     * Counters
     */
    [CCode (cprefix = "GPCT_", cheader_filename = "comedi.h")]
    public enum CounterAttribute {
        RESET,
        SET_SOURCE,
        SET_GATE,
        SET_DIRECTION,
        SET_OPERATION,
        ARM,
        DISARM,
        GET_INT_CLK_FRQ,
        INT_CLOCK,
        EXT_PIN,
        NO_GATE,
        UP,
        DOWN,
        HWUD,
        SIMPLE_EVENT,
        SINGLE_PERIOD,
        SINGLE_PW,
        CONT_PULSE_OUT,
        SINGLE_PULSE_OUT
    }

    /*
     * Instructions
     */
    [CCode (cprefix = "INSN_MASK_", cheader_filename = "comedi.h")]
    public enum InstructionMask {
        WRITE,
        READ,
        SPECIAL
    }

    [CCode (cprefix = "INSN_", cheader_filename = "comedi.h")]
    public enum InstructionAttribute {
        READ,
        WRITE,
        BITS,
        CONFIG,
        GTOD,
        WAIT,
        INTTRIG
    }

    [CCode (cprefix = "INSN_CONFIG_", cheader_filename = "comedi.h")]
    public enum InstructionConfiguration {
        DIO_INPUT,
        DIO_OUTPUT,
        DIO_OPENDRAIN,
        ANALOG_TRIG,
        ALT_SOURCE,
        DIGITAL_TRIG,
        BLOCK_SIZE,
        TIMER_1,
        FILTER,
        CHANGE_NOTIFY,
        SERIAL_CLOCK,
        BIDIRECTIONAL_DATA,
        DIO_QUERY,
        PWM_OUTPUT,
        GET_PWM_OUTPUT,
        ARM,
        DISARM,
        GET_COUNTER_STATUS,
        RESET,
        GPCT_SINGLE_PULSE_GENERATOR,
        GPCT_PULSE_TRAIN_GENERATOR,
        GPCT_QUADRATURE_ENCODER,
        SET_GATE_SRC,
        GET_GATE_SRC,
        SET_CLOCK_SRC,
        GET_CLOCK_SRC,
        SET_OTHER_SRC,
        SET_COUNTER_MODE,
        8254_READ_STATUS,
        SET_ROUTING,
        GET_ROUTING
    }

    [CCode (cprefix = "COMEDI_", cheader_filename = "comedi.h")]
    public enum IODirection {
        INPUT,
        OUTPUT,
        OPENDRAIN
    }

    /*
     * Triggers
     */
    [CCode (cprefix = "TRIG_", cheader_filename = "comedi.h")]
    public enum TriggerFlag {
        BOGUS,
        DITHER,
        DEGLITCH,
        CONFIG,
        RT,
        WAKE_EOS,
        WRITE
    }

    [CCode (cprefix = "TRIG_ROUND_", cheader_filename = "comedi.h")]
    public enum TriggerRounding {
        MASK,
        NEAREST,
        DOWN,
        UP,
        UP_NEXT
    }

    [CCode (cprefix = "TRIG_", cheader_filename = "comedi.h")]
    public enum TriggerSource {
        ANY,
        INVALID,
        NONE,
        NOW,
        FOLLOW,
        TIME,
        TIMER,
        COUNT,
        EXT,
        INT,
        OTHER
    }

    /*
     * Commands
     */
    [CCode (cprefix = "CMDF_", cheader_filename = "comedi.h")]
    public enum CommandFlag {
        PRIORITY,
        WRITE,
        RAWDATA
    }

    [CCode (cprefix = "COMEDI_EV_", cheader_filename = "comedi.h")]
    public enum CommandEvent {
        START,
        SCAN_BEGIN,
        CONVERT,
        SCAN_END,
        STOP
    }

    /*
     * Subdevice
     */
    [CCode (cprefix = "SDF_", cheader_filename = "comedi.h")]
    public enum SubdeviceFlag {
        BUSY,
        BUSY_OWNER,
        LOCKED,
        LOCK_OWNER,
        MAX_DATA,
        FLAGS,
        RANGETYPE,
        MODE0,
        MODE1,
        MODE2,
        MODE3,
        MODE4,
        CMD,
        SOFT_CALIBRATED,
        CMD_WRITE,
        CMD_READ,
        READABLE,
        WRITABLE,
        WRITEABLE,
        INTERNAL,
        RT,
        GROUND,
        COMMON,
        DIFF,
        OTHER,
        DITHER,
        DEGLITCH,
        MMAP,
        RUNNING,
        LSAMPL,
        PACKED
    }

    [CCode (cprefix = "COMEDI_SUBD_", cheader_filename = "comedi.h")]
    public enum SubdeviceType {
        UNUSED,
        AI,
        AO,
        DI,
        DO,
        DIO,
        COUNTER,
        TIMER,
        MEMORY,
        CALIB,
        PROC,
        SERIAL
    }

    [CCode (cprefix = "UNIT_", cheader_filename = "comedi.h")]
    public enum Unit {
        volt,
        mA,
        none
    }

    /*
     * Callback Stuff
     */
    [CCode (cprefix = "COMEDI_CB_", cheader_filename = "comedi.h")]
    public enum Callback {
        EOS,
        EOA,
        BLOCK,
        EOBUF,
        ERROR,
        OVERFLOW
    }

    [CCode (cprefix = "COMEDI_OOR_", cheader_filename = "comedilib.h")]
    public enum OorBehavior {
        NUMBER,
        NAN
    }

    [CCode (cname = "comedi_trig", cheader_filename = "comedi.h")]
    public class Trigger {
        public uint subdev;
        public uint mode;
        public uint flags;
        public uint n_chan;
        public uint[] chanlist;
        public uint16[] data;
        public uint n;
        public uint trigsrc;
        public uint trigvar;
        public uint trigvar1;
        public uint data_len;
        public uint unused[3];
    }

    //[CCode (cname = "comedi_cmd", cheader_filename = "comedi.h", unref_function = "")]
    //public class Command {
        //[CCode (cname = "g_new0")]
        //public Command (ulong size = sizeof (Command));

    [CCode (cname = "comedi_cmd", cheader_filename = "comedi.h", destroy_function = "")]
    public struct Command {

        public uint subdev;
        public uint flags;
        public uint start_src;
        public uint start_arg;
        public uint scan_begin_src;
        public uint scan_begin_arg;
        public uint convert_src;
        public uint convert_arg;
        public uint scan_end_src;
        public uint scan_end_arg;
        public uint stop_src;
        public uint stop_arg;
        [CCode (array_length = false)]
        public uint[] chanlist;
        public uint chanlist_len;
        public uint16[] data;
        public uint data_len;
    }

    [CCode (cname = "comedi_insn", cheader_filename = "comedi.h", destroy_function = "", has_copy_function = false)]
    public struct Instruction {
        public uint insn;
        public uint n;
        public uint *data;
        public uint subdev;
        public uint chanspec;
        public uint unused[3];
    }

    [CCode (cname = "comedi_insnlist", cheader_filename = "comedi.h", destroy_function = "")]
    public struct InstructionList {
        public uint n_insns;
        [CCode (array_length = false)]
        public Instruction[] insns;
    }

    [CCode (cname = "comedi_chaninfo", cheader_filename = "comedi.h")]
    public class ChannelInfo {
        public uint subdev;
        public uint[] maxdata_list;
        public uint[] flaglist;
        public uint[] rangelist;
        public uint unused[4];
    }

    [CCode (cname = "comedi_subdinfo", cheader_filename = "comedi.h")]
    public class SubdeviceInfo {
        public uint type;
        public uint n_chan;
        public uint subd_flags;
        public uint timer_type;
        public uint len_chanlist;
        public uint maxdata;
        public uint flags;
        public uint range_type;
        public uint settling_time_0;
        public uint unused[9];
    }

    [CCode (cname = "comedi_devinfo", cheader_filename = "comedi.h")]
    public class DeviceInfo {
        public uint version_code;
        public uint n_subdevs;
        public char driver_name[20];       /* had to change NAMELEN -> 20 */
        public char board_name[20];        /* had to change NAMELEN -> 20 */
        public int read_subdevice;
        public int write_subdevice;
        public int unused[30];
    }

    [CCode (cname = "comedi_devconfig", cheader_filename = "comedi.h")]
    public class DeviceConfig {
        public char board_name[20];        /* had to change NAMELEN -> 20 */
        public int options[32];            /* had to change NDEVCONFOPTS -> 32 */
    }

    [CCode (cname = "comedi_rangeinfo", cheader_filename = "comedi.h")]
    public class RangeInfo {
        public uint range_type;
        public void *range_ptr;
    }

    [CCode (cname = "comedi_krange", cheader_filename = "comedi.h")]
    public class KRange {
        public int min;
        public int max;
        public uint flags;
    }

    [CCode (cname = "comedi_bufconfig", cheader_filename = "comedi.h")]
    public class BufferConfig {
        public uint subdevice;
        public uint flags;
        public uint maximum_size;
        public uint size;
        public uint unused[4];
    }

    [CCode (cname = "comedi_bufinfo", cheader_filename = "comedi.h")]
    public class BufferInfo {
        public uint subdevice;
        public uint bytes_read;
        public uint buf_write_ptr;
        public uint buf_read_ptr;
        public uint buf_write_count;
        public uint buf_read_count;
        public uint bytes_written;
        public uint unused[4];
    }

    [CCode (cname = "comedi_range", cheader_filename = "comedi.h", unref_function = "")]
    public class Range {
        public double min;
        public double max;
        public uint unit;
    }

    [CCode (cname = "comedi_sv_t", cprefix = "comedi_sv_", cheader_filename = "comedi.h")]
    public class SlowVarying {
        public Device dev;
        public uint subdevice;
        public uint chan;
        public int range;
        public int aref;
        public int n;
        public uint maxdata;

        public int init (Device dev, uint subd, uint chan);
        public int update ();
        public int measure ([CCode (array_length = false)] double[] data);
    }

    /*
     * Device
     */
    [CCode (cname = "comedi_t", cprefix = "comedi_", cheader_filename = "comedilib.h", unref_function = "", free_function = "comedi_close")]
    public class Device {
        [CCode (cname = "comedi_open")]
        public Device (string fn);

        public int close ();
        public int get_n_subdevices ();
        public int get_version_code ();
        public unowned string get_driver_name ();
        public unowned string get_board_name ();
        public int get_read_subdevice ();
        public int get_write_subdevice ();
        public int fileno ();

        /* subdevice queries */
        public int get_subdevice_type (uint subdevice);
        public int find_subdevice_by_type (int type, uint subd);
        public int get_subdevice_flags (uint subdevice);
        public int get_n_channels (uint subdevice);
        public int range_is_chan_specific (uint subdevice);
        public int maxdata_is_chan_specific (uint subdevice);

        /* channel queries */
        public uint get_maxdata (uint subdevice, uint chan);
        public int get_n_ranges (uint subdevice, uint chan);
        public Range get_range (uint subdevice, uint chan, uint range);
        public int find_range (uint subd, uint chan, uint unit, double min, double max);

        /* buffer queries */
        public int get_buffer_size (uint subdevice);
        public int get_max_buffer_size (uint subdevice);
        public int set_buffer_size (uint subdevice, uint len);

        /* low-level */
        public int do_insnlist (InstructionList il);
        public int do_insn (Instruction insn);
        public int lock (uint subdevice);
        public int unlock (uint subdevice);

        /* syncronous */
        public int data_read (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data);
        public int data_read_n (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint n);
        public int data_read_hint (uint subd, uint chan, uint range, uint aref);
        public int data_read_delayed (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint nano_sec);
        public int data_write (uint subd, uint chan, uint range, uint aref, uint data);
        public int dio_config (uint subd, uint chan, uint dir);
        public int dio_get_config (uint subd, uint chan, [CCode (array_length = false)] uint[] dir);
        public int dio_read (uint subd, uint chan, [CCode (array_length = false)] uint[] bit);
        public int dio_write (uint subd, uint chan, uint bit);
        public int dio_bitfield2 (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits, uint base_channel);
        public int dio_bitfield (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits);

        /* streaming I/O (commands) */
        public int get_cmd_src_mask (uint subdevice, Command cmd);
        public int get_cmd_generic_timed (uint subdevice, out Command cmd, uint chanlist_len, uint scan_period_ns);
        public int cancel (uint subdevice);
        public int command (Command cmd);
        public int command_test (Command cmd);
        public int poll (uint subdevice);

        /* buffer control */
        public int set_max_buffer_size (uint subdev, uint max_size);
        public int get_buffer_contents (uint subdev);
        public int mark_buffer_read (uint subdev, uint bytes);
        public int mark_buffer_written (uint subdev, uint bytes);
        public int get_buffer_offset (uint subdev);
    }

    /*
     * Static utility functions
     */
    public static OorBehavior set_global_oor_behavior (OorBehavior oor);
    public static int loglevel (int loglevel);
    public static void perror (string s);
    public static string strerror (int errnum);
    public static int errno (int loglevel);
    public static double to_phys (uint data, Range rng, uint maxdata);
    public static uint from_phys (double data, Range rng, uint maxdata);
    public static int sampl_to_phys ([CCode (array_length = false)] double[] dest, int dst_stride, [CCode (array_length = false)] uint16[] src, int src_stride, Range rng, uint maxdata, int n);
    public static int sampl_from_phys ([CCode (array_length = false)] uint16[] dest, int dst_stride, [CCode (array_length = false)] double[] src, int src_stride, Range rng, uint maxdata, int n);
}
