
module Fluent
  class CatSweepInput < Input
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
    config_param :format,                  :string
    config_param :waiting_seconds,         :integer  # seconds
    config_param :auth_url, :string
    config_param :auth_user, :string
    config_param :auth_tenant, :string, :default => nil
    config_param :auth_api_key, :string
    config_param :swift_account, :string, :default => nil
    config_param :swift_container, :string
    config_param :store_as, :string, :default => "gzip"
    config_param :auto_create_container, :bool, :default => true
    config_param :ssl_verify, :bool, :default => true

    # To support log_level option implemented by Fluentd v0.10.43
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    # Define `router` method of v0.12 to support v0.10 or earlier
    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def configure(conf)
      super

      # Message for users about supported fluentd versions
      supported_versions_information

      if @file_path_with_glob.empty?
        raise Fluent::ConfigError, "in_swift_sweep: `@file_path_with_glob` must has a valid path."
      end

    end

    def start
      super

      Excon.defaults[:ssl_verify_peer] = @ssl_verify

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
        sleep @run_interval

        Dir.glob(@file_path_with_glob).map do |filename|
          if file_array.include?(filename)
            log.info "File #{filename} is already present"
            next
          else
            file_array << filename
          end

          File.open(filename) do |file|
            @storage.put_object(@swift_container, swift_path, file, {:content_type => @mime_type})
            a.delete_if {|i| i == file}
            FileUtils.rm(filename)
          end
        end
      end
    end

    def check_object_exists(container, object)
      begin
        @storage.head_object(container, object)
      rescue Fog::Storage::OpenStack::NotFound
        return false
      end
      return true
    end


    def supported_versions_information
      if current_fluent_version < fluent_version('0.12.0')
        log.warn "in_swift_sweep: the support for fluentd v0.10 will end near future. Please upgrade your fluentd or fix this plugin version."
      end
      if current_fluent_version < fluent_version('0.10.58')
        log.warn "in_swift_sweep: fluentd officially supports Plugin.new_parser/Plugin.register_parser APIs from v0.10.58." \
          " The support for v0.10.58 will end near future." \
          " Please upgrade your fluentd or fix this plugin version."
      end
      if current_fluent_version < fluent_version('0.10.46')
        log.warn "in_swift_sweep: fluentd officially supports parser plugin from v0.10.46." \
          " If you use `time_key` parameter and fluentd v0.10.45, doesn't work properly." \
          " The support for v0.10.45 will end near future." \
          " Please upgrade your fluentd or fix this plugin version."
      end
    end

    def current_fluent_version
      parse_version_comparable(Fluent::VERSION)
    end
    
    def parse_version_comparable(v)
      Gem::Version.new(v)
    end
    alias :fluent_version :parse_version_comparable # For the readability

    def safe_fail(e, filename)
      begin
        error_filename = get_error_filename(e, filename)
        lock_with_renaming(filename, error_filename)
      rescue => e
        log.error "in_swift_sweep: rename #{filename} to error filename #{error_filename}",
          :error => e, :error_class => e.class
        log.error_backtrace
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
