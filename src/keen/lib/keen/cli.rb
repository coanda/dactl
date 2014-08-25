require 'keen'
require 'keen/cld'
require 'dbus'
require 'thor'
require 'user_config'

# look at lg (logbook) gem for an example of how to use the config

class Keen::CLI < Thor

  desc "echo MSG", "echo the input MSG"
  def echo(msg)
    puts "#{msg}"
  end

  desc "ping SERVICE", "ping the Dactl DBus service"
  def ping()
    bus = DBus::SessionBus.instance

    service = bus.service("org.gnome.Dactl")
    dactl = service.object("/org/gnome/Dactl")

    dactl.introspect
    if dactl.has_iface? "org.gnome.Dactl"
      puts "Received Dactl interface"
    end

    dactl.default_iface = "org.gnome.Dactl"
    dactl.Ping
    dactl.on_signal("Pong") do |u|
      puts "Received reply from Dactl #{u}"
    end
  end

  desc "cld SUBCOMMAND ...ARGS", "interface with a CLD context"
  subcommand "cld", Keen::CLD

  private
    def config
      @uconf ||= UserConfig.new(".keen")
      @uconf["keen.yaml"]
    end

    def em(text)
      shell.set_color(text, nil, true)
    end

    def ok(detail=nil)
      text = detail ? "OK, #{detail}." : "OK."
      say text, :green
    end

    def error(detail)
      say detail, :red
    end

end
