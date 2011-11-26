# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "deprec-filter-hosts requires Capistrano 2"
  end

  module Deprec
    module FilterHosts
      def filter_hosts(hostfilter)
        old_hostfilter = ENV['HOSTFILTER']
        ENV['HOSTFILTER'] = hostfilter ? [hostfilter].flatten.map(&:to_s).join(',') : nil
        yield
        if old_hostfilter
          ENV['HOSTFILTER'] = old_hostfilter.to_s
        else
          ENV.delete('HOSTFILTER')
        end
      end     

      def for_hosts(hosts)
        old_hosts = ENV['HOSTS']
        ENV['HOSTS'] = hosts ? [hosts].flatten.map(&:to_s).join(',') : nil
        yield
        if old_hosts
          ENV['HOSTS'] = old_hosts.to_s
        else
          ENV.delete('HOSTS')
        end
      end     
    end
  end

  Capistrano::EXTENSIONS[:deprec2].send(:include, Deprec::FilterHosts)
end