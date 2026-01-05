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

# Хелпер для форматирования денег
helpers do
  def number_to_currency(number, options = {})
    defaults = { unit: '₽', format: '%n %u' }
    opts = defaults.merge(options)
    
    formatted_number = sprintf('%.2f', number.to_f)
    formatted_number = formatted_number.gsub('.', ',')
    formatted_number = formatted_number.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")
    
    opts[:format].gsub('%n', formatted_number).gsub('%u', opts[:unit])
  end
end

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

# Обработка формы обратной связи
post '/contacts' do
  content_type :json
  
  begin
    message = Message.create(
      name: params[:name],
      phone: params[:phone],
      email: params[:email],
      subject: params[:subject],
      message: params[:message]
    )
    
    if message.persisted?
      { success: true, message: 'Сообщение успешно отправлено!' }.to_json
    else
      { success: false, errors: message.errors.full_messages }.to_json
    end
  rescue => e
    { success: false, error: 'Произошла ошибка при отправке сообщения' }.to_json
  end
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

# ==================== АДМИНСКИЕ МАРШРУТЫ ====================

# Простая аутентификация для админки
before '/admin*' do
  # Проверяем аутентификацию через HTTP Basic Auth
  auth = Rack::Auth::Basic::Request.new(request.env)
  
  unless auth.provided? && auth.basic? && auth.credentials && auth.credentials == ['admin', '123']
    response['WWW-Authenticate'] = 'Basic realm="Админка"'
    halt 401, "Требуется авторизация\n"
  end
  
end

# Выход из админки (перезапрос авторизации)
get '/admin/logout' do
  response['WWW-Authenticate'] = 'Basic realm="Админка"'
  halt 401, "Вы вышли из админки. Обновите страницу для повторного входа.\n"
end

# Админская панель
get '/admin' do
  redirect '/admin/messages'
end

# Управление сообщениями
get '/admin/messages' do
  @messages = Message.all
  erb :'admin/messages'
end

# Управление врачами
get '/admin/doctors' do
  @doctors = Doctor.all.order(:last_name, :first_name)
  erb :'admin/doctors'
end

# Добавление врача
post '/admin/doctors' do
  Doctor.create(params[:doctor])
  redirect '/admin/doctors'
end

# Удаление врача
post '/admin/doctors/:id/delete' do
  Doctor.find(params[:id]).destroy
  redirect '/admin/doctors'
end

# Управление услугами
get '/admin/prices' do
  @service_categories = ServiceCategory.includes(:services).all
  erb :'admin/prices'
end

# Добавление категории услуг
post '/admin/categories' do
  ServiceCategory.create(params[:category])
  redirect '/admin/prices'
end

# Добавление услуги
post '/admin/services' do
  Service.create(params[:service])
  redirect '/admin/prices'
end

# Удаление услуги
post '/admin/services/:id/delete' do
  Service.find(params[:id]).destroy
  redirect '/admin/prices'
end

# Удаление категории
post '/admin/categories/:id/delete' do
  ServiceCategory.find(params[:id]).destroy
  redirect '/admin/prices'
end

# Отметить сообщение как прочитанное
post '/admin/messages/:id/read' do
  message = Message.find(params[:id])
  message.update(read: true)
  redirect '/admin/messages'
end

# Удаление сообщения
post '/admin/messages/:id/delete' do
  Message.find(params[:id]).destroy
  redirect '/admin/messages'
end