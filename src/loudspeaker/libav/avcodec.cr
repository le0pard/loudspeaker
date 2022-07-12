require "./bindings/libavcodec"

module Loudspeaker
  module LibAV
    module AVCodec
      extend self

      def version : String
        v = Bindings::LibAVCodec.avcodec_version
        "#{v >> 16}.#{(v & 0x00FF00) >> 8}.#{v & 0xFF}"
      end
    end
  end
end

puts Loudspeaker::LibAV::AVCodec.version
