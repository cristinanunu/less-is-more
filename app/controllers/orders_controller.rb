class OrdersController < ApplicationController
  def create
    donation = Donation.find(params[:donation_id])
    order = Order.create!(
      donation: donation,
      donation_name: donation.name,
      amount: donation.price,
      state: 'pending',
      user: current_user
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: donation.name,
        amount: donation.price_cents,
        currency: 'eur',
        quantity: 1
      }],
      success_url: order_url(order),
      cancel_url: order_url(order)
    )

    order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(order)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
