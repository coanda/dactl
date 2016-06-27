/* msgpack.vapi
 *
 * Copyright (C) 2016 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 *      Geoff Johnson <geoff.jay@gmail.com>
 */

// XXX is the MSGPACK_DLLEXPORT ... required for some funcs? left off several
[CCode (lower_case_cprefix = "msgpack_")]
namespace MsgPack {

    [CCode (cprefix = "MSGPACK_", cheader_filename = "msgpack/util.h")]
    public const int UNUSED;

    [CCode (cname = "msgpack_object_type", cprefix = "MSGPACK_OBJECT_", has_type_id = false, cheader_filename = "msgpack/object.h")]
    public enum ObjectType {
        NIL,
        BOOLEAN,
        POSITIVE_INTEGER,
        NEGATIVE_INTEGER,
        FLOAT,
        DOUBLE,
        STR,
        ARRAY,
        MAP,
        BIN,
        EXT
    }

    [CCode (cheader_filename = "msgpack/object.h")]
    public struct Object {
        public ObjectType type;
        [CCode (cname = "MSGPACK_DLLEXPORT msgpack_object_print", instance_pos = 1.1)]
        public void print (Posix.FILE out);
        [CCode (cname = "MSGPACK_DLLEXPORT msgpack_object_equal", instance_pos = 1.1)]
        public bool equal (MsgPack.Object y);
    }

    [CCode (has_target = false, cheader_filename = "msgpack/zone.h")]
    public delegate void ZoneFinalizerFunc<T> (T data);

    [CCode (cheader_filename = "msgpack/zone.h")]
    public struct ZoneFinalizer<T> {
        public ZoneFinalizerFunc<T> func;
        public T data;
    }

    [CCode (cheader_filename = "msgpack/zone.h")]
    public struct ZoneFinalizerArray {
        public ZoneFinalizer tail;
        public ZoneFinalizer end;
        public ZoneFinalizer array;
    }

    [CCode (cheader_filename = "msgpack/zone.h")]
    public struct ZoneChunk {
        [CCode (cprefix = "MSGPACK_ZONE_CHUNK_")]
        public const int SIZE;
    }

    [CCode (cheader_filename = "msgpack/zone.h")]
    public struct ZoneChunkList {
        public size_t free;
        public string ptr;
        public ZoneChunk head;
    }

    [CCode (cheader_filename = "msgpack/zone.h", free_function = "msgpack_zone_free")]
    public class Zone {
        [CCode (cprefix = "MSGPACK_ZONE_")]
        public const int ALIGN;
        public ZoneChunkList chunk_list;
        public ZoneFinalizerArray finalizer_array;
        public size_t size;
        [CCode (cname = "msgpack_zone_new")]
        public Zone (size_t chunk_size);
        public void free ();
        public bool init (size_t chunk_size);
        public void destroy ();
        public static inline void* malloc (size_t size);
        public static inline void* malloc_no_align (size_t size);
        public static inline bool push_finalizer (ZoneFinalizerFunc<T> func, T data);
        public static inline void swap (Zone b);
        public bool is_empty ();
        public void clear ();
        public static inline void* malloc_expand (size_t size);
        public bool push_finalizer_expand (ZoneFinalizerFunc<T> func, T data);
    }

    [CCode (has_target = false, cheader_filename = "msgpack/pack.h")]
    public delegate int PackerWriteFunc<T> (T data, string buf, size_t len);

    [CCode (cheader_filename = "msgpack/pack.h")]
    public class Packer<T> {
        public T data;
        public PackerWriteFunc callback;
        [CCode (cname = "msgpack_packer_new")]
        public Packer(T data, PackerWriteFunc<T> callback);
        public void free ();
        public void init (T data, PackerWriteFunc<T> callback);
        public int pack_char (char d);
        public int pack_short (short d);
        public int pack_int (int d);
        public int pack_long (long d);
        public int pack_long_long (int64 d);
        public int pack_unsigned_char (uchar d);
        public int pack_unsigned_short (ushort d);
        public int pack_unsigned_int (uint d);
        public int pack_unsigned_long (ulong d);
        public int pack_unsigned_long_long (uint64 d);
        public int pack_uint8 (uint8 d);
        public int pack_uint16 (uint16 d);
        public int pack_uint32 (uint32 d);
        public int pack_uint64 (uint64 d);
        public int pack_int8 (int8 d);
        public int pack_int16 (int16 d);
        public int pack_int32 (int32 d);
        public int pack_int64 (int64 d);
        public int pack_fix_uint8 (uint8 d);
        public int pack_fix_uint16 (uint16 d);
        public int pack_fix_uint32 (uint32 d);
        public int pack_fix_uint64 (uint64 d);
        public int pack_fix_int8 (int8 d);
        public int pack_fix_int16 (int16 d);
        public int pack_fix_int32 (int32 d);
        public int pack_fix_int64 (int64 d);
        public int pack_float (float d);
        public int pack_double (double d);
        public int pack_nil ();
        public int pack_true ();
        public int pack_false ();
        public int pack_array (size_t n);
        public int pack_map (size_t n);
        public int pack_str (size_t l);
        public int pack_str_body (const T b, size_t l);
        public int pack_v4raw (size_t l);
        public int pack_v4raw_body (const T b, size_t l);
        public int pack_bin (size_t l);
        public int pack_bin_body (const T b, size_t l);
        public int pack_ext (size_t l, int8 type);
        public int pack_ext_body (const T b, size_t l);
        public int pack_object (MsgPack.Object d);
    }

    [CCode (cname = "msgpack_unpack_return", cprefix = "MSGPACK_UNPACK_", has_type_id = false, cheader_filename = "msgpack/unpack.h")]
    public enum UnpackReturn {
        SUCCESS,
        EXTRA_BYTES,
        CONTINUE,
        PARSE_ERROR,
        NOMEM_ERROR
    }

    [CCode (cheader_filename = "msgpack/unpack.h")]
    public struct Unpacked {
        public Zone zone;
        public MsgPack.Object data;
    }

    [CCode (cname = "msgpack_unpack_next", cheader_filename = "msgpack/unpack.h")]
    public UnpackReturn unpack_next (Unpacked result, const string data, size_t len, [CCode (array_length = false, array_null_terminated = true)] size_t[] off);

    [CCode (cheader_filename = "msgpack/unpack.h")]
    public class Unpacker<T> {
        [CCode (cprefix = "MSGPACK_UNPACKER_")]
        public const int INIT_BUFFER_SIZE;
        public string buffer;
        public size_t used;
        public size_t free;
        public size_t off;
        public size_t parsed;
        public Zone z;
        public size_t initial_buffer_size;
        public T ctx;
    }
}
