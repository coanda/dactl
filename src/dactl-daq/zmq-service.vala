public class Dactl.DAQ.ZmqService : Dactl.Net.ZmqService {

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
                    string str = @"\"data\": { \"grp0\": [ 0.0, 1.0, 2.0 ] }";
                    var reply = ZMQ.Msg.with_data (str.data);
                    var n = reply.send (publisher);
                    data_published (str.data);
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
