module IB
  module RequestIds
    # The id counter is scoped to the module so that it's unique across each Ruby VM
    @id ||= 1000;
    # Mutex ensures we can't double-vend the same id
    @lock ||= Mutex.new

    extend self

    def self.next_request_ids(num = 1)
      @lock.synchronize { (@id...(@id += num)) }
    end

    def next_request_ids(num = 1)
      OramIb::RequestIds.next_request_ids(num)
    end

    def next_request_id
      next_request_ids.to_a[0]
    end
  end

end