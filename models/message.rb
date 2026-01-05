# models/message.rb
class Message < ActiveRecord::Base
  validates :name, :phone, :email, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # Сортировка по дате создания (новые сверху)
  default_scope { order(created_at: :desc) }
end