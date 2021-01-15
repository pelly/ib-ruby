module IB
  class IncrementalIdGenerator
    def initialize(start_val: 1000)
      @id = start_val
      @mutex = Mutex.new
    end

    def get
      @mutex.synchronize {
        val = @id
        @id += 1
        return val
      }
    end
    alias_method :next, :get

    def get_batch(batch_num)
      @mutex.synchronize do
        vals = (@id...@id+batch_num)
        @id += batch_num
        return vals
      end
    end
  end
end