# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'
configure do
  set :port, ENV['PORT'] || 9292 # Использует порт от Amvera или 9292 для локальной разработки
  set :bind, '0.0.0.0'
end
# Загружаем модели
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

# Настройка подключения к базе данных
configure :development do
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/development.sqlite3'
  )
end

# Включаем поддержку статических файлов
set :public_folder, File.dirname(__FILE__) + '/public'

# Включаем поддержку шаблонов
set :views, File.dirname(__FILE__) + '/views'

# Главная страница
get '/' do
  erb :'pages/index'
end

# О клинике
get '/about' do
  erb :'pages/about'
end

# Контакты
get '/contacts' do
  erb :'pages/contacts'
end

get '/doctors' do
  @doctors = Doctor.all.order(:last_name, :first_name)
  @specialties = Doctor.unique_specialties
  erb :'dynamic/doctors'
end

# AJAX поиск врачей
post '/doctors/search' do
  content_type :json
  
  query = params[:query] || ''
  specialty = params[:specialty] || ''
  
  @doctors = Doctor.search(query, specialty)
  
  # Генерируем HTML для списка врачей
  html = if @doctors.empty?
    '<div class="empty-state"><p>Врачи не найдены. Попробуйте изменить условия поиска.</p></div>'
  else
    @doctors.map { |doctor| 
      erb :'dynamic/_doctor_card', locals: { doctor: doctor }, layout: false 
    }.join('')
  end
  
  { html: html, count: @doctors.count }.to_json
end

get '/prices' do
  @service_categories = ServiceCategory.includes(:services).all
  erb :'dynamic/prices'
end

# AJAX поиск услуг
post '/services/search' do
  content_type :json
  
  query = params[:query] || ''
  category_id = params[:category_id] || ''
  
  services = Service.search(query, category_id.presence)
  grouped_services = services.group_by(&:service_category)
  
  # Генерируем HTML для списка услуг
  html = if grouped_services.empty?
    '<div class="empty-state"><p>Услуги не найдены. Попробуйте изменить условия поиска.</p></div>'
  else
    grouped_services.map { |category, category_services|
      erb :'dynamic/_service_category', 
          locals: { category: category, services: category_services }, 
          layout: false
    }.join('')
  end
  
  { html: html, count: services.count }.to_json
end

get '/docs' do
  erb :'pages/docs'
end

get '/privacy' do
  erb :'pages/privacy'
end

# Базовый маршрут для проверки
get '/test' do
  'Клиника доказательной медицины доктора Медведевой. Приложение работает!'
end