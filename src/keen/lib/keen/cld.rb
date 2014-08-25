require 'keen'
require 'thor'

module Keen

  class CLD < Thor
    # just for testing, but this could likely be its own subcommand
    desc "channel <id>", "Print a CLD channel"
    def channel(id)
      puts "Print #{id}"
    end
  end

end
