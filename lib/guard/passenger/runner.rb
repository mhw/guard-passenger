module Guard
  class Passenger
    module Runner
      PASSENGER_VERSION = Gem.latest_spec_for('passenger').version

      class << self
        def restart_passenger
          if PASSENGER_VERSION >= Gem::Version.new('4.0.31')
            succeed = system("passenger-config restart-app #{ Dir.getwd }")
          else
            succeed = system("touch tmp/restart.txt")
          end

          if succeed
            UI.info "Passenger successfully restarted."
          else
            UI.error "Passenger failed to restart!"
            throw :task_has_failed
          end
          succeed
        end

        def start_passenger(cli, sudo = '')
          if passenger_standalone_installed?
            succeed = system("#{sudo} passenger start #{cli}".strip)
            if succeed
              UI.info "Passenger standalone started."
            else
              UI.error "Passenger standalone failed to start!"
              throw :task_has_failed
            end
            succeed
          else
            UI.error "Passenger standalone is not installed. You need at least Passenger version >= 3.0.0.\nPlease run 'gem install passenger' or add it to your Gemfile."
            throw :task_has_failed
          end
        end

        def stop_passenger(cli, sudo = '')
          succeed = system("#{sudo} passenger stop #{cli}".strip)
          if succeed
            UI.info "Passenger standalone stopped."
          else
            UI.error "Passenger standalone failed to stop!"
            throw :task_has_failed
          end
          succeed
        end

        def passenger_standalone_installed?
          PASSENGER_VERSION >= Gem::Version.new('3')
        end
      end
    end
  end
end
