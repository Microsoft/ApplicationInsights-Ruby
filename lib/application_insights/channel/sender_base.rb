require 'json'
require 'net/http'
require 'openssl'
require 'stringio'
require 'zlib'

module ApplicationInsights
  module Channel
    # The base class for all types of senders for use in conjunction with an
    # implementation of {QueueBase}. The queue will notify the sender that it
    # needs to pick up items. The concrete sender implementation will listen to
    # these notifications and will pull items from the queue using
    # {QueueBase#pop} getting at most {#send_buffer_size} items.
    # It will then call {#send} using the list of items pulled from the queue.
    class SenderBase
      # Initializes a new instance of the class.
      # @param [String] service_endpoint_uri the address of the service to send
      #   telemetry data to.
      def initialize(service_endpoint_uri)
        @service_endpoint_uri = service_endpoint_uri
        @queue = nil
        @send_buffer_size = 100
      end

      # The service endpoint URI where this sender will send data to.
      # @return [String] the service endpoint URI.
      attr_accessor :service_endpoint_uri

      # The queue that this sender is draining. While {SenderBase} doesn't
      # implement any means of doing so, derivations of this class do.
      # @return [QueueBase] the queue instance that this sender is draining.
      attr_accessor :queue

      # The buffer size for a single batch of telemetry. This is the maximum number
      # of items in a single service request that this sender is going to send.
      # @return [Fixnum] the maximum number of items in a telemetry batch.
      attr_accessor :send_buffer_size

      # Immediately sends the data passed in to {#service_endpoint_uri}. If the
      # service request fails, the passed in items are pushed back to the {#queue}.
      # @param [Array<Contracts::Envelope>] data_to_send an array of
      #   {Contracts::Envelope} objects to send to the service.
      def send(data_to_send)
        uri = URI(@service_endpoint_uri)
        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json; charset=utf-8',
          'Content-Encoding' => 'gzip'
        }
        request = Net::HTTP::Post.new(uri.path, headers)

        # Use JSON.generate instead of to_json, otherwise it will
        # default to ActiveSupport::JSON.encode for Rails app
        json = JSON.generate(data_to_send)
        compressed_data = compress(json)
        request.body = compressed_data

        http = Net::HTTP.new uri.hostname, uri.port
        if uri.scheme.downcase == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = http.request(request)
      end

      private

      def compress(string)
        wio = StringIO.new("w")
        w_gz = Zlib::GzipWriter.new wio, nil, nil
        w_gz.write(string)
        w_gz.close
        wio.string
      end
    end
  end
end
