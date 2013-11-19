module VagrantPlugins
  module SoftLayer
    module Util
      module Warden
        # Handles gracefully SoftLayer API calls.
        #
        # The block code is executed, catching both common
        # connection errors and API exceptions.
        #
        # Optionally, in the not-so-uncommon case when
        # the object (e.g. the SoftLayer instance) is not
        # found, executes a proc and/or retry the API call
        # after some seconds.
        #
        # A future version of the method will add a retry timeout.
        def sl_warden(rescue_proc = nil, retry_interval = 0, &block)
          begin
            yield
          rescue ::OpenSSL::SSL::SSLError
            raise Errors::SLCertificateError
          rescue SocketError, ::SoftLayer::SoftLayerAPIException => e
            if e.class == ::SoftLayer::SoftLayerAPIException && (e.message.start_with?("Unable to find object") || e.message.start_with?("Object does not exist"))
              out = rescue_proc.call if rescue_proc
              if retry_interval > 0
                sleep retry_interval
                retry
              else
                return out
              end
            else
              raise Errors::SLApiError, :class => e.class, :message => e.message
            end
          end
        end
      end
    end
  end
end
