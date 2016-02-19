#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

#процедура инициализации БД

def init_db
	@db = SQLite3::Database.new "MyBlog.db"
	@db.results_as_hash = true
end

#before вызывается каждый раз при перезагрузке
#любой страницы

before do
	#инициализация БД
	init_db
end

#configure вызывается каждый раз при инициализации приложения
#когда изменился код программы и  перезагрузилась страница

configure do
	#инициализауия БД
	init_db
	#создается таблица если ее еще не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS	Posts
	(
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date DATE,
	content	TEXT
	)'
end


get '/' do

	#выбираем список постов
	
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

#обработчик get-запроса /new
#браузер получает страницу с сервера

get '/new' do
  erb :new
end

#обработчие post-запроса /new
#браузер отправляет страницу на сервер

post '/new' do
#получаем переменную из post-запроса 
  content = params[:content]

  if content.length <= 0
  		@error = "Введите текст поста"
  		return erb :new
  end

  #сщхранение данных в БД

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
  
  #перенапрвление на главную страницу

  redirect to ('/')
  
end