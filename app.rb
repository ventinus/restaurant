Dir["models/*.rb"].each do |file|
	require_relative file
end

Dir["models/concerns/*.rb"].each do |file|
	require_relative file
end

class Restaurant < Sinatra::Base
	set :method_override, true
	enable :sessions


	get '/' do
		erb :'home'
	end

	get '/welcome' do
		@employee = current_employee
		erb :welcome
	end

	get '/signup' do 
		@employee = Employee.new
		erb :'employees/new'
	end

	post '/signup' do
		@employee = Employee.new(username: params[:employee][:username])

		if params[:employee][:password] == params[:employee][:password_confirmation]
			@employee.password = params[:employee][:password]
			if @employee.save
				login!(@employee)
				redirect to('/welcome')
			else
				erb :'employees/new'
			end
		else
			@employee.errors.add(:password, "and confirmation need to match.")
			erb :'employees/new'
		end
	end

	get '/login' do
		@employee = Employee.new
		erb :'employees/login'
	end


	post '/login' do
		@employee = Employee.find_by_credentials(params[:employee])

		if @employee
			login!(@employee)

			redirect to('/welcome')
		else
			@employee = Employee.new(username: params[:employee][:username])
			@employee.errors.add(:password, "and username aint goin tagether")
			erb :'employees/login'
		end
	end

	delete '/logout' do
		logout!
		redirect to('/login')
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
		food = Food.create(params[:food])
		redirect to "/foods"
	end

	get '/foods/:id/edit' do |id|
		@food = Food.find(id)
		erb :'food/edit'
	end

	patch '/foods/:id' do |id|
		Food.find(id).update(params[:food])
		redirect to "/foods"
	end

	delete '/foods/:id' do |id|
		Food.find(id).destroy
		redirect to "/foods"
	end

	###########party

	get '/parties' do
		@parties = Party.all
		erb :'party/index'
	end

	get '/parties/new' do
		@available = Party.open_tables
		erb :'party/new'
	end

	get '/parties/:id' do |id|
		@party = Party.find(id)
		# @orders = Order.find_by_party_id(id)
		erb :'party/show'
	end

	post '/parties' do
		Party.create(params[:party])
		Receipt.create(party_id: Party.last.id)
		redirect to "/parties"
	end

	get '/parties/:id/edit' do |id|
		@party = Party.find(id)
		@foods = Food.all
		erb :'party/edit'
	end

	patch '/parties/:id' do |id|
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
		@orders = Order.all
		erb :'order/index'
	end

	get '/orders/:id/edit' do |id|
		@order = Order.find(id)
		@foods = Food.all
		erb :'order/edit'
	end

	patch '/orders/:id' do |id|
		Order.find(id).update(params[:order])
		redirect to "orders"	
	end

	delete '/orders/:id' do |id|
		Order.find(id).destroy
		redirect to "/orders"
	end

	##############checkout

	get '/checkout/:id' do |id|
		@party = Party.find(id)
		@receipt = Receipt.find_by_party_id(id)
		erb :'/checkout/show'
	end

	###########closed

	get '/closed' do 
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
		@receipt = Receipt.find_by_party_id(id)
		erb :'checkout/closed'
	end

	get '/print_closed/:id' do |id|
		@receipt = Receipt.find_by_party_id(id)
		erb :'checkout/bare_receipt', layout: :print
	end

	############
	get '/console' do
		Pry.start(binding)
	end

	get '/*' do
		<<-HTML
		<img src="http://33.media.tumblr.com/0d96fafaee76198607b6185241cea02d/tumblr_mldfv2jD5G1rvnnvyo6_250.gif#.png">
		HTML
	end

	private
	def create_token
		return SecureRandom.urlsafe_base64
	end
	def current_employee
		Employee.find_by(authorization_token: session[:authorization_token])
	end

	def login!(employee)
		employee.authorization_token = session[:authorization_token] = create_token
		employee.save
	end

	def logout!
		employee = current_employee
		employee.authorization_token = session[:authorization_token] = nil
		employee.save
	end

end