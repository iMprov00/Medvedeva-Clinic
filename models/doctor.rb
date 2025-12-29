# models/doctor.rb
class Doctor < ActiveRecord::Base
  validates :last_name, :first_name, :specialties, :bio, presence: true
  validates :experience_years, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Метод для поиска врачей
  def self.search(query, specialty_filter = nil)
    doctors = all
    
    # Поиск по любому совпадению
    if query.present?
      doctors = doctors.where(
        "last_name LIKE :q OR first_name LIKE :q OR middle_name LIKE :q OR bio LIKE :q OR specialties LIKE :q",
        q: "%#{query}%"
      )
    end
    
    # Фильтр по специальности
    if specialty_filter.present?
      doctors = doctors.where("specialties LIKE ?", "%#{specialty_filter}%")
    end
    
    doctors.order(:last_name, :first_name)
  end
  
  # Получаем уникальные специальности для фильтра
  def self.unique_specialties
    all.pluck(:specialties)
       .flat_map { |s| s.split(',') }
       .map(&:strip)
       .uniq
       .sort
  end
  
  # Метод для полного имени
  def full_name
    [last_name, first_name, middle_name].compact.join(' ')
  end
  
  # Метод для отображения опыта
  def experience_text
    return "Опыт не указан" unless experience_years
    
    case experience_years
    when 0
      "менее года"
    when 1
      "1 год"
    when 2..4
      "#{experience_years} года"
    else
      "#{experience_years} лет"
    end
  end
end