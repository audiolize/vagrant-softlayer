module VagrantPlugins
  module SoftLayer
    module Util
      module Warden
        # Raised by `sl_warden_retry`
        class RetryError < StandardError
        end

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
        # Use retry_interval and retry_timeout to adjust the retry periods.
        def sl_warden(rescue_proc = nil, retry_interval = 0, retry_timeout = 0, &block)
          started_at = Time.now.to_i
          begin
            yield
          rescue ::OpenSSL::SSL::SSLError
            raise Errors::SLCertificateError
          rescue Exception => e
            if e.class == RetryError || e.class != SocketError && (e.message.start_with?("Unable to find object") || e.message.start_with?("Object does not exist"))
              out = rescue_proc.call if rescue_proc
              if retry_interval > 0 && Time.now.to_i < started_at + retry_timeout
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

        # Notifies the retry to `sl_warden`
        #
        # Call this method in the block which passed to `sl_warden` to raise
        # `RetryError` exception and re-execute the block code.
        #
        # @example Retry getObject with 3secs intervals and timeout in 30secs
        #   sl_warden(nil, 3, 30) do
        #     sl_warden_retry if client['Service'].getObject.nil?
        #   end
        #
        # @raise [RetryError] to retry
        def sl_warden_retry
          raise RetryError
        end
      end
    end
  end
end
