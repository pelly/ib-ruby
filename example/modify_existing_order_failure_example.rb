require "ib-ruby"

class IB::ModifyExistingOrderFailureExample
  class Condition
    def initialize(name:)
      @name = name
    end

    def wait_for(timeout, sleep_time: 0.05, &block)
      done_at = Time.now.to_f + timeout
      sleep(sleep_time) until Time.now.to_f > done_at || yield
    end
  end
    
  def run(client:, contract: IB::Symbols::Stocks.wfc, account:nil)
    attrs = {
             size: 100,
             price: 1,  # crazy price so it doesn't execute
             tif: "GTC",
             action: :buy,
             open_close: "O",
             account: account
            }
    attrs.merge!(account: account) if account
    order = IB::Limit.order(**attrs)

    order_id = client.place_order(order, contract)
    placed_order_found = Condition.new(name: "Order #{order_id} to be found")

    client.clear_received # clear all previously received messages
    open = []
    client.subscribe(:OpenOrder) { |msg| puts "adding #{msg.to_human} to open orders"; open << msg }
    puts "Requesting all open orders"
    client.send_message(:RequestOpenOrders)
    
    found = nil
    placed_order_found.wait_for(10) { found = open.find { |o| o.data[:order][:local_id] == order_id } }

    raise "Can't find open orders matching the one just placed" if found.nil?
    modified_from_read_order = IB::Order.new(found.data[:order])
    modified_from_read_order.limit_price += 1

    # Expect: Existing order just place should change limit price from $1 -> $2
    client.modify_order(modified_from_read_order, contract)
  end
end
