module Loudspeaker
  module LibAV
    module Bindings
      @[Link("avcodec")]
      lib LibAVCodec
        fun avcodec_version : UInt32
      end
    end
  end
end
