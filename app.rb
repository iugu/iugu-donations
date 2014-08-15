#encoding: UTF-8

require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/donation'
require 'debugger'
require 'money'
require 'global'
require 'iugu'

Global.configure do |config|
  config.environment = settings.environment
  config.config_directory = settings.root + '/config/global'
end

def to_money(cents)
  Money.new(cents, "BRL").format(decimal_mark: ",", thousands_separator: ".", symbol: true)
end

def clamp(value, max)
  [[value, max].min, value].min
end

def set_donation_vars
  @goal_cents = 500000
  @goal = to_money(@goal_cents)

  @nr_donations = Donation.project("nfe").count
  @donations_cents = Donation.project("nfe").sum("amount_cents")
  @donations = to_money(@donations_cents)
  @total_donations = @donations

  @stretch_cents = @donations_cents - @goal_cents
  @stretch = to_money(@stretch_cents)

  @goal_percent = clamp((@donations_cents.to_f / @goal_cents.to_f) * 100, 100)
  @total_goal_percent = @goal_percent.to_i

  if (@donations_cents > @goal_cents)
    @donations = to_money(@donations_cents - @stretch_cents)
    @goal_percent = clamp((@goal_cents / @donations_cents.to_f) * 100, 100)
  end
end

get '/' do
  set_donation_vars
  erb :index
end

post '/' do
  Iugu.api_key = Global.iugu.api_token

  charge = Iugu::Charge.create({
    token: params[:token],
    email: params[:email],
    items: [{
      description: "Doação p/ causa OpenSource",
      quantity: "1",
      price_cents: params[:amount_cents]
    }]
  })

  if charge.success 
    Donation.create(email: params[:email], amount_cents: params[:amount_cents], project: "nfe")
    erb(:thanks) 
  else 
    set_donation_vars 
    erb(:index, { locals: { error: true, charge: charge } })
  end
end
