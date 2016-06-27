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

    [CCode (cheader_filename = "msgpack/pack.h")]
    public class Packer {
    }
}
