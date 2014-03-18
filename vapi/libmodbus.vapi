[CCode (cprefix = "modbus_", cheader_filename = "modbus.h")]
namespace Modbus {

    [CCode (cprefix = "MODBUS_EXCEPTION_", cheader_filename = "modbus.h")]
    public enum Exception {
        ILLEGAL_FUNCTION,
        ILLEGAL_DATA_ADDRESS,
        ILLEGAL_DATA_VALUE,
        SLAVE_OR_SERVER_FAILURE,
        ACKNOWLEDGE,
        SLAVE_OR_SERVER_BUSY,
        NEGATIVE_ACKNOWLEDGE,
        MEMORY_PARITY,
        NOT_DEFINED,
        GATEWAY_PATH,
        GATEWAY_TARGET,
        MAX
    }

	[CCode (cprefix = "MODBUS_ERROR_RECOVERY_", cheader_filename = "modbus.h", has_type_id = false)]
	public enum ErrorRecovery {
		NONE,
		LINK,
		PROTOCOL
	}

	[CCode (cprefix = "LIBMODBUS_VERSION_", cheader_filename = "modbus.h")]
	public enum Version {
		HEX,
		MAJOR,
		MICRO,
        MINOR,
        STRING
	}

    [CCode (cprefix = "MODBUS_MAX_", cheader_filename = "modbus.h")]
    public enum Max {
        READ_BITS,
        WRITE_BITS,
        READ_REGISTERS,
        WRITE_REGISTERS,
        RW_WRITE_REGISTERS
    }

    [CCode (cprefix = "MODBUS_RTU_", cheader_filename = "modbus.h")]
    public enum RtuAttributes {
        MAX_ADU_LENGTH,
        RS232,
        RS485
    }

    [CCode (cprefix = "MODBUS_TCP_", cheader_filename = "modbus.h")]
    public enum TcpAttributes {
        DEFAULT_PORT,
        MAX_ADU_LENGTH,
        SLAVE
    }

	[CCode (cheader_filename = "modbus.h")]
	public const int BROADCAST_ADDRESS;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBBADCRC;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBBADDATA;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBBADEXC;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBMDATA;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBUNKEXC;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXACK;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXGPATH;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXGTAR;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXILADD;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXILFUN;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXILVAL;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXMEMPAR;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXNACK;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXSBUSY;
	[CCode (cheader_filename = "modbus.h")]
	public const int EMBXSFAIL;
	[CCode (cheader_filename = "modbus.h")]
	public const int ENOBASE;

	[CCode (cname = "modbus_mapping_t", cheader_filename = "modbus.h", unref_function = "", free_function = "modbus_mapping_free")]
	public class Mapping {
		public int nb_bits;
		public int nb_input_bits;
		public int nb_input_registers;
		public int nb_registers;

        [CCode (array_length_cname = "nb_bits", array_length_type = "int")]
		public uchar tab_bits;

        [CCode (array_length_cname = "nb_input_bits", array_length_type = "int")]
		public uchar tab_input_bits;

        [CCode (array_length_cname = "nb_input_registers", array_length_type = "int")]
		public uint16 tab_input_registers;

        [CCode (array_length_cname = "nb_registers", array_length_type = "int")]
		public uint16 tab_registers;

        [CCode (cname = "modbus_mapping_new")]
        public Mapping (int nb_coil_status, int nb_input_status, int nb_holding_registers, int nb_input_registers);
	}

	[CCode (cname = "modbus_t", cprefix = "modbus_", cheader_filename = "modbus.h", unref_function = "", free_function = "modbus_free")]
	public class Context {
        [CCode (cname = "modbus_new_rtu")]
        public Context.rtu (string device, int baud, GLib.ObjectPath parity, int data_bit, int stop_bit);

        [CCode (cname = "modbus_new_tcp")]
        public Context.tcp (string ip_address, int port);

        [CCode (cname = "modbus_new_tcp_pi")]
        public Context.tcp_pi (string node, string service);

        public void close ();
        public int connect ();
        public int flush ();
        public void get_byte_timeout (void* timeout);
        public int get_header_length ();
        public void get_response_timeout (void* timeout);
        public int get_socket ();
        public int read_bits (int addr, [CCode (array_length_pos = 1.5)] uchar[] dest);
        public int read_input_bits (int addr, [CCode (array_length_pos = 1.5)] uchar[] dest);
        public int read_input_registers (int addr, [CCode (array_length_pos = 1.5)] uint16[] dest);
        public int read_registers (int addr, [CCode (array_length_pos = 1.5)] uint16[] dest);
        public int receive ([CCode (array_length = false)] uchar[] req);
        public int receive_confirmation ([CCode (array_length = false)] uchar[] rsp);
        public int receive_from (int sockfd, [CCode (array_length = false)] uchar[] req);
        public int reply ([CCode (array_length_pos = 1.5)] uchar req, Mapping mb_mapping);
        public int reply_exception ([CCode (array_length = false)] uchar[] req, uint exception_code);
        public int report_slave_id ([CCode (array_length = false)] uchar[] dest);
        public int rtu_get_serial_mode ();
        public int rtu_set_serial_mode (int mode);
        public int send_raw_request ([CCode (array_length_pos = 1.5)] uchar[] raw_req);
        public void set_byte_timeout (void* timeout);
        public void set_debug (int boolean);
        public int set_error_recovery (ErrorRecovery error_recovery);
        public void set_response_timeout (void* timeout);
        public int set_slave (int slave);
        public void set_socket (int socket);
        public int tcp_accept (int socket);
        public int tcp_listen (int nb_connection);
        public int tcp_pi_accept (int socket);
        public int tcp_pi_listen (int nb_connection);
        public int write_and_read_registers (int write_addr, [CCode (array_length_pos = 1.5)] uint16[] src, int read_addr, [CCode (array_length_pos = 2.5)]  uint16[] dest);
        public int write_bit (int coil_addr, int status);
        public int write_bits (int addr, [CCode (array_length_pos = 1.5)] uchar[] data);
        public int write_register (int reg_addr, int value);
        public int write_registers (int addr, [CCode (array_length_pos = 1.5)] uint16[] data);
	}

	public static uchar get_byte_from_bits ([CCode (array_length_pos = 2.5)] uchar[] src, int index);
	public static float get_float ([CCode (array_length = false)] uint16[] src);
	public static void set_bits_from_byte ([CCode (array_length = false)] uchar[] dest, int index, uchar value);
	public static void set_bits_from_bytes ([CCode (array_length = false)] uchar[] dest, int index, [CCode (array_length_pos = 2.5)] uchar[] tab_byte);
	public static void set_float (float f,[CCode (array_length = false)]  uint16[] dest);
	public static unowned string strerror (int errnum);
}
