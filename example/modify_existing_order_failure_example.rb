class ModifyExistingOrderFailureExample
  def run(client:, contract: IB::Symbols::Stocks.wfc, account:nil)

    attrs = {
             size: 100,
             price: 1,  # crazy price so it doesn't execute
             tif: "GTC",
             action: :buy,
             open_close: "O",
             account: account
            }
    order = IB::Limit.order(**attrs)

    order_id = client.place_order(order, contract)

    client.clear_received # clear all previously received messages
    open = []
    client.subscribe(:OpenOrder) { |msg| open << msg }
    client.send_message(:RequestOpenOrders)
    client.wait_for(:OpenOrderEnd, 10)
    found = open.find { |o| o.data[:order][:local_id] == order_id }
    raise "Can't find open orders matching the one just placed" if found.nil?
    modified_from_read_order = IB::Order.new(found.data[:order])
    modified_from_read_order.limit_price += 1

    # Expect: Existing order just place should change limit price from $1 -> $2
    client.modify_order(modified_from_read_order, contract)
  end
end
