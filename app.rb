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
	content	TEXT,
	autor TEXT
	)'
	
	#создается таблица если ее еще не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS	Comments
	(
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date DATE,
	content	TEXT,
	post_id INTEGER
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
  autor = params[:autor]

  if content.length <= 0
  		@error = "Введите текст поста"
  		return erb :new
  end

  #сохранение данных в БД

  @db.execute 'insert into Posts
  (
  	content,
  	created_date,
  	autor
  ) values (?, datetime(), ?)', [content, autor]
  
  #перенапрвление на главную страницу

  redirect to '/'
  
end

#вывод информации о посте

get '/details/:post_id' do
	
	#получаем переменную из url-ла
	
	post_id = params[:post_id]

	#получаем список постов
	#у нас будет только один конкретный
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	#выбираем этот один пост в переменную @row
	@row = results[0]

	#выбираем комментарии для нашего поста

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	#возвращаем представление 
	erb :details

end

#обработчик post-запроса /details/...
#браузер отправляет страницу на сервер,а мы их принимаем

post '/details/:post_id' do

	#получаем переменную из url-ла
	
	post_id = params[:post_id]

	#получаем переменную из post-запроса 

	content = params[:content]

	if content.length <= 0
	  		@error = "Введите текст комментария"
	  		break
	end

  #сохранение данных в БД

  @db.execute 'insert into Comments 
	  (
	  	content,
	  	created_date,
	  	post_id
	  )
	   values
	  (
	  	?,
	  	datetime(),
	  	?
	  )', [content, post_id]

	#перенапрявляем на страницу поста

	redirect to('/details/' + post_id)

end