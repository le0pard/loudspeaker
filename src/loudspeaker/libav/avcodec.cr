module Loudspeaker
  module LibAV
    @[Link("avcodec")]
    lib AVCodecBinding
      fun version = avcodec_version : UInt32
    end

    module AVCodec
      extend self

      def version
        v = AVCodecBinding.version
        "#{v >> 16}.#{(v & 0x00FF00) >> 8}.#{v & 0xFF}"
      end
    end
  end
end

# puts Loudspeaker::LibAV::AVCodec.version
