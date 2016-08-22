public class Dactl.Recorder.ZmqClient : Dactl.Net.ZmqClient {

    public ZmqClient () {
        base ();
    }

    public ZmqClient.with_conn_info (Dactl.Net.ZmqTransport transport,
                                     string address,
                                     int port) {
        base.with_conn_info (transport, address, port);
    }

    public override void run () {
        watch.begin ((obj, res) => {
            try {
                watch.end (res);
            } catch (ThreadError e) {
                error (e.message);
            }
        });
    }

    protected override async void watch () throws ThreadError {
        SourceFunc callback = watch.callback;

        debug ("watch");

        ThreadFunc<void*> run = () => {
            try {
                debug ("watch - run");
                var ntimes = 0;
                // XXX just here to do something
                while (true) {
                    var msg = ZMQ.Msg ();
                    var n = msg.recv (subscriber);
                    if (n == -1) {
                        critical (_("Failed to read data from the server"));
                    }

                    size_t size = msg.size () + 1;
                    uint8[] data = new uint8[size];
                    GLib.Memory.copy (data, msg.data, size - 1);
                    data[size - 1] = '\0';
                    var str = (string) data;

                    data_received (data);
                    debug (_("received (%9d): %s"), ntimes, str);
                    ntimes++;
                }
            } catch (GLib.Error e) {
                error (e.message);
            }

            Idle.add ((owned) callback);
            return null;
        };

        Thread.create<void*> (run, false);
        yield;
    }
}
