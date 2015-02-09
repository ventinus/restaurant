ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "restaurant"
)

Dir["models/*.rb"].each do |file|
	require_relative file
end

Dir["models/concerns/*.rb"].each do |file|
	require_relative file
end

enable :sessions
set :app_password, "fresh"

get '/' do
  @password = session[:password]
  @id = session[:id]
  @employees = Employee.all

  if @id && @password == settings.app_password
    redirect to("/employees/#{@id}")
  else
    erb :'employees/login'
  end  
end

post '/login' do
  session[:password] = params[:password]
  session[:id] = params[:id]
  redirect to('/')
end

get '/logout' do
  session[:password] = nil
  session[:id] = nil
  redirect to '/'
end

get '/' do
	erb :'index'
end

############food

get '/foods' do
	@foods = Food.all
	erb :'food/index'
end

get '/foods/new' do
	erb :'food/new'
end

post '/foods' do
#post new food item
	food = Food.create(params[:food])
	redirect to "/foods"
end

get '/foods/:id/edit' do |id|
#edit food item
	@food = Food.find(id)
	erb :'food/edit'
end

patch '/foods/:id' do |id|
#update that food item
	Food.find(id).update(params[:food])
	redirect to "/foods"
end

delete '/foods/:id' do |id|
	Food.find(id).destroy
	redirect to "/foods"
end



###########party

get '/parties' do
#display parties. 2 tables with current (having not paid) and past (having paid) both ordered by most recent
#each party links the party_id to the order_id to show the ordered. if they havent ordered, show "not ordered yet"
	@parties = Party.all
	erb :'party/index'
end

get '/parties/new' do
#create new party item
	@available = Party.open_tables
	erb :'party/new'
end

get '/parties/:id' do |id|
#display the specificities of each party with order items
	@party = Party.find(id)
	@orders = Order.find_by_party_id(id)
	erb :'party/show'
end

post '/parties' do
#post new party item
	Party.create(params[:party])
	Receipt.create(party_id: Party.last.id)
	redirect to "/parties"
end

get '/parties/:id/edit' do |id|
#edit party item. with button to complete order that changes paid to true and creates a txt file with receipt
	@party = Party.find(id)
	@available = Party.open_tables
	@foods = Food.all
	erb :'party/edit'
end

patch '/parties/:id' do |id|
#update that party item
	Party.find(id).update(params[:party])
	Order.create(params[:order].merge({ party_id: id}))
	redirect to "/parties/#{id}"
end

patch '/parties/:id/checkout' do |id|
	Party.find(id).update(params[:party])
	collection = Party.find(id).foods.map do |food|
		food.price
	end
	sum = collection.inject(:+)
	Receipt.find_by_party_id(id).update(sub_total: sum)
	redirect to "/checkout/#{id}"
end

# delete '/parties/:id' do |id|
# 	Party.find(id).destroy
# 	redirect to "/parties"
# end

#############order

get '/orders' do
#display order items
	# @parties = Party.all.where(paid: 'f')
	@orders = Order.all

	erb :'order/index'
end

# get '/orders/new' do
# #create new order item
# 	@foods = Food.all
# 	@unavailable = Party.used_tables
# 	erb :'order/new'
# end

# post '/orders' do
# #post new order item
# 	Order.create(params[:order])
# 	redirect to "/orders"
# end


get '/orders/:id/edit' do |id|
#edit order item.
	@order = Order.find(id)
	@foods = Food.all
	erb :'order/edit'
end

patch '/orders/:id' do |id|
#update that order item
	Order.find(id).update(params[:order])
	redirect to "orders"	
end

delete '/orders/:id' do |id|
	Order.find(id).destroy
	redirect to "/orders"
end

get '/console' do
	Pry.start(binding)
end

##############checkout

get 'receipts' do
	@receipts = Receipt.all
	erb :'/checkout/receipt'
end

get '/checkout/:id' do |id|
	@party = Party.find(id)
	@receipt = Receipt.find_by_party_id(id)
	erb :'/checkout/show'
end


###########closed

get '/closed' do 
	# shows all closed
	@receipts = Receipt.all
	erb :'checkout/index'
end

patch '/closed/:id' do |id|
	a = Receipt.find_by_party_id(id)
	a.update(params[:receipt])
	total = a.sub_total+a.gratuity
	a.update(total: total)
	
	redirect to "closed/#{id}"
end

get '/closed/:id' do |id|
	# shows details of individuals closed
	@receipt = Receipt.find_by_party_id(id)
	erb :'checkout/closed'
end

