module Fluent
  class SwiftSweepInput < Input
    Plugin.register_input('swift_sweep', self)
    $file_array = []
    
    def initialize
      super
      require 'fog'
      require 'zlib'
      require 'time'
      require 'tempfile'
      require 'open3'
    end

    config_param :file_path_with_glob,     :string
    config_param :auth_url, :string
    config_param :auth_user, :string
    config_param :auth_tenant, :string
    config_param :auth_api_key, :string
    config_param :swift_container, :string
    config_param :auto_create_container, :bool, :default => true
    config_param :ssl_verify, :bool, :default => false


    def configure(conf)
      super

      if @file_path_with_glob.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@file_path_with_glob` must has a valid path."
      end

      if @auth_url.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@auth_url` is empty."
      end

      if @auth_user.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@auth_user` is empty."
      end

      if @auth_tenant.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@auth_tenant` is empty."
      end

      if @auth_api_key.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@auth_api_key` is empty."
      end

      if @swift_container.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@swift_container` is empty."
      end

    end

    def start
      super

      Excon.defaults[:ssl_verify_peer] = false

      $log.debug "openstack_auth_url: #{@auth_url}"
      $log.debug "openstack_username: #{@auth_user}"
      $log.debug "openstack_tenant: #{@auth_tenant}"
      $log.debug "openstack_auth_key: #{@auth_api_key}"
      @storage = Fog::Storage.new :provider => 'OpenStack',
                        :openstack_auth_url => @auth_url,
                        :openstack_username => @auth_user,
                        :openstack_tenant => @auth_tenant,
                        :openstack_api_key  => @auth_api_key
      @storage.change_account @swift_account if @swift_account

      check_container
      
      @processing = true
      @thread = Thread.new(&method(:run_periodic))
    end

    def shutdown
      @processing = false
      @thread.join
    end

    def run_periodic
      while @processing
        Dir.glob(@file_path_with_glob).map do |filename|
          File.open(filename) do |file|
            @storage.put_object('jer_ironman_cfuse', filename, file)
            log.info "File #{filename} sent to swift"
            FileUtils.rm(filename)
            log.info "File #{filename} deleted"
          end
        end
      end
    end


    def check_container
      begin
        @storage.get_container(@swift_container)
      rescue Fog::Storage::OpenStack::NotFound
        if @auto_create_container
          $log.info "Creating container #{@swift_container} on #{@auth_url}, #{@swift_account}"
          @storage.put_container(@swift_container)
        else
          raise "The specified container does not exist: container = #{swift_container}"
        end
      end
    end

  end
end
