require "sinatra"
require "sinatra/reloader"
require 'sinatra/content_for'
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
  @lists = session[:lists]
end

get '/' do
  redirect '/lists'
end

# GET  /lists       -> view all lists
# GET  /lists       -> new list form
# POST /lists       -> create new list
# GET  /lists/1     -> view a single list

get "/lists" do
  erb :lists, layout: :layout
end

get '/lists/new' do
  erb :new_list, layout: :layout
end

# Return an error message if the name is invalide. Nil otherwise.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    "List name must be between 1 and 100 characters."
  elsif @lists.any? { |list| list[:name] == name }
    "List name must be unique."
  end
end

# Create a new list.
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

get '/lists/:list_id' do
  @list = @lists[params[:list_id].to_i]
  erb :todos, layout: :layout
end

def error_for_todo_name(name)
  if !(1..100).cover? name.size
    "Todo item must be between 1 and 100 characters."
  elsif @list[:todos].any? { |todo| todo == name }
    "Todo item must be unique."
  end
end

post '/lists/:list_id/todos' do
  todo_name = params[:todo_name].strip
  @list = @lists[params[:list_id].to_i]
  error = error_for_todo_name(todo_name)

  if error
    session[:error] = error
    erb :todos, layout: :layout
  else
    @list[:todos] << params[:todo_name]
    session[:success] = 'The todo item has been created.'
    erb :todos, layout: :layout
  end
end

get '/lists/:list_id/edit' do
  @list = @lists[params[:list_id].to_i]
  erb :edit_list, layout: :layout
end

post '/lists/:list_id/edit' do
  @list = @lists[params[:list_id].to_i]
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)

  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list has been updated."
    redirect "/lists/#{params[:list_id]}"
  end
end

post '/lists/:list_id/destroy' do
  @lists.delete_at params[:list_id].to_i
  session[:success] = "The list has been deleted."
  redirect '/lists'
end
