require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# GET  /lists       -> view all lists
# GET  /lists       -> new list form
# POST /lists       -> create new list
# GET  /lists/1     -> view a single list

get "/lists" do
  @lists = session[:lists]

  erb :lists, layout: :layout
end

get '/lists/new' do
  erb :new_list, layout: :layout
end

# Return an error message if the name is invalide. Nil otherwise.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    "List name must be between 1 and 100 characters."
  elsif session[:lists].any? { |list| list[:name] == name }
    "List name must be unique."
  end
end

post '/lists' do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)

  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = 'The list has been created.'
    redirect "/lists"
  end
end
