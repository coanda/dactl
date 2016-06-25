internal class Dactl.Recorder.ZmqService : Dactl.Net.ZmqService {

    public ZmqService () {
        base ();
    }

    public ZmqService.with_conn_info (Dactl.Net.ZmqTransport transport,
                                      string address,
                                      int port) {
        base.with_conn_info (transport, address, port);
    }

    public override void run () {
        listen.begin ((obj, res) => {
            try {
                listen.end (res);
            } catch (ThreadError e) {
                error (e.message);
            }
        });
    }

    protected override async void listen () throws ThreadError {
        SourceFunc callback = listen.callback;

        ThreadFunc<void*> run = () => {
            try {
                var ntimes = 0;
                // XXX just here to do something
                while (true) {
                    string str = @"1000 nailed it! - $(ntimes)";
                    var reply = ZMQ.Msg.with_data (str.data);
                    var n = reply.send (publisher);
                    Posix.sleep (1);
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
