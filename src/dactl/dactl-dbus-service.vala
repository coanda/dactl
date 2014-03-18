[DBus (name = "org.gnome.Dactl")]
internal class Dactl.DBusService : GLib.Object {

    private Dactl.Main main;
    private uint name_id;
    private uint connection_id;

    public DBusService (Dactl.Main main) {
        this.main = main;
    }

    public void shutdown () throws IOError {
        this.main.exit (0);
    }

    internal void publish () {
        this.name_id = Bus.own_name (BusType.SESSION,
                                     "/org/gnome/Dactl",
                                     BusNameOwnerFlags.NONE,
                                     this.on_bus_aquired,
                                     this.on_name_available,
                                     this.on_name_lost);
    }

    internal void unpublish () {
        if (connection_id != 0) {
            try {
                var connection = Bus.get_sync (BusType.SESSION);
                connection.unregister_object (this.connection_id);
            } catch (IOError error) {};
        }

        if (name_id != 0) {
            Bus.unown_name (this.name_id);
        }
    }


    private void on_bus_aquired (DBusConnection connection) {
        try {
            this.connection_id = connection.register_object ("/org/gnome/Dactl", this);
        } catch (IOError error) {
            stderr.printf ("Could not register service");
        }
    }

    private void on_name_available (DBusConnection connection) {
        this.main.dbus_available ();
    }

    private void on_name_lost (DBusConnection? connection) {
        if (connection == null) {
            // This means there is no DBus available at all
            this.main.dbus_available ();

            return;
        }

        message (_("Another instance of dactl is already running. Not starting."));
        this.main.exit (-15);
    }
}
